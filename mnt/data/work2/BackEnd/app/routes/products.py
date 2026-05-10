from datetime import datetime, timezone

from bson import ObjectId
from fastapi import APIRouter, Depends, HTTPException, Query, status

from app.db.mongo import get_db
from app.models.product import ProductCreate, ProductListResponse, ProductPublic, ProductUpdate
from app.services.deps import get_current_user, require_roles

router = APIRouter(prefix="/products", tags=["products"])


def _serialize(doc: dict) -> dict:
    doc["_id"] = str(doc["_id"])
    return doc


@router.get("", response_model=ProductListResponse)
def list_products(search: str | None = None, category: str | None = None, limit: int = Query(default=20, le=100)):
    db = get_db()
    query: dict = {"is_active": True}
    if category:
        query["category"] = category
    if search:
        query["name"] = {"$regex": search, "$options": "i"}
    docs = [_serialize(x) for x in db.products.find(query).limit(limit)]
    return ProductListResponse(items=[ProductPublic(**d) for d in docs], total=len(docs))


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
