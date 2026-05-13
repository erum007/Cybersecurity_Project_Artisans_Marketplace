from pydantic_settings import BaseSettings, SettingsConfigDict
from pydantic import field_validator, model_validator

import os

class Settings(BaseSettings):
    app_name: str = "Artisans Marketplace API"
    api_prefix: str = "/api/v1"
    # mongo_uri: str = "mongodb://localhost:27017"
    # mongo_db: str = "artisan-marketplace"
    jwt_secret: str
    mongo_uri: str = os.getenv("DATABASE_URL", "mongodb://db:27017/")
    mongo_db: str = os.getenv("MONGO_DB", "artisan-marketplace")
    jwt_secret: str = "change-me-in-production"
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 40
    refresh_token_expire_days: int = 7
    refresh_token_secret: str
    cors_origins: list[str] = []

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    @field_validator("cors_origins", mode="before")
    def split_cors_origins(cls, value):
        if isinstance(value, str):
            return [origin.strip() for origin in value.split(",") if origin.strip()]
        return value

    @model_validator(mode="after")
    def validate_settings(self):
        if not self.jwt_secret.strip():
            raise ValueError("JWT_SECRET must be set in environment and cannot be empty")

        if len(self.jwt_secret.strip()) < 32:
            raise ValueError("JWT_SECRET must be at least 32 characters long")

        if not self.refresh_token_secret.strip():
            raise ValueError("REFRESH_TOKEN_SECRET must be set in environment and cannot be empty")

        if len(self.refresh_token_secret.strip()) < 32:
            raise ValueError("REFRESH_TOKEN_SECRET must be at least 32 characters long")

        if not self.cors_origins:
            raise ValueError("CORS_ORIGINS must be set to one or more trusted origins")

        if any(origin.strip() == "" for origin in self.cors_origins):
            raise ValueError("CORS_ORIGINS must not contain empty values")

        if "*" in self.cors_origins:
            raise ValueError("Wildcard CORS origins are not allowed in production")

        return self


settings = Settings()

