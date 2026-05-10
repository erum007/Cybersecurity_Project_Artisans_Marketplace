from pydantic import BaseModel, EmailStr, Field

from app.models.common import MongoBaseModel, TimestampedModel


class UserCreate(BaseModel):
    full_name: str
    email: EmailStr
    password: str = Field(min_length=8)
    role: str = Field(pattern="^(customer|artisan|admin)$")
    phone: str | None = None
    address: str | None = None
    city: str | None = None


class UserUpdate(BaseModel):
    full_name: str | None = None
    email: EmailStr | None = None
    password: str | None = Field(None, min_length=8)
    phone: str | None = None
    address: str | None = None
    city: str | None = None
    postal_code: str | None = None
    bio: str | None = None
    profile_picture: str | None = None


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class UserInDB(MongoBaseModel, TimestampedModel):
    full_name: str
    email: EmailStr
    password_hash: str
    role: str
    phone: str | None = None
    address: str | None = None
    city: str | None = None
    postal_code: str | None = None
    bio: str | None = None
    profile_picture: str | None = None
    is_active: bool = True


class UserPublic(MongoBaseModel):
    full_name: str
    email: EmailStr
    role: str
    phone: str | None = None
    address: str | None = None
    city: str | None = None
    postal_code: str | None = None
    bio: str | None = None
    profile_picture: str | None = None
    is_active: bool = True


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserPublic
