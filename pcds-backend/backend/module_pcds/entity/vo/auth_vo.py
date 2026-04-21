from typing import Optional
from pydantic import BaseModel, EmailStr


class RegisterRequest(BaseModel):
    email: str
    password: str
    nickname: Optional[str] = None


class LoginRequest(BaseModel):
    email: str
    password: str


class SendOtpRequest(BaseModel):
    email: str


class VerifyOtpRequest(BaseModel):
    email: str
    code: str


class ChangePasswordRequest(BaseModel):
    old_password: str
    new_password: str


class ResetPasswordRequest(BaseModel):
    email: str
    code: str
    new_password: str


class TokenResponse(BaseModel):
    token: str
    user_id: int
    email: str
    nickname: str
    avatar_url: str
