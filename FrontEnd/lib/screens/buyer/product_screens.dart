import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';

// Removed local _resolveImageUrl in favor of global resolveImageUrl from widgets.dart


// ── Product Detail Screen (Buyer) ─────────────────────────────────────────────
class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});
    
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _qty = 1;
  String _selectedSize = 'M';
  int _selectedColor = 1;
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showAddReviewDialog() {
    final commentController = TextEditingController();
    double rating = 5.0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Leave a Review', style: TextStyle(fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your rating', style: TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) => GestureDetector(
                  onTap: () => setDialogState(() => rating = (index + 1).toDouble()),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      (index + 1) <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: AppTheme.starYellow,
                      size: 36,
                    ),
                  ),
                )),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  ['', 'Poor', 'Fair', 'Good', 'Great', 'Excellent!'][rating.toInt()],
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.starYellow,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text('Your comment', style: TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 6),
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: 'Tell others what you think...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.all(12),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (commentController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please write a comment')),
                  );
                  return;
                }
                try {
                  await context.read<AppState>().addReview(
                    widget.product.id,
                    rating: rating,
                    comment: commentController.text.trim(),
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Review submitted! Thank you.')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
                    );
                  }
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    // Find product in state to get fresh review data
    final p = state.products.firstWhere((element) => element.id == widget.product.id, orElse: () => widget.product);
    final totalPrice = p.price * _qty;
    final sizes = p.sizes.isNotEmpty ? p.sizes : ['XS', 'S', 'M', 'L', 'XL'];
    final colors = [
      const Color(0xFF8B6914),
      AppTheme.primaryRed,
      const Color(0xFFF5DEB3)
    ];

    // Any logged-in customer can leave a review
    final bool canReview = state.isCustomer;

    return Scaffold(
      appBar: AppBar(
        title: Text(p.name),
        actions: const [ProfileAvatarButton()],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Gallery
            SizedBox(
              height: 300,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: p.imageUrls.length,
                    onPageChanged: (index) => setState(() => _currentImageIndex = index),
                    itemBuilder: (context, index) => CachedNetworkImage(
                      imageUrl: resolveImageUrl(p.imageUrls[index]),
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.grey[200]),
                      errorWidget: (context, url, error) => Container(color: Colors.grey[200], child: const Icon(Icons.error)),
                    ),
                  ),
                  if (p.imageUrls.length > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          p.imageUrls.length,
                          (index) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImageIndex == index ? AppTheme.primaryRed : Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Thumbnail row
            if (p.imageUrls.length > 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: p.imageUrls.length,
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () {
                        setState(() => _currentImageIndex = index);
                        _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      },
                      child: Container(
                        width: 60,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _currentImageIndex == index ? AppTheme.primaryRed : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: CachedNetworkImage(
                            imageUrl: resolveImageUrl(p.imageUrls[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price
                  Text('${p.currency}${p.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name.isEmpty ? 'Red Persian Rug' : p.name,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(p.description,
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 12),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      Row(children: [
                        const Icon(Icons.star,
                            color: AppTheme.starYellow, size: 18),
                        const SizedBox(width: 4),
                        Text('${p.rating}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15)),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Color selector
                  const Text('Color',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                      children: List.generate(
                          colors.length,
                          (i) => GestureDetector(
                                onTap: () => setState(() => _selectedColor = i),
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: colors[i],
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _selectedColor == i
                                          ? Colors.black
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ))),
                  const SizedBox(height: 14),

                  // Size selector
                  const Text('Size',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                      children: sizes
                          .map((s) => GestureDetector(
                                onTap: () => setState(() => _selectedSize = s),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _selectedSize == s
                                        ? Colors.grey.shade200
                                        : Colors.white,
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(s,
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: _selectedSize == s
                                              ? FontWeight.w700
                                              : FontWeight.normal)),
                                ),
                              ))
                          .toList()),
                  const SizedBox(height: 14),

                  // Quantity
                  const Text('Quantity',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _QtyButton(
                          icon: Icons.remove,
                          onTap: () {
                            if (_qty > 1) setState(() => _qty--);
                          }),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('$_qty',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                      _QtyButton(
                          icon: Icons.add, onTap: () => setState(() => _qty++)),
                      const Spacer(),
                      Text(
                          'Total  ${p.currency}${totalPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Reviews
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Reviews (${p.reviews.length})',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                      if (canReview)
                        TextButton(
                          onPressed: _showAddReviewDialog,
                          child: const Text('Add Review'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (p.reviews.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                      child: Column(children: [
                        Icon(Icons.rate_review_outlined, size: 32, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text(
                          canReview ? 'Be the first to review this product!' : 'No reviews yet.',
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ]),
                    )
                  else
                    ...p.reviews.map((r) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              StarRating(rating: r.rating, size: 14),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  r.userName,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '${r.date.day}/${r.date.month}/${r.date.year}',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(r.comment, style: const TextStyle(fontSize: 13, height: 1.4)),
                        ],
                      ),
                    )),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/reviews', arguments: p.reviews),
                    child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('View All Reviews',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13, color: Colors.blue)),
                          Icon(Icons.chevron_right, size: 20, color: Colors.blue),
                        ]),
                  ),
                  const Divider(height: 24),
                  const SizedBox(height: 8),
                  NavyButton(
                    label: 'Add to cart',
                    icon: Icons.shopping_cart_outlined,
                    onPressed: () async {
                      try {
                        await context.read<AppState>().addToCart(p, quantity: _qty);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Added to cart!')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/home');
          if (index == 1) Navigator.pushReplacementNamed(context, '/catalog');
          if (index == 3) Navigator.pushNamed(context, '/cart');
        },
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}

// ── Seller Product Detail ──────────────────────────────────────────────────────
class SellerProductDetailScreen extends StatefulWidget {
  final Product product;
  const SellerProductDetailScreen({super.key, required this.product});

  @override
  State<SellerProductDetailScreen> createState() => _SellerProductDetailScreenState();
}

class _SellerProductDetailScreenState extends State<SellerProductDetailScreen> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final p = state.products.firstWhere((element) => element.id == widget.product.id, orElse: () => widget.product);
    final colors = [
      const Color(0xFF8B6914),
      AppTheme.primaryRed,
      const Color(0xFFF5DEB3)
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(p.name),
        actions: [
          const Icon(Icons.shopping_cart_outlined),
          const SizedBox(width: 8),
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 8),
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: ClipOval(
              child: Image.network(
                  'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.person, size: 16))),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Gallery
            SizedBox(
              height: 300,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: p.imageUrls.length,
                    onPageChanged: (index) => setState(() => _currentImageIndex = index),
                    itemBuilder: (context, index) => CachedNetworkImage(
                      imageUrl: resolveImageUrl(p.imageUrls[index]),
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.grey[200]),
                      errorWidget: (context, url, error) => Container(color: Colors.grey[200], child: const Icon(Icons.error)),
                    ),
                  ),
                  if (p.imageUrls.length > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          p.imageUrls.length,
                          (index) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImageIndex == index ? AppTheme.primaryRed : Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (p.imageUrls.length > 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: p.imageUrls.length,
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () {
                        setState(() => _currentImageIndex = index);
                        _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      },
                      child: Container(
                        width: 60,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _currentImageIndex == index ? AppTheme.primaryRed : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: CachedNetworkImage(
                            imageUrl: resolveImageUrl(p.imageUrls[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('\$${p.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Row(children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(p.description,
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 12)),
                          ]),
                    ),
                    Row(children: [
                      const Icon(Icons.star,
                          color: AppTheme.starYellow, size: 18),
                      Text(' ${p.rating}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                    ]),
                  ]),
                  const SizedBox(height: 14),
                  const Text('Color',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                      children: List.generate(
                          colors.length,
                          (i) => Container(
                                width: 28,
                                height: 28,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                    color: colors[i], shape: BoxShape.circle),
                              ))),
                  const SizedBox(height: 14),
                  const Text('Size',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                      children: ['XS', 'S', 'M', 'L', 'XL']
                          .map((s) => Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: s == 'M'
                                      ? Colors.grey.shade200
                                      : Colors.white,
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(s,
                                    style: const TextStyle(fontSize: 13)),
                              ))
                          .toList()),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/reviews', arguments: p.reviews),
                    child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('View All Reviews',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13, color: Colors.blue)),
                          Icon(Icons.chevron_right, size: 20, color: Colors.blue),
                        ]),
                  ),
                  const Divider(height: 24),
                  const SizedBox(height: 8),
                  NavyButton(
                    label: 'Edit Details',
                    icon: Icons.edit_outlined,
                    onPressed: () => Navigator.pushNamed(
                        context, '/edit-product',
                        arguments: p),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          AppBottomNavBar(currentIndex: 0, isSeller: true, onTap: (_) {}),
    );
  }
}