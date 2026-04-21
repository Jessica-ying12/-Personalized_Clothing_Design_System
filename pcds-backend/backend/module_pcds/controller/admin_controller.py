"""管理台接口 — 供管理后台使用"""
from fastapi import APIRouter, Depends
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from config.get_db import get_db
from module_pcds.controller.deps import get_current_user
from module_pcds.entity.do.user_do import PcdsUser
from module_pcds.entity.do.flat_design_do import PcdsFlatDesign
from module_pcds.entity.do.design_3d_do import PcdsDesign3d
from utils.response_util import ResponseUtil

admin_controller = APIRouter(prefix='/api/admin')


@admin_controller.get('/stats', summary='管理台首页统计')
async def get_stats(
    db: AsyncSession = Depends(get_db),
    _: PcdsUser = Depends(get_current_user),
):
    user_total = (await db.execute(
        select(func.count()).select_from(PcdsUser).where(PcdsUser.deleted_at.is_(None))
    )).scalar() or 0
    flat_total = (await db.execute(select(func.count()).select_from(PcdsFlatDesign))).scalar() or 0
    d3_total = (await db.execute(select(func.count()).select_from(PcdsDesign3d))).scalar() or 0
    return ResponseUtil.success(data={
        'user_total': user_total,
        'flat_total': flat_total,
        'design_3d_total': d3_total,
    })


@admin_controller.get('/users', summary='用户列表')
async def get_users(
    page: int = 1,
    page_size: int = 20,
    db: AsyncSession = Depends(get_db),
    _: PcdsUser = Depends(get_current_user),
):
    offset = (page - 1) * page_size
    total = (await db.execute(
        select(func.count()).select_from(PcdsUser).where(PcdsUser.deleted_at.is_(None))
    )).scalar() or 0
    result = await db.execute(
        select(PcdsUser).where(PcdsUser.deleted_at.is_(None))
        .order_by(PcdsUser.created_at.desc()).offset(offset).limit(page_size)
    )
    users = result.scalars().all()
    return ResponseUtil.success(data={
        'data': [
            {
                'user_id': u.user_id, 'email': u.email,
                'nickname': u.nickname, 'status': u.status,
                'created_at': str(u.created_at),
            }
            for u in users
        ],
        'total': total, 'page': page, 'page_size': page_size,
    })


@admin_controller.get('/flat-designs', summary='平面图列表')
async def get_flat_designs(
    page: int = 1,
    page_size: int = 20,
    db: AsyncSession = Depends(get_db),
    _: PcdsUser = Depends(get_current_user),
):
    offset = (page - 1) * page_size
    total = (await db.execute(select(func.count()).select_from(PcdsFlatDesign))).scalar() or 0
    result = await db.execute(
        select(PcdsFlatDesign).order_by(PcdsFlatDesign.created_at.desc()).offset(offset).limit(page_size)
    )
    items = result.scalars().all()
    return ResponseUtil.success(data={
        'data': [
            {
                'design_id': d.design_id, 'user_id': d.user_id,
                'clothing_type_code': d.clothing_type_code, 'pattern_code': d.pattern_code,
                'material_code': d.material_code, 'style_code': d.style_code,
                'image_url': d.image_url, 'status': d.status,
                'created_at': str(d.created_at),
            }
            for d in items
        ],
        'total': total, 'page': page, 'page_size': page_size,
    })


@admin_controller.get('/3d-designs', summary='立体图列表')
async def get_3d_designs(
    page: int = 1,
    page_size: int = 20,
    db: AsyncSession = Depends(get_db),
    _: PcdsUser = Depends(get_current_user),
):
    offset = (page - 1) * page_size
    total = (await db.execute(select(func.count()).select_from(PcdsDesign3d))).scalar() or 0
    result = await db.execute(
        select(PcdsDesign3d).order_by(PcdsDesign3d.created_at.desc()).offset(offset).limit(page_size)
    )
    items = result.scalars().all()
    return ResponseUtil.success(data={
        'data': [
            {
                'design_id': d.design_id, 'user_id': d.user_id,
                'flat_design_id': d.flat_design_id,
                'body_type_code': d.body_type_code, 'skin_tone_code': d.skin_tone_code,
                'gender_code': d.gender_code, 'background_code': d.background_code,
                'image_url': d.image_url, 'status': d.status,
                'created_at': str(d.created_at),
            }
            for d in items
        ],
        'total': total, 'page': page, 'page_size': page_size,
    })
