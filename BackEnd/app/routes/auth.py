# from datetime import datetime, timezone


# from bson import ObjectId
# from fastapi import APIRouter, Depends, HTTPException, status

# from app.core.security import create_access_token, get_current_user, get_password_hash, verify_password
# from app.db.mongo import get_db
# from app.models.user import TokenResponse, UserCreate, UserLogin, UserPublic, UserUpdate

# router = APIRouter(prefix="/auth", tags=["auth"])

# #register - creates a new user account
# @router.post("/register", response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
# def register(payload: UserCreate):
#     db = get_db()
#     if db.users.find_one({"email": payload.email.lower()}):
#         raise HTTPException(status_code=400, detail="Email already registered")

#     now = datetime.now(timezone.utc)
#     user_doc = {
#         "full_name": payload.full_name,
#         "email": payload.email.lower(),
#         "password_hash": get_password_hash(payload.password),
#         "role": payload.role,
#         "phone": payload.phone,
#         "address": payload.address,
#         "city": payload.city,
#         "is_active": True,
#         "created_at": now,
#         "updated_at": now,
#     }
#     result = db.users.insert_one(user_doc)
#     user_doc["_id"] = str(result.inserted_id)
#     token = create_access_token(str(result.inserted_id), {"role": payload.role})
#     return TokenResponse(access_token=token, user=UserPublic(**user_doc))

# #login - authenticates user and returns JWT token
# @router.post("/login", response_model=TokenResponse)
# def login(payload: UserLogin):
#     db = get_db()
#     user = db.users.find_one({"email": payload.email.lower()})
#     if not user or not verify_password(payload.password, user["password_hash"]):
#         raise HTTPException(status_code=401, detail="Invalid email or password")

#     user["_id"] = str(user["_id"])
#     token = create_access_token(user["_id"], {"role": user["role"]})
#     return TokenResponse(access_token=token, user=UserPublic(**user))


# @router.get("/me", response_model=UserPublic)
# def get_me(user=Depends(get_current_user)):
#     return UserPublic(**user)


# @router.patch("/me", response_model=UserPublic)
# def update_me(payload: UserUpdate, user=Depends(get_current_user)):
#     db = get_db()
#     updates = {k: v for k, v in payload.model_dump().items() if v is not None}

#     if "password" in updates:
#         updates["password_hash"] = get_password_hash(updates.pop("password"))

#     if not updates:
#         return UserPublic(**user)

#     updates["updated_at"] = datetime.now(timezone.utc)
#     db.users.update_one({"_id": ObjectId(user["_id"])}, {"$set": updates})
#     refreshed = db.users.find_one({"_id": ObjectId(user["_id"])})
#     refreshed["_id"] = str(refreshed["_id"])
#     return UserPublic(**refreshed)


from datetime import datetime, timezone, timedelta
import re
from secrets import token_hex
import hashlib

from bson import ObjectId
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel

from app.core.config import settings
from app.core.security import (
    create_access_token,
    create_refresh_token,
    decode_refresh_token,
    get_current_user,
    get_password_hash,
    verify_password,
)

from app.db.mongo import get_db
from app.models.user import (
    TokenResponse,
    UserCreate,
    UserLogin,
    UserPublic,
    UserUpdate,
)

router = APIRouter(prefix="/auth", tags=["auth"])


class RefreshRequest(BaseModel):
    refresh_token: str


class SessionInfo(BaseModel):
    id: str
    created_at: datetime
    expires_at: datetime


# ─────────────────────────────────────────────────────────────
# PASSWORD VALIDATION
# ─────────────────────────────────────────────────────────────

def validate_password_strength(password: str):

    if len(password) < 16:
        raise HTTPException(
            status_code=400,
            detail="Password must be at least 16 characters long"
        )

    if not re.search(r"[A-Z]", password):
        raise HTTPException(
            status_code=400,
            detail="Password must contain at least one uppercase letter"
        )

    if not re.search(r"[a-z]", password):
        raise HTTPException(
            status_code=400,
            detail="Password must contain at least one lowercase letter"
        )

    if not re.search(r"\d", password):
        raise HTTPException(
            status_code=400,
            detail="Password must contain at least one number"
        )

    if not re.search(r"[!@#$%^&*(),.?\":{}|<>]", password):
        raise HTTPException(
            status_code=400,
            detail="Password must contain at least one special character"
        )


# ─────────────────────────────────────────────────────────────
# REGISTER
# ─────────────────────────────────────────────────────────────

@router.post(
    "/register",
    response_model=TokenResponse,
    status_code=status.HTTP_201_CREATED
)
def register(payload: UserCreate):

    db = get_db()

    existing_user = db.users.find_one({
        "email": payload.email.lower()
    })

    if existing_user:
        raise HTTPException(
            status_code=400,
            detail="Email already registered"
        )

    # PASSWORD SECURITY ENFORCEMENT
    validate_password_strength(payload.password)

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

    token = create_access_token(
        str(result.inserted_id),
        {"role": payload.role}
    )

    refresh_raw = token_hex(64)
    refresh_hash = hashlib.sha256(refresh_raw.encode()).hexdigest()
    db.sessions.insert_one({
        "user_id": str(result.inserted_id),
        "refresh_token_hash": refresh_hash,
        "created_at": datetime.now(timezone.utc),
        "expires_at": datetime.now(timezone.utc) + timedelta(days=settings.refresh_token_expire_days),
        "revoked": False,
        "revoked_at": None,
    })

    return TokenResponse(
        access_token=token,
        refresh_token=refresh_raw,
        user=UserPublic(**user_doc)
    )



# ─────────────────────────────────────────────────────────────
# LOGIN
# ─────────────────────────────────────────────────────────────

@router.post("/login", response_model=TokenResponse)
def login(payload: UserLogin):

    db = get_db()

    user = db.users.find_one({
        "email": payload.email.lower()
    })

    if not user or not verify_password(
        payload.password,
        user["password_hash"]
    ):
        raise HTTPException(
            status_code=401,
            detail="Invalid email or password"
        )

    user["_id"] = str(user["_id"])

    token = create_access_token(
        user["_id"],
        {"role": user["role"]}
    )

    refresh_raw = token_hex(64)
    refresh_hash = hashlib.sha256(refresh_raw.encode()).hexdigest()
    db.sessions.insert_one({
        "user_id": user["_id"],
        "refresh_token_hash": refresh_hash,
        "created_at": datetime.now(timezone.utc),
        "expires_at": datetime.now(timezone.utc) + timedelta(days=settings.refresh_token_expire_days),
        "revoked": False,
        "revoked_at": None,
    })

    return TokenResponse(
        access_token=token,
        refresh_token=refresh_raw,
        user=UserPublic(**user)
    )


@router.post("/token/refresh")
def refresh_token(payload: RefreshRequest):
    db = get_db()
    refresh_hash = hashlib.sha256(payload.refresh_token.encode()).hexdigest()
    session = db.sessions.find_one({
        "refresh_token_hash": refresh_hash,
        "revoked": False,
    })
    if not session:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired refresh token"
        )
    if session["expires_at"] <= datetime.now(timezone.utc):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired refresh token"
        )

    user = db.users.find_one({"_id": ObjectId(session["user_id"])})
    if not user or user.get("is_active") is False:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired refresh token"
        )

    new_token = create_access_token(session["user_id"], {"role": user["role"]})
    return {"access_token": new_token, "token_type": "bearer"}


@router.get("/sessions", response_model=list[SessionInfo])
def list_sessions(user=Depends(get_current_user)):
    db = get_db()
    now = datetime.now(timezone.utc)
    sessions = []
    for session in db.sessions.find({
        "user_id": user["_id"],
        "revoked": False,
        "expires_at": {"$gt": now},
    }).sort("created_at", -1):
        sessions.append(SessionInfo(
            id=str(session["_id"]),
            created_at=session["created_at"],
            expires_at=session["expires_at"],
        ))
    return sessions


@router.delete("/sessions/{session_id}")
def revoke_session(session_id: str, user=Depends(get_current_user)):
    db = get_db()
    try:
        session_obj_id = ObjectId(session_id)
    except Exception:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Session not found")

    session = db.sessions.find_one({"_id": session_obj_id, "user_id": user["_id"]})
    if not session:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Session not found")

    db.sessions.update_one(
        {"_id": session_obj_id},
        {"$set": {"revoked": True, "revoked_at": datetime.now(timezone.utc)}}
    )
    return {"message": "Session revoked"}


@router.post("/logout")
def logout(payload: RefreshRequest | None = None, user=Depends(get_current_user)):
    db = get_db()
    now = datetime.now(timezone.utc)
    if payload and payload.refresh_token:
        refresh_hash = hashlib.sha256(payload.refresh_token.encode()).hexdigest()
        result = db.sessions.update_one(
            {"refresh_token_hash": refresh_hash},
            {"$set": {"revoked": True, "revoked_at": now}}
        )
        count = int(result.modified_count)
    else:
        result = db.sessions.update_many(
            {"user_id": str(user["_id"]), "revoked": False},
            {"$set": {"revoked": True, "revoked_at": now}}
        )
        count = int(result.modified_count)
    return {"message": "Logged out successfully", "sessions_revoked": count}


# ─────────────────────────────────────────────────────────────
# GET CURRENT USER
# ─────────────────────────────────────────────────────────────

@router.get("/me", response_model=UserPublic)
def get_me(user=Depends(get_current_user)):
    return UserPublic(**user)


# ─────────────────────────────────────────────────────────────
# UPDATE USER
# ─────────────────────────────────────────────────────────────

@router.patch("/me", response_model=UserPublic)
def update_me(
    payload: UserUpdate,
    user=Depends(get_current_user)
):

    db = get_db()

    updates = {
        k: v
        for k, v in payload.model_dump().items()
        if v is not None
    }

    # PASSWORD UPDATE SECURITY
    if "password" in updates:

        validate_password_strength(updates["password"])

        updates["password_hash"] = get_password_hash(
            updates.pop("password")
        )

    if not updates:
        return UserPublic(**user)

    updates["updated_at"] = datetime.now(timezone.utc)

    db.users.update_one(
        {"_id": ObjectId(user["_id"])},
        {"$set": updates}
    )

    refreshed = db.users.find_one({
        "_id": ObjectId(user["_id"])
    })

    refreshed["_id"] = str(refreshed["_id"])

    return UserPublic(**refreshed)
