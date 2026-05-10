import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../../models/models.dart';


// ── Product Detail Screen (Buyer) ─────────────────────────────────────────────
class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});
    
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _qty = 2;
  String _selectedSize = 'M';
  int _selectedColor = 1;

  
  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final totalPrice = p.price * _qty;
    final sizes = p.sizes.isNotEmpty ? p.sizes : ['XS', 'S', 'M', 'L', 'XL'];
    final colors = [
      const Color(0xFF8B6914),
      AppTheme.primaryRed,
      const Color(0xFFF5DEB3)
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(p.name),
        actions: const [ProfileAvatarButton()],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main image
            Image.network(p.imageUrl,
                width: double.infinity,
                height: 240,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(height: 240, color: Colors.grey.shade200)),

            // Thumbnail row
            if (p.categories.contains('Rugs'))
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: List.generate(
                      4,
                      (i) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(p.imageUrl,
                                  width: 72,
                                  height: 56,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                      width: 72,
                                      height: 56,
                                      color: Colors.grey.shade200)),
                            ),
                          )),
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
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/reviews'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Reviews (${p.reviewCount})',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 15)),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                  const Divider(height: 24),
                  const SizedBox(height: 8),
                  NavyButton(
                    label: 'Add to cart',
                    icon: Icons.shopping_cart_outlined,
                    onPressed: () {
                      
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(currentIndex: 0, onTap: (_) {},),
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
class SellerProductDetailScreen extends StatelessWidget {
  final Product product;
  const SellerProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final p = product;
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
            Image.network(p.imageUrl,
                width: double.infinity,
                height: 240,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(height: 240, color: Colors.grey.shade200)),
            if (p.categories.contains('Rugs'))
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                    children: List.generate(
                        4,
                        (i) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(p.imageUrl,
                                      width: 72,
                                      height: 56,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                          width: 72,
                                          height: 56,
                                          color: Colors.grey.shade200))),
                            ))),
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
                    onTap: () => Navigator.pushNamed(context, '/reviews'),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Reviews (${p.reviewCount})',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 15)),
                          const Icon(Icons.chevron_right),
                        ]),
                  ),
                  const Divider(height: 24),
                  const SizedBox(height: 8),
                  NavyButton(
                    label: 'Edit Details',
                    icon: Icons.edit_outlined,
                    onPressed: () => Navigator.pushNamed(
                        context, '/edit-product',
                        arguments: product),
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

// ── Checkout Screen ───────────────────────────────────────────────────────────
class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'name': 'Red Persian Rug',
        'price': 'Rs.70,000',
        'qty': 'x2',
        'img':
            'https://images.unsplash.com/photo-1600166898405-da9535204843?w=200',
        'sub': ''
      },
      {
        'name': 'Crockery Set',
        'price': 'Rs. 10,000',
        'qty': 'x1',
        'img':
            'https://images.unsplash.com/photo-1565193566173-7a0ee3dbe261?w=200',
        'sub': ''
      },
      {
        'name': 'Coffee Mug',
        'price': 'Rs. 1000',
        'qty': 'x1',
        'img':
            'https://images.unsplash.com/photo-1514228742587-6b1558fcca3d?w=200',
        'sub': 'Consequat ex eu'
      },
      {
        'name': 'Clay Plate',
        'price': 'Rs.2000',
        'qty': 'x1',
        'img':
            'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=200',
        'sub': 'Consequat ex eu'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        actions: const [ProfileAvatarButton()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cart items
            ...items.map((item) => Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(item['img']!,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                                width: 72,
                                height: 72,
                                color: Colors.grey.shade200)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['name']!,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14)),
                              if (item['sub']!.isNotEmpty)
                                Text(item['sub']!,
                                    style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 12)),
                              const SizedBox(height: 4),
                              Text(item['price']!,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14)),
                            ]),
                      ),
                      Column(children: [
                        Icon(Icons.edit_outlined,
                            size: 18, color: Colors.grey.shade500),
                        const SizedBox(height: 12),
                        Text(item['qty']!,
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 13)),
                      ]),
                    ],
                  ),
                )),
            const Divider(height: 24),

            // Voucher
            const Text('Voucher',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Enter voucher code',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('Apply',
                  style: TextStyle(
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 20),

            // Total
            const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('TOTAL',
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  Text('Rs.83,000',
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
                ]),
            const SizedBox(height: 20),

            // Pay button
            NavyButton(
              label: 'Make Payment',
              icon: Icons.arrow_forward,
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment processed!'))),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(currentIndex: 3, onTap: (_) {}),
    );
  }
}
