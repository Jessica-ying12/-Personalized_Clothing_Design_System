from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from module_pcds.entity.do.design_3d_do import PcdsDesign3d
from module_pcds.entity.do.flat_design_do import PcdsFlatDesign
from module_pcds.entity.vo.design_vo import Design3dGenerateRequest, Design3dVO, PageListResponse, ChangeBackgroundRequest
from module_pcds.service.ai_service import PcdsAIService


def _to_vo(d: PcdsDesign3d) -> Design3dVO:
    return Design3dVO(
        id=str(d.design_id),
        user_id=d.user_id,
        flat_design_id=str(d.flat_design_id),
        body_type_code=d.body_type_code,
        skin_tone_code=d.skin_tone_code,
        gender_code=d.gender_code,
        background_code=d.background_code,
        ai_model_code=d.ai_model_code,
        image_url=d.image_url,
        status=d.status,
        is_saved=bool(d.is_saved),
        regen_count=d.regen_count,
        created_at=d.created_at,
        updated_at=d.updated_at,
    )


class PcdsDesign3dService:

    @staticmethod
    async def generate(db: AsyncSession, user_id: int, req: Design3dGenerateRequest) -> Design3dVO:
        # 获取平面图URL和服装信息
        flat_result = await db.execute(
            select(PcdsFlatDesign).where(PcdsFlatDesign.design_id == int(req.flat_design_id))
        )
        flat = flat_result.scalar_one_or_none()
        flat_image_url = flat.image_url if flat else None

        image_url, prompt = await PcdsAIService.generate_3d_image(
            body_type_code=req.body_type_code,
            skin_tone_code=req.skin_tone_code,
            gender_code=req.gender_code,
            background_code=req.background_code,
            ai_model_code=req.ai_model_code,
            flat_image_url=flat_image_url,
            clothing_type_code=flat.clothing_type_code if flat else None,
            style_code=flat.style_code if flat else None,
            color_code=flat.color_code if flat else None,
        )
        design = PcdsDesign3d(
            user_id=user_id,
            flat_design_id=int(req.flat_design_id),
            body_type_code=req.body_type_code,
            skin_tone_code=req.skin_tone_code,
            gender_code=req.gender_code,
            background_code=req.background_code,
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
    async def regenerate(db: AsyncSession, user_id: int, design_id: int) -> Design3dVO:
        result = await db.execute(
            select(PcdsDesign3d).where(PcdsDesign3d.design_id == design_id, PcdsDesign3d.user_id == user_id)
        )
        design = result.scalar_one_or_none()
        if not design:
            raise ValueError('设计不存在')

        flat_result = await db.execute(
            select(PcdsFlatDesign).where(PcdsFlatDesign.design_id == design.flat_design_id)
        )
        flat = flat_result.scalar_one_or_none()
        flat_image_url = flat.image_url if flat else None

        image_url, prompt = await PcdsAIService.generate_3d_image(
            body_type_code=design.body_type_code,
            skin_tone_code=design.skin_tone_code,
            gender_code=design.gender_code,
            background_code=design.background_code,
            ai_model_code=design.ai_model_code,
            flat_image_url=flat_image_url,
            clothing_type_code=flat.clothing_type_code if flat else None,
            style_code=flat.style_code if flat else None,
            color_code=flat.color_code if flat else None,
        )
        design.image_url = image_url
        design.prompt = prompt
        design.regen_count += 1
        await db.commit()
        await db.refresh(design)
        return _to_vo(design)

    @staticmethod
    async def change_background(db: AsyncSession, user_id: int, req: ChangeBackgroundRequest) -> Design3dVO:
        result = await db.execute(
            select(PcdsDesign3d).where(PcdsDesign3d.design_id == int(req.design_id), PcdsDesign3d.user_id == user_id)
        )
        design = result.scalar_one_or_none()
        if not design:
            raise ValueError('设计不存在')

        flat_result = await db.execute(
            select(PcdsFlatDesign).where(PcdsFlatDesign.design_id == design.flat_design_id)
        )
        flat = flat_result.scalar_one_or_none()
        flat_image_url = flat.image_url if flat else None

        design.background_code = req.background_code
        image_url, prompt = await PcdsAIService.generate_3d_image(
            body_type_code=design.body_type_code,
            skin_tone_code=design.skin_tone_code,
            gender_code=design.gender_code,
            background_code=req.background_code,
            ai_model_code=design.ai_model_code,
            flat_image_url=flat_image_url,
            clothing_type_code=flat.clothing_type_code if flat else None,
            style_code=flat.style_code if flat else None,
            color_code=flat.color_code if flat else None,
        )
        design.image_url = image_url
        design.prompt = prompt
        await db.commit()
        await db.refresh(design)
        return _to_vo(design)

    @staticmethod
    async def get_list(db: AsyncSession, user_id: int, page: int = 1, page_size: int = 20) -> PageListResponse:
        """仓库列表：只返回 is_saved=1 的记录"""
        offset = (page - 1) * page_size
        count_result = await db.execute(
            select(func.count()).select_from(PcdsDesign3d)
            .where(PcdsDesign3d.user_id == user_id, PcdsDesign3d.is_saved == 1)
        )
        total = count_result.scalar()
        result = await db.execute(
            select(PcdsDesign3d)
            .where(PcdsDesign3d.user_id == user_id, PcdsDesign3d.is_saved == 1)
            .order_by(PcdsDesign3d.created_at.desc())
            .offset(offset).limit(page_size)
        )
        items = result.scalars().all()
        return PageListResponse(data=[_to_vo(d) for d in items], total=total, page=page, page_size=page_size)

    @staticmethod
    async def get_history(db: AsyncSession, user_id: int, page: int = 1, page_size: int = 20) -> PageListResponse:
        """历史记录：返回全部记录（含已从仓库移除的）"""
        offset = (page - 1) * page_size
        count_result = await db.execute(
            select(func.count()).select_from(PcdsDesign3d).where(PcdsDesign3d.user_id == user_id)
        )
        total = count_result.scalar()
        result = await db.execute(
            select(PcdsDesign3d)
            .where(PcdsDesign3d.user_id == user_id)
            .order_by(PcdsDesign3d.created_at.desc())
            .offset(offset).limit(page_size)
        )
        items = result.scalars().all()
        return PageListResponse(data=[_to_vo(d) for d in items], total=total, page=page, page_size=page_size)

    @staticmethod
    async def remove_from_gallery(db: AsyncSession, user_id: int, design_id: int) -> None:
        """从仓库移除（软删除，is_saved=0）"""
        result = await db.execute(
            select(PcdsDesign3d).where(PcdsDesign3d.design_id == design_id, PcdsDesign3d.user_id == user_id)
        )
        design = result.scalar_one_or_none()
        if not design:
            raise ValueError('设计不存在')
        design.is_saved = 0
        await db.commit()

    @staticmethod
    async def get_detail(db: AsyncSession, user_id: int, design_id: int) -> Design3dVO:
        result = await db.execute(
            select(PcdsDesign3d).where(PcdsDesign3d.design_id == design_id, PcdsDesign3d.user_id == user_id)
        )
        design = result.scalar_one_or_none()
        if not design:
            raise ValueError('设计不存在')
        return _to_vo(design)

    @staticmethod
    async def remove(db: AsyncSession, user_id: int, design_id: int) -> None:
        result = await db.execute(
            select(PcdsDesign3d).where(PcdsDesign3d.design_id == design_id, PcdsDesign3d.user_id == user_id)
        )
        design = result.scalar_one_or_none()
        if not design:
            raise ValueError('设计不存在')
        await db.delete(design)
        await db.commit()

    @staticmethod
    async def save(db: AsyncSession, user_id: int, design_id: int) -> None:
        result = await db.execute(
            select(PcdsDesign3d).where(PcdsDesign3d.design_id == design_id, PcdsDesign3d.user_id == user_id)
        )
        design = result.scalar_one_or_none()
        if not design:
            raise ValueError('设计不存在')
        design.is_saved = 1
        await db.commit()

    @staticmethod
    async def batch_remove(db: AsyncSession, user_id: int, ids: list[int]) -> int:
        result = await db.execute(
            select(PcdsDesign3d).where(PcdsDesign3d.design_id.in_(ids), PcdsDesign3d.user_id == user_id)
        )
        designs = result.scalars().all()
        for d in designs:
            await db.delete(d)
        await db.commit()
        return len(designs)
