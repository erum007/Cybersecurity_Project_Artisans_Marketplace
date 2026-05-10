from pydantic import BaseModel, Field

from app.models.common import MongoBaseModel, TimestampedModel


class ProductCreate(BaseModel):
    name: str
    description: str
    price: float = Field(ge=0)
    stock: int = Field(ge=0)
    category: str
    image_url: str | None = None


class ProductUpdate(BaseModel):
    name: str | None = None
    description: str | None = None
    price: float | None = Field(default=None, ge=0)
    stock: int | None = Field(default=None, ge=0)
    category: str | None = None
    image_url: str | None = None
    is_active: bool | None = None


class ProductInDB(MongoBaseModel, TimestampedModel):
    artisan_id: str
    artisan_name: str
    name: str
    description: str
    price: float
    stock: int
    category: str
    image_url: str | None = None
    is_active: bool = True


class ProductPublic(ProductInDB):
    pass


class ProductListResponse(BaseModel):
    items: list[ProductPublic]
    total: int
