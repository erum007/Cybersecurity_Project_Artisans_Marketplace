from pydantic_settings import BaseSettings, SettingsConfigDict
import os

class Settings(BaseSettings):
    app_name: str = "Artisans Marketplace API"
    api_prefix: str = "/api/v1"
    mongo_uri: str = os.getenv("DATABASE_URL", "mongodb://db:27017/")
    mongo_db: str = os.getenv("MONGO_DB", "artisan-marketplace")
    jwt_secret: str = "change-me-in-production"
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 40
    cors_origins: list[str] = ["*"]

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")


settings = Settings()

