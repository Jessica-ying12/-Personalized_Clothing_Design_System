"""管理台接口 — 供管理后台使用"""
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from typing import Optional

from config.get_db import get_db
from module_pcds.controller.deps import get_current_user
from module_pcds.entity.do.design_option_do import PcdsDesignOption
from module_pcds.entity.do.user_do import PcdsUser
from module_pcds.entity.do.flat_design_do import PcdsFlatDesign
from module_pcds.entity.do.design_3d_do import PcdsDesign3d
from utils.response_util import ResponseUtil

admin_controller = APIRouter(prefix='/api/admin')


# ── 请求体模型 ────────────────────────────────────────────────────

class OptionCreateRequest(BaseModel):
    category: str
    option_code: str
    name_zh: str
    name_en: str
    parent_code: Optional[str] = None
    sort_order: int = 0

class OptionUpdateRequest(BaseModel):
    name_zh: Optional[str] = None
    name_en: Optional[str] = None
    sort_order: Optional[int] = None
    status: Optional[str] = None


# ── 统计 ──────────────────────────────────────────────────────────

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
    option_total = (await db.execute(
        select(func.count()).select_from(PcdsDesignOption).where(PcdsDesignOption.status == '0')
    )).scalar() or 0
    # 今日新增用户
    from datetime import date
    today_users = (await db.execute(
        select(func.count()).select_from(PcdsUser)
        .where(PcdsUser.deleted_at.is_(None), func.date(PcdsUser.created_at) == date.today())
    )).scalar() or 0
    return ResponseUtil.success(data={
        'user_total': user_total,
        'flat_total': flat_total,
        'design_3d_total': d3_total,
        'option_total': option_total,
        'today_users': today_users,
    })


# ── 用户管理 ──────────────────────────────────────────────────────

@admin_controller.get('/users', summary='用户列表')
async def get_users(
    page: int = 1,
    page_size: int = 20,
    keyword: Optional[str] = None,
    db: AsyncSession = Depends(get_db),
    _: PcdsUser = Depends(get_current_user),
):
    query = select(PcdsUser).where(PcdsUser.deleted_at.is_(None))
    count_query = select(func.count()).select_from(PcdsUser).where(PcdsUser.deleted_at.is_(None))
    if keyword:
        like = f'%{keyword}%'
        from sqlalchemy import or_
        query = query.where(or_(PcdsUser.email.like(like), PcdsUser.nickname.like(like)))
        count_query = count_query.where(or_(PcdsUser.email.like(like), PcdsUser.nickname.like(like)))

    total = (await db.execute(count_query)).scalar() or 0
    offset = (page - 1) * page_size
    result = await db.execute(query.order_by(PcdsUser.created_at.desc()).offset(offset).limit(page_size))
    users = result.scalars().all()
    return ResponseUtil.success(data={
        'data': [
            {
                'user_id': u.user_id, 'email': u.email,
                'nickname': u.nickname or '', 'avatar_url': u.avatar_url or '',
                'status': u.status, 'created_at': str(u.created_at),
            }
            for u in users
        ],
        'total': total, 'page': page, 'page_size': page_size,
    })


@admin_controller.put('/users/{user_id}/status', summary='启用/停用用户')
async def update_user_status(
    user_id: int,
    db: AsyncSession = Depends(get_db),
    _: PcdsUser = Depends(get_current_user),
):
    result = await db.execute(select(PcdsUser).where(PcdsUser.user_id == user_id))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail='用户不存在')
    user.status = '1' if user.status == '0' else '0'
    await db.commit()
    return ResponseUtil.success(msg='操作成功', data={'status': user.status})


@admin_controller.delete('/users/{user_id}', summary='删除用户')
async def delete_user(
    user_id: int,
    db: AsyncSession = Depends(get_db),
    _: PcdsUser = Depends(get_current_user),
):
    from datetime import datetime
    result = await db.execute(select(PcdsUser).where(PcdsUser.user_id == user_id))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail='用户不存在')
    user.deleted_at = datetime.now()
    await db.commit()
    return ResponseUtil.success(msg='删除成功')


# ── 平面图管理 ────────────────────────────────────────────────────

@admin_controller.get('/flat-designs', summary='平面图列表')
async def get_flat_designs(
    page: int = 1,
    page_size: int = 20,
    user_id: Optional[int] = None,
    db: AsyncSession = Depends(get_db),
    _: PcdsUser = Depends(get_current_user),
):
    query = select(PcdsFlatDesign)
    count_query = select(func.count()).select_from(PcdsFlatDesign)
    if user_id:
        query = query.where(PcdsFlatDesign.user_id == user_id)
        count_query = count_query.where(PcdsFlatDesign.user_id == user_id)

    total = (await db.execute(count_query)).scalar() or 0
    offset = (page - 1) * page_size
    result = await db.execute(query.order_by(PcdsFlatDesign.created_at.desc()).offset(offset).limit(page_size))
    items = result.scalars().all()
    return ResponseUtil.success(data={
        'data': [
            {
                'design_id': d.design_id, 'user_id': d.user_id,
                'clothing_type_code': d.clothing_type_code, 'pattern_code': d.pattern_code,
                'material_code': d.material_code, 'style_code': d.style_code,
                'audience_code': d.audience_code, 'color_code': d.color_code or '',
                'ai_model_code': d.ai_model_code, 'image_url': d.image_url,
                'is_saved': bool(d.is_saved), 'regen_count': d.regen_count,
                'status': d.status, 'created_at': str(d.created_at),
            }
            for d in items
        ],
        'total': total, 'page': page, 'page_size': page_size,
    })


@admin_controller.delete('/flat-designs/{design_id}', summary='删除平面图')
async def delete_flat_design(
    design_id: int,
    db: AsyncSession = Depends(get_db),
    _: PcdsUser = Depends(get_current_user),
):
    result = await db.execute(select(PcdsFlatDesign).where(PcdsFlatDesign.design_id == design_id))
    item = result.scalar_one_or_none()
    if not item:
        raise HTTPException(status_code=404, detail='记录不存在')
    await db.delete(item)
    await db.commit()
    return ResponseUtil.success(msg='删除成功')


# ── 立体图管理 ────────────────────────────────────────────────────

@admin_controller.get('/3d-designs', summary='立体图列表')
async def get_3d_designs(
    page: int = 1,
    page_size: int = 20,
    user_id: Optional[int] = None,
    db: AsyncSession = Depends(get_db),
    _: PcdsUser = Depends(get_current_user),
):
    query = select(PcdsDesign3d)
    count_query = select(func.count()).select_from(PcdsDesign3d)
    if user_id:
        query = query.where(PcdsDesign3d.user_id == user_id)
        count_query = count_query.where(PcdsDesign3d.user_id == user_id)

    total = (await db.execute(count_query)).scalar() or 0
    offset = (page - 1) * page_size
    result = await db.execute(query.order_by(PcdsDesign3d.created_at.desc()).offset(offset).limit(page_size))
    items = result.scalars().all()
    return ResponseUtil.success(data={
        'data': [
            {
                'design_id': d.design_id, 'user_id': d.user_id,
                'flat_design_id': d.flat_design_id,
                'body_type_code': d.body_type_code, 'skin_tone_code': d.skin_tone_code,
                'gender_code': d.gender_code, 'background_code': d.background_code,
                'ai_model_code': d.ai_model_code, 'image_url': d.image_url,
                'is_saved': bool(d.is_saved), 'regen_count': d.regen_count,
                'status': d.status, 'created_at': str(d.created_at),
            }
            for d in items
        ],
        'total': total, 'page': page, 'page_size': page_size,
    })


@admin_controller.delete('/3d-designs/{design_id}', summary='删除立体图')
async def delete_3d_design(
    design_id: int,
    db: AsyncSession = Depends(get_db),
    _: PcdsUser = Depends(get_current_user),
):
    result = await db.execute(select(PcdsDesign3d).where(PcdsDesign3d.design_id == design_id))
    item = result.scalar_one_or_none()
    if not item:
        raise HTTPException(status_code=404, detail='记录不存在')
    await db.delete(item)
    await db.commit()
    return ResponseUtil.success(msg='删除成功')


# ── 设计选项管理 ──────────────────────────────────────────────────

@admin_controller.get('/design-options', summary='设计选项列表（管理台）')
async def get_design_options(
    category: Optional[str] = None,
    keyword: Optional[str] = None,
    db: AsyncSession = Depends(get_db),
    _: PcdsUser = Depends(get_current_user),
):
    query = select(PcdsDesignOption)
    if category:
        query = query.where(PcdsDesignOption.category == category)
    if keyword:
        like = f'%{keyword}%'
        from sqlalchemy import or_
        query = query.where(or_(PcdsDesignOption.name_zh.like(like), PcdsDesignOption.option_code.like(like)))
    result = await db.execute(query.order_by(PcdsDesignOption.category, PcdsDesignOption.sort_order))
    options = result.scalars().all()
    id_to_code = {o.option_id: o.option_code for o in options}
    return ResponseUtil.success(data=[
        {
            'option_id': o.option_id, 'category': o.category,
            'option_code': o.option_code, 'name_zh': o.name_zh, 'name_en': o.name_en,
            'parent_id': o.parent_id,
            'parent_code': id_to_code.get(o.parent_id, '') if o.parent_id else '',
            'sort_order': o.sort_order, 'status': o.status,
        }
        for o in options
    ])


@admin_controller.post('/design-options', summary='新增设计选项')
async def create_design_option(
    req: OptionCreateRequest,
    db: AsyncSession = Depends(get_db),
    _: PcdsUser = Depends(get_current_user),
):
    # 检查 code 是否重复
    exists = (await db.execute(
        select(PcdsDesignOption).where(PcdsDesignOption.option_code == req.option_code)
    )).scalar_one_or_none()
    if exists:
        raise HTTPException(status_code=400, detail='选项代码已存在')

    parent_id = None
    if req.parent_code:
        parent = (await db.execute(
            select(PcdsDesignOption).where(PcdsDesignOption.option_code == req.parent_code)
        )).scalar_one_or_none()
        if parent:
            parent_id = parent.option_id

    option = PcdsDesignOption(
        category=req.category, option_code=req.option_code,
        name_zh=req.name_zh, name_en=req.name_en,
        parent_id=parent_id, sort_order=req.sort_order, status='0',
    )
    db.add(option)
    await db.commit()
    await db.refresh(option)
    return ResponseUtil.success(msg='新增成功', data={'option_id': option.option_id})


@admin_controller.put('/design-options/{option_id}', summary='修改设计选项')
async def update_design_option(
    option_id: int,
    req: OptionUpdateRequest,
    db: AsyncSession = Depends(get_db),
    _: PcdsUser = Depends(get_current_user),
):
    result = await db.execute(select(PcdsDesignOption).where(PcdsDesignOption.option_id == option_id))
    option = result.scalar_one_or_none()
    if not option:
        raise HTTPException(status_code=404, detail='选项不存在')
    if req.name_zh is not None: option.name_zh = req.name_zh
    if req.name_en is not None: option.name_en = req.name_en
    if req.sort_order is not None: option.sort_order = req.sort_order
    if req.status is not None: option.status = req.status
    await db.commit()
    return ResponseUtil.success(msg='修改成功')


@admin_controller.delete('/design-options/{option_id}', summary='删除设计选项')
async def delete_design_option(
    option_id: int,
    db: AsyncSession = Depends(get_db),
    _: PcdsUser = Depends(get_current_user),
):
    result = await db.execute(select(PcdsDesignOption).where(PcdsDesignOption.option_id == option_id))
    option = result.scalar_one_or_none()
    if not option:
        raise HTTPException(status_code=404, detail='选项不存在')
    await db.delete(option)
    await db.commit()
    return ResponseUtil.success(msg='删除成功')
