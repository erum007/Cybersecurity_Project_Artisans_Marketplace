"""Generate secure JWT and refresh token secrets for local environment setup."""

from secrets import token_urlsafe


def generate_secret(length: int = 48) -> str:
    return token_urlsafe(length)


if __name__ == "__main__":
    print("# Copy these values into BackEnd/.env or your environment configuration")
    print(f"JWT_SECRET={generate_secret()}")
    print(f"REFRESH_TOKEN_SECRET={generate_secret()}")
