from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from config.get_db import get_db
from module_pcds.controller.deps import get_current_user
from module_pcds.entity.do.user_do import PcdsUser
from module_pcds.entity.vo.design_vo import Design3dGenerateRequest, ChangeBackgroundRequest, BatchIdsRequest
from module_pcds.service.design_3d_service import PcdsDesign3dService
from utils.response_util import ResponseUtil

design_3d_controller = APIRouter(prefix='/api/3d-design')


@design_3d_controller.post('/generate', summary='生成立体图')
async def generate(
    req: Design3dGenerateRequest,
    current_user: PcdsUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await PcdsDesign3dService.generate(db, current_user.user_id, req)
    return ResponseUtil.success(data=result.model_dump(), msg='生成成功')


@design_3d_controller.post('/regenerate/{design_id}', summary='重新生成立体图')
async def regenerate(
    design_id: int,
    current_user: PcdsUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    try:
        result = await PcdsDesign3dService.regenerate(db, current_user.user_id, design_id)
        return ResponseUtil.success(data=result.model_dump(), msg='重新生成成功')
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))


@design_3d_controller.post('/change-background', summary='更换背景')
async def change_background(
    req: ChangeBackgroundRequest,
    current_user: PcdsUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    try:
        result = await PcdsDesign3dService.change_background(db, current_user.user_id, req)
        return ResponseUtil.success(data=result.model_dump(), msg='背景更换成功')
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))


@design_3d_controller.get('/list', summary='获取立体图列表')
async def get_list(
    page: int = 1,
    page_size: int = 20,
    current_user: PcdsUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await PcdsDesign3dService.get_list(db, current_user.user_id, page, page_size)
    return ResponseUtil.success(data=result.model_dump())


@design_3d_controller.get('/history', summary='获取历史记录（全部，含已移除）')
async def get_history(
    page: int = 1,
    page_size: int = 20,
    current_user: PcdsUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await PcdsDesign3dService.get_history(db, current_user.user_id, page, page_size)
    return ResponseUtil.success(data=result.model_dump())


@design_3d_controller.get('/detail/{design_id}', summary='获取立体图详情')
async def get_detail(
    design_id: int,
    current_user: PcdsUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    try:
        result = await PcdsDesign3dService.get_detail(db, current_user.user_id, design_id)
        return ResponseUtil.success(data=result.model_dump())
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))


@design_3d_controller.delete('/remove/{design_id}', summary='从仓库移除（软删除）')
async def remove(
    design_id: int,
    current_user: PcdsUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    try:
        await PcdsDesign3dService.remove_from_gallery(db, current_user.user_id, design_id)
        return ResponseUtil.success(msg='已从仓库移除')
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))


@design_3d_controller.post('/save/{design_id}', summary='保存立体图')
async def save(
    design_id: int,
    current_user: PcdsUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    try:
        await PcdsDesign3dService.save(db, current_user.user_id, design_id)
        return ResponseUtil.success(msg='保存成功')
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))


@design_3d_controller.post('/batch-remove', summary='批量删除立体图')
async def batch_remove(
    req: BatchIdsRequest,
    current_user: PcdsUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    count = await PcdsDesign3dService.batch_remove(db, current_user.user_id, [int(i) for i in req.ids])
    return ResponseUtil.success(data={'count': count}, msg=f'已删除 {count} 条')


@design_3d_controller.delete('/history-remove/{design_id}', summary='从历史记录彻底删除')
async def history_remove(
    design_id: int,
    current_user: PcdsUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    try:
        await PcdsDesign3dService.remove(db, current_user.user_id, design_id)
        return ResponseUtil.success(msg='删除成功')
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
