import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../../models/models.dart';

// ── Buyer Home Screen ─────────────────────────────────────────────────────────
class BuyerHomeScreen extends StatefulWidget {
  const BuyerHomeScreen({super.key});

  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Welcome, Customer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20)),
        actions: [
          ProfileAvatarButton(onTap: () => Navigator.pushNamed(context, '/profile')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Row(children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(children: [
                    const SizedBox(width: 12),
                    Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                    const SizedBox(width: 8),
                    Text('Search for product', style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
                  ]),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.tune, color: Colors.grey.shade600),
              ),
            ]),
            const SizedBox(height: 16),

            // Category Circles
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: SampleData.categories.length,
                itemBuilder: (context, index) {
                  final imgs = [
                    'https://images.unsplash.com/photo-1600166898405-da9535204843?w=200',
                    'https://images.unsplash.com/photo-1565193566173-7a0ee3dbe261?w=200',
                    'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=200',
                    'https://images.unsplash.com/photo-1549465220-1a8b9238cd48?w=200',
                  ];
                  final borders = [AppTheme.navyBlue, AppTheme.primaryRed, AppTheme.lightGrey, const Color(0xFFD4A017)];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Column(
                      children: [
                        Container(
                          width: 58, height: 58,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: borders[index % borders.length], width: 2.5),
                          ),
                          child: ClipOval(
                            child: Image.network(imgs[index % imgs.length], fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200)),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(SampleData.categories[index], style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Hero Banner
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=600'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Artisans\nMarketplace',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                      SizedBox(height: 4),
                      Text('The one and only\nmarketplace for all!',
                          style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Mission & Shops tiles
            Row(children: [
              Expanded(
                child: _InfoTile(
                  label: 'Our Mission',
                  imageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=300',
                  onTap: () => Navigator.pushNamed(context, '/about'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _InfoTile(
                  label: 'Shops',
                  imageUrl: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=300',
                  onTap: () => Navigator.pushNamed(context, '/shops'),
                ),
              ),
            ]),
            const SizedBox(height: 20),

            // Popular Now
            const SectionHeader(title: 'Popular Now!', actionLabel: 'View all'),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: SampleData.products.take(4).length,
                itemBuilder: (context, index) {
                  final p = SampleData.products[index];
                  return GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/product', arguments: p),
                    child: Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              child: Image.network(p.imageUrl, fit: BoxFit.cover, width: double.infinity,
                                  errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                                Row(children: [
                                  const Icon(Icons.star, color: AppTheme.starYellow, size: 13),
                                  Text(' ${p.rating}  ', style: const TextStyle(fontSize: 12)),
                                  Text('\$${p.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                ]),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _navIndex,
        onTap: (i) {
          setState(() => _navIndex = i);
          if (i == 1) Navigator.pushNamed(context, '/catalog');
          if (i == 2) Navigator.pushNamed(context, '/sell-product');
          if (i == 3) Navigator.pushNamed(context, '/checkout');
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String imageUrl;
  final VoidCallback? onTap;
  const _InfoTile({required this.label, required this.imageUrl, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
              colorFilter: const ColorFilter.mode(Colors.black38, BlendMode.darken),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A017),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Catalog Screen ────────────────────────────────────────────────────────────
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Local Products'),
        actions: const [ProfileAvatarButton()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search
            Row(children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                  child: Row(children: [
                    const SizedBox(width: 12),
                    Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                    const SizedBox(width: 8),
                    Text('Search', style: TextStyle(color: Colors.grey.shade400)),
                  ]),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.tune, color: Colors.grey.shade600),
              ),
            ]),
            const SizedBox(height: 16),

            // Featured banner
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'https://images.unsplash.com/photo-1600166898405-da9535204843?w=600',
                width: double.infinity, height: 160, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(height: 160, color: Colors.grey.shade200),
              ),
            ),
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(4, (i) =>
              Container(width: i == 0 ? 20 : 8, height: 8, margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(color: i == 0 ? AppTheme.navyBlue : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4))))),
            const SizedBox(height: 16),

            // Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.75,
              ),
              itemCount: SampleData.products.length,
              itemBuilder: (context, index) => ProductCard(
                product: SampleData.products[index],
                onTap: () => Navigator.pushNamed(context, '/product', arguments: SampleData.products[index]),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity, height: 44,
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
              child: const Center(child: Text('See all', style: TextStyle(color: Colors.black54))),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(currentIndex: 1, onTap: (_) {}),
    );
  }
}

// ── Shops Screen ──────────────────────────────────────────────────────────────
class ShopsScreen extends StatelessWidget {
  const ShopsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        actions: const [ProfileAvatarButton()],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // View All Shops banner
            GestureDetector(
              child: Container(
                height: 160, width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=600'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.black, BlendMode.darken),
                  ),
                ),
                child: const Center(
                  child: Text('View All Shops', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.9,
                    ),
                    itemCount: SampleData.shops.length,
                    itemBuilder: (context, index) {
                      final shop = SampleData.shops[index];
                      return GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/view-shop', arguments: shop),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(shop.imageUrl, fit: BoxFit.cover, width: double.infinity,
                                    errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200)),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(children: [
                              Text(shop.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                              const SizedBox(width: 4),
                              Icon(Icons.chevron_right, size: 16, color: Colors.grey.shade500),
                            ]),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 80, width: double.infinity,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage('https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=600'),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
                        ),
                      ),
                      child: const Center(
                        child: Text('Support Local Artists!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(currentIndex: 0, onTap: (_) {}),
    );
  }
}

// ── View Shop Screen ──────────────────────────────────────────────────────────
class ViewShopScreen extends StatelessWidget {
  final Shop shop;
  const ViewShopScreen({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    final shopProducts = SampleData.products.where((p) => p.shopId == shop.id).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('View Shop'),
        actions: const [ProfileAvatarButton()],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner
            Stack(
              clipBehavior: Clip.none,
              children: [
                Image.network(shop.imageUrl, width: double.infinity, height: 140, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(height: 140, color: Colors.grey.shade300)),
                Positioned(
                  bottom: -30,
                  left: 16,
                  child: Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: ClipOval(
                      child: Image.network(shop.ownerImageUrl, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade300, child: const Icon(Icons.person, color: Colors.grey))),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(shop.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(shop.bio, style: const TextStyle(fontSize: 14, height: 1.5)),
                  ),
                  const SizedBox(height: 20),
                  SectionHeader(title: 'Products by ${shop.name}', actionLabel: 'View all'),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: shopProducts.isEmpty ? SampleData.products.take(3).length : shopProducts.take(3).length,
                      itemBuilder: (context, index) {
                        final p = shopProducts.isEmpty ? SampleData.products[index] : shopProducts[index];
                        return GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/product', arguments: p),
                          child: Container(
                            width: 130, margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                    child: Image.network(p.imageUrl, fit: BoxFit.cover, width: double.infinity,
                                        errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200)),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    Row(children: [
                                      const Icon(Icons.star, color: AppTheme.starYellow, size: 12),
                                      Text(' ${p.rating}  \$${p.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11)),
                                    ]),
                                  ]),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(currentIndex: 0, onTap: (_) {}),
    );
  }
}

// ── About Us Screen ───────────────────────────────────────────────────────────
class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        actions: const [ProfileAvatarButton()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 160, width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=600'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.black, BlendMode.darken),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Artisans\nMarketplace', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                      SizedBox(height: 4),
                      Text('The one and only\nmarketplace for all!', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "At Artisan's Marketplace, we believe that the best things aren't made in factories—they're made in the spare bedrooms, backyard sheds, and sun-drenched studios of our neighbors.\n\nOur platform was born out of a simple realization: our community is overflowing with talent, but many of our best local makers didn't have a digital storefront to call home. We decided to build them one.\n\nBy bringing together a curated collective of local artisans, we've created a space where you can support a small business with every click. When you shop with us, you aren't just buying a \"product.\" You're supporting a craft, preserving a tradition, and helping a local artist keep doing what they love.",
                style: TextStyle(fontSize: 14, height: 1.6),
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 80, width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=600'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
                  ),
                ),
                child: const Center(
                  child: Text('Support Local Artists!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(currentIndex: 0, onTap: (_) {}),
    );
  }
}
