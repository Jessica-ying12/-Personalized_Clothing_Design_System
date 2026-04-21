from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from config.get_db import get_db
from module_pcds.controller.deps import get_current_user
from module_pcds.entity.do.user_do import PcdsUser
from module_pcds.entity.vo.design_vo import FlatDesignGenerateRequest, BatchIdsRequest
from module_pcds.service.flat_design_service import PcdsFlatDesignService
from utils.response_util import ResponseUtil

flat_design_controller = APIRouter(prefix='/api/flat-design')


@flat_design_controller.post('/generate', summary='生成平面图')
async def generate(
    req: FlatDesignGenerateRequest,
    current_user: PcdsUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await PcdsFlatDesignService.generate(db, current_user.user_id, req)
    return ResponseUtil.success(data=result.model_dump(), msg='生成成功')


@flat_design_controller.post('/generate-random', summary='随机生成平面图')
async def generate_random(
    current_user: PcdsUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await PcdsFlatDesignService.generate_random(db, current_user.user_id)
    return ResponseUtil.success(data={
        'model': result['model'].model_dump(),
        'clothing_type_code': result['clothing_type_code'],
        'pattern_code': result['pattern_code'],
        'material_code': result['material_code'],
        'style_code': result['style_code'],
        'audience_code': result['audience_code'],
    }, msg='随机生成成功')


@flat_design_controller.post('/regenerate/{design_id}', summary='重新生成平面图')
async def regenerate(
    design_id: int,
    current_user: PcdsUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    try:
        result = await PcdsFlatDesignService.regenerate(db, current_user.user_id, design_id)
        return ResponseUtil.success(data=result.model_dump(), msg='重新生成成功')
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))


@flat_design_controller.get('/list', summary='获取平面图列表')
async def get_list(
    page: int = 1,
    page_size: int = 20,
    current_user: PcdsUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await PcdsFlatDesignService.get_list(db, current_user.user_id, page, page_size)
    return ResponseUtil.success(data=result.model_dump())


@flat_design_controller.get('/history', summary='获取历史记录（全部，含已移除）')
async def get_history(
    page: int = 1,
    page_size: int = 20,
    current_user: PcdsUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await PcdsFlatDesignService.get_history(db, current_user.user_id, page, page_size)
    return ResponseUtil.success(data=result.model_dump())


@flat_design_controller.get('/detail/{design_id}', summary='获取平面图详情')
async def get_detail(
    design_id: int,
    current_user: PcdsUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    try:
        result = await PcdsFlatDesignService.get_detail(db, current_user.user_id, design_id)
        return ResponseUtil.success(data=result.model_dump())
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))


@flat_design_controller.delete('/remove/{design_id}', summary='从仓库移除（软删除）')
async def remove(
    design_id: int,
    current_user: PcdsUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    try:
        await PcdsFlatDesignService.remove_from_gallery(db, current_user.user_id, design_id)
        return ResponseUtil.success(msg='已从仓库移除')
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))


@flat_design_controller.post('/save/{design_id}', summary='保存平面图')
async def save(
    design_id: int,
    current_user: PcdsUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    try:
        await PcdsFlatDesignService.save(db, current_user.user_id, design_id)
        return ResponseUtil.success(msg='保存成功')
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))


@flat_design_controller.post('/batch-remove', summary='批量删除平面图')
async def batch_remove(
    req: BatchIdsRequest,
    current_user: PcdsUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    count = await PcdsFlatDesignService.batch_remove(db, current_user.user_id, [int(i) for i in req.ids])
    return ResponseUtil.success(data={'count': count}, msg=f'已删除 {count} 条')


@flat_design_controller.delete('/history-remove/{design_id}', summary='从历史记录彻底删除')
async def history_remove(
    design_id: int,
    current_user: PcdsUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    try:
        await PcdsFlatDesignService.remove(db, current_user.user_id, design_id)
        return ResponseUtil.success(msg='删除成功')
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
