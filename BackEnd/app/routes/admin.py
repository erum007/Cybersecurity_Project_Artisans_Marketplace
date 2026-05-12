from datetime import datetime, timezone
from fastapi import APIRouter, Depends, HTTPException, status
from bson import ObjectId

from app.db.mongo import get_db
from app.services.deps import require_roles

router = APIRouter(prefix="/admin", tags=["admin"])


@router.get("/dashboard")
def dashboard(_user=Depends(require_roles("admin"))):
    db = get_db()
    total_revenue = 0.0
    for order in db.orders.find({"status": {"$in": ["pending", "processing", "completed"]}}):
        total_revenue += float(order.get("total_amount", 0))
    return {
        "users": db.users.count_documents({}),
        "artisans": db.users.count_documents({"role": "artisan"}),
        "customers": db.users.count_documents({"role": "customer"}),
        "products": db.products.count_documents({}),
        "orders": db.orders.count_documents({}),
        "revenue": total_revenue,
    }


@router.get("/users")
def list_users(_user=Depends(require_roles("admin"))):
    """Return all customers and artisans with basic profile info."""
    db = get_db()
    users = []
    for u in db.users.find({"role": {"$in": ["customer", "artisan"]}}):
        users.append({
            "id": str(u["_id"]),
            "full_name": u.get("full_name", ""),
            "email": u.get("email", ""),
            "role": u.get("role", "customer"),
            "phone": u.get("phone", ""),
            "city": u.get("city", ""),
            "profile_picture": u.get("profile_picture", ""),
        })
    return users


@router.get("/artisan-revenue")
def artisan_revenue(_user=Depends(require_roles("admin"))):
    """Return per-artisan revenue, order count, and product count."""
    db = get_db()
    artisans = list(db.users.find({"role": "artisan"}))
    result = []
    for a in artisans:
        artisan_id = str(a["_id"])
        # Count products belonging to this artisan
        product_count = db.products.count_documents({"artisan_id": artisan_id})
        # Sum revenue from orders that contain this artisan's products
        revenue = 0.0
        order_ids = set()
        for order in db.orders.find({"status": {"$in": ["pending", "processing", "completed"]}}):
            for item in order.get("items", []):
                if str(item.get("artisan_id", "")) == artisan_id:
                    revenue += float(item.get("price", 0)) * int(item.get("quantity", 1))
                    order_ids.add(str(order["_id"]))
        result.append({
            "id": artisan_id,
            "full_name": a.get("full_name", ""),
            "email": a.get("email", ""),
            "city": a.get("city", ""),
            "profile_picture": a.get("profile_picture", ""),
            "product_count": product_count,
            "order_count": len(order_ids),
            "revenue": revenue,
        })
    # Sort by revenue descending
    result.sort(key=lambda x: x["revenue"], reverse=True)
    return result


@router.get("/users/{user_id}/sessions")
def list_user_sessions(user_id: str, _user=Depends(require_roles("admin"))):
    db = get_db()
    try:
        target_id = ObjectId(user_id)
    except Exception:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    user = db.users.find_one({"_id": target_id})
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    sessions = []
    for session in db.sessions.find({"user_id": user_id}).sort("created_at", -1):
        sessions.append({
            "id": str(session["_id"]),
            "created_at": session["created_at"],
            "expires_at": session["expires_at"],
            "revoked": session.get("revoked", False),
            "revoked_at": session.get("revoked_at"),
        })
    return sessions


@router.delete("/users/{user_id}/sessions")
def revoke_user_sessions(user_id: str, _user=Depends(require_roles("admin"))):
    db = get_db()
    try:
        target_id = ObjectId(user_id)
    except Exception:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    user = db.users.find_one({"_id": target_id})
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    now = datetime.now(timezone.utc)
    result = db.sessions.update_many(
        {"user_id": user_id, "revoked": False},
        {"$set": {"revoked": True, "revoked_at": now}}
    )
    db.users.update_one({"_id": target_id}, {"$set": {"force_logout_at": now}})
    return {
        "message": "All sessions revoked",
        "sessions_revoked": int(result.modified_count),
    }
