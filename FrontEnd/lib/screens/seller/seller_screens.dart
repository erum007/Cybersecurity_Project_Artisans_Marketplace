
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../state/app_state.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadArtisanOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final orders = state.artisanOrders;
    final artisanId = state.user?.id ?? '';

    double totalRevenue = 0;
    int totalItemsSold = 0;
    int completedOrders = 0;
    int pendingOrders = 0;

    final now = DateTime.now();
    // Build ordered map of last 6 months
    final monthKeys = <int>[];
    for (var offset = 5; offset >= 0; offset--) {
      var m = now.month - offset;
      if (m <= 0) m += 12;
      monthKeys.add(m);
    }
    final monthRevenue = <int, double>{for (var m in monthKeys) m: 0.0};

    for (final order in orders) {
      bool hasMyItem = false;
      for (final item in order.items) {
        if (item.artisanId == artisanId) {
          final lineTotal = item.price * item.quantity;
          totalRevenue += lineTotal;
          totalItemsSold += item.quantity;
          hasMyItem = true;
          if (order.placedAt != null && monthRevenue.containsKey(order.placedAt!.month)) {
            monthRevenue[order.placedAt!.month] = monthRevenue[order.placedAt!.month]! + lineTotal;
          }
        }
      }
      if (hasMyItem) {
        if (order.status.toLowerCase() == 'completed') completedOrders++;
        if (order.status.toLowerCase() == 'pending') pendingOrders++;
      }
    }

    final maxMonthRevenue =
        monthRevenue.values.isEmpty ? 1.0 : monthRevenue.values.reduce((a, b) => a > b ? a : b);

    const monthNames = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Finances',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20)),
        actions: const [ProfileAvatarButton()],
      ),
      body: RefreshIndicator(
        onRefresh: () => state.loadArtisanOrders(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Overview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _SummaryCard(title: 'Total Revenue', amount: 'Rs ${totalRevenue.toStringAsFixed(0)}')),
                const SizedBox(width: 12),
                Expanded(child: _SummaryCard(title: 'Items Sold', amount: totalItemsSold.toString())),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _SummaryCard(title: 'Completed', amount: completedOrders.toString())),
                const SizedBox(width: 12),
                Expanded(child: _SummaryCard(title: 'Pending', amount: pendingOrders.toString())),
              ]),
              const SizedBox(height: 24),
              const Text('Revenue — Last 6 Months',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: monthKeys.map((m) {
                    final val = monthRevenue[m] ?? 0;
                    final barH = maxMonthRevenue > 0
                        ? (val / maxMonthRevenue) * 140
                        : 0.0;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (val > 0)
                          Text('Rs ${val.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 8, color: Colors.grey)),
                        const SizedBox(height: 2),
                        Container(
                          width: 38,
                          height: barH.clamp(4.0, 140.0),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryRed,
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(monthNames[m],
                            style:
                                TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              SectionHeader(
                  title: 'Recent Reviews',
                  actionLabel: 'See all',
                  onAction: () => Navigator.pushNamed(context, '/reviews')),
              const SizedBox(height: 12),
              Builder(builder: (context) {
                final allReviews = state.sellerProducts
                    .expand((p) => p.reviews.map((r) => MapEntry(p.name, r)))
                    .toList();
                allReviews.sort((a, b) => b.value.date.compareTo(a.value.date));
                final recent = allReviews.take(3).toList();
                if (recent.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Center(
                        child: Text('No reviews yet.',
                            style: TextStyle(color: Colors.grey))),
                  );
                }
                return Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: recent.asMap().entries.map((e) {
                      final r = e.value.value;
                      final isLast = e.key == recent.length - 1;
                      return Column(children: [
                        _ReviewRow(
                          name: '${r.userName} — ${e.value.key}',
                          time: '${r.date.day}/${r.date.month}/${r.date.year}',
                          comment: r.comment,
                          rating: r.rating,
                        ),
                        if (!isLast) Divider(height: 1, color: Colors.grey.shade200),
                      ]);
                    }).toList(),
                  ),
                );
              }),
              const SizedBox(height: 24),
              const Text('Order Tasks',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(12)),
                child: Column(children: [
                  _TaskRow(
                    icon: Icons.list_alt,
                    label: '$pendingOrders orders',
                    badge: 'to fulfill',
                    color: Colors.blue.shade100,
                    onTap: () => Navigator.pushNamed(context, '/manage-orders'),
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),
                  _TaskRow(
                    icon: Icons.receipt_long,
                    label: '$completedOrders orders',
                    badge: 'completed',
                    color: Colors.green.shade100,
                    onTap: () => Navigator.pushNamed(context, '/manage-orders'),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 0,
        isSeller: true,
        onTap: (i) {
          if (i == 0) Navigator.pushNamed(context, '/seller-home');
          if (i == 2) Navigator.pushNamed(context, '/profile');
        },
      ),
    );
  }
}

// ── Summary Card ──────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  const _SummaryCard({required this.title, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppTheme.primaryRed, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 6),
        Row(children: [
          Text(amount,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800)),
        ]),
      ]),
    );
  }
}

// ── Review Row ────────────────────────────────────────────────────────────────
class _ReviewRow extends StatelessWidget {
  final String name;
  final String time;
  final String comment;
  final double rating;
  const _ReviewRow(
      {required this.name,
      required this.time,
      required this.comment,
      required this.rating});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
                color: Colors.grey, shape: BoxShape.circle),
            child: const Icon(Icons.person, color: Colors.white, size: 20)),
        const SizedBox(width: 10),
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
          Text(name,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13)),
          Text(comment,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(time,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
          Row(children: [
            const Icon(Icons.star, color: AppTheme.starYellow, size: 14),
            Text(' ${rating.toStringAsFixed(1)}',
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700)),
          ]),
        ]),
      ]),
    );
  }
}

// ── Task Row ──────────────────────────────────────────────────────────────────
class _TaskRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String badge;
  final Color color;
  final VoidCallback onTap;
  const _TaskRow(
      {required this.icon,
      required this.label,
      required this.badge,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(6)),
        child: Icon(icon, size: 18, color: AppTheme.navyBlue),
      ),
      title: RichText(
          text: TextSpan(
        text: label,
        style: const TextStyle(
            color: Colors.black, fontWeight: FontWeight.w600, fontSize: 14),
        children: [
          TextSpan(
              text: ' $badge',
              style: TextStyle(
                  color: Colors.green.shade600,
                  fontWeight: FontWeight.normal)),
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
  String _tab = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadArtisanOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final artisanId = state.user?.id ?? '';
    final allOrders = state.artisanOrders;

    // Only include orders that have at least one item belonging to this artisan,
    // and apply status tab filter
    final filteredOrders = allOrders.where((order) {
      final hasMyItem =
          order.items.any((i) => i.artisanId == artisanId);
      if (!hasMyItem) return false;
      if (_tab == 'All') return true;
      return order.status.toLowerCase() == _tab.toLowerCase();
    }).toList();

    final total = allOrders
        .where((o) => o.items.any((i) => i.artisanId == artisanId))
        .length;
    final completed = allOrders
        .where((o) =>
            o.status.toLowerCase() == 'completed' &&
            o.items.any((i) => i.artisanId == artisanId))
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Orders')),
      body: state.isBusy && allOrders.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => state.loadArtisanOrders(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  // Progress card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: AppTheme.primaryRed,
                        borderRadius: BorderRadius.circular(14)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      const Text('Completed',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 4),
                      Row(children: [
                        Text('$completed',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.w800)),
                        Text('/$total',
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 28)),
                      ]),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: total > 0 ? completed / total : 0,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppTheme.navyBlue),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          total > 0
                              ? '${((completed / total) * 100).toInt()}%'
                              : '0%',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  // Filter tabs
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Pending', 'Processing', 'Completed', 'Cancelled']
                          .map((tab) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _OrderFilterChip(
                                  label: tab,
                                  selected: _tab == tab,
                                  onTap: () =>
                                      setState(() => _tab = tab),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (filteredOrders.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: Center(
                        child: Text('No $_tab orders.',
                            style:
                                TextStyle(color: Colors.grey.shade500)),
                      ),
                    )
                  else
                    ...filteredOrders.map((order) => _ArtisanOrderCard(
                          order: order,
                          artisanId: artisanId,
                        )),
                ]),
              ),
            ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 0,
        isSeller: true,
        onTap: (i) {
          if (i == 0) Navigator.pushNamed(context, '/seller-home');
          if (i == 2) Navigator.pushNamed(context, '/profile');
        },
      ),
    );
  }
}

// ── Order Filter Chip ─────────────────────────────────────────────────────────
class _OrderFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _OrderFilterChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.navyBlue : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight:
                selected ? FontWeight.w700 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// ── Artisan Order Card ────────────────────────────────────────────────────────
// Shows only the items belonging to this artisan — even if the order
// was placed with multiple artisans' products.
class _ArtisanOrderCard extends StatelessWidget {
  final OrderModel order;
  final String artisanId;
  const _ArtisanOrderCard(
      {required this.order, required this.artisanId});

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'processing':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final myItems =
        order.items.where((i) => i.artisanId == artisanId).toList();
    final myTotal =
        myItems.fold(0.0, (s, i) => s + i.lineTotal);
    final statusColor = _statusColor(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
          child: Row(children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
              Text(
                'Order #${order.id.length >= 8 ? order.id.substring(0, 8).toUpperCase() : order.id.toUpperCase()}',
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15),
              ),
              if (order.placedAt != null)
                Text(
                  '${order.placedAt!.day}/${order.placedAt!.month}/${order.placedAt!.year}',
                  style: TextStyle(
                      color: Colors.grey.shade500, fontSize: 12),
                ),
              Text('Customer: ${order.customerName}',
                  style: TextStyle(
                      color: Colors.grey.shade500, fontSize: 12)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                order.status[0].toUpperCase() +
                    order.status.substring(1),
                style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ]),
        ),
        const Divider(height: 1),
        // My items only
        ...myItems.map((item) => Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
              child: Row(children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.inventory_2_outlined,
                      color: Colors.grey, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                  Text(item.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(
                      'Qty ${item.quantity}  ×  Rs ${item.price.toStringAsFixed(0)}',
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 12)),
                ])),
                Text('Rs ${item.lineTotal.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ]),
            )),
        // Footer
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Divider(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Your subtotal',
                  style:
                      TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              Text('Rs ${myTotal.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 15)),
            ]),
            const SizedBox(height: 10),
            const Text('Update Status:',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: ['pending', 'processing', 'completed', 'cancelled']
                  .map((status) => GestureDetector(
                        onTap: order.status == status
                            ? null
                            : () => context
                                .read<AppState>()
                                .updateOrderStatus(order.id, status),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: order.status == status
                                ? _statusColor(status)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: order.status == status
                                  ? _statusColor(status)
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            status[0].toUpperCase() + status.substring(1),
                            style: TextStyle(
                              color: order.status == status
                                  ? Colors.white
                                  : Colors.grey.shade600,
                              fontSize: 12,
                              fontWeight: order.status == status
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ── Reviews Screen ─────────────────────────────────────────────────────────────
class ReviewsScreen extends StatelessWidget {
  final List<Review>? reviews;
  const ReviewsScreen({super.key, this.reviews});

  @override
  Widget build(BuildContext context) {
    final displayReviews = reviews ??
        context
            .watch<AppState>()
            .sellerProducts
            .expand((p) => p.reviews)
            .toList();
    final double avgRating = displayReviews.isEmpty
        ? 0
        : displayReviews.map((e) => e.rating).reduce((a, b) => a + b) /
            displayReviews.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Reviews')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(avgRating.toStringAsFixed(1),
                      style: const TextStyle(
                          fontSize: 42, fontWeight: FontWeight.w800)),
                  Text('out of 5',
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 12)),
                ]),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: List.generate(5, (i) {
                      final stars = 5 - i;
                      final count = displayReviews
                          .where((r) =>
                              r.rating >= stars && r.rating < stars + 1)
                          .length;
                      final fill = displayReviews.isEmpty
                          ? 0.0
                          : count / displayReviews.length;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(children: [
                          ...List.generate(
                              stars,
                              (_) => const Icon(Icons.star,
                                  color: AppTheme.starYellow, size: 12)),
                          ...List.generate(
                              5 - stars,
                              (_) => Icon(Icons.star_border,
                                  color: Colors.grey.shade300, size: 12)),
                          const SizedBox(width: 6),
                          Expanded(
                              child: LinearProgressIndicator(
                            value: fill,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.grey.shade500),
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
            Align(
                alignment: Alignment.centerRight,
                child: Text('${displayReviews.length} Ratings',
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 12))),
            const SizedBox(height: 12),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  if (i < avgRating.floor()) {
                    return const Icon(Icons.star,
                        color: AppTheme.starYellow, size: 34);
                  }
                  if (i < avgRating) {
                    return const Icon(Icons.star_half,
                        color: AppTheme.starYellow, size: 34);
                  }
                  return const Icon(Icons.star_border,
                      color: AppTheme.starYellow, size: 34);
                })),
            const Divider(height: 32),
            Row(children: [
              Text('Sort by: ',
                  style: TextStyle(
                      color: Colors.grey.shade600, fontSize: 13)),
              const Text('Recent',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
              const Icon(Icons.keyboard_arrow_down, size: 18),
            ]),
            const Divider(height: 20),
            ...displayReviews.map((r) => _ReviewItem(review: r)),
          ],
        ),
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final Review review;
  const _ReviewItem({required this.review});

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(review.title,
            style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 15)),
        const SizedBox(height: 4),
        StarRating(rating: review.rating, size: 16),
        const SizedBox(height: 4),
        Row(children: [
          Text(review.userName,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13)),
          Text(' • ',
              style: TextStyle(color: Colors.grey.shade400)),
          Text(
            '${_monthName(review.date.month)} ${review.date.day}, ${review.date.year}',
            style:
                TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ]),
        const SizedBox(height: 4),
        Text(review.comment,
            style: const TextStyle(fontSize: 13, height: 1.4)),
        const SizedBox(height: 8),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8)),
          child: Row(children: [
            Expanded(
                child: Text('Reply...',
                    style: TextStyle(
                        color: Colors.grey.shade400, fontSize: 13))),
            Icon(Icons.edit_outlined,
                size: 16, color: Colors.grey.shade400),
          ]),
        ),
        const Divider(height: 24),
      ],
    );
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
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late String _category;

  List<String> _imageUrls = [];
  final List<XFile> _newImages = [];

  bool get isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _descController = TextEditingController(text: p?.description ?? '');
    _priceController =
        TextEditingController(text: p?.price.toString() ?? '');
    _stockController =
        TextEditingController(text: p?.stock.toString() ?? '1');
    _category = p?.category ?? 'General';
    _imageUrls = List.from(p?.imageUrls ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(imageQuality: 80);
    if (images.isNotEmpty) {
      setState(() => _newImages.addAll(images));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageUrls.isEmpty && _newImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one image')),
      );
      return;
    }
    final state = context.read<AppState>();
    try {
      List<String> finalUrls = List.from(_imageUrls);
      for (var file in _newImages) {
        final url = await state.uploadProductImage(file);
        finalUrls.add(url);
      }
      if (isEdit) {
        await state.updateProduct(
          id: widget.product!.id,
          name: _nameController.text,
          description: _descController.text,
          price: double.parse(_priceController.text),
          stock: int.parse(_stockController.text),
          category: _category,
          imageUrls: finalUrls,
        );
      } else {
        await state.createProduct(
          name: _nameController.text,
          description: _descController.text,
          price: double.parse(_priceController.text),
          stock: int.parse(_stockController.text),
          category: _category,
          imageUrls: finalUrls,
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
          title: Text(isEdit ? 'Edit Product' : 'Add Product')),
      body: state.isBusy
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Product Images',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 120,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 120,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: Colors.grey[300]!),
                              ),
                              child: const Icon(Icons.add_a_photo,
                                  size: 40, color: Colors.grey),
                            ),
                          ),
                          ..._imageUrls.map((url) => _ImageThumbnail(
                                url: url,
                                onRemove: () =>
                                    setState(() => _imageUrls.remove(url)),
                              )),
                          ..._newImages.map((file) => _ImageThumbnail(
                                file: file,
                                onRemove: () =>
                                    setState(() => _newImages.remove(file)),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                          labelText: 'Product Name',
                          border: OutlineInputBorder()),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descController,
                      decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder()),
                      maxLines: 3,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          decoration: const InputDecoration(
                              labelText: 'Price',
                              border: OutlineInputBorder(),
                              prefixText: 'Rs. '),
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              v == null || double.tryParse(v) == null
                                  ? 'Invalid price'
                                  : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _stockController,
                          decoration: const InputDecoration(
                              labelText: 'Stock',
                              border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              v == null || int.tryParse(v) == null
                                  ? 'Invalid stock'
                                  : null,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: state.categories.contains(_category)
                          ? _category
                          : (state.categories.isNotEmpty
                              ? state.categories.first
                              : 'General'),
                      decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder()),
                      items: state.categories
                          .map((c) => DropdownMenuItem(
                              value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _category = v!),
                    ),
                    const SizedBox(height: 32),
                    if (state.isUploadingImage)
                      const Center(
                          child: Column(children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text('Uploading images...'),
                      ]))
                    else
                      RedButton(
                        label: isEdit ? 'Update Product' : 'Create Product',
                        onPressed: _save,
                      ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}

// ── Image Thumbnail ───────────────────────────────────────────────────────────
class _ImageThumbnail extends StatelessWidget {
  final String? url;
  final XFile? file;
  final VoidCallback onRemove;
  const _ImageThumbnail({this.url, this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    if (url != null) {
      imageWidget = Image.network(resolveImageUrl(url!),
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.broken_image));
    } else if (file != null) {
      imageWidget = kIsWeb
          ? Image.network(file!.path,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.broken_image))
          : Image.file(File(file!.path),
              width: 120, height: 120, fit: BoxFit.cover);
    } else {
      imageWidget = const Icon(Icons.image_not_supported);
    }
    return Container(
      width: 120,
      margin: const EdgeInsets.only(left: 12),
      child: Stack(children: [
        ClipRRect(
            borderRadius: BorderRadius.circular(12), child: imageWidget),
        Positioned(
          right: 4,
          top: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                  color: Colors.black54, shape: BoxShape.circle),
              child: const Icon(Icons.close,
                  size: 16, color: Colors.white),
            ),
          ),
        ),
      ]),
    );
  }
}
