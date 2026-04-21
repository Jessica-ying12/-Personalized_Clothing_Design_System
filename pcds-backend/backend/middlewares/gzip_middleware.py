from fastapi import FastAPI
from starlette.datastructures import Headers
from starlette.middleware.gzip import GZipResponder
from starlette.types import ASGIApp, Receive, Scope, Send


class CustomGZipMiddleware:
    def __init__(self, app: ASGIApp, minimum_size: int = 500, compresslevel: int = 9) -> None:
        self.app = app
        self.minimum_size = minimum_size
        self.compresslevel = compresslevel

    async def __call__(self, scope: Scope, receive: Receive, send: Send) -> None:
        if scope['type'] == 'http':  # pragma: no branch
            headers = Headers(scope=scope)
            accept = headers.get('Accept', '')
            accept_encoding = headers.get('Accept-Encoding', '')

            # 检查是否是sse请求
            if 'text/event-stream' in accept:
                await self.app(scope, receive, send)
                return

            # 检查是否支持 gzip 压缩
            if 'gzip' in accept_encoding:
                responder = GZipResponder(self.app, self.minimum_size, compresslevel=self.compresslevel)
                await responder(scope, receive, send)
                return

        await self.app(scope, receive, send)


def add_gzip_middleware(app: FastAPI):
    """
    添加gzip压缩中间件

    :param app: FastAPI对象
    :return:
    """
    app.add_middleware(CustomGZipMiddleware, minimum_size=1000, compresslevel=9)
