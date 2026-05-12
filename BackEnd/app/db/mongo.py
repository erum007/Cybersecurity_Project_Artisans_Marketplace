# from pymongo import MongoClient
# from pymongo.database import Database

# from app.core.config import settings

# _client: MongoClient | None = None


# def get_client() -> MongoClient:
#     global _client
#     if _client is None:
#         _client = MongoClient(settings.mongo_uri)
#     return _client


# def get_db() -> Database:
#     db = get_client()[settings.mongo_db]
#     # Ensure indexes for performance
#     db.products.create_index([("name", "text"), ("description", "text")])
#     db.products.create_index("category")
#     db.products.create_index("is_active")
#     return db


from pymongo import MongoClient, TEXT
from pymongo.database import Database
from app.core.config import settings

_client: MongoClient | None = None

def get_client() -> MongoClient:
    global _client
    if _client is None:
        # settings.mongo_uri must be "mongodb://db:27017/"
        _client = MongoClient(settings.mongo_uri, serverSelectionTimeoutMS=5000) 
    return _client

def get_db() -> Database:
    client = get_client()
    db = client[settings.mongo_db]
    
    # Optional: Move index creation to a separate startup script 
    # or wrap it in a try/except to prevent the "Internal Server Error" 
    # if the DB is momentarily unreachable.
    try:
        # use list_indexes to check if they exist, or just let pymongo handle it
        # but consider moving these to an 'on_startup' event in FastAPI
        db.products.create_index([("name", TEXT), ("description", TEXT)])
        db.products.create_index("category")
        db.products.create_index("is_active")
    except Exception as e:
        print(f"Index creation warning: {e}")
        
    return db