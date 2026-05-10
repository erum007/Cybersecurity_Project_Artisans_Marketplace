from datetime import datetime, timezone

from bson import ObjectId
from fastapi import APIRouter, Depends, HTTPException, status

from app.db.mongo import get_db
from app.models.order import CheckoutRequest, OrderItem, OrderPublic, OrderStatusUpdate
from app.services.deps import require_roles

router = APIRouter(prefix="/orders", tags=["orders"])


def _serialize(doc: dict) -> dict:
    doc["_id"] = str(doc["_id"])
    return doc

#place order - converts cart into order, checks stock, reduces stock, clears cart
@router.post("/checkout", response_model=OrderPublic, status_code=status.HTTP_201_CREATED)
def checkout(payload: CheckoutRequest, user=Depends(require_roles("customer", "admin"))):
    db = get_db()
    cart = db.carts.find_one({"user_id": user["_id"]})
    if not cart or not cart.get("items"):
        raise HTTPException(status_code=400, detail="Cart is empty")

    order_items: list[OrderItem] = []
    total_amount = 0.0
    for item in cart["items"]:
        product = db.products.find_one({"_id": ObjectId(item["product_id"]), "is_active": True})
        if not product:
            continue
        quantity = int(item["quantity"])
        if product["stock"] < quantity:
            raise HTTPException(status_code=400, detail=f"Insufficient stock for {product['name']}")
        line_total = float(product["price"]) * quantity
        total_amount += line_total
        order_items.append(
            OrderItem(
                product_id=str(product["_id"]),
                name=product["name"],
                artisan_id=str(product["artisan_id"]),
                quantity=quantity,
                price=float(product["price"]),
                line_total=line_total,
            )
        )
        db.products.update_one({"_id": product["_id"]}, {"$inc": {"stock": -quantity}})

    now = datetime.now(timezone.utc)
    order_doc = {
        "customer_id": user["_id"],
        "customer_name": user["full_name"],
        "items": [item.model_dump() for item in order_items],
        "total_amount": total_amount,
        "payment_method": payload.payment_method,
        "shipping_address": payload.shipping_address,
        "status": "pending",
        "placed_at": now,
        "created_at": now,
        "updated_at": now,
    }
    result = db.orders.insert_one(order_doc)
    db.carts.update_one({"user_id": user["_id"]}, {"$set": {"items": []}}, upsert=True)
    order_doc["_id"] = str(result.inserted_id)
    return OrderPublic(**order_doc)

#my orders - returns list of orders placed by the user
@router.get("/me", response_model=list[OrderPublic])
def my_orders(user=Depends(require_roles("customer", "admin"))):
    db = get_db()
    docs = [_serialize(x) for x in db.orders.find({"customer_id": user["_id"]}).sort("placed_at", -1)]
    return [OrderPublic(**doc) for doc in docs]


@router.get("/artisan", response_model=list[OrderPublic])
def artisan_orders(user=Depends(require_roles("artisan", "admin"))):
    db = get_db()
    docs = []
    for order in db.orders.find().sort("placed_at", -1):
        if any(item.get("artisan_id") == user["_id"] for item in order.get("items", [])):
            docs.append(OrderPublic(**_serialize(order)))
    return docs

#update order status - allows artisan to update status of an order (e.g. pending -> in_progress -> completed)
@router.patch("/{order_id}/status", response_model=OrderPublic)
def update_order_status(order_id: str, payload: OrderStatusUpdate, user=Depends(require_roles("artisan", "admin"))):
    db = get_db()
    existing = db.orders.find_one({"_id": ObjectId(order_id)})
    if not existing:
        raise HTTPException(status_code=404, detail="Order not found")
    if user["role"] != "admin" and not any(item.get("artisan_id") == user["_id"] for item in existing.get("items", [])):
        raise HTTPException(status_code=403, detail="Not your order")

    db.orders.update_one(
        {"_id": ObjectId(order_id)},
        {"$set": {"status": payload.status, "updated_at": datetime.now(timezone.utc)}},
    )
    refreshed = db.orders.find_one({"_id": ObjectId(order_id)})
    return OrderPublic(**_serialize(refreshed))
