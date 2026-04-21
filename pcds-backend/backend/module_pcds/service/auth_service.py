import os
import random
import string
from datetime import datetime, timedelta
from typing import Optional

import jwt
from passlib.context import CryptContext
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from config.env import JwtConfig
from module_pcds.entity.do.user_do import PcdsUser
from module_pcds.entity.vo.auth_vo import RegisterRequest, LoginRequest, TokenResponse
from utils.log_util import logger

pwd_context = CryptContext(schemes=['bcrypt'], deprecated='auto')

# 内存OTP存储（生产环境应使用Redis）
_otp_store: dict[str, tuple[str, datetime]] = {}


class PcdsAuthService:

    @staticmethod
    def hash_password(password: str) -> str:
        return pwd_context.hash(password)

    @staticmethod
    def verify_password(plain: str, hashed: str) -> bool:
        return pwd_context.verify(plain, hashed)

    @staticmethod
    def create_token(user_id: int, email: str) -> str:
        expire = datetime.utcnow() + timedelta(minutes=JwtConfig.jwt_expire_minutes)
        payload = {'user_id': user_id, 'email': email, 'exp': expire}
        return jwt.encode(payload, JwtConfig.jwt_secret_key, algorithm=JwtConfig.jwt_algorithm)

    @staticmethod
    def decode_token(token: str) -> Optional[dict]:
        try:
            return jwt.decode(token, JwtConfig.jwt_secret_key, algorithms=[JwtConfig.jwt_algorithm])
        except jwt.ExpiredSignatureError:
            raise ValueError('Token已过期')
        except jwt.InvalidTokenError:
            raise ValueError('Token无效')

    @staticmethod
    async def register(db: AsyncSession, req: RegisterRequest) -> TokenResponse:
        # 检查邮箱是否已注册
        result = await db.execute(select(PcdsUser).where(PcdsUser.email == req.email, PcdsUser.deleted_at.is_(None)))
        existing = result.scalar_one_or_none()
        if existing:
            raise ValueError('该邮箱已被注册')

        user = PcdsUser(
            email=req.email,
            password_hash=PcdsAuthService.hash_password(req.password),
            nickname=req.nickname or req.email.split('@')[0],
        )
        db.add(user)
        await db.commit()
        await db.refresh(user)

        token = PcdsAuthService.create_token(user.user_id, user.email)
        return TokenResponse(
            token=token,
            user_id=user.user_id,
            email=user.email,
            nickname=user.nickname or '',
            avatar_url=user.avatar_url or '',
        )

    @staticmethod
    async def login(db: AsyncSession, req: LoginRequest) -> TokenResponse:
        result = await db.execute(select(PcdsUser).where(PcdsUser.email == req.email, PcdsUser.deleted_at.is_(None)))
        user = result.scalar_one_or_none()
        if not user or not PcdsAuthService.verify_password(req.password, user.password_hash):
            raise ValueError('邮箱或密码错误')
        if user.status == '1':
            raise ValueError('账号已被停用')

        token = PcdsAuthService.create_token(user.user_id, user.email)
        return TokenResponse(
            token=token,
            user_id=user.user_id,
            email=user.email,
            nickname=user.nickname or '',
            avatar_url=user.avatar_url or '',
        )

    @staticmethod
    async def send_otp(email: str) -> None:
        """发送OTP验证码（6位数字）"""
        code = ''.join(random.choices(string.digits, k=6))
        expire = datetime.now() + timedelta(minutes=10)
        _otp_store[email] = (code, expire)
        logger.info(f'[OTP] 验证码已生成 email={email} code={code}（开发模式直接打印）')
        # TODO: 生产环境接入邮件服务发送验证码
        # await send_email(email, f'您的验证码是：{code}，10分钟内有效')

    @staticmethod
    async def verify_otp(db: AsyncSession, email: str, code: str) -> TokenResponse:
        """验证OTP并登录/注册"""
        stored = _otp_store.get(email)
        if not stored:
            raise ValueError('验证码不存在或已过期，请重新获取')
        stored_code, expire = stored
        if datetime.now() > expire:
            del _otp_store[email]
            raise ValueError('验证码已过期，请重新获取')
        if stored_code != code:
            raise ValueError('验证码错误')

        del _otp_store[email]

        # 查找或创建用户
        result = await db.execute(select(PcdsUser).where(PcdsUser.email == email, PcdsUser.deleted_at.is_(None)))
        user = result.scalar_one_or_none()
        if not user:
            # 邮箱登录自动注册
            user = PcdsUser(
                email=email,
                password_hash=PcdsAuthService.hash_password(''),
                nickname=email.split('@')[0],
            )
            db.add(user)
            await db.commit()
            await db.refresh(user)

        token = PcdsAuthService.create_token(user.user_id, user.email)
        return TokenResponse(
            token=token,
            user_id=user.user_id,
            email=user.email,
            nickname=user.nickname or '',
            avatar_url=user.avatar_url or '',
        )

    @staticmethod
    async def change_password(db: AsyncSession, user_id: int, old_password: str, new_password: str) -> None:
        result = await db.execute(select(PcdsUser).where(PcdsUser.user_id == user_id))
        user = result.scalar_one_or_none()
        if not user:
            raise ValueError('用户不存在')
        if not PcdsAuthService.verify_password(old_password, user.password_hash):
            raise ValueError('原密码错误')
        user.password_hash = PcdsAuthService.hash_password(new_password)
        await db.commit()

    @staticmethod
    async def get_user_by_token(db: AsyncSession, token: str) -> PcdsUser:
        payload = PcdsAuthService.decode_token(token)
        user_id = payload.get('user_id')
        result = await db.execute(select(PcdsUser).where(PcdsUser.user_id == user_id, PcdsUser.deleted_at.is_(None)))
        user = result.scalar_one_or_none()
        if not user:
            raise ValueError('用户不存在')
        return user
