from fastapi import APIRouter, Depends

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
