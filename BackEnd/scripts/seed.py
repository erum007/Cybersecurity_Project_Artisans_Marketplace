import json
from pathlib import Path
from datetime import datetime, timezone

from app.core.security import get_password_hash
from app.db.mongo import get_db

BASE = Path(__file__).resolve().parents[2] / "SE-Proj-main" / "Database" / "sample_data"


def load_json(name: str):
    with open(BASE / name, "r", encoding="utf-8") as f:
        return json.load(f)


def main():
    db = get_db()
    now = datetime.now(timezone.utc)

    db.users.delete_many({})
    db.products.delete_many({})
    db.orders.delete_many({})
    db.carts.delete_many({})

    artisan_user_ids = {}
    for artisan in load_json("artisans.json"):
        email = artisan.get("email") or f"{artisan['name'].lower().replace(' ', '')}@artisan.local"
        user_doc = {
            "full_name": artisan["name"],
            "email": email,
            "password_hash": get_password_hash("Password123!"),
            "role": "artisan",
            "phone": artisan.get("phone"),
            "address": artisan.get("location"),
            "city": artisan.get("location"),
            "is_active": True,
            "created_at": now,
            "updated_at": now,
        }
        result = db.users.insert_one(user_doc)
        artisan_user_ids[artisan.get("_id") or artisan.get("id") or artisan["name"]] = str(result.inserted_id)

    customer = {
        "full_name": "Demo Customer",
        "email": "customer@example.com",
        "password_hash": get_password_hash("Password123!"),
        "role": "customer",
        "phone": "0000000000",
        "address": "Karachi",
        "city": "Karachi",
        "is_active": True,
        "created_at": now,
        "updated_at": now,
    }
    db.users.insert_one(customer)

    for product in load_json("products.json"):
        artisan_key = product.get("artisan_id") or product.get("artisanId") or product.get("artisan_name")
        name = product.get("name") or product.get("title")
        doc = {
            "name": name,
            "description": product.get("description", ""),
            "price": float(product.get("price", 0)),
            "stock": int(product.get("stock", 10)),
            "category": product.get("category", "General"),
            "image_url": product.get("image") or product.get("image_url"),
            "artisan_id": artisan_user_ids.get(artisan_key) or next(iter(artisan_user_ids.values())),
            "artisan_name": product.get("artisan_name", "Artisan"),
            "is_active": True,
            "created_at": now,
            "updated_at": now,
        }
        db.products.insert_one(doc)

    print("Database seeded.")
    print("Demo customer login: customer@example.com / Password123!")


if __name__ == "__main__":
    main()
