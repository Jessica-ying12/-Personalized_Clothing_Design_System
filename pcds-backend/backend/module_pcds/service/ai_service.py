"""
AI 图片生成服务
- 平面图：使用 Gemini 生成提示词 + Pollinations AI 生成图片（免费）
- 立体图：使用 Replicate IDM-VTON 虚拟试穿（或 Pollinations AI 备用）
"""
import os
import time
from typing import Optional

import httpx
from utils.log_util import logger

# Gemini API Key（从环境变量读取）
GEMINI_API_KEY = os.getenv('GEMINI_API_KEY', '')
GEMINI_MODEL = os.getenv('GEMINI_MODEL', 'gemini-1.5-flash')

# 选项代码 → 英文描述映射
_CLOTHING_TYPE_MAP = {
    'ct_tshirt': 'T-shirt', 'ct_shirt': 'dress shirt', 'ct_polo': 'polo shirt',
    'ct_hoodie': 'hoodie', 'ct_sweater': 'sweater', 'ct_vest': 'vest',
    'ct_blouse': 'blouse', 'ct_jeans': 'jeans', 'ct_trousers': 'trousers',
    'ct_shorts': 'shorts', 'ct_skirt': 'skirt', 'ct_leggings': 'leggings',
    'ct_dress_casual': 'casual dress', 'ct_dress_formal': 'formal dress',
    'ct_jumpsuit': 'jumpsuit', 'ct_romper': 'romper',
    'ct_jacket': 'jacket', 'ct_coat': 'coat', 'ct_blazer': 'blazer',
    'ct_windbreaker': 'windbreaker', 'ct_down_jacket': 'down jacket',
    # 父级
    'ct_top': 'top', 'ct_bottom': 'bottom', 'ct_dress': 'dress', 'ct_outerwear': 'outerwear',
}
_PATTERN_MAP = {
    'p_solid': 'solid color', 'p_stripe': 'striped', 'p_plaid': 'plaid',
    'p_print': 'printed', 'p_floral': 'floral', 'p_geometric': 'geometric',
    'p_abstract': 'abstract', 'p_animal': 'animal print', 'p_camouflage': 'camouflage',
    'p_tie_dye': 'tie-dye',
}
_MATERIAL_MAP = {
    'm_cotton': 'cotton', 'm_linen': 'linen', 'm_silk': 'silk', 'm_denim': 'denim',
    'm_wool': 'wool', 'm_polyester': 'polyester', 'm_chiffon': 'chiffon',
    'm_velvet': 'velvet', 'm_leather': 'leather', 'm_knit': 'knit',
}
_STYLE_MAP = {
    's_casual': 'casual', 's_business': 'business', 's_sport': 'sporty',
    's_vintage': 'vintage', 's_streetwear': 'streetwear', 's_formal': 'formal',
    's_bohemian': 'bohemian', 's_minimalist': 'minimalist', 's_romantic': 'romantic',
    's_gothic': 'gothic',
}
_AUDIENCE_MAP = {
    'a_men': "men's", 'a_women': "women's", 'a_unisex': 'unisex',
    'a_kids_boy': "boys'", 'a_kids_girl': "girls'", 'a_elderly': "elderly",
    'a_office': 'office', 'a_student': 'student', 'a_athlete': 'athletic',
}
_COLOR_MAP = {
    'col_white': 'white', 'col_black': 'black', 'col_sky_blue': 'sky blue',
    'col_coral': 'coral red', 'col_mint': 'mint green', 'col_cream': 'cream yellow',
    'col_gray': 'smoke gray', 'col_navy': 'navy blue', 'col_pink': 'pink',
    'col_purple': 'purple', 'col_orange': 'orange', 'col_brown': 'brown',
}
_BACKGROUND_MAP = {
    'bg_white': 'pure white studio background', 'bg_city': 'urban city street background',
    'bg_nature': 'natural scenery background', 'bg_studio': 'professional photography studio',
    'bg_indoor': 'indoor room background', 'bg_beach': 'beach background',
}
_BODY_TYPE_MAP = {
    'bt_standard': 'standard body', 'bt_slim': 'slim body', 'bt_athletic': 'athletic body',
    'bt_plus': 'plus size body', 'bt_petite': 'petite body', 'bt_tall': 'tall body',
}
_SKIN_TONE_MAP = {
    'sk_fair': 'fair skin', 'sk_light': 'light skin', 'sk_natural': 'natural skin',
    'sk_tan': 'tan skin', 'sk_brown': 'brown skin', 'sk_dark': 'dark skin',
}
_GENDER_MAP = {
    'g_male': 'male', 'g_female': 'female',
}


class PcdsAIService:

    @staticmethod
    def _build_flat_prompt(
        clothing_type_code: str,
        pattern_code: str,
        material_code: str,
        style_code: str,
        audience_code: str,
        color_code: Optional[str] = None,
    ) -> str:
        clothing = _CLOTHING_TYPE_MAP.get(clothing_type_code, 'clothing')
        pattern = _PATTERN_MAP.get(pattern_code, 'solid color')
        material = _MATERIAL_MAP.get(material_code, 'cotton')
        style = _STYLE_MAP.get(style_code, 'casual')
        audience = _AUDIENCE_MAP.get(audience_code, "")
        color = _COLOR_MAP.get(color_code, '') if color_code else ''

        color_str = f'{color} ' if color else ''
        return (
            f'flat lay product photo of a single {color_str}{material} {pattern} {style} {audience} {clothing}, '
            f'isolated on pure white background, no model, no person, no mannequin, '
            f'top view overhead shot, fashion product photography, '
            f'high quality, clean minimal, detailed fabric texture'
        )

    @staticmethod
    def _build_3d_prompt(
        body_type_code: str,
        skin_tone_code: str,
        gender_code: str,
        background_code: str,
        clothing_desc: str = '',
    ) -> str:
        body = _BODY_TYPE_MAP.get(body_type_code, 'standard body')
        skin = _SKIN_TONE_MAP.get(skin_tone_code, 'natural skin')
        gender = _GENDER_MAP.get(gender_code, 'female')
        bg = _BACKGROUND_MAP.get(background_code, 'white studio background')
        clothing_part = f'wearing {clothing_desc}, ' if clothing_desc else ''
        return (
            f'full body fashion photo of a {gender} model with {skin}, {body}, '
            f'{clothing_part}'
            f'{bg}, standing pose, full body shot, '
            f'professional fashion photography, studio lighting, '
            f'high quality, photorealistic, fashion magazine style'
        )

    @staticmethod
    def _pollinations_url(prompt: str, w: int = 400, h: int = 500) -> str:
        seed = int(time.time() * 1000) % 99999
        return (
            f'https://image.pollinations.ai/prompt/{httpx.URL(prompt).path}'
            f'?width={w}&height={h}&seed={seed}&nologo=true&enhance=true'
        )

    @staticmethod
    def _pollinations_url_raw(prompt: str, w: int = 400, h: int = 500) -> str:
        import urllib.parse
        seed = int(time.time() * 1000) % 99999
        encoded = urllib.parse.quote(prompt)
        return (
            f'https://image.pollinations.ai/prompt/{encoded}'
            f'?width={w}&height={h}&seed={seed}&nologo=true&enhance=true'
        )

    @staticmethod
    async def generate_flat_image(
        clothing_type_code: str,
        pattern_code: str,
        material_code: str,
        style_code: str,
        audience_code: str,
        ai_model_code: str,
        color_code: Optional[str] = None,
    ) -> tuple[str, str]:
        """
        生成平面图
        Returns: (image_url, prompt)
        """
        prompt = PcdsAIService._build_flat_prompt(
            clothing_type_code, pattern_code, material_code,
            style_code, audience_code, color_code
        )

        # 如果配置了 Gemini Key，使用 Gemini 优化提示词
        if GEMINI_API_KEY and GEMINI_API_KEY != 'your_gemini_api_key_here':
            try:
                enhanced_prompt = await PcdsAIService._enhance_prompt_with_gemini(prompt)
                if enhanced_prompt:
                    prompt = enhanced_prompt
            except Exception as e:
                logger.warning(f'[AI] Gemini 提示词优化失败，使用默认提示词: {e}')

        image_url = PcdsAIService._pollinations_url_raw(prompt, w=400, h=500)
        logger.info(f'[AI] 平面图生成 URL: {image_url[:100]}...')
        return image_url, prompt

    @staticmethod
    async def generate_3d_image(
        body_type_code: str,
        skin_tone_code: str,
        gender_code: str,
        background_code: str,
        ai_model_code: str,
        flat_image_url: Optional[str] = None,
        clothing_type_code: Optional[str] = None,
        style_code: Optional[str] = None,
        color_code: Optional[str] = None,
    ) -> tuple[str, str]:
        """
        生成立体图（虚拟试穿）
        Returns: (image_url, prompt)
        """
        # 构建衣服描述用于 prompt
        clothing_desc = ''
        if clothing_type_code:
            clothing = _CLOTHING_TYPE_MAP.get(clothing_type_code, '')
            style = _STYLE_MAP.get(style_code or '', '')
            color = _COLOR_MAP.get(color_code or '', '')
            parts = [p for p in [color, style, clothing] if p]
            clothing_desc = ' '.join(parts)

        prompt = PcdsAIService._build_3d_prompt(
            body_type_code, skin_tone_code, gender_code, background_code, clothing_desc
        )

        # 尝试使用 IDM-VTON 虚拟试穿
        if flat_image_url:
            try:
                result_url = await PcdsAIService._try_virtual_tryon(
                    flat_image_url, gender_code, body_type_code
                )
                if result_url:
                    return result_url, prompt
            except Exception as e:
                logger.warning(f'[AI] 虚拟试穿失败，使用 Pollinations 备用: {e}')

        image_url = PcdsAIService._pollinations_url_raw(prompt, w=400, h=600)
        return image_url, prompt

    @staticmethod
    async def _enhance_prompt_with_gemini(base_prompt: str) -> Optional[str]:
        """使用 Gemini 优化图片生成提示词"""
        import google.generativeai as genai
        genai.configure(api_key=GEMINI_API_KEY)
        model = genai.GenerativeModel(GEMINI_MODEL)
        system = (
            'You are a fashion design AI assistant. '
            'Enhance the following image generation prompt to be more detailed and vivid. '
            'Keep it under 200 words. Return only the enhanced prompt, no explanation.'
        )
        response = model.generate_content(f'{system}\n\nPrompt: {base_prompt}')
        return response.text.strip() if response.text else None

    @staticmethod
    async def _try_virtual_tryon(garment_url: str, gender_code: str = 'g_female', body_type_code: str = 'bt_standard') -> Optional[str]:
        """尝试使用 HuggingFace IDM-VTON 虚拟试穿"""
        import json
        # 根据性别选择合适的人体模特图
        if gender_code == 'g_male':
            mannequin_url = 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=768&q=80'
        else:
            mannequin_url = 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=768&q=80'

        async with httpx.AsyncClient(timeout=120) as client:
            resp = await client.post(
                'https://yisol-idm-vton.hf.space/run/predict',
                content=json.dumps({
                    'fn_index': 0,
                    'data': [
                        {'background': {'url': mannequin_url}, 'layers': [], 'composite': None},
                        {'url': garment_url},
                        'fashionable clothing design',
                        True, False, 30, 42,
                    ],
                }),
                headers={'Content-Type': 'application/json'},
            )
            if resp.status_code == 200:
                data = resp.json()
                output = data.get('data', [])
                if output:
                    first = output[0]
                    if isinstance(first, dict):
                        url = first.get('url') or first.get('path')
                        if url and not url.startswith('http'):
                            url = f'https://yisol-idm-vton.hf.space/file={url}'
                        return url
                    elif isinstance(first, str):
                        return first
        return None
