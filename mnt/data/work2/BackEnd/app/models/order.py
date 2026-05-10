from datetime import datetime
from pydantic import BaseModel, Field

from app.models.common import MongoBaseModel, TimestampedModel


class CheckoutRequest(BaseModel):
    payment_method: str = Field(pattern="^(cod|card)$")
    shipping_address: str


class OrderItem(BaseModel):
    product_id: str
    name: str
    artisan_id: str
    quantity: int
    price: float
    line_total: float


class OrderInDB(MongoBaseModel, TimestampedModel):
    customer_id: str
    customer_name: str
    items: list[OrderItem]
    total_amount: float
    payment_method: str
    shipping_address: str
    status: str = "pending"
    placed_at: datetime


class OrderPublic(OrderInDB):
    pass


class OrderStatusUpdate(BaseModel):
    status: str = Field(pattern="^(pending|processing|completed|cancelled)$")
