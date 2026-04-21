from datetime import datetime

from sqlalchemy import BigInteger, Column, DateTime, Integer, String

from config.database import Base


class PcdsDesignOption(Base):
    """设计选项表"""

    __tablename__ = 'pcds_design_option'

    option_id = Column(BigInteger, primary_key=True, autoincrement=True, comment='选项ID')
    category = Column(String(50), nullable=False, comment='类别：clothing_type/pattern/material/style/audience/ai_model/body_type/skin_tone/gender/background/color')
    option_code = Column(String(50), nullable=False, comment='选项代码')
    name_zh = Column(String(100), nullable=False, comment='中文名称')
    name_en = Column(String(100), nullable=False, comment='英文名称')
    parent_id = Column(BigInteger, nullable=True, comment='父级ID')
    sort_order = Column(Integer, default=0, comment='排序')
    status = Column(String(1), default='0', comment='状态 0正常 1停用')
    created_at = Column(DateTime, default=lambda: datetime.now(), comment='创建时间')
