"""
服装 AI 问答服务
- 有 Gemini Key：使用 Gemini 回答
- 无 Gemini Key：使用规则匹配返回预设答案
"""
import os
from utils.log_util import logger

GEMINI_API_KEY = os.getenv('GEMINI_API_KEY', '')
GEMINI_MODEL = os.getenv('GEMINI_MODEL', 'gemini-1.5-flash')

_SYSTEM_PROMPT = (
    '你是一位专业的服装设计顾问，名叫"小裁"。'
    '你只回答与服装、时尚、穿搭、面料、设计相关的问题。'
    '如果用户问的问题与服装无关，请礼貌地说明你只能回答服装相关问题。'
    '回答要简洁、专业、友好，使用中文回答。'
    '不要使用 Markdown 格式，直接用纯文本回答。'
)

# 关键词 → 预设回答（无 Gemini 时的备用）
_FALLBACK_QA = [
    (['棉', '棉质', 'cotton'], '棉质面料透气吸汗，适合日常穿着，尤其是夏季。纯棉容易起皱，可选棉混纺来改善。'),
    (['丝绸', '真丝', 'silk'], '丝绸光泽感强、手感柔滑，适合正式场合。需要手洗或干洗，避免阳光直晒。'),
    (['牛仔', 'denim', 'jeans'], '牛仔面料耐穿耐磨，百搭实用。深色牛仔更显瘦，浅色牛仔休闲感更强。'),
    (['羊毛', 'wool'], '羊毛保暖性好，适合秋冬季节。美利奴羊毛细腻不扎皮肤，是高品质选择。'),
    (['穿搭', '搭配', '怎么穿'], '好的穿搭建议：上深下浅显高挑，同色系搭配显高级，加腰带可以修饰身材比例。'),
    (['显瘦', '瘦'], '显瘦技巧：选择深色系、竖条纹、合身剪裁；避免横条纹和过于宽松的版型。'),
    (['颜色', '配色', '色彩'], '经典配色方案：黑白灰永不出错；同色系深浅搭配显高级；互补色搭配活泼有活力。'),
    (['风格', '穿衣风格'], '常见穿衣风格：休闲风（T恤+牛仔）、商务风（西装+衬衫）、街头风（卫衣+运动裤）、简约风（纯色+基础款）。'),
    (['洗涤', '清洗', '保养'], '服装保养建议：深色衣物反面洗涤防褪色；羊毛类手洗或干洗；棉麻类可机洗但避免高温烘干。'),
    (['尺码', '尺寸', '大小'], '选择尺码建议：上衣以肩宽和胸围为准，裤子以腰围和臀围为准。宁可稍大也不要太紧，影响舒适度。'),
    (['夏天', '夏季', '夏'], '夏季穿搭推荐：棉麻材质透气，浅色系反光降温，宽松版型比紧身更凉快。'),
    (['冬天', '冬季', '冬'], '冬季穿搭推荐：羽绒服保暖性最强，羊毛大衣兼顾保暖与时尚，叠穿法（打底+毛衣+外套）灵活应对温差。'),
    (['面试', '职场', '工作'], '职场穿搭建议：选择简洁大方的商务休闲风，避免过于鲜艳的颜色，保持整洁是关键。'),
    (['约会', '出行'], '约会穿搭建议：根据场合选择，正式餐厅可选连衣裙或衬衫，休闲约会可选牛仔+上衣的组合。'),
]


class PcdsChatService:

    @staticmethod
    async def ask(message: str) -> str:
        # 优先使用 Gemini
        if GEMINI_API_KEY and GEMINI_API_KEY != 'your_gemini_api_key_here':
            try:
                return await PcdsChatService._ask_gemini(message)
            except Exception as e:
                logger.warning(f'[Chat] Gemini 调用失败，使用备用回答: {e}')

        logger.info(f'[Chat] 使用关键词匹配，消息: {message[:30]}')
        return PcdsChatService._fallback_answer(message)

    @staticmethod
    async def _ask_gemini(message: str) -> str:
        import google.generativeai as genai
        genai.configure(api_key=GEMINI_API_KEY)
        model = genai.GenerativeModel(
            GEMINI_MODEL,
            system_instruction=_SYSTEM_PROMPT,
        )
        response = model.generate_content(message)
        return response.text.strip() if response.text else '抱歉，我暂时无法回答这个问题，请稍后再试。'

    @staticmethod
    def _fallback_answer(message: str) -> str:
        msg_lower = message.lower()
        for keywords, answer in _FALLBACK_QA:
            if any(kw in msg_lower for kw in keywords):
                return answer
        return (
            '您好！我是服装顾问小裁 👗\n'
            '我可以回答关于面料、穿搭、风格、保养等服装相关问题。\n'
            '请问您想了解什么？'
        )
