from pymongo import MongoClient
from pymongo.database import Database

from app.core.config import settings

_client: MongoClient | None = None


def get_client() -> MongoClient:
    global _client
    if _client is None:
        _client = MongoClient(settings.mongo_uri)
    return _client


def get_db() -> Database:
    db = get_client()[settings.mongo_db]
    # Ensure indexes for performance
    db.products.create_index([("name", "text"), ("description", "text")])
    db.products.create_index("category")
    db.products.create_index("is_active")
    return db
