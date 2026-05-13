import pymongo
import json
import os
from datetime import datetime
from bson import ObjectId
from passlib.context import CryptContext

# ----------------------------
# CONNECTION
# ----------------------------
mongo_uri = os.getenv("DATABASE_URL", "mongodb://db:27017/")

client = pymongo.MongoClient(mongo_uri)
# client = pymongo.MongoClient("mongodb://localhost:27017/")
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
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
   
def seed():

    # USERS
    users = load_file("users.json")
    raw_password = os.getenv("DEFAULT_USER_PASSWORD")

    if not raw_password:
        raise ValueError("CRITICAL SECURITY ERROR: 'DEFAULT_USER_PASSWORD' environment variable is not set.")

    hashed_password = pwd_context.hash(raw_password)
   
    for user in users:
        user["password_hash"] = hashed_password   # issue 13: Inject the hash dynamically so it's not hard-coded in the JSON
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