Project for the Cybersecurity course at Habib University.

# 🛍️ Artisans Marketplace — Flutter App

A mobile ecommerce app connecting local artisans with buyers. Built with Flutter for Android.

---
# Meet The Team

### Erum Naushad 
### Work Done:
Password strength validation, JWT token expiry setup, setting up ci.yml pipeline, DAST and setting up nginx config as a result, and completing relevant report sections.

### Khadija Abbas 
### Work Done:
SAST, completing relevant report sections.

### Roshaan Khan 
### Work Done:
SCA, completing relevant report sections.

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

### Note: App can also be run on the web by exposing frontend and backend to different servers and then running in browser.

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

## 🔧 Details

### User roles
The app supports three roles:
- **Buyer**: Home → Catalog → Product → Checkout
- **Seller**: Finances → Manage Orders → Edit Products
- **Admin**: View Dashboard With Metrics of Customer and Seller (number/amount earned)


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
cd Backend
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

## Run locally
```bash
cd Frontend
flutter pub get (if not done)
cp .env.example .env
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

## Gaps still left for production
- Payment gateway integration
- Image uploads to S3 / Cloudinary
- Pagination and richer filtering
- Email / OTP verification

## Database Setup
1. Ensure MongoDB Compass is running on your machine.
2. Install dependencies: `pip install -r reqs.txt`
3. Initialize the database through the python file in Database/sample_data/DBinit/py


# Artisans Marketplace - Dockerized
1. Run Notepad as Administrator. Click File->Open and Enter Path C:/[User_Name]/Windows/System32/drivers/etc/hosts and at the end of the file, add 127.0.0.1 artisan.marketplace
2. Save and Close.
3. Clone repository.
4. Navigate to project root through terminal of choice.
6. Run docker compose up -d (after installing and setting up Docker).
7. Run https://artisans.marketplace in browser.






