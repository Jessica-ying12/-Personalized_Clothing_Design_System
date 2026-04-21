from typing import Optional
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from config.get_db import get_db
from module_pcds.service.design_options_service import PcdsDesignOptionsService
from utils.response_util import ResponseUtil

design_options_controller = APIRouter(prefix='/api/design-options')


@design_options_controller.get('/list', summary='获取所有设计选项')
async def get_options(category: Optional[str] = None, db: AsyncSession = Depends(get_db)):
    result = await PcdsDesignOptionsService.get_options(db, category)
    return ResponseUtil.success(data=[o.model_dump() for o in result])


@design_options_controller.get('/category/{category}', summary='按类别获取设计选项')
async def get_by_category(category: str, db: AsyncSession = Depends(get_db)):
    result = await PcdsDesignOptionsService.get_options(db, category)
    return ResponseUtil.success(data=[o.model_dump() for o in result])


@design_options_controller.get('/children/{parent_id}', summary='获取子选项')
async def get_children(parent_id: str, db: AsyncSession = Depends(get_db)):
    result = await PcdsDesignOptionsService.get_children(db, parent_id)
    return ResponseUtil.success(data=[o.model_dump() for o in result])
