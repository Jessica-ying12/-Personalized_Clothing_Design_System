import logging
import sys
from pathlib import Path

from loguru import logger as _logger

from middlewares.trace_middleware import TraceCtx


# 创建一个自定义的日志处理器，用来将日志转发给loguru
class InterceptHandler(logging.Handler):
    def emit(self, record):
        # 将记录转换为loguru可以理解的格式
        level = logger.level(record.levelname).name
        logger.opt(depth=6, exception=record.exc_info).log(level, record.getMessage())


class LoggerInitializer:
    def __init__(self):
        self.log_path = Path.cwd() / 'logs'
        self.__ensure_log_directory_exists()

    def __ensure_log_directory_exists(self):
        """
        确保日志目录存在，如果不存在则创建
        """
        if not self.log_path.exists():
            self.log_path.mkdir()

    @staticmethod
    def __filter(record):
        """
        自定义日志过滤器，添加trace_id
        """
        record['trace_id'] = TraceCtx.get_id()
        return True

    def init_log(self):
        """
        初始化日志配置
        """
        # 自定义日志格式
        format_str = (
            '<green>{time:YYYY-MM-DD HH:mm:ss.SSS}</green> | '
            '<cyan>{trace_id}</cyan> | '
            '<level>{level: <8}</level> | '
            '<cyan>{name}</cyan>:<cyan>{function}</cyan>:<cyan>{line}</cyan> - '
            '<level>{message}</level>'
        )
        _logger.remove()
        # 移除后重新添加sys.stderr, 目的: 控制台输出与文件日志内容和结构一致
        _logger.add(sys.stderr, filter=self.__filter, format=format_str, enqueue=True)
        _logger.add(
            str(self.log_path / '{time:YYYY-MM-DD}_info.log'),
            filter=self.__filter,
            format=format_str,
            rotation='00:00',
            retention='30 days',
            encoding='utf-8',
            enqueue=True,
            compression='zip',
        )

        return _logger


# 配置logging使用InterceptHandler
logging.basicConfig(handlers=[InterceptHandler()], level=logging.DEBUG)

# 设置特定库的日志级别，减少冗余日志
logging.getLogger('httpx').setLevel(logging.WARNING)
logging.getLogger('httpcore').setLevel(logging.WARNING)
logging.getLogger('httpcore.connection').setLevel(logging.WARNING)
logging.getLogger('httpcore.http11').setLevel(logging.WARNING)

# 初始化日志处理器
log_initializer = LoggerInitializer()
logger = log_initializer.init_log()
