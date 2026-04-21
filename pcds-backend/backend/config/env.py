import argparse
import os
import sys
from functools import lru_cache
from pathlib import Path
from typing import Literal

from dotenv import load_dotenv
from pydantic import computed_field
from pydantic_settings import BaseSettings


class AppSettings(BaseSettings):
    """
    应用配置
    """

    app_env: str = 'dev'
    app_name: str = 'RuoYi-FasAPI'
    app_root_path: str = '/dev-api'
    app_host: str = '0.0.0.0'
    app_port: int = 9099
    app_version: str = '1.0.0'
    app_reload: bool = True
    app_ip_location_query: bool = False
    app_same_time_login: bool = True

    apispace_enable: bool = False
    apispace_token: str = ''  # https://www.apispace.com/eolink/api/ipguishu/introduction
    adstract_api_key: str = '8d372c0b4d404cea9358df16381ea7e0'  #'8d372c0b4d404cea9358df16381ea7e0'

    # Gemini AI 配置
    gemini_api_key: str = ''
    gemini_model: str = 'gemini-1.5-flash'


class JwtSettings(BaseSettings):
    """
    Jwt配置
    """

    jwt_secret_key: str = 'b01c66dc2c58dc6a0aabfe2144256be36226de378bf87f72c0c795dda67f4d55'
    jwt_algorithm: str = 'HS256'
    jwt_expire_minutes: int = 1440
    jwt_redis_expire_minutes: int = 30


class DataBaseSettings(BaseSettings):
    """
    数据库配置
    """

    db_type: Literal['mysql', 'postgresql'] = 'mysql'
    db_host: str = '127.0.0.1'
    db_port: int = 3306
    db_username: str = 'root'
    db_password: str = 'mysqlroot'
    db_database: str = 'ruoyi-fastapi'
    db_echo: bool = True
    db_max_overflow: int = 10
    db_pool_size: int = 50
    db_pool_recycle: int = 3600
    db_pool_timeout: int = 30

    @property
    @computed_field
    def sqlglot_parse_dialect(self) -> str:
        if self.db_type == 'postgresql':
            return 'postgres'
        return self.db_type


class RedisSettings(BaseSettings):
    """
    Redis配置
    """

    redis_host: str = '127.0.0.1'
    redis_port: int = 6379
    redis_username: str = ''
    redis_password: str = ''
    redis_database: int = 2


class GenSettings:
    """
    代码生成配置
    """

    author = 'hammer'
    package_name = 'module_hammer.admin'
    module_name = 'hammer'
    auto_remove_pre = True
    table_prefix = 'hammer_'
    allow_overwrite = False

    GEN_PATH = 'vf_admin/gen_path'

    def __init__(self):
        if not Path(self.GEN_PATH).exists():
            Path(self.GEN_PATH).mkdir(parents=True)


class UploadSettings:
    """
    上传配置
    """

    UPLOAD_PREFIX = '/profile'
    UPLOAD_PATH = 'vf_admin/upload_path'
    UPLOAD_MACHINE = 'A'
    DEFAULT_ALLOWED_EXTENSION = [
        # 图片
        'bmp',
        'gif',
        'jpg',
        'jpeg',
        'png',
        'heic',
        'HEIC',
        # word excel powerpoint
        'doc',
        'docx',
        'xls',
        'xlsx',
        'ppt',
        'pptx',
        'html',
        'htm',
        'txt',
        # 压缩文件
        'rar',
        'zip',
        'gz',
        'bz2',
        # 视频格式
        'mp4',
        'avi',
        'rmvb',
        'mov',
        'MOV',
        # pdf
        'pdf',
        # json
        'json',
        # 安装包
        'apk',
    ]
    DOWNLOAD_PATH = 'vf_admin/download_path'

    def __init__(self):
        if not Path(self.UPLOAD_PATH).exists():
            Path(self.UPLOAD_PATH).mkdir(parents=True)
        if not Path(self.DOWNLOAD_PATH).exists():
            Path(self.DOWNLOAD_PATH).mkdir(parents=True)


class CachePathConfig:
    """
    缓存目录配置
    """

    PATH = Path.cwd() / 'caches'
    PATHSTR = 'caches'


class GetConfig:
    """
    获取配置
    """

    def __init__(self):
        self.parse_cli_args()

    @staticmethod
    @lru_cache
    def get_app_config():
        """
        获取应用配置
        """
        # 实例化应用配置模型
        return AppSettings()

    @staticmethod
    @lru_cache
    def get_jwt_config():
        """
        获取Jwt配置
        """
        # 实例化Jwt配置模型
        return JwtSettings()

    @staticmethod
    @lru_cache
    def get_database_config():
        """
        获取数据库配置
        """
        # 实例化数据库配置模型
        return DataBaseSettings()

    @staticmethod
    @lru_cache
    def get_redis_config():
        """
        获取Redis配置
        """
        # 实例化Redis配置模型
        return RedisSettings()

    @staticmethod
    @lru_cache
    def get_gen_config():
        """
        获取代码生成配置
        """
        # 实例化代码生成配置
        return GenSettings()

    @staticmethod
    @lru_cache
    def get_upload_config():
        """
        获取数据库配置
        """
        # 实例上传配置
        return UploadSettings()

    @staticmethod
    def parse_cli_args():
        """
        解析命令行参数
        """
        if 'uvicorn' in sys.argv[0]:
            # 使用uvicorn启动时，命令行参数需要按照uvicorn的文档进行配置，无法自定义参数
            pass
        else:
            # 使用argparse定义命令行参数
            parser = argparse.ArgumentParser(description='命令行参数')
            parser.add_argument('--env', type=str, default='', help='运行环境')
            # 解析命令行参数
            args = parser.parse_args()
            # 设置环境变量，如果未设置命令行参数，默认APP_ENV为dev
            os.environ['APP_ENV'] = args.env if args.env else 'dev'
        # 读取运行环境
        run_env = os.environ.get('APP_ENV', '')
        # 运行环境未指定时默认加载.env.dev
        env_file = '.env.dev'
        # 运行环境不为空时按命令行参数加载对应.env文件
        if run_env != '':
            env_file = f'.env.{run_env}'
        # 加载配置
        load_dotenv(env_file)


# 实例化获取配置类
get_config = GetConfig()
# 应用配置
AppConfig = get_config.get_app_config()
# Jwt配置
JwtConfig = get_config.get_jwt_config()
# 数据库配置
DataBaseConfig = get_config.get_database_config()
# Redis配置
RedisConfig = get_config.get_redis_config()
# 代码生成配置
GenConfig = get_config.get_gen_config()
# 上传配置
UploadConfig = get_config.get_upload_config()
