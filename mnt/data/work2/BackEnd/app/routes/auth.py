from datetime import datetime, timezone

from bson import ObjectId
from fastapi import APIRouter, HTTPException, status

from app.core.security import create_access_token, get_password_hash, verify_password
from app.db.mongo import get_db
from app.models.user import TokenResponse, UserCreate, UserLogin, UserPublic

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/register", response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
def register(payload: UserCreate):
    db = get_db()
    if db.users.find_one({"email": payload.email.lower()}):
        raise HTTPException(status_code=400, detail="Email already registered")

    now = datetime.now(timezone.utc)
    user_doc = {
        "full_name": payload.full_name,
        "email": payload.email.lower(),
        "password_hash": get_password_hash(payload.password),
        "role": payload.role,
        "phone": payload.phone,
        "address": payload.address,
        "city": payload.city,
        "is_active": True,
        "created_at": now,
        "updated_at": now,
    }
    result = db.users.insert_one(user_doc)
    user_doc["_id"] = str(result.inserted_id)
    token = create_access_token(str(result.inserted_id), {"role": payload.role})
    return TokenResponse(access_token=token, user=UserPublic(**user_doc))


@router.post("/login", response_model=TokenResponse)
def login(payload: UserLogin):
    db = get_db()
    user = db.users.find_one({"email": payload.email.lower()})
    if not user or not verify_password(payload.password, user["password_hash"]):
        raise HTTPException(status_code=401, detail="Invalid email or password")

    user["_id"] = str(user["_id"])
    token = create_access_token(user["_id"], {"role": user["role"]})
    return TokenResponse(access_token=token, user=UserPublic(**user))
