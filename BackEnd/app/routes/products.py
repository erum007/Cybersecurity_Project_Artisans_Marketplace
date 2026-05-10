from datetime import datetime, timezone

from bson import ObjectId
from fastapi import APIRouter, Depends, HTTPException, Query, status

from app.db.mongo import get_db
from app.models.product import ProductCreate, ProductListResponse, ProductPublic, ProductUpdate, ReviewCreate, ReviewPublic
from app.services.deps import get_current_user, require_roles

router = APIRouter(prefix="/products", tags=["products"])


def _serialize(doc: dict) -> dict:
    doc["_id"] = str(doc["_id"])
    return doc


@router.get("", response_model=ProductListResponse)
def list_products(
    search: str | None = None,
    category: str | None = None,
    skip: int = Query(default=0, ge=0),
    limit: int = Query(default=30, le=100),
):
    db = get_db()
    query: dict = {"is_active": True}
    if category:
        query["category"] = category
    if search:
        # Use text search if index exists, else fallback to regex
        query["$text"] = {"$search": search}

    cursor = db.products.find(query)
    total = db.products.count_documents(query)
    docs = [_serialize(x) for x in cursor.skip(skip).limit(limit)]

    return ProductListResponse(items=[ProductPublic(**d) for d in docs], total=total)


@router.get("/{product_id}", response_model=ProductPublic)
def get_product(product_id: str):
    db = get_db()
    doc = db.products.find_one({"_id": ObjectId(product_id)})
    if not doc:
        raise HTTPException(status_code=404, detail="Product not found")
    return ProductPublic(**_serialize(doc))


@router.post("", response_model=ProductPublic, status_code=status.HTTP_201_CREATED)
def create_product(payload: ProductCreate, user=Depends(require_roles("artisan", "admin"))):
    db = get_db()
    now = datetime.now(timezone.utc)
    doc = {
        **payload.model_dump(),
        "artisan_id": user["_id"],
        "artisan_name": user["full_name"],
        "is_active": True,
        "created_at": now,
        "updated_at": now,
    }
    result = db.products.insert_one(doc)
    doc["_id"] = str(result.inserted_id)
    return ProductPublic(**doc)


@router.put("/{product_id}", response_model=ProductPublic)
def update_product(product_id: str, payload: ProductUpdate, user=Depends(require_roles("artisan", "admin"))):
    db = get_db()
    existing = db.products.find_one({"_id": ObjectId(product_id)})
    if not existing:
        raise HTTPException(status_code=404, detail="Product not found")
    if user["role"] != "admin" and str(existing["artisan_id"]) != user["_id"]:
        raise HTTPException(status_code=403, detail="You can edit only your own products")

    updates = {k: v for k, v in payload.model_dump().items() if v is not None}
    updates["updated_at"] = datetime.now(timezone.utc)
    db.products.update_one({"_id": ObjectId(product_id)}, {"$set": updates})
    refreshed = db.products.find_one({"_id": ObjectId(product_id)})
    return ProductPublic(**_serialize(refreshed))


@router.delete("/{product_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_product(product_id: str, user=Depends(require_roles("artisan", "admin"))):
    db = get_db()
    existing = db.products.find_one({"_id": ObjectId(product_id)})
    if not existing:
        raise HTTPException(status_code=404, detail="Product not found")
    if user["role"] != "admin" and str(existing["artisan_id"]) != user["_id"]:
        raise HTTPException(status_code=403, detail="You can delete only your own products")
    db.products.delete_one({"_id": ObjectId(product_id)})


@router.post("/{product_id}/reviews", response_model=ProductPublic)
def add_review(product_id: str, payload: ReviewCreate, user=Depends(get_current_user)):
    db = get_db()
    try:
        oid = ObjectId(product_id)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid product ID")

    product = db.products.find_one({"_id": oid})
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    # Check if user has a completed order for this product
    # Note: Using customer_id to match the orders collection
    order = db.orders.find_one({
        "customer_id": user["_id"],
        "status": "completed",
        "items.product_id": product_id
    })
    if not order:
        raise HTTPException(
            status_code=403,
            detail="Only customers who purchased this product can leave a review"
        )

    new_review = {
        "user_id": user["_id"],
        "user_name": user["full_name"],
        "rating": payload.rating,
        "comment": payload.comment,
        "created_at": datetime.now(timezone.utc)
    }

    db.products.update_one(
        {"_id": oid},
        {"$push": {"reviews": new_review}}
    )

    # Update aggregate rating and review count
    product = db.products.find_one({"_id": oid})
    reviews = product.get("reviews", [])
    review_count = len(reviews)
    avg_rating = sum(r["rating"] for r in reviews) / review_count if review_count > 0 else 0.0

    db.products.update_one(
        {"_id": oid},
        {"$set": {"rating": avg_rating, "review_count": review_count}}
    )

    # Return updated product
    updated = db.products.find_one({"_id": oid})
    return ProductPublic(**_serialize(updated))


