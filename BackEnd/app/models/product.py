from datetime import datetime
from pydantic import BaseModel, Field

from app.models.common import MongoBaseModel, TimestampedModel


class ProductCreate(BaseModel):
    name: str
    description: str
    price: float = Field(ge=0)
    stock: int = Field(ge=0)
    category: str
    image_urls: list[str] = Field(default_factory=list)


class ProductUpdate(BaseModel):
    name: str | None = None
    description: str | None = None
    price: float | None = Field(default=None, ge=0)
    stock: int | None = Field(default=None, ge=0)
    category: str | None = None
    image_urls: list[str] | None = None
    is_active: bool | None = None


class ReviewCreate(BaseModel):
    rating: float = Field(ge=1, le=5)
    comment: str

class ReviewPublic(BaseModel):
    user_id: str
    user_name: str
    rating: float
    comment: str
    created_at: datetime


class ProductInDB(MongoBaseModel, TimestampedModel):
    artisan_id: str
    artisan_name: str
    name: str
    description: str
    price: float
    stock: int
    category: str
    image_urls: list[str] = Field(default_factory=list)
    reviews: list[ReviewPublic] = Field(default_factory=list)
    rating: float = 0.0
    review_count: int = 0
    is_active: bool = True


class ProductPublic(ProductInDB):
    pass


class ProductListResponse(BaseModel):
    items: list[ProductPublic]
    total: int
