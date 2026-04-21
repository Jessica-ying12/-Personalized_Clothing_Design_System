from datetime import datetime

from sqlalchemy import BigInteger, Column, DateTime, String, Text

from config.database import Base


class PcdsUser(Base):
    """个性化服装设计系统 - 用户表"""

    __tablename__ = 'pcds_user'

    user_id = Column(BigInteger, primary_key=True, autoincrement=True, comment='用户ID')
    email = Column(String(100), nullable=False, unique=True, comment='邮箱（登录账号）')
    password_hash = Column(String(255), nullable=False, comment='密码哈希')
    nickname = Column(String(50), default='', comment='昵称')
    avatar_url = Column(String(500), default='', comment='头像URL')
    status = Column(String(1), default='0', comment='状态 0正常 1停用')
    created_at = Column(DateTime, default=lambda: datetime.now(), comment='创建时间')
    updated_at = Column(DateTime, default=lambda: datetime.now(), onupdate=lambda: datetime.now(), comment='更新时间')
    deleted_at = Column(DateTime, nullable=True, comment='删除时间（软删除）')
