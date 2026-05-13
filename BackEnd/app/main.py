from pathlib import Path
import os
import json
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from app.core.config import settings
from app.routes import admin, auth, cart, orders, products, uploads

app = FastAPI()
raw_origins = os.getenv("CORS_ORIGINS", '["https://artisan.marketplace"]')

try:
    origins = json.loads(raw_origins)
except json.JSONDecodeError:
    # Fallback to a safe default if env variable is malformed
    origins = ["https://artisan.marketplace"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# @app.get("/")
# async def root():
#     return {"message": "Artisans Marketplace API is Secure and Running"}

@app.get("/")
def healthcheck():
    return {"status": "ok", "app": settings.app_name}

Path("uploads").mkdir(parents=True, exist_ok=True)
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

app.include_router(auth.router, prefix=settings.api_prefix)
app.include_router(products.router, prefix=settings.api_prefix)
app.include_router(cart.router, prefix=settings.api_prefix)
app.include_router(orders.router, prefix=settings.api_prefix)
app.include_router(admin.router, prefix=settings.api_prefix)
app.include_router(uploads.router, prefix=settings.api_prefix)