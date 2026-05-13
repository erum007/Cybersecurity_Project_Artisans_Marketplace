import pymongo
import json
import os
from datetime import datetime
from bson import ObjectId
from passlib.context import CryptContext
from pymongo import UpdateOne

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
    # db.users.insert_many(users)
    # print(f"👤 Users: {len(users)}")

    

    # Create a list of update operations
    operations = [
        UpdateOne(
            {"email": user["email"]}, # Search by unique email
            {"$set": user},           # Update with new data/hash
            upsert=True               # Insert if email doesn't exist
        ) for user in users
    ]

    # Execute all operations at once
    result = db.users.bulk_write(operations)
    print(f"👤 Users processed: {len(users)} (Upserted: {result.upserted_count}, Modified: {result.modified_count})")

    # PRODUCTS
    products = load_file("products.json")


    # Loading: products.json logic...
    operations = [
        UpdateOne(
            {"_id": product["_id"]}, # Match by the unique ID
            {"$set": product},       # Update the fields
            upsert=True              # Create if it doesn't exist
        ) for product in products
    ]

    result = db.products.bulk_write(operations)
    print(f"📦 Products processed: {len(products)} (Upserted: {result.upserted_count}, Modified: {result.modified_count})")


    # CARTS (all string IDs)
    carts = load_file("carts.json")

    cart_ops = []
    for c in carts:
        c["user_id"] = str(c["user_id"])
        for item in c.get("items", []):
            item["product_id"] = str(item["product_id"])
        
        # Use UpdateOne instead of insert_many
        cart_ops.append(
            UpdateOne({"_id": c["_id"]}, {"$set": c}, upsert=True)
        )

    if cart_ops:
        result = db.carts.bulk_write(cart_ops)
        print(f"🛒 Carts processed: {len(carts)} (Upserted: {result.upserted_count}, Modified: {result.modified_count})")


    # ORDERS (UPDATED HERE)
    orders = load_file("orders.json")

    orders = load_file("orders.json")

    order_ops = []
    for o in orders:
        o["customer_id"] = str(o["customer_id"])
        for item in o.get("items", []):
            item["product_id"] = str(item["product_id"])
            item["artisan_id"] = str(item["artisan_id"])

        # Use UpdateOne instead of insert_many
        order_ops.append(
            UpdateOne({"_id": o["_id"]}, {"$set": o}, upsert=True)
        )

    if order_ops:
        result = db.orders.bulk_write(order_ops)
        print(f"📦 Orders processed: {len(orders)} (Upserted: {result.upserted_count}, Modified: {result.modified_count})")

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