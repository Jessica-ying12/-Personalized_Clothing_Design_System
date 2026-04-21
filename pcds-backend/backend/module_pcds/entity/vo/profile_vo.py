from typing import Optional
from pydantic import BaseModel


class UserProfileVO(BaseModel):
    user_id: int
    email: str
    nickname: str
    avatar_url: str

    class Config:
        from_attributes = True


class UpdateProfileRequest(BaseModel):
    nickname: Optional[str] = None
    avatar_url: Optional[str] = None


class UserStatsVO(BaseModel):
    flat_total: int = 0
    flat_saved: int = 0
    design_3d_total: int = 0
    design_3d_saved: int = 0
