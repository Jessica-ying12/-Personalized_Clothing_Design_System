from datetime import datetime
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from module_pcds.entity.do.user_do import PcdsUser
from module_pcds.entity.do.flat_design_do import PcdsFlatDesign
from module_pcds.entity.do.design_3d_do import PcdsDesign3d
from module_pcds.entity.vo.profile_vo import UserProfileVO, UpdateProfileRequest, UserStatsVO


class PcdsProfileService:

    @staticmethod
    async def get_me(db: AsyncSession, user_id: int) -> UserProfileVO:
        result = await db.execute(select(PcdsUser).where(PcdsUser.user_id == user_id, PcdsUser.deleted_at.is_(None)))
        user = result.scalar_one_or_none()
        if not user:
            raise ValueError('用户不存在')
        return UserProfileVO(
            user_id=user.user_id,
            email=user.email,
            nickname=user.nickname or '',
            avatar_url=user.avatar_url or '',
        )

    @staticmethod
    async def update_profile(db: AsyncSession, user_id: int, req: UpdateProfileRequest) -> UserProfileVO:
        result = await db.execute(select(PcdsUser).where(PcdsUser.user_id == user_id, PcdsUser.deleted_at.is_(None)))
        user = result.scalar_one_or_none()
        if not user:
            raise ValueError('用户不存在')
        if req.nickname is not None:
            user.nickname = req.nickname
        if req.avatar_url is not None:
            user.avatar_url = req.avatar_url
        await db.commit()
        await db.refresh(user)
        return UserProfileVO(
            user_id=user.user_id,
            email=user.email,
            nickname=user.nickname or '',
            avatar_url=user.avatar_url or '',
        )

    @staticmethod
    async def delete_account(db: AsyncSession, user_id: int) -> None:
        result = await db.execute(select(PcdsUser).where(PcdsUser.user_id == user_id))
        user = result.scalar_one_or_none()
        if not user:
            raise ValueError('用户不存在')
        user.deleted_at = datetime.now()
        await db.commit()

    @staticmethod
    async def get_stats(db: AsyncSession, user_id: int) -> UserStatsVO:
        flat_total = (await db.execute(
            select(func.count()).select_from(PcdsFlatDesign).where(PcdsFlatDesign.user_id == user_id)
        )).scalar() or 0
        flat_saved = (await db.execute(
            select(func.count()).select_from(PcdsFlatDesign)
            .where(PcdsFlatDesign.user_id == user_id, PcdsFlatDesign.is_saved == 1)
        )).scalar() or 0
        d3_total = (await db.execute(
            select(func.count()).select_from(PcdsDesign3d).where(PcdsDesign3d.user_id == user_id)
        )).scalar() or 0
        d3_saved = (await db.execute(
            select(func.count()).select_from(PcdsDesign3d)
            .where(PcdsDesign3d.user_id == user_id, PcdsDesign3d.is_saved == 1)
        )).scalar() or 0
        return UserStatsVO(
            flat_total=flat_total, flat_saved=flat_saved,
            design_3d_total=d3_total, design_3d_saved=d3_saved,
        )
