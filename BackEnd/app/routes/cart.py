from fastapi import APIRouter, Depends, HTTPException
from bson import ObjectId

from app.db.mongo import get_db
from app.models.cart import CartItemIn, CartItemOut, CartResponse, CartUpdate
from app.services.deps import require_roles

router = APIRouter(prefix="/cart", tags=["cart"])

# Converts raw cart document into response model
def _cart_to_response(db, cart_doc) -> CartResponse:
    items: list[CartItemOut] = []
    total = 0.0
    for item in cart_doc.get("items", []):
        product = db.products.find_one({"_id": ObjectId(item["product_id"])})
        if not product:
            continue
        line_total = float(product["price"]) * int(item["quantity"])
        total += line_total
        items.append(
            CartItemOut(
                product_id=str(product["_id"]),
                name=product["name"],
                price=float(product["price"]),
                quantity=int(item["quantity"]),
                line_total=line_total,
            )
        )
    return CartResponse(items=items, total=total)

#get cart - returns users current cart
@router.get("", response_model=CartResponse)
def get_cart(user=Depends(require_roles("customer", "admin"))):
    db = get_db()
    cart = db.carts.find_one({"user_id": user["_id"]}) or {"items": []}
    return _cart_to_response(db, cart)

#add to cart - adds a product to the cart or updates quantity if already exists
@router.post("/items", response_model=CartResponse)
def add_to_cart(payload: CartItemIn, user=Depends(require_roles("customer", "admin"))):
    db = get_db()
    product = db.products.find_one({"_id": ObjectId(payload.product_id), "is_active": True})
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    cart = db.carts.find_one({"user_id": user["_id"]})
    if not cart:
        db.carts.insert_one({"user_id": user["_id"], "items": [{"product_id": payload.product_id, "quantity": payload.quantity}]})
    else:
        items = cart.get("items", [])
        matched = False
        for item in items:
            if item["product_id"] == payload.product_id:
                item["quantity"] += payload.quantity
                matched = True
                break
        if not matched:
            items.append({"product_id": payload.product_id, "quantity": payload.quantity})
        db.carts.update_one({"_id": cart["_id"]}, {"$set": {"items": items}})

    cart = db.carts.find_one({"user_id": user["_id"]})
    return _cart_to_response(db, cart)

#remove from cart - removes a product from the cart
@router.delete("/items/{product_id}", response_model=CartResponse)
def remove_from_cart(product_id: str, user=Depends(require_roles("customer", "admin"))):
    db = get_db()
    cart = db.carts.find_one({"user_id": user["_id"]}) or {"items": []}
    items = [item for item in cart.get("items", []) if item["product_id"] != product_id]
    if "_id" in cart:
        db.carts.update_one({"_id": cart["_id"]}, {"$set": {"items": items}})
    cart = db.carts.find_one({"user_id": user["_id"]}) or {"items": []}
    return _cart_to_response(db, cart)

# update cart item quantity - updates the quantity of a product in the cart
@router.patch("/items/{product_id}", response_model=CartResponse)
def update_cart_item(product_id: str, payload: CartUpdate, user=Depends(require_roles("customer", "admin"))):
    db = get_db()

    # Verify product exists and check stock
    product = db.products.find_one({"_id": ObjectId(product_id)})
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    if payload.quantity > product.get("stock", 0):
        raise HTTPException(status_code=400, detail=f"Only {product.get('stock')} items in stock")

    cart = db.carts.find_one({"user_id": user["_id"]})
    if not cart:
        raise HTTPException(status_code=404, detail="Cart not found")

    items = cart.get("items", [])
    updated = False
    for item in items:
        if item["product_id"] == product_id:
            item["quantity"] = payload.quantity
            updated = True
            break

    if not updated:
        raise HTTPException(status_code=404, detail="Item not in cart")

    db.carts.update_one({"_id": cart["_id"]}, {"$set": {"items": items}})

    return _cart_to_response(db, cart)
