class LoginError(Exception):
    """
    自定义登录异常LoginError
    """

    def __init__(self, data: str | None = None, message: str | None = None):
        self.data = data
        self.message = message


class AuthError(Exception):
    """
    自定义令牌异常AuthError
    """

    def __init__(self, data: str | None = None, message: str | None = None):
        self.data = data
        self.message = message


class PermissionError(Exception):
    """
    自定义权限异常PermissionError
    """

    def __init__(self, data: str | None = None, message: str | None = None):
        self.data = data
        self.message = message


class ServiceError(Exception):
    """
    自定义服务异常ServiceError
    """

    def __init__(self, data: str | None = None, message: str | None = None):
        self.data = data
        self.message = message


class ServiceWarningErrorError(Exception):
    """
    自定义服务警告ServiceWarningErrorError
    """

    def __init__(self, data: str | None = None, message: str | None = None):
        self.data = data
        self.message = message


class ModelValidatorError(Exception):
    """
    自定义模型校验异常ModelValidatorError
    """

    def __init__(self, data: str | None = None, message: str | None = None):
        self.data = data
        self.message = message
