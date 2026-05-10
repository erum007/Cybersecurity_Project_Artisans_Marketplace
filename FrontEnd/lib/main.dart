import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/models.dart';
import 'screens/app_screens.dart';
import 'screens/buyer/buyer_screens.dart';
import 'screens/buyer/product_screens.dart';
import 'screens/seller/seller_screens.dart';
import 'screens/shared/profile_screens.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ArtisansMarketplaceApp());
}

class ArtisansMarketplaceApp extends StatelessWidget {
  const ArtisansMarketplaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..bootstrap(),
      child: MaterialApp(
        title: 'Artisans Marketplace',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const RootScreen(),
        routes: {
          '/home': (context) => const BuyerHomeScreen(),
          '/catalog': (context) => const CatalogScreen(),
          '/shops': (context) => const ShopsScreen(),
          '/about': (context) => const AboutUsScreen(),
          '/checkout': (context) => const CheckoutScreen(),
          '/cart': (context) => const CartScreen(),
          '/finances': (context) => const FinancesScreen(),
          '/manage-orders': (context) => const ManageOrdersScreen(),
          '/reviews': (context) {
            final reviews = ModalRoute.of(context)?.settings.arguments as List<Review>?;
            return ReviewsScreen(reviews: reviews);
          },
          '/edit-product': (context) {
            final product = ModalRoute.of(context)?.settings.arguments as Product?;
            return EditProductScreen(product: product);
          },
          '/profile': (context) => const ProfileScreen(),
          '/profile-account': (context) => const AccountSecurityScreen(),
          '/profile-contact': (context) => const ContactDetailsScreen(),
          '/profile-communication': (context) => const CommunicationScreen(),
          '/orders': (context) => const OrderHistoryScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/product') {
            final product = settings.arguments as Product;
            return MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            );
          }
          if (settings.name == '/view-shop') {
            final shop = settings.arguments as Shop;
            return MaterialPageRoute(
              builder: (context) => ViewShopScreen(shop: shop),
            );
          }
          return null;
        },
      ),
    );
  }
}