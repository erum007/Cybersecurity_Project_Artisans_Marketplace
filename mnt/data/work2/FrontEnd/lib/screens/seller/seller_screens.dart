import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../../models/models.dart';

// ── Finances Screen ───────────────────────────────────────────────────────────
class FinancesScreen extends StatefulWidget {
  const FinancesScreen({super.key});

  @override
  State<FinancesScreen> createState() => _FinancesScreenState();
}

class _FinancesScreenState extends State<FinancesScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Finances', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20)),
        actions: const [Icon(Icons.menu, color: Colors.white), SizedBox(width: 12)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),

            // Summary cards
            const Row(children: [
              Expanded(child: _SummaryCard(title: 'Monthly Sales', amount: '\$230', badge: '+5.39%')),
              SizedBox(width: 12),
              Expanded(child: _SummaryCard(title: 'Annual Sales', amount: '\$135')),
            ]),
            const SizedBox(height: 20),

            const Text('Stats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),

            // Tabs
            const Row(children: [
              _StatsTab(label: 'Total sales', selected: true),
              SizedBox(width: 16),
              _StatsTab(label: 'Revenue'),
              SizedBox(width: 16),
              _StatsTab(label: 'Traffic'),
            ]),
            const SizedBox(height: 16),

            // Bar chart (custom drawn)
            SizedBox(
              height: 160,
              child: _SimpleBarChart(),
            ),
            const SizedBox(height: 8),

            // Legend
            Row(children: [
              const SizedBox(width: 16),
              Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppTheme.primaryRed, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text('Tips', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
              const SizedBox(width: 16),
              Container(width: 10, height: 10, decoration: BoxDecoration(color: AppTheme.primaryRed.withOpacity(0.3), shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text('Sale', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
            ]),
            const SizedBox(height: 20),

            // Reviews
            SectionHeader(title: 'Reviews', actionLabel: 'See all',
                onAction: () => Navigator.pushNamed(context, '/reviews')),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  const _ReviewRow(
                    name: 'Jane Cooper - Product #1',
                    time: '12:00 PM',
                    comment: 'Loved it!! Ordering Again!!',
                    rating: 5.0,
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),
                  const _ReviewRow(
                    name: 'James Harrid - Product #3',
                    time: '11:37 PM',
                    comment: 'Slightly Late Delivery, but Loved it...',
                    rating: 4.5,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tasks
            const Text('Tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)),
              child: Column(children: [
                _TaskRow(icon: Icons.list_alt, label: '6 orders', badge: 'to fulfill', color: Colors.blue.shade100,
                    onTap: () => Navigator.pushNamed(context, '/manage-orders')),
                Divider(height: 1, color: Colors.grey.shade200),
                _TaskRow(icon: Icons.receipt_long, label: '20 orders', badge: 'on delivery', color: Colors.orange.shade100,
                    onTap: () => Navigator.pushNamed(context, '/manage-orders')),
                Divider(height: 1, color: Colors.grey.shade200),
                _TaskRow(icon: Icons.credit_card, label: '23 payments', badge: 'processed', color: Colors.blue.shade100,
                    onTap: () {}),
                Divider(height: 1, color: Colors.grey.shade200),
                _TaskRow(icon: Icons.receipt_long, label: '1 chargeback', badge: 'to review', color: Colors.blue.shade100,
                    onTap: () {}),
              ]),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _navIndex,
        isSeller: true,
        onTap: (i) {
          setState(() => _navIndex = i);
          if (i == 0) Navigator.pushNamed(context, '/seller-home');
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final String? badge;
  const _SummaryCard({required this.title, required this.amount, this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.primaryRed, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 6),
        Row(children: [
          Text(amount, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.green.shade400, borderRadius: BorderRadius.circular(6)),
              child: Text(badge!, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
            ),
          ],
        ]),
      ]),
    );
  }
}

class _StatsTab extends StatelessWidget {
  final String label;
  final bool selected;
  const _StatsTab({required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: TextStyle(
          fontSize: 13,
          color: selected ? Colors.grey.shade600 : Colors.grey.shade400,
          decoration: selected ? TextDecoration.underline : TextDecoration.none,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ));
  }
}

class _SimpleBarChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final data = [0.6, 0.9, 0.5, 0.3, 0.8, 0.7, 0.4, 0.9, 0.5, 0.6];
    final saleData = [0.8, 1.0, 0.7, 0.5, 1.0, 0.8, 0.6, 1.0, 0.7, 0.9];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(data.length, (i) => Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 22,
                  height: 160 * saleData[i],
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRed.withOpacity(0.25),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 22,
                    height: 160 * data[i],
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryRed,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      )),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String name;
  final String time;
  final String comment;
  final double rating;
  const _ReviewRow({required this.name, required this.time, required this.comment, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        Container(width: 36, height: 36, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
            child: const Icon(Icons.person, color: Colors.white, size: 20)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          Text(comment, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(time, style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
          Row(children: [
            const Icon(Icons.star, color: AppTheme.starYellow, size: 14),
            Text(' ${rating.toStringAsFixed(1)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          ]),
        ]),
      ]),
    );
  }
}

class _TaskRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String badge;
  final Color color;
  final VoidCallback onTap;
  const _TaskRow({required this.icon, required this.label, required this.badge, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
        child: Icon(icon, size: 18, color: AppTheme.navyBlue),
      ),
      title: RichText(text: TextSpan(
        text: label,
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 14),
        children: [
          TextSpan(text: ' $badge', style: TextStyle(color: Colors.green.shade600, fontWeight: FontWeight.normal)),
        ],
      )),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      dense: true,
    );
  }
}

// ── Manage Orders Screen ──────────────────────────────────────────────────────
class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({super.key});

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  String _tab = 'All tasks';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.calendar_today, color: AppTheme.navyBlue, size: 18),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Progress card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppTheme.primaryRed, borderRadius: BorderRadius.circular(14)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Completed', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 4),
                const Row(children: [
                  Text('23', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w800)),
                  Text('/49', style: TextStyle(color: Colors.white54, fontSize: 28)),
                ]),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    value: 0.54,
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.navyBlue),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 4),
                const Align(alignment: Alignment.centerRight, child: Text('54%', style: TextStyle(color: Colors.white70, fontSize: 12))),
              ]),
            ),
            const SizedBox(height: 16),

            // Tabs
            Row(children: [
              _OrderTab(label: 'All tasks', selected: _tab == 'All tasks', onTap: () => setState(() => _tab = 'All tasks')),
              const SizedBox(width: 12),
              _OrderTab(label: 'Ongoing', selected: _tab == 'Ongoing', onTap: () => setState(() => _tab = 'Ongoing')),
              const SizedBox(width: 12),
              _OrderTab(label: 'Completed', selected: _tab == 'Completed', onTap: () => setState(() => _tab = 'Completed')),
            ]),
            const SizedBox(height: 16),

            // Orders list
            ...SampleData.orders.map((order) => _OrderCard(order: order)),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(currentIndex: 0, isSeller: true, onTap: (_) {}),
    );
  }
}

class _OrderTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _OrderTab({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryRed.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(
          color: selected ? AppTheme.primaryRed : Colors.grey.shade500,
          fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
          fontSize: 13,
        )),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(Icons.calendar_today, size: 13, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text(
                  '${_monthName(order.date.month)} ${order.date.day}, ${order.date.year}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ]),
              const SizedBox(height: 4),
              Text('Order #${order.id}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 6),
              Container(
                width: 30, height: 30, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
                child: const Icon(Icons.person, color: Colors.white, size: 16),
              ),
              const SizedBox(height: 6),
              Row(children: [
                _StatusChip(label: order.status, color: Colors.green),
                if (order.deliveryStatus.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  _StatusChip(label: order.deliveryStatus, color: Colors.blue),
                ],
                if (order.progress >= 1.0) ...[
                  const SizedBox(width: 6),
                  const _StatusChip(label: 'Review Gotten', color: Colors.purple),
                ],
              ]),
            ]),
          ),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Row(children: [
              Icon(Icons.edit_outlined, size: 16, color: Colors.grey.shade400),
            ]),
            const SizedBox(height: 12),
            SizedBox(
              width: 60, height: 60,
              child: Stack(
                children: [
                  CircularProgressIndicator(
                    value: order.progress,
                    backgroundColor: Colors.pink.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      order.progress >= 1.0 ? AppTheme.primaryRed : AppTheme.primaryRed,
                    ),
                    strokeWidth: 6,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              order.progress >= 1.0
                  ? 'Done'
                  : '${(order.progress * 100).toInt()}% completed',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
          ]),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

// ── Reviews Screen ─────────────────────────────────────────────────────────────
class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Rating summary
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('4.7', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w800)),
                  Text('out of 5', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ]),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: List.generate(5, (i) {
                      final stars = 5 - i;
                      final fills = [0.7, 0.5, 0.3, 0.2, 0.1];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(children: [
                          ...List.generate(stars, (_) => const Icon(Icons.star, color: AppTheme.starYellow, size: 12)),
                          ...List.generate(5 - stars, (_) => Icon(Icons.star_border, color: Colors.grey.shade300, size: 12)),
                          const SizedBox(width: 6),
                          Expanded(child: LinearProgressIndicator(
                            value: fills[i],
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade500),
                            minHeight: 6,
                          )),
                        ]),
                      );
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Align(alignment: Alignment.centerRight, child: Text('26 Ratings', style: TextStyle(color: Colors.grey.shade500, fontSize: 12))),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) =>
              Icon(i < 4 ? Icons.star : Icons.star_half, color: AppTheme.starYellow, size: 34))),
            const Divider(height: 32),

            // Sort
            Row(children: [
              Text('Sort by: ', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              const Text('Unreplied', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const Icon(Icons.keyboard_arrow_down, size: 18),
            ]),
            const Divider(height: 20),

            // Reviews list
            ...SampleData.reviews.map((r) => _ReviewItem(review: r)),
          ],
        ),
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final Review review;
  const _ReviewItem({required this.review});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(review.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        const SizedBox(height: 4),
        StarRating(rating: review.rating, size: 16),
        const SizedBox(height: 4),
        Row(children: [
          Text(review.userName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          Text(' • ', style: TextStyle(color: Colors.grey.shade400)),
          Text(
            '${_monthName(review.date.month)} ${review.date.day}, ${review.date.year}',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ]),
        const SizedBox(height: 4),
        Text(review.comment, style: const TextStyle(fontSize: 13, height: 1.4)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
          child: Row(children: [
            Expanded(child: Text('Reply...', style: TextStyle(color: Colors.grey.shade400, fontSize: 13))),
            Icon(Icons.edit_outlined, size: 16, color: Colors.grey.shade400),
          ]),
        ),
        const Divider(height: 24),
      ],
    );
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}

// ── Edit Product Screen ───────────────────────────────────────────────────────
class EditProductScreen extends StatefulWidget {
  final Product? product;
  const EditProductScreen({super.key, this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final List<String> _categories = ['Hand Sewn', 'Woolen Goods', 'Luxury'];
  int _selectedColor = 1;
  final colors = [const Color(0xFF8B6914), AppTheme.primaryRed, const Color(0xFFF5DEB3)];
  bool get isEdit => widget.product != null;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? (p?.name ?? 'Product') : 'Product Name',
            style: const TextStyle(fontSize: 14)),
        leadingWidth: 40,
        actions: [
          const Icon(Icons.shopping_cart_outlined, size: 22),
          const SizedBox(width: 8),
          Container(
            width: 32, height: 32,
            margin: const EdgeInsets.only(right: 8),
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: ClipOval(
              child: Image.network('https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100', fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade300, child: const Icon(Icons.person, size: 16))),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo upload area
            GestureDetector(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.network(
                      p?.imageUrl ?? 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
                      width: double.infinity, height: 200, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(height: 200, color: Colors.grey.shade200),
                    ),
                    Container(
                      color: Colors.black38,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Column(children: [
                        Text(isEdit ? 'Edit Photos' : 'Upload Photos',
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                        const Icon(Icons.arrow_upward, color: Colors.white),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(4, (i) =>
              Container(width: i == 0 ? 20 : 8, height: 8, margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(color: i == 0 ? Colors.grey.shade400 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4))))),
            const SizedBox(height: 16),

            // Price + Colors
            Row(
              children: [
                GestureDetector(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(color: AppTheme.primaryRed, borderRadius: BorderRadius.circular(8)),
                    child: Row(children: [
                      Text(p != null ? '\$${p.price.toStringAsFixed(0)}' : '\$Price',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      const SizedBox(width: 6),
                      const Icon(Icons.edit, color: Colors.white, size: 14),
                    ]),
                  ),
                ),
                const Spacer(),
                const Text('Colors', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                const Icon(Icons.add, color: AppTheme.primaryRed),
                const SizedBox(width: 8),
                Row(children: List.generate(colors.length, (i) => GestureDetector(
                  onTap: () => setState(() => _selectedColor = i),
                  child: Container(
                    width: 24, height: 24, margin: const EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(
                      color: colors[i],
                      shape: BoxShape.circle,
                      border: Border.all(color: _selectedColor == i ? Colors.black : Colors.transparent, width: 1.5),
                    ),
                  ),
                ))),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            const Row(children: [
              Text('Description', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              SizedBox(width: 8),
              Icon(Icons.edit_outlined, size: 16, color: Colors.grey),
            ]),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: p?.description ?? 'Add Description..',
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 16),

            // Add Categories
            RedButton(
              label: '+ Add Categories',
              onPressed: () {},
            ),
            const SizedBox(height: 12),

            // Category chips
            ..._categories.map((cat) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(cat, style: const TextStyle(fontSize: 14)),
                  GestureDetector(
                    onTap: () => setState(() => _categories.remove(cat)),
                    child: Icon(Icons.delete_outline, color: Colors.grey.shade600),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 16),

            RedButton(
              label: isEdit ? 'Save' : 'Upload',
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
