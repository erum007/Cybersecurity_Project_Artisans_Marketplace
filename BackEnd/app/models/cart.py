from pydantic import BaseModel, Field


class CartItemIn(BaseModel):
    product_id: str
    quantity: int = Field(ge=1, default=1)


class CartUpdate(BaseModel):
    quantity: int = Field(ge=1)


class CartItemOut(BaseModel):
    product_id: str
    name: str
    price: float
    quantity: int
    line_total: float


class CartResponse(BaseModel):
    items: list[CartItemOut]
    total: float
