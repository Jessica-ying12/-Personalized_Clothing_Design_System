from fastapi import FastAPI
from starlette.datastructures import Headers, MutableHeaders
from starlette.types import ASGIApp, Message, Receive, Scope, Send

from i18n.translator import normalize_lang, set_locale


class LocaleMiddleware:
    def __init__(self, app: ASGIApp) -> None:
        self.app = app

    async def __call__(self, scope: Scope, receive: Receive, send: Send) -> None:
        if scope['type'] == 'http':
            headers = Headers(scope=scope)
            lang = headers.get('X-Language') or headers.get('Accept-Language')
            set_locale(normalize_lang(lang))

            async def send_wrapper(message: Message) -> None:
                if message.get('type') == 'http.response.start':
                    mh = MutableHeaders(scope=message)
                    mh.append('Content-Language', normalize_lang(lang))
                await send(message)

            await self.app(scope, receive, send_wrapper)
            return
        await self.app(scope, receive, send)


def add_locale_middleware(app: FastAPI):
    app.add_middleware(LocaleMiddleware)
