# config/custom_decorators.py
import functools
from collections.abc import Callable

# 存储所有标记的方法
app_init_methods: list[Callable] = []

app_shutdown_methods: list[Callable] = []


def custom_app_init_call(func: Callable) -> Callable:
    app_init_methods.append(func)

    @functools.wraps(func)
    async def wrapper(*args, **kwargs):
        return await func(*args, **kwargs)

    return wrapper


def custom_app_shutdown_call(func: Callable) -> Callable:
    app_shutdown_methods.append(func)

    @functools.wraps(func)
    async def wrapper(*args, **kwargs):
        return await func(*args, **kwargs)

    return wrapper
