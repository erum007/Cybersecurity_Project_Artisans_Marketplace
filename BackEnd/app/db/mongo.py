from pymongo import MongoClient
from pymongo.database import Database

from app.core.config import settings

_client: MongoClient | None = None


def get_client() -> MongoClient:
    global _client
    if _client is None:
        _client = MongoClient(settings.mongo_uri)
    return _client


def ensure_session_indexes(db: Database) -> None:
    db.sessions.create_index("refresh_token_hash", unique=True)
    db.sessions.create_index("user_id")
    db.sessions.create_index([("user_id", 1), ("revoked", 1)])
    db.sessions.create_index("expires_at", expireAfterSeconds=0)


def get_db() -> Database:
    db = get_client()[settings.mongo_db]
    # Ensure indexes for performance
    db.products.create_index([("name", "text"), ("description", "text")])
    db.products.create_index("category")
    db.products.create_index("is_active")
    ensure_session_indexes(db)
    return db
