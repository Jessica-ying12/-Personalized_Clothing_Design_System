"""认证依赖注入"""
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.ext.asyncio import AsyncSession

from config.get_db import get_db
from module_pcds.entity.do.user_do import PcdsUser
from module_pcds.service.auth_service import PcdsAuthService

bearer_scheme = HTTPBearer()


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(bearer_scheme),
    db: AsyncSession = Depends(get_db),
) -> PcdsUser:
    try:
        user = await PcdsAuthService.get_user_by_token(db, credentials.credentials)
        return user
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=str(e))
