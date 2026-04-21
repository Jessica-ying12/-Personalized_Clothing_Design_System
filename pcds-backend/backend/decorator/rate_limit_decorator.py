# rate_limit_decorator.py
from collections.abc import Callable
from functools import wraps

from fastapi import HTTPException

from decorator.rate_limiter import rate_limiter
from utils.ip_util import get_ip_addr


def rate_limit(max_requests: int = 10, window: int = 60, identifier_extractor: Callable | None = None):
    """
    限流装饰器

    :param max_requests: 时间窗口内最大请求数
    :param window: 时间窗口（秒）
    :param identifier_extractor: 标识符提取函数，默认使用客户端IP
    """

    def decorator(func):
        @wraps(func)
        async def wrapper(*args, **kwargs):
            # 获取request对象
            request = None
            for arg in args:
                if hasattr(arg, '__class__') and 'Request' in str(arg.__class__):
                    request = arg
                    break

            if request is None:
                for value in kwargs.values():
                    if hasattr(value, '__class__') and 'Request' in str(value.__class__):
                        request = value
                        break

            if request is None:
                raise HTTPException(status_code=500, detail='无法获取请求对象')

            # 获取标识符
            identifier = identifier_extractor(request) if identifier_extractor else get_ip_addr(request)

            # 检查是否允许请求
            if not rate_limiter.is_allowed(identifier, max_requests, window):
                raise HTTPException(status_code=429, detail='请求过于频繁，请稍后重试')

            return await func(*args, **kwargs)

        return wrapper

    return decorator
