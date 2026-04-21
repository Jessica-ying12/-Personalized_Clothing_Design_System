from datetime import datetime

from sqlalchemy import BigInteger, Column, DateTime, Integer, String, Text, SmallInteger

from config.database import Base


class PcdsDesign3d(Base):
    """立体设计表"""

    __tablename__ = 'pcds_3d_design'

    design_id = Column(BigInteger, primary_key=True, autoincrement=True, comment='设计ID')
    user_id = Column(BigInteger, nullable=False, comment='用户ID')
    flat_design_id = Column(BigInteger, nullable=False, comment='关联平面设计ID')
    body_type_code = Column(String(50), nullable=False, comment='身体三维代码')
    skin_tone_code = Column(String(50), nullable=False, comment='肤色代码')
    gender_code = Column(String(50), nullable=False, comment='性别代码')
    background_code = Column(String(50), nullable=False, comment='背景代码')
    ai_model_code = Column(String(50), nullable=False, comment='AI模型代码')
    image_url = Column(String(500), nullable=False, comment='生成图片URL')
    prompt = Column(Text, nullable=True, comment='AI提示词')
    status = Column(String(20), default='done', comment='状态 pending/processing/done/failed')
    is_saved = Column(SmallInteger, default=1, comment='是否保存 0否 1是')
    regen_count = Column(Integer, default=0, comment='重新生成次数')
    created_at = Column(DateTime, default=lambda: datetime.now(), comment='创建时间')
    updated_at = Column(DateTime, default=lambda: datetime.now(), onupdate=lambda: datetime.now(), comment='更新时间')
