# Artisans Marketplace Backend

FastAPI + MongoDB backend for the artisan marketplace app.

## What is included
- JWT auth for customer, artisan, and admin roles
- Product catalog CRUD
- Customer cart
- Checkout and order history
- Artisan order management
- Admin dashboard API

## Run locally
```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
uvicorn app.main:app --reload
```

## Seed sample data
Place this folder next to `SE-Proj-main` or update the seed path, then run:
```bash
python -m scripts.seed
```

## Suggested frontend wiring
- Register / login screens -> `/api/v1/auth/register`, `/api/v1/auth/login`
- Catalog / product detail -> `/api/v1/products`
- Add to cart / checkout -> `/api/v1/cart`, `/api/v1/orders/checkout`
- Artisan screens -> `/api/v1/products`, `/api/v1/orders/artisan`
- Admin portal -> build a small web panel against `/api/v1/admin/dashboard`

## Gaps still left for production
- Payment gateway integration
- Image uploads to S3 / Cloudinary
- Pagination and richer filtering
- Email / OTP verification
- Audit logs and admin user management
- Automated tests and CI/CD
