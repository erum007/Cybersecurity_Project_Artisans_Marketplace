from datetime import datetime, timezone
from fastapi import Depends, Header, HTTPException, status
from bson import ObjectId

from app.core.security import decode_token
from app.db.mongo import get_db


def get_current_user(authorization: str = Header(default="")):
    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Missing bearer token")
    token = authorization.removeprefix("Bearer ").strip()
    try:
        payload = decode_token(token)
    except ValueError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")

    user_id = payload.get("sub")
    db = get_db()
    user = db.users.find_one({"_id": ObjectId(user_id)})
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User not found")

    force_logout_at = user.get("force_logout_at")
    issued_at = payload.get("iat")
    if force_logout_at is not None and issued_at is not None:
        if isinstance(issued_at, (int, float)):
            issued_at_dt = datetime.fromtimestamp(issued_at, timezone.utc)
        elif isinstance(issued_at, str):
            issued_at_dt = datetime.fromisoformat(issued_at)
        else:
            issued_at_dt = issued_at

        if isinstance(force_logout_at, str):
            force_logout_at_dt = datetime.fromisoformat(force_logout_at)
        else:
            force_logout_at_dt = force_logout_at

        if hasattr(force_logout_at_dt, "tzinfo") and force_logout_at_dt.tzinfo is None:
            force_logout_at_dt = force_logout_at_dt.replace(tzinfo=timezone.utc)

        if issued_at_dt < force_logout_at_dt:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Could not validate credentials")

    user["_id"] = str(user["_id"])
    return user


def require_roles(*roles: str):
    def checker(user=Depends(get_current_user)):
        if user.get("role") not in roles:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Insufficient permissions")
        return user

    return checker
