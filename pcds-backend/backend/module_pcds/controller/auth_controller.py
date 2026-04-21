from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from config.get_db import get_db
from module_pcds.controller.deps import get_current_user
from module_pcds.entity.do.user_do import PcdsUser
from module_pcds.entity.vo.auth_vo import (
    RegisterRequest, LoginRequest, SendOtpRequest,
    VerifyOtpRequest, ChangePasswordRequest, TokenResponse,
)
from module_pcds.service.auth_service import PcdsAuthService
from utils.response_util import ResponseUtil

auth_controller = APIRouter(prefix='/api/auth')


@auth_controller.post('/register', summary='注册')
async def register(req: RegisterRequest, db: AsyncSession = Depends(get_db)):
    try:
        result = await PcdsAuthService.register(db, req)
        return ResponseUtil.success(data=result.model_dump(), msg='注册成功')
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@auth_controller.post('/login', summary='账号密码登录')
async def login(req: LoginRequest, db: AsyncSession = Depends(get_db)):
    try:
        result = await PcdsAuthService.login(db, req)
        return ResponseUtil.success(data=result.model_dump(), msg='登录成功')
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=str(e))


@auth_controller.post('/send-otp', summary='发送邮箱验证码')
async def send_otp(req: SendOtpRequest):
    await PcdsAuthService.send_otp(req.email)
    return ResponseUtil.success(msg='验证码已发送，请查收邮件（开发模式：查看后端日志）')


@auth_controller.post('/verify-otp', summary='验证邮箱验证码登录')
async def verify_otp(req: VerifyOtpRequest, db: AsyncSession = Depends(get_db)):
    try:
        result = await PcdsAuthService.verify_otp(db, req.email, req.code)
        return ResponseUtil.success(data=result.model_dump(), msg='登录成功')
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@auth_controller.post('/logout', summary='登出')
async def logout(current_user: PcdsUser = Depends(get_current_user)):
    return ResponseUtil.success(msg='退出成功')


@auth_controller.post('/change-password', summary='修改密码')
async def change_password(
    req: ChangePasswordRequest,
    current_user: PcdsUser = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    try:
        await PcdsAuthService.change_password(db, current_user.user_id, req.old_password, req.new_password)
        return ResponseUtil.success(msg='密码修改成功')
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
