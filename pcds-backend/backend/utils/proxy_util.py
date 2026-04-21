import os
from functools import wraps


def with_proxy(
    proxy_enable: bool = True,
    proxy_https: str | None = None,
    proxy_http: str | None = None,
    no_proxy: str | None = None,
):
    """
    为函数临时设置代理环境变量的装饰器

    Args:
        proxy_enable: 是否启用代理
        proxy_https: HTTPS代理地址
        proxy_http: HTTP代理地址
        no_proxy: 不使用代理的地址列表

    Returns:
        装饰器函数

    Usage:
        from utils.proxy_util import with_proxy

        @with_proxy(
            proxy_enable=True,
            proxy_https='http://192.168.11.42:5081',
            proxy_http='http://192.168.11.42:5081',
            no_proxy='localhost,127.0.0.1,*.local'
        )
        def send_request():
            # 这里的请求会使用代理
            pass
    """

    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            # 如果未启用代理，直接执行函数
            if not proxy_enable:
                return func(*args, **kwargs)

            # 保存原始环境变量
            old_https_proxy = os.environ.get('HTTPS_PROXY')
            old_http_proxy = os.environ.get('HTTP_PROXY')
            old_no_proxy = os.environ.get('NO_PROXY')

            try:
                # 临时设置代理
                if proxy_https:
                    os.environ['HTTPS_PROXY'] = proxy_https
                if proxy_http:
                    os.environ['HTTP_PROXY'] = proxy_http
                if no_proxy:
                    os.environ['NO_PROXY'] = no_proxy

                # 执行原函数
                return func(*args, **kwargs)
            finally:
                # 恢复原始环境变量
                if old_https_proxy is None:
                    os.environ.pop('HTTPS_PROXY', None)
                else:
                    os.environ['HTTPS_PROXY'] = old_https_proxy

                if old_http_proxy is None:
                    os.environ.pop('HTTP_PROXY', None)
                else:
                    os.environ['HTTP_PROXY'] = old_http_proxy

                if old_no_proxy is None:
                    os.environ.pop('NO_PROXY', None)
                else:
                    os.environ['NO_PROXY'] = old_no_proxy

        return wrapper

    return decorator
