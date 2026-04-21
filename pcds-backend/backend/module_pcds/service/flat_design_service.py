import random
from typing import Optional
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from module_pcds.entity.do.flat_design_do import PcdsFlatDesign
from module_pcds.entity.vo.design_vo import FlatDesignGenerateRequest, FlatDesignVO, PageListResponse
from module_pcds.service.ai_service import PcdsAIService
from utils.log_util import logger


def _to_vo(d: PcdsFlatDesign) -> FlatDesignVO:
    return FlatDesignVO(
        id=str(d.design_id),
        user_id=d.user_id,
        clothing_type_code=d.clothing_type_code,
        pattern_code=d.pattern_code,
        material_code=d.material_code,
        style_code=d.style_code,
        audience_code=d.audience_code,
        color_code=d.color_code,
        ai_model_code=d.ai_model_code,
        image_url=d.image_url,
        status=d.status,
        is_saved=bool(d.is_saved),
        regen_count=d.regen_count,
        created_at=d.created_at,
        updated_at=d.updated_at,
    )


class PcdsFlatDesignService:

    @staticmethod
    async def generate(db: AsyncSession, user_id: int, req: FlatDesignGenerateRequest) -> FlatDesignVO:
        image_url, prompt = await PcdsAIService.generate_flat_image(
            clothing_type_code=req.clothing_type_code,
            pattern_code=req.pattern_code,
            material_code=req.material_code,
            style_code=req.style_code,
            audience_code=req.audience_code,
            ai_model_code=req.ai_model_code,
            color_code=req.color_code,
        )
        design = PcdsFlatDesign(
            user_id=user_id,
            clothing_type_code=req.clothing_type_code,
            pattern_code=req.pattern_code,
            material_code=req.material_code,
            style_code=req.style_code,
            audience_code=req.audience_code,
            color_code=req.color_code,
            ai_model_code=req.ai_model_code,
            image_url=image_url,
            prompt=prompt,
            status='done',
            is_saved=1,
        )
        db.add(design)
        await db.commit()
        await db.refresh(design)
        return _to_vo(design)

    @staticmethod
    async def generate_random(db: AsyncSession, user_id: int) -> dict:
        clothing_types = ['ct_tshirt', 'ct_shirt', 'ct_hoodie', 'ct_jeans', 'ct_dress_casual', 'ct_jacket']
        patterns = ['p_solid', 'p_stripe', 'p_plaid', 'p_print', 'p_floral']
        materials = ['m_cotton', 'm_linen', 'm_denim', 'm_polyester', 'm_knit']
        styles = ['s_casual', 's_business', 's_sport', 's_vintage', 's_streetwear']
        audiences = ['a_men', 'a_women', 'a_unisex']

        ct = random.choice(clothing_types)
        p = random.choice(patterns)
        m = random.choice(materials)
        s = random.choice(styles)
        a = random.choice(audiences)

        req = FlatDesignGenerateRequest(
            clothing_type_code=ct, pattern_code=p, material_code=m,
            style_code=s, audience_code=a, ai_model_code='ai_standard',
        )
        model = await PcdsFlatDesignService.generate(db, user_id, req)
        return {
            'model': model,
            'clothing_type_code': ct, 'pattern_code': p,
            'material_code': m, 'style_code': s, 'audience_code': a,
        }

    @staticmethod
    async def regenerate(db: AsyncSession, user_id: int, design_id: int) -> FlatDesignVO:
        result = await db.execute(
            select(PcdsFlatDesign).where(PcdsFlatDesign.design_id == design_id, PcdsFlatDesign.user_id == user_id)
        )
        design = result.scalar_one_or_none()
        if not design:
            raise ValueError('设计不存在')

        image_url, prompt = await PcdsAIService.generate_flat_image(
            clothing_type_code=design.clothing_type_code,
            pattern_code=design.pattern_code,
            material_code=design.material_code,
            style_code=design.style_code,
            audience_code=design.audience_code,
            ai_model_code=design.ai_model_code,
            color_code=design.color_code,
        )
        design.image_url = image_url
        design.prompt = prompt
        design.regen_count += 1
        await db.commit()
        await db.refresh(design)
        return _to_vo(design)

    @staticmethod
    async def get_list(db: AsyncSession, user_id: int, page: int = 1, page_size: int = 20) -> PageListResponse:
        """仓库列表：只返回 is_saved=1 的记录"""
        offset = (page - 1) * page_size
        count_result = await db.execute(
            select(func.count()).select_from(PcdsFlatDesign)
            .where(PcdsFlatDesign.user_id == user_id, PcdsFlatDesign.is_saved == 1)
        )
        total = count_result.scalar()
        result = await db.execute(
            select(PcdsFlatDesign)
            .where(PcdsFlatDesign.user_id == user_id, PcdsFlatDesign.is_saved == 1)
            .order_by(PcdsFlatDesign.created_at.desc())
            .offset(offset).limit(page_size)
        )
        items = result.scalars().all()
        return PageListResponse(data=[_to_vo(d) for d in items], total=total, page=page, page_size=page_size)

    @staticmethod
    async def get_history(db: AsyncSession, user_id: int, page: int = 1, page_size: int = 20) -> PageListResponse:
        """历史记录：返回全部记录（含已从仓库移除的）"""
        offset = (page - 1) * page_size
        count_result = await db.execute(
            select(func.count()).select_from(PcdsFlatDesign).where(PcdsFlatDesign.user_id == user_id)
        )
        total = count_result.scalar()
        result = await db.execute(
            select(PcdsFlatDesign)
            .where(PcdsFlatDesign.user_id == user_id)
            .order_by(PcdsFlatDesign.created_at.desc())
            .offset(offset).limit(page_size)
        )
        items = result.scalars().all()
        return PageListResponse(data=[_to_vo(d) for d in items], total=total, page=page, page_size=page_size)

    @staticmethod
    async def remove_from_gallery(db: AsyncSession, user_id: int, design_id: int) -> None:
        """从仓库移除（软删除，is_saved=0）"""
        result = await db.execute(
            select(PcdsFlatDesign).where(PcdsFlatDesign.design_id == design_id, PcdsFlatDesign.user_id == user_id)
        )
        design = result.scalar_one_or_none()
        if not design:
            raise ValueError('设计不存在')
        design.is_saved = 0
        await db.commit()

    @staticmethod
    async def get_detail(db: AsyncSession, user_id: int, design_id: int) -> FlatDesignVO:
        result = await db.execute(
            select(PcdsFlatDesign).where(PcdsFlatDesign.design_id == design_id, PcdsFlatDesign.user_id == user_id)
        )
        design = result.scalar_one_or_none()
        if not design:
            raise ValueError('设计不存在')
        return _to_vo(design)

    @staticmethod
    async def remove(db: AsyncSession, user_id: int, design_id: int) -> None:
        result = await db.execute(
            select(PcdsFlatDesign).where(PcdsFlatDesign.design_id == design_id, PcdsFlatDesign.user_id == user_id)
        )
        design = result.scalar_one_or_none()
        if not design:
            raise ValueError('设计不存在')
        await db.delete(design)
        await db.commit()

    @staticmethod
    async def save(db: AsyncSession, user_id: int, design_id: int) -> None:
        result = await db.execute(
            select(PcdsFlatDesign).where(PcdsFlatDesign.design_id == design_id, PcdsFlatDesign.user_id == user_id)
        )
        design = result.scalar_one_or_none()
        if not design:
            raise ValueError('设计不存在')
        design.is_saved = 1
        await db.commit()

    @staticmethod
    async def batch_remove(db: AsyncSession, user_id: int, ids: list[int]) -> int:
        result = await db.execute(
            select(PcdsFlatDesign).where(PcdsFlatDesign.design_id.in_(ids), PcdsFlatDesign.user_id == user_id)
        )
        designs = result.scalars().all()
        for d in designs:
            await db.delete(d)
        await db.commit()
        return len(designs)
