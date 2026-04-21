from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel


class DesignOptionVO(BaseModel):
    id: str
    category: str
    name: str
    name_en: str
    parent_id: Optional[str] = None
    sort_order: int = 0

    class Config:
        from_attributes = True


class FlatDesignGenerateRequest(BaseModel):
    clothing_type_code: str
    pattern_code: str
    material_code: str
    style_code: str
    audience_code: str
    ai_model_code: str
    color_code: Optional[str] = None
    params: Optional[dict] = None


class FlatDesignVO(BaseModel):
    id: str
    user_id: int
    clothing_type_code: str
    pattern_code: str
    material_code: str
    style_code: str
    audience_code: str
    color_code: Optional[str] = None
    ai_model_code: str
    image_url: str
    status: str
    is_saved: bool
    regen_count: int
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class Design3dGenerateRequest(BaseModel):
    flat_design_id: str
    body_type_code: str
    skin_tone_code: str
    gender_code: str
    background_code: str
    ai_model_code: str


class Design3dVO(BaseModel):
    id: str
    user_id: int
    flat_design_id: str
    body_type_code: str
    skin_tone_code: str
    gender_code: str
    background_code: str
    ai_model_code: str
    image_url: str
    status: str
    is_saved: bool
    regen_count: int
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class ChangeBackgroundRequest(BaseModel):
    design_id: str
    background_code: str


class BatchIdsRequest(BaseModel):
    ids: List[str]


class PageListResponse(BaseModel):
    data: list
    total: int
    page: int
    page_size: int
