# Artisans Marketplace - Added Session Persistence and Image Upload

## What was added
- Persistent login using `shared_preferences`
- Product image upload flow using Flutter `image_picker`
- FastAPI multipart upload endpoint
- Static file serving for uploaded product images

## Backend setup
```bash
cd BackEnd
python -m venv .venv
source .venv/bin/activate (For git)
.\.venv\Scripts\Activate.ps1 (For windows)
pip install -r requirements.txt
uvicorn app.main:app --reload
```

Uploaded images are stored in:
- `BackEnd/uploads/`

They are served from:
- `http://<host>:8000/uploads/<filename>`

## Frontend setup
```bash
cd FrontEnd
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

For a physical phone, replace `10.0.2.2` with your machine IP.

## How product images work
1. Artisan opens Add Product or Edit Product
2. Tap **Pick product image**
3. Choose image from gallery
4. App uploads it to FastAPI
5. Returned URL is saved into the product

## Notes
- Uploads currently allow JPG, JPEG, PNG, WEBP
- Max upload size is 5 MB
- Session restore uses locally stored token + user snapshot
- For production, move uploads to S3 or Cloudinary and add token refresh
