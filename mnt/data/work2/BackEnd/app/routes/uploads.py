from pathlib import Path
from secrets import token_hex

from fastapi import APIRouter, Depends, File, HTTPException, UploadFile, status

from app.services.deps import require_roles

router = APIRouter(prefix='/uploads', tags=['uploads'])

ALLOWED_SUFFIXES = {'.jpg', '.jpeg', '.png', '.webp'}
MAX_FILE_SIZE = 5 * 1024 * 1024
UPLOAD_DIR = Path('uploads')
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)


@router.post('/image', status_code=status.HTTP_201_CREATED)
async def upload_image(file: UploadFile = File(...), user=Depends(require_roles('artisan', 'admin'))):
    suffix = Path(file.filename or '').suffix.lower()
    if suffix not in ALLOWED_SUFFIXES:
        raise HTTPException(status_code=400, detail='Only JPG, PNG, and WEBP images are allowed')

    data = await file.read()
    if not data:
        raise HTTPException(status_code=400, detail='Empty file upload')
    if len(data) > MAX_FILE_SIZE:
        raise HTTPException(status_code=400, detail='Image must be 5MB or smaller')

    safe_name = f"{token_hex(16)}{suffix}"
    destination = UPLOAD_DIR / safe_name
    destination.write_bytes(data)

    return {
        'filename': safe_name,
        'url': f'/uploads/{safe_name}',
        'uploaded_by': user['_id'],
    }
