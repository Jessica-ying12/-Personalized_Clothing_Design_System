from fastapi import FastAPI, Request
from fastapi.exceptions import HTTPException
from pydantic_validation_decorator import FieldValidationError

from exceptions.exception import (
    AuthError,
    LoginError,
    ModelValidatorError,
    PermissionError,
    ServiceError,
    ServiceWarningErrorError,
)
from module_jftech.utils.exception import JftechLoginError
from utils.log_util import logger
from utils.response_util import JSONResponse, ResponseUtil, jsonable_encoder


def handle_exception(app: FastAPI):
    """
    全局异常处理
    """

    # 自定义token检验异常
    @app.exception_handler(AuthError)
    async def auth_exception_handler(request: Request, exc: AuthError):
        return ResponseUtil.unauthorized(data=exc.data, msg=exc.message or '认证失败')

    # 自定义登录检验异常
    @app.exception_handler(LoginError)
    async def login_exception_handler(request: Request, exc: LoginError):
        return ResponseUtil.failure(data=exc.data, msg=exc.message or '登录异常')

    # 自定义模型检验异常
    @app.exception_handler(ModelValidatorError)
    async def model_validator_exception_handler(request: Request, exc: ModelValidatorError):
        logger.warning(exc.message)
        return ResponseUtil.failure(data=exc.data, msg=exc.message or '参数校验失败')

    # 自定义字段检验异常
    @app.exception_handler(FieldValidationError)
    async def field_validation_error_handler(request: Request, exc: FieldValidationError):
        logger.warning(exc.message)
        return ResponseUtil.failure(msg=exc.message)

    # 自定义权限检验异常
    @app.exception_handler(PermissionError)
    async def permission_exception_handler(request: Request, exc: PermissionError):
        return ResponseUtil.forbidden(data=exc.data, msg=exc.message or '权限不足')

    # 自定义服务异常
    @app.exception_handler(ServiceError)
    async def service_exception_handler(request: Request, exc: ServiceError):
        logger.error(exc.message)
        return ResponseUtil.error(data=exc.data, msg=exc.message or '服务异常')

    # 自定义服务警告
    @app.exception_handler(ServiceWarningErrorError)
    async def service_warning_handler(request: Request, exc: ServiceWarningErrorError):
        logger.warning(exc.message)
        return ResponseUtil.failure(data=exc.data, msg=exc.message or '服务警告')

    # 处理其他http请求异常
    @app.exception_handler(HTTPException)
    async def http_exception_handler(request: Request, exc: HTTPException):
        return JSONResponse(
            content=jsonable_encoder({'code': exc.status_code, 'msg': exc.detail}), status_code=exc.status_code
        )

    # 处理其他异常
    @app.exception_handler(Exception)
    async def exception_handler(request: Request, exc: Exception):
        logger.exception(exc)
        return ResponseUtil.error(msg=str(exc))

    # 自定义服务异常
    @app.exception_handler(JftechLoginError)
    async def jftech_login_exception_handler(request: Request, exc: JftechLoginError):
        logger.error(exc.message)
        return ResponseUtil.error(data=exc.data, msg=exc.message or '登录异常')
