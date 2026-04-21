from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from config.get_db import get_db
from module_pcds.controller.deps import get_current_user
from module_pcds.entity.do.user_do import PcdsUser
from module_pcds.entity.vo.profile_vo import UpdateProfileRequest
from module_pcds.service.profile_service import PcdsProfileService
from utils.response_util import ResponseUtil

profile_controller = APIRouter(prefix='/api/profile')


@profile_controller.get('/me', summary='获取当前用户信息')
async def get_me(
    current_user: PcdsUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await PcdsProfileService.get_me(db, current_user.user_id)
    return ResponseUtil.success(data=result.model_dump())


@profile_controller.put('/update', summary='更新用户信息')
async def update_profile(
    req: UpdateProfileRequest,
    current_user: PcdsUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    try:
        result = await PcdsProfileService.update_profile(db, current_user.user_id, req)
        return ResponseUtil.success(data=result.model_dump(), msg='更新成功')
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@profile_controller.delete('/delete', summary='注销账号')
async def delete_account(
    current_user: PcdsUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    await PcdsProfileService.delete_account(db, current_user.user_id)
    return ResponseUtil.success(msg='账号已注销')


@profile_controller.get('/stats', summary='获取用户统计数据')
async def get_stats(
    current_user: PcdsUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await PcdsProfileService.get_stats(db, current_user.user_id)
    return ResponseUtil.success(data=result.model_dump())
