# import pymongo

# def initialize_marketplace_db(client, db):
#     # 1. Connect to local MongoDB instance
    
    

#     # 3. List of collections to ensure exist
#     required_collections = [
#         "users", 
#         "products", 
#         "orders", 
#         "carts", 
#     ]

#     # 4. Get current collections to avoid re-defining
#     current_collections = db.list_collection_names()

#     for col_name in required_collections:
#         if col_name in current_collections:
#             print(f"✔️  Collection '{col_name}' already exists. Skipping.")
#         else:
#             # Create the collection safely
#             # We use a placeholder insert/delete to force physical creation
#             temp_doc = db[col_name].insert_one({"init": True})
#             db[col_name].delete_one({"_id": temp_doc.inserted_id})
#             print(f"✅ Created new collection: {col_name}")

#     print("\nInitialization check complete.")

# def apply_marketplace_schemas(db):
#     """Applies strict 'attribute' rules to the SE-Marketplace collections."""
    
#     # Define the rules for each collection
#     schemas = {
#         "Artisans": {
#             "required": ["name", "location", "is_verified"],
#             "properties": {
#                 "name": {"bsonType": "string"},
#                 "bio": {"bsonType": "string"},
#                 "location": {"bsonType": "string"},
#                 "is_verified": {"bsonType": "bool"}
#             }
#         },
#         "Products": {
#             "required": ["name", "price", "stock", "category_id"],
#             "properties": {
#                 "name": {"bsonType": "string"},
#                 "price": {"bsonType": "double", "minimum": 0},
#                 "stock": {"bsonType": "int", "minimum": 0},
#                 "category_id": {"bsonType": "objectId"},
#                 "artisan_id": {"bsonType": "objectId"}
#             }
#         },
#         "Users": {
#             "required": ["username", "email", "password_hash"],
#             "properties": {
#                 "username": {"bsonType": "string"},
#                 "email": {"bsonType": "string", "pattern": "^.+@.+$"},
#                 "password_hash": {"bsonType": "string"}
#             }
#         },
#         "Orders": {
#             "required": ["user_id", "total_amount", "status"],
#             "properties": {
#                 "user_id": {"bsonType": "objectId"},
#                 "total_amount": {"bsonType": "double"},
#                 "status": {"enum": ["Processing", "Shipped", "Delivered"]}
#             }
#         }
#     }

#     for coll_name, schema_details in schemas.items():
#         validator = {
#             "$jsonSchema": {
#                 "bsonType": "object",
#                 "required": schema_details["required"],
#                 "properties": schema_details["properties"]
#             }
#         }
        
#         try:
#             # Apply the validator to the collection
#             db.command("collMod", coll_name, validator=validator)
#             print(f"🛠️  Validation applied to: {coll_name}")
#         except Exception as e:
#             print(f"❌ Error applying schema to {coll_name}: {e}")

# # Usage inside your main initialization script:
# # client = pymongo.MongoClient("mongodb://localhost:27017/")
# # db = client["SE-Marketplace"]
# # apply_marketplace_schemas(db)

# if __name__ == "__main__":
#     client = pymongo.MongoClient("mongodb://localhost:27017/")
#     db_name = "artisan-marketplace"

#         # 2. Check if Database already exists
#     existing_dbs = client.list_database_names()
#     if db_name in existing_dbs:
#         print(f"⚠️  Database '{db_name}' already exists. Skipping creation.")
#     else:
#         print(f"🆕 Creating Database: {db_name}")

#     db = client[db_name]

#     initialize_marketplace_db(client, db)

#     apply_marketplace_schemas(db)

# import pymongo


# def initialize_marketplace_db(db):
#     """Ensures collections exist in MongoDB."""

#     required_collections = [
#         "users",
#         "products",
#         "orders",
#         "carts",
#     ]

#     current_collections = db.list_collection_names()

#     for col_name in required_collections:
#         if col_name in current_collections:
#             print(f"✔️ Collection '{col_name}' already exists. Skipping.")
#         else:
#             db.create_collection(col_name)
#             print(f"🆕 Created collection: {col_name}")

#     print("\n✔ Initialization complete.\n")


# def apply_marketplace_schemas(db):
#     """Applies MongoDB JSON Schema validation rules."""

#     schemas = {
#         "users": {
#             "required": ["full_name", "email", "password_hash", "role"],
#             "properties": {
#                 "full_name": {"bsonType": "string"},
#                 "email": {"bsonType": "string", "pattern": "^.+@.+$"},
#                 "password_hash": {"bsonType": "string"},
#                 "role": {"enum": ["customer", "artisan"]},
#                 "phone": {"bsonType": "string"},
#                 "address": {"bsonType": "string"},
#                 "city": {"bsonType": "string"},
#                 "is_active": {"bsonType": "bool"},
#                 "created_at": {"bsonType": "date"},
#                 "updated_at": {"bsonType": "date"},
#             }
#         },

#         "products": {
#             "required": ["name", "price", "stock", "category", "artisan_id"],
#             "properties": {
#                 "name": {"bsonType": "string"},
#                 "description": {"bsonType": "string"},
#                 "price": {"bsonType": "number", "minimum": 0},
#                 "stock": {"bsonType": "int", "minimum": 0},
#                 "category": {"bsonType": "string"},
#                 "image_urls": {
#                     "bsonType": "array",
#                     "items": {"bsonType": "string"}
#                 },
#                 "artisan_id": {"bsonType": "string"},
#                 "artisan_name": {"bsonType": "string"},
#                 "is_active": {"bsonType": "bool"},
#                 "created_at": {"bsonType": "date"},
#                 "updated_at": {"bsonType": "date"},
#             }
#         },

#         "orders": {
#             "required": [
#                 "customer_id",
#                 "items",
#                 "total_amount",
#                 "status"
#             ],
#             "properties": {
#                 "customer_id": {"bsonType": "string"},
#                 "customer_name": {"bsonType": "string"},
#                 "items": {
#                     "bsonType": "array",
#                     "items": {
#                         "bsonType": "object",
#                         "required": ["product_id", "quantity", "price"],
#                         "properties": {
#                             "product_id": {"bsonType": "string"},
#                             "name": {"bsonType": "string"},
#                             "artisan_id": {"bsonType": "string"},
#                             "quantity": {"bsonType": "int", "minimum": 1},
#                             "price": {"bsonType": "number"},
#                             "line_total": {"bsonType": "number"},
#                         }
#                     }
#                 },
#                 "total_amount": {"bsonType": "number"},
#                 "payment_method": {"bsonType": "string"},
#                 "shipping_address": {"bsonType": "string"},
#                 "status": {
#                     "enum": ["pending", "processing", "completed", "cancelled"]
#                 },
#                 "placed_at": {"bsonType": "date"},
#                 "created_at": {"bsonType": "date"},
#                 "updated_at": {"bsonType": "date"},
#             }
#         },

#         "carts": {
#             "required": ["user_id", "items"],
#             "properties": {
#                 "user_id": {"bsonType": "string"},
#                 "items": {
#                     "bsonType": "array",
#                     "items": {
#                         "bsonType": "object",
#                         "required": ["product_id", "quantity"],
#                         "properties": {
#                             "product_id": {"bsonType": "string"},
#                             "quantity": {"bsonType": "int", "minimum": 1},
#                         }
#                     }
#                 }
#             }
#         }
#     }

#     for coll_name, schema_details in schemas.items():

#         validator = {
#             "$jsonSchema": {
#                 "bsonType": "object",
#                 "required": schema_details["required"],
#                 "properties": schema_details["properties"]
#             }
#         }

#         try:
#             db.command("collMod", coll_name, validator=validator)
#             print(f"🛠 Schema applied: {coll_name}")

#         except Exception as e:
#             print(f"❌ Could not apply schema to {coll_name}: {e}")


# if __name__ == "__main__":

#     client = pymongo.MongoClient("mongodb://localhost:27017/")
#     db_name = "artisan-marketplace"

#     db = client[db_name]

#     print(f"\n📦 Using database: {db_name}")

#     initialize_marketplace_db(db)
#     apply_marketplace_schemas(db)

#     print("\n✅ Database initialization complete.\n")


import pymongo
import json
import os
from datetime import datetime
from bson import ObjectId


# ----------------------------
# CONNECTION
# ----------------------------
client = pymongo.MongoClient("mongodb://localhost:27017/")
db = client["artisan-marketplace"]


# ----------------------------
# BASE PATH
# ----------------------------
BASE_DIR = os.path.dirname(os.path.abspath(__file__))


# ----------------------------
# CLEAN JSON
# ----------------------------
def clean(obj):

    if isinstance(obj, list):
        return [clean(i) for i in obj]

    if isinstance(obj, dict):

        if "$oid" in obj:
            return ObjectId(obj["$oid"])

        if "$date" in obj:
            return datetime.fromisoformat(obj["$date"].replace("Z", "+00:00"))

        return {k: clean(v) for k, v in obj.items()}

    return obj


# ----------------------------
# LOAD FILE
# ----------------------------
def load_file(filename):

    path = os.path.join(BASE_DIR, filename)

    print(f"\n📂 Loading: {filename}")

    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)

    if isinstance(data, dict):
        data = list(data.values())[0]

    data = clean(data)

    print(f"📊 Records: {len(data)}")

    return data


# ----------------------------
# INIT DB
# ----------------------------
def init_db():

    collections = ["users", "products", "orders", "carts"]

    for c in collections:
        if c not in db.list_collection_names():
            db.create_collection(c)
            print(f"🆕 Created: {c}")
        else:
            print(f"✔ Exists: {c}")


# ----------------------------
# SEED DATA
# ----------------------------
def seed():

    # USERS
    users = load_file("users.json")
    db.users.insert_many(users)
    print(f"👤 Users: {len(users)}")

    # PRODUCTS
    products = load_file("products.json")
    db.products.insert_many(products)
    print(f"🛍 Products: {len(products)}")

    # CARTS (all string IDs)
    carts = load_file("carts.json")

    for c in carts:
        c["user_id"] = str(c["user_id"])

        for item in c.get("items", []):
            item["product_id"] = str(item["product_id"])

    db.carts.insert_many(carts)
    print(f"🛒 Carts: {len(carts)}")

    # ORDERS (UPDATED HERE)
    orders = load_file("orders.json")

    for o in orders:
        # string
        o["customer_id"] = str(o["customer_id"])

        for item in o.get("items", []):
            item["product_id"] = str(item["product_id"])
            item["artisan_id"] = str(item["artisan_id"])  # ✅ FIXED

    db.orders.insert_many(orders)
    print(f"📦 Orders: {len(orders)}")


# ----------------------------
# VERIFY
# ----------------------------
def verify():

    print("\n🔍 DATABASE CHECK")
    print("Users:", db.users.count_documents({}))
    print("Products:", db.products.count_documents({}))
    print("Carts:", db.carts.count_documents({}))
    print("Orders:", db.orders.count_documents({}))


# ----------------------------
# RUN
# ----------------------------
if __name__ == "__main__":

    print("\n🚀 Starting Seeder...\n")

    init_db()
    seed()
    verify()

    print("\n✅ DONE\n")