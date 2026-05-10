import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
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
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final userName = state.user?.fullName.split(' ').first ?? 'Customer';
    final allProducts = state.products;
    final categories = state.categories;

    // Filter by selected category
    final filteredProducts = _selectedCategory == null
        ? allProducts
        : allProducts.where((p) => p.category == _selectedCategory).toList();

    // Popular products: show first 4
    final popularProducts = filteredProducts.take(4).toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Welcome, $userName',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20),
        ),
        actions: [
          ProfileAvatarButton(
              onTap: () => Navigator.pushNamed(context, '/profile')),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => state.loadProducts(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar (tappable, navigates to catalog)
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/catalog'),
                child: Row(children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(children: [
                        const SizedBox(width: 12),
                        Icon(Icons.search,
                            color: Colors.grey.shade400, size: 20),
                        const SizedBox(width: 8),
                        Text('Search for product',
                            style: TextStyle(
                                color: Colors.grey.shade400, fontSize: 14)),
                      ]),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.tune, color: Colors.grey.shade600),
                  ),
                ]),
              ),
              const SizedBox(height: 16),

              // Category Circles
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = _selectedCategory == cat;
                    final borders = [
                      AppTheme.navyBlue,
                      AppTheme.primaryRed,
                      AppTheme.lightGrey,
                      const Color(0xFFD4A017),
                      AppTheme.navyBlue,
                      AppTheme.primaryRed,
                      AppTheme.lightGrey,
                    ];
                    final imgs = [
                      'https://images.unsplash.com/photo-1600166898405-da9535204843?w=200',
                      'https://images.unsplash.com/photo-1565193566173-7a0ee3dbe261?w=200',
                      'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=200',
                      'https://images.unsplash.com/photo-1549465220-1a8b9238cd48?w=200',
                      'https://images.unsplash.com/photo-1600166898405-da9535204843?w=200',
                      'https://images.unsplash.com/photo-1565193566173-7a0ee3dbe261?w=200',
                      'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=200',
                    ];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = isSelected ? null : cat;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Column(
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.primaryRed
                                      : borders[index % borders.length],
                                  width: isSelected ? 3.5 : 2.5,
                                ),
                              ),
                              child: ClipOval(
                                child: Image.network(
                                  resolveImageUrl(imgs[index % imgs.length]),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      Container(color: Colors.grey.shade200),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(cat,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? AppTheme.primaryRed
                                      : Colors.black87,
                                )),
                          ],
                        ),
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
                    image: DecorationImage(
                      image: NetworkImage(
                          resolveImageUrl('https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=600')),
                      fit: BoxFit.cover,
                      colorFilter:
                          const ColorFilter.mode(Colors.black45, BlendMode.darken),
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
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800)),
                        SizedBox(height: 4),
                        Text('The one and only\nmarketplace for all!',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 13)),
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
                    imageUrl:
                        resolveImageUrl('https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=300'),
                    onTap: () => Navigator.pushNamed(context, '/about'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _InfoTile(
                    label: 'Shops',
                    imageUrl:
                        resolveImageUrl('https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=300'),
                    onTap: () => Navigator.pushNamed(context, '/shops'),
                  ),
                ),
              ]),
              const SizedBox(height: 20),

              // Popular Now — real products in grid
              SectionHeader(
                title: _selectedCategory != null
                    ? _selectedCategory!
                    : 'Popular Now!',
                actionLabel: 'View all',
                onAction: () => Navigator.pushNamed(context, '/catalog'),
              ),
              const SizedBox(height: 12),

              if (state.isBusy && allProducts.isEmpty)
                const Center(
                    child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: CircularProgressIndicator(),
                ))
              else if (popularProducts.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      _selectedCategory != null
                          ? 'No products in this category yet.'
                          : 'No products available.',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: popularProducts.length,
                  itemBuilder: (context, index) {
                    final p = popularProducts[index];
                    return ProductCard(
                      product: p,
                      onTap: () =>
                          Navigator.pushNamed(context, '/product', arguments: p),
                      onAddToCart: () async {
                        try {
                          await state.addToCart(p);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('${p.name} added to cart'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(state.error ?? 'Error adding to cart')),
                            );
                          }
                        }
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _navIndex,
        onTap: (i) {
          if (i == 0) {
            setState(() => _navIndex = 0);
            Navigator.pushReplacementNamed(context, '/home');
          }
          if (i == 1) Navigator.pushNamed(context, '/catalog');
          if (i == 2) Navigator.pushNamed(context, '/profile');
          if (i == 3) Navigator.pushNamed(context, '/cart');
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
              image: NetworkImage(resolveImageUrl(imageUrl)),
              fit: BoxFit.cover,
              colorFilter:
                  const ColorFilter.mode(Colors.black38, BlendMode.darken),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A017),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Catalog / Search Screen ───────────────────────────────────────────────────
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String? _selectedCategory;
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadProducts();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _search(AppState state) async {
    setState(() => _searching = true);
    await state.loadProducts(
      search: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
      category: _selectedCategory == 'All' ? null : _selectedCategory,
    );
    setState(() => _searching = false);
  }

  /// Instantly filter products locally so results appear as the user types.
  List<Product> _localFilter(List<Product> all) {
    final query = _searchCtrl.text.trim().toLowerCase();
    return all.where((p) {
      final matchesQuery = query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          p.description.toLowerCase().contains(query) ||
          p.artisanName.toLowerCase().contains(query) ||
          p.category.toLowerCase().contains(query);
      final matchesCat = _selectedCategory == null ||
          _selectedCategory == 'All' ||
          p.category == _selectedCategory;
      return matchesQuery && matchesCat;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final categories = ['All', ...state.categories];

    // Use local filter for instant results — no waiting for API
    final products = _localFilter(state.products);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Local Products'),
        actions: const [ProfileAvatarButton()],
      ),
      body: Column(
        children: [
          // Search + filter bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(children: [
                    const SizedBox(width: 12),
                    Icon(Icons.search,
                        color: Colors.grey.shade400, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(
                          hintText: 'Search products…',
                          hintStyle: TextStyle(
                              color: Colors.grey.shade400, fontSize: 14),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        textInputAction: TextInputAction.search,
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) => _search(state),
                      ),
                    ),
                    if (_searchCtrl.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchCtrl.clear();
                          _search(state);
                        },
                        child:
                            Icon(Icons.close, color: Colors.grey.shade400, size: 18),
                      ),
                    const SizedBox(width: 8),
                  ]),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _search(state),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                      color: AppTheme.navyBlue,
                      borderRadius: BorderRadius.circular(10)),
                  child:
                      const Icon(Icons.search, color: Colors.white, size: 20),
                ),
              ),
            ]),
          ),

          // Category chips
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = (_selectedCategory ?? 'All') == cat;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat == 'All' ? null : cat;
                    });
                    // Trigger API search with category
                    _search(state);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.navyBlue
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Product grid
          Expanded(
            child: _searching || (state.isBusy && state.products.isEmpty)
                ? const Center(child: CircularProgressIndicator())
                : products.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off,
                                size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              'No products found.',
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                            if (_searchCtrl.text.isNotEmpty ||
                                _selectedCategory != null) ...[
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() => _selectedCategory = null);
                                  state.loadProducts();
                                },
                                child: const Text('Clear filters'),
                              ),
                            ]
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => _search(state),
                        child: GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final p = products[index];
                            return ProductCard(
                              product: p,
                              onTap: () => Navigator.pushNamed(
                                  context, '/product',
                                  arguments: p),
                              onAddToCart: () async {
                                try {
                                  await state.addToCart(p);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('${p.name} added to cart'),
                                        duration:
                                            const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                          content: Text(state.error ??
                                              'Error adding to cart')),
                                    );
                                  }
                                }
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 1,
        onTap: (i) {
          if (i == 0) Navigator.pushReplacementNamed(context, '/home');
          if (i == 1) Navigator.pushReplacementNamed(context, '/catalog');
          if (i == 2) Navigator.pushNamed(context, '/profile');
          if (i == 3) Navigator.pushNamed(context, '/cart');
        },
      ),
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
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                        resolveImageUrl('https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=600')),
                    fit: BoxFit.cover,
                    colorFilter:
                        const ColorFilter.mode(Colors.black, BlendMode.darken),
                  ),
                ),
                child: const Center(
                  child: Text('View All Shops',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800)),
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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: SampleData.shops.length,
                    itemBuilder: (context, index) {
                      final shop = SampleData.shops[index];
                      return GestureDetector(
                        onTap: () => Navigator.pushNamed(
                            context, '/view-shop',
                            arguments: shop),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(resolveImageUrl(shop.imageUrl),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (_, __, ___) =>
                                        Container(color: Colors.grey.shade200)),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(children: [
                              Text(shop.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14)),
                              const SizedBox(width: 4),
                              Icon(Icons.chevron_right,
                                  size: 16, color: Colors.grey.shade500),
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
                      height: 80,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                              resolveImageUrl('https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=600')),
                          fit: BoxFit.cover,
                          colorFilter: const ColorFilter.mode(
                              Colors.black45, BlendMode.darken),
                        ),
                      ),
                      child: const Center(
                        child: Text('Support Local Artists!',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 0,
        onTap: (i) {
          if (i == 0) Navigator.pushReplacementNamed(context, '/home');
          if (i == 1) Navigator.pushNamed(context, '/catalog');
          if (i == 2) Navigator.pushNamed(context, '/profile');
          if (i == 3) Navigator.pushNamed(context, '/cart');
        },
      ),
    );
  }
}

// ── View Shop Screen ──────────────────────────────────────────────────────────
class ViewShopScreen extends StatelessWidget {
  final Shop shop;
  const ViewShopScreen({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    // Use real products from AppState filtered by artisanId matching shopId
    final state = context.watch<AppState>();
    final shopProducts = state.products
        .where((p) => p.shopId == shop.id || p.artisanId == shop.id)
        .toList();
    final displayProducts =
        shopProducts.isEmpty ? state.products.take(3).toList() : shopProducts.take(3).toList();

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
                Image.network(resolveImageUrl(shop.imageUrl),
                    width: double.infinity,
                    height: 140,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(height: 140, color: Colors.grey.shade300)),
                Positioned(
                  bottom: -30,
                  left: 16,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: ClipOval(
                      child: Image.network(resolveImageUrl(shop.ownerImageUrl),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.person,
                                  color: Colors.grey))),
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
                  Text(shop.name,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(shop.bio,
                        style:
                            const TextStyle(fontSize: 14, height: 1.5)),
                  ),
                  const SizedBox(height: 20),
                  SectionHeader(
                      title: 'Products by ${shop.name}',
                      actionLabel: 'View all'),
                  const SizedBox(height: 12),
                  if (displayProducts.isEmpty)
                    const Text('No products available.',
                        style: TextStyle(color: Colors.grey))
                  else
                    SizedBox(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: displayProducts.length,
                        itemBuilder: (context, index) {
                          final p = displayProducts[index];
                          return GestureDetector(
                            onTap: () => Navigator.pushNamed(
                                context, '/product',
                                arguments: p),
                            child: Container(
                              width: 130,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius:
                                          const BorderRadius.vertical(
                                              top: Radius.circular(10)),
                                      child: Image.network(resolveImageUrl(p.imageUrl),
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                                  color: Colors
                                                      .grey.shade200)),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(p.name,
                                              style: const TextStyle(
                                                  fontWeight:
                                                      FontWeight.w600,
                                                  fontSize: 12),
                                              maxLines: 1,
                                              overflow:
                                                  TextOverflow.ellipsis),
                                          Row(children: [
                                            const Icon(Icons.star,
                                                color: AppTheme.starYellow,
                                                size: 12),
                                            Text(
                                                ' ${p.rating}  ${p.currency}${p.price.toStringAsFixed(0)}',
                                                style: const TextStyle(
                                                    fontSize: 11)),
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
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 0,
        onTap: (i) {
          if (i == 0) Navigator.pushReplacementNamed(context, '/home');
          if (i == 1) Navigator.pushNamed(context, '/catalog');
          if (i == 2) Navigator.pushNamed(context, '/profile');
          if (i == 3) Navigator.pushNamed(context, '/cart');
        },
      ),
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
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                        resolveImageUrl('https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=600')),
                    fit: BoxFit.cover,
                    colorFilter:
                        const ColorFilter.mode(Colors.black, BlendMode.darken),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Artisans\nMarketplace',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800)),
                      SizedBox(height: 4),
                      Text('The one and only\nmarketplace for all!',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 13)),
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
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                        resolveImageUrl('https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=600')),
                    fit: BoxFit.cover,
                    colorFilter:
                        const ColorFilter.mode(Colors.black45, BlendMode.darken),
                  ),
                ),
                child: const Center(
                  child: Text('Support Local Artists!',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800)),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 0,
        onTap: (i) {
          if (i == 0) Navigator.pushReplacementNamed(context, '/home');
          if (i == 1) Navigator.pushNamed(context, '/catalog');
          if (i == 2) Navigator.pushNamed(context, '/profile');
          if (i == 3) Navigator.pushNamed(context, '/cart');
        },
      ),
    );
  }
}