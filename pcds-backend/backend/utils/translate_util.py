import asyncio
import time
import uuid
from typing import Any, Callable

from exceptions.exception import ServiceError
from i18n.translator import normalize_lang
from module_baidu.async_client import BaiduTranslateAipClient


class TranslateUtil:
    _translation_tasks: dict[str, dict[str, Any]] = {}
    _translation_task_ttl_seconds = 10 * 60

    def __init__(self, max_retry: int = 3):
        self.translate_client = BaiduTranslateAipClient(max_retry=max_retry)

    async def translate_text(self, text: str | None, from_lang: str = 'zh', to_lang: str = 'en') -> str | None:
        return await self.translate_client.translate(text, from_lang, to_lang)

    async def translate_all_languages(
        self,
        text: str,
        from_lang: str | None = 'zh',
        progress_callback: Callable[[int, int, str, str], None] | None = None,
        empty_message: str | None = None,
    ) -> dict[str, Any]:
        if not text or not text.strip():
            raise ServiceError(message=empty_message or 'Translation text cannot be empty')

        source_lang = normalize_lang(from_lang)
        lang_codes = list(self.translate_client.language_map.keys())
        translations: dict[str, str] = {}
        same_as_source: list[str] = []
        start_time = time.time()

        for index, lang_code in enumerate(lang_codes, start=1):
            if lang_code == source_lang:
                translated_text = text
            else:
                translated_text = await self.translate_client.translate(text, source_lang, lang_code)
            translations[lang_code] = translated_text
            if lang_code != source_lang and translated_text == text:
                same_as_source.append(lang_code)
            if progress_callback:
                progress_callback(index, len(lang_codes), lang_code, translated_text)

        duration_ms = int((time.time() - start_time) * 1000)
        return {
            'translations': translations,
            'summary': {
                'total': len(lang_codes),
                'sourceLang': source_lang,
                'sameAsSource': same_as_source,
                'durationMs': duration_ms,
            },
        }

    @classmethod
    def create_translate_task(cls, text: str, from_lang: str | None = 'zh', empty_message: str | None = None):
        translate_util = cls()
        task_id = uuid.uuid4().hex
        total = len(translate_util.translate_client.language_map.keys())
        task = {
            'taskId': task_id,
            'status': 'running',
            'total': total,
            'done': 0,
            'error': None,
            'summary': None,
            'translations': None,
            'createdAt': time.time(),
        }
        cls._translation_tasks[task_id] = task
        asyncio.create_task(cls._run_translate_task(task_id, text, from_lang, empty_message))
        return task

    @classmethod
    async def _run_translate_task(cls, task_id: str, text: str, from_lang: str | None, empty_message: str | None):
        def progress_callback(done: int, total: int, _lang: str, _translated_text: str):
            task = cls._translation_tasks.get(task_id)
            if task:
                task['done'] = done
                task['total'] = total

        try:
            translate_util = cls()
            result = await translate_util.translate_all_languages(
                text, from_lang, progress_callback=progress_callback, empty_message=empty_message
            )
            task = cls._translation_tasks.get(task_id)
            if task:
                task['status'] = 'completed'
                task['done'] = result['summary']['total']
                task['translations'] = result['translations']
                task['summary'] = result['summary']
        except Exception as e:
            task = cls._translation_tasks.get(task_id)
            if task:
                task['status'] = 'failed'
                task['error'] = str(e)

    @classmethod
    def get_translate_task(cls, task_id: str):
        task = cls._translation_tasks.get(task_id)
        if not task:
            return None
        if task.get('status') in {'completed', 'failed'}:
            created_at = task.get('createdAt')
            if created_at and time.time() - created_at > cls._translation_task_ttl_seconds:
                cls._translation_tasks.pop(task_id, None)
                return None
        return task
