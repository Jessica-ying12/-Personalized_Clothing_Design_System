from config.database import AsyncSessionLocal, Base, async_engine
from utils.log_util import logger

# 导入所有模型，确保 SQLAlchemy 能创建对应的表
from module_pcds.entity.do.user_do import PcdsUser  # noqa: F401
from module_pcds.entity.do.design_option_do import PcdsDesignOption  # noqa: F401
from module_pcds.entity.do.flat_design_do import PcdsFlatDesign  # noqa: F401
from module_pcds.entity.do.design_3d_do import PcdsDesign3d  # noqa: F401


async def get_db():
    """
    每一个请求处理完毕后会关闭当前连接，不同的请求使用不同的连接

    :return:
    """
    async with AsyncSessionLocal() as current_db:
        yield current_db


async def init_create_table():
    """
    应用启动时初始化数据库连接

    :return:
    """
    logger.info('初始化数据库连接...')
    async with async_engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    logger.info('数据库连接成功')
