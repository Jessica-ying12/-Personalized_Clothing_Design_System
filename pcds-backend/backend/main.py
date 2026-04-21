"""
个性化服装设计系统 - 后端服务入口
论文题目：基于Flutter与多模态AI的个性化服装设计自动化APP
"""
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from config.env import AppConfig
from config.get_db import init_create_table
from module_pcds.controller.auth_controller import auth_controller
from module_pcds.controller.profile_controller import profile_controller
from module_pcds.controller.design_options_controller import design_options_controller
from module_pcds.controller.flat_design_controller import flat_design_controller
from module_pcds.controller.design_3d_controller import design_3d_controller
from module_pcds.controller.admin_controller import admin_controller
from module_pcds.controller.chat_controller import chat_controller
from utils.log_util import logger


@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info('个性化服装设计系统后端启动中...')
    # 初始化数据库表
    await init_create_table()
    # 初始化默认设计选项数据
    await _init_design_options()
    logger.info('个性化服装设计系统后端启动成功')
    yield
    logger.info('个性化服装设计系统后端已停止')


async def _init_design_options():
    """初始化设计选项数据"""
    from config.get_db import AsyncSessionLocal
    from module_pcds.service.design_options_service import PcdsDesignOptionsService
    async with AsyncSessionLocal() as db:
        try:
            await PcdsDesignOptionsService.init_default_options(db)
            logger.info('设计选项数据初始化完成')
        except Exception as e:
            logger.warning(f'设计选项数据初始化失败（可能已存在）: {e}')


app = FastAPI(
    title='个性化服装设计系统 API',
    description='基于Flutter与多模态AI的个性化服装设计自动化APP - 后端接口文档',
    version='1.0.0',
    lifespan=lifespan,
    docs_url='/dev-api/docs',
    redoc_url='/dev-api/redoc',
    openapi_url='/dev-api/openapi.json',
)

# CORS 配置（允许 Flutter APP 和管理台访问）
app.add_middleware(
    CORSMiddleware,
    allow_origins=['*'],  # 生产环境请改为具体域名
    allow_credentials=True,
    allow_methods=['*'],
    allow_headers=['*'],
)

# 注册路由
app.include_router(auth_controller, tags=['认证模块'])
app.include_router(profile_controller, tags=['用户模块'])
app.include_router(design_options_controller, tags=['设计选项模块'])
app.include_router(flat_design_controller, tags=['平面设计模块'])
app.include_router(design_3d_controller, tags=['立体设计模块'])
app.include_router(admin_controller, tags=['管理台模块'])
app.include_router(chat_controller, tags=['AI问答模块'])


@app.get('/dev-api/health', tags=['系统'])
async def health():
    return {'status': 'ok', 'message': '个性化服装设计系统运行正常'}


if __name__ == '__main__':
    import uvicorn
    uvicorn.run(
        'main:app',
        host='0.0.0.0',
        port=9099,
        reload=True,
    )
