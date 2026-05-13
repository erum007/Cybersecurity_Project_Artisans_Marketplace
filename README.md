Project for the Cybersecurity course at Habib University.

# 🛍️ Artisans Marketplace — Flutter App

A mobile ecommerce app connecting local artisans with buyers. Built with Flutter for Android.

---

## 📱 Screens Implemented

### Auth Flow
| Screen | File |
|--------|------|
| Register | `lib/screens/auth/auth_screens.dart` |
| Forgot Password | `lib/screens/auth/auth_screens.dart` |
| Verify Code | `lib/screens/auth/auth_screens.dart` |

### Buyer Flow
| Screen | File |
|--------|------|
| Home | `lib/screens/buyer/buyer_screens.dart` |
| Browse Catalog | `lib/screens/buyer/buyer_screens.dart` |
| Shops | `lib/screens/buyer/buyer_screens.dart` |
| View Shop | `lib/screens/buyer/buyer_screens.dart` |
| About Us | `lib/screens/buyer/buyer_screens.dart` |
| Product Detail | `lib/screens/buyer/product_screens.dart` |
| Checkout | `lib/screens/buyer/product_screens.dart` |

### Seller Flow
| Screen | File |
|--------|------|
| Finances Dashboard | `lib/screens/seller/seller_screens.dart` |
| Manage Orders | `lib/screens/seller/seller_screens.dart` |
| Reviews | `lib/screens/seller/seller_screens.dart` |
| Product Detail (Seller) | `lib/screens/buyer/product_screens.dart` |
| Edit Product | `lib/screens/seller/seller_screens.dart` |
| Add New Product | `lib/screens/seller/seller_screens.dart` |

### Profile Flow
| Screen | File |
|--------|------|
| Profile (Collapsed) | `lib/screens/shared/profile_screens.dart` |
| Account & Security | `lib/screens/shared/profile_screens.dart` |
| Contact Details | `lib/screens/shared/profile_screens.dart` |
| Communication | `lib/screens/shared/profile_screens.dart` |

---

## 🗂️ Project Structure

```
artisans_marketplace/
├── lib/
│   ├── main.dart                        # App entry + router
│   ├── theme/
│   │   └── app_theme.dart               # Colors, typography, component themes
│   ├── models/
│   │   └── models.dart                  # Data models + sample data
│   ├── widgets/
│   │   └── widgets.dart                 # Reusable UI components
│   └── screens/
│       ├── auth/
│       │   └── auth_screens.dart
│       ├── buyer/
│       │   ├── buyer_screens.dart
│       │   └── product_screens.dart
│       ├── seller/
│       │   └── seller_screens.dart
│       └── shared/
│           └── profile_screens.dart
├── pubspec.yaml
└── README.md
```

---

## 🎨 Design System

- **Primary Color**: `#E53E2F` (Artisan Red)
- **Secondary Color**: `#3D4B8F` (Navy Blue) — used for CTA buttons
- **Typography**: Material 3 defaults with custom weights
- **Bottom Nav**: 4 tabs — Home, Search, Sell Goods, Cart

---

## 🚀 Setup & Run

### Prerequisites
- Flutter SDK ≥ 3.0.0
- Android Studio / VS Code
- Android emulator or physical device

### Steps

```bash
# 1. Navigate to project
cd artisans_marketplace

# 2. Get dependencies
flutter pub get

# 3. Create assets folder
mkdir -p assets/images

# 4. Run on Android
flutter run
```

### Build APK
```bash
flutter build apk --release
```
APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

---

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| `provider` | State management |
| `go_router` | Navigation |
| `cached_network_image` | Image caching |
| `fl_chart` | Charts (finances screen) |
| `smooth_page_indicator` | Carousel dots |
| `flutter_rating_bar` | Star ratings |

---

## 🗺️ Navigation Routes

| Route | Screen |
|-------|--------|
| `/register` | Registration |
| `/forgot-password` | Forgot Password |
| `/verify` | Verification Code |
| `/home` | Buyer Home |
| `/catalog` | Browse Products |
| `/shops` | All Shops |
| `/view-shop` | Shop Detail (pass `Shop` arg) |
| `/about` | About Us |
| `/product` | Product Detail (pass `Product` arg) |
| `/checkout` | Checkout |
| `/finances` | Seller Dashboard |
| `/manage-orders` | Order Management |
| `/reviews` | Reviews |
| `/edit-product` | Edit/Add Product |
| `/profile` | Profile |
| `/profile-account` | Account & Security |
| `/profile-contact` | Contact Details |
| `/profile-communication` | Notifications |

---

## 🔧 Customization

### Swap sample data for real API
Replace `SampleData` in `lib/models/models.dart` with API calls via your preferred HTTP client (`http`, `dio`).

### Add real images
Replace `NetworkImage` URLs with `AssetImage` paths under `assets/images/` and update `pubspec.yaml` accordingly.

### User roles
The app supports two roles out of the box:
- **Buyer**: Home → Catalog → Product → Checkout
- **Seller**: Finances → Manage Orders → Edit Products


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


## Frontend wiring
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

## Database Setup
1. Ensure MongoDB Compass is running on your machine.
2. Install dependencies: `pip install -r reqs.txt`
3. Initialize the database through the python file

##  Import Data
1. Enter mongodb://localhost:27017/ in browser address bar.
2. Compass will open up and show the SE-Marketplace database that you created during the setup.
3. Click on the name of any collection (Users, Artisans, Reviews, Products, Categories, Orders) and then the green + icon and click on "Import JSON or CSV file".
4. Select the respective JSON file in the sample_data folder for the respective collection (artisans.json for Artisans collection and so on for all 6).

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
<!-- - `http://<host>:8000/uploads/<filename>` -->
[https://artisan.marketplace/uploads/]

## Frontend setup
```bash
cd FrontEnd
flutter pub get

flutter run --dart-define=API_BASE_URL=[https://artisan.marketplace](https://artisan.marketplace)
# flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
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





