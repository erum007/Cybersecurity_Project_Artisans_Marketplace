from datetime import datetime, timedelta, timezone
from typing import Any
from secrets import token_hex

from jose import JWTError, jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from app.db.mongo import get_db

from app.core.config import settings
from passlib.context import CryptContext

# -------------------------
# PASSWORD HASHING (NO BCRYPT)
# -------------------------

pwd_context = CryptContext(
    schemes=["bcrypt"],
    deprecated="auto"
)

def get_password_hash(password: str):
    # Truncate to 72 characters to satisfy bcrypt limits
    return pwd_context.hash(password[:72])


def verify_password(plain_password: str, hashed_password: str) -> bool:
    print("VERIFY INPUT:", repr(plain_password))
    return pwd_context.verify(plain_password, hashed_password)


# -------------------------
# JWT
# -------------------------

def create_access_token(subject: str, extra_claims: dict[str, Any] | None = None) -> str:
    now = datetime.now(timezone.utc)
    expire = now + timedelta(
        minutes=settings.access_token_expire_minutes
    )

    to_encode: dict[str, Any] = {
        "sub": subject,
        "exp": expire,
        "iat": now,
    }

    if extra_claims:
        to_encode.update(extra_claims)

    return jwt.encode(
        to_encode,
        settings.jwt_secret,
        algorithm=settings.jwt_algorithm
    )


def decode_token(token: str) -> dict[str, Any]:
    try:
        return jwt.decode(
            token,
            settings.jwt_secret,
            algorithms=[settings.jwt_algorithm]
        )
    except JWTError:
        raise ValueError("Invalid token")


def create_refresh_token(subject: str) -> str:
    expire = datetime.now(timezone.utc) + timedelta(days=settings.refresh_token_expire_days)
    to_encode: dict[str, Any] = {
        "sub": subject,
        "exp": expire,
        "type": "refresh"
    }
    return jwt.encode(
        to_encode,
        settings.refresh_token_secret,
        algorithm=settings.jwt_algorithm
    )


def decode_refresh_token(token: str) -> dict[str, Any]:
    try:
        payload = jwt.decode(
            token,
            settings.refresh_token_secret,
            algorithms=[settings.jwt_algorithm]
        )
    except JWTError:
        raise ValueError("Invalid refresh token")

    if payload.get("type") != "refresh":
        raise ValueError("Not a refresh token")

    return payload


oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")


def get_current_user(token: str = Depends(oauth2_scheme)) -> dict:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = decode_token(token)
        user_id: str = payload.get("sub")
        if user_id is None:
            raise credentials_exception
    except ValueError:
        raise credentials_exception

    from bson import ObjectId
    db = get_db()
    user = db.users.find_one({"_id": ObjectId(user_id)})
    if user is None:
        raise credentials_exception

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
            raise credentials_exception

    user["_id"] = str(user["_id"])
    return user
