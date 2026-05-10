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
