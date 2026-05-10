import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'buyer/buyer_screens.dart';
import 'buyer/product_screens.dart';

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        if (state.isBootstrapping) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        if (!state.isLoggedIn) return const AuthScreen();
        if (state.isAdmin) return const AdminDashboardScreen();
        if (state.isArtisan) return const ArtisanHomeScreen();
        // Customer: render BuyerHomeScreen directly — no named route push,
        // so the nav stack stays clean and logout works correctly.
        return const BuyerHomeScreen();
      },
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();
  final _loginEmail = TextEditingController();
  final _loginPassword = TextEditingController();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  String _role = 'customer';
  bool _isLogin = true;

  @override
  void dispose() {
    _loginEmail.dispose();
    _loginPassword.dispose();
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _phone.dispose();
    _address.dispose();
    _city.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  const Icon(Icons.storefront, size: 60),
                  const SizedBox(height: 12),
                  Text(
                    'Artisans Marketplace',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Customers can shop. Artisans can sell. Admin can supervise.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 24),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: true, label: Text('Login')),
                      ButtonSegment(value: false, label: Text('Register')),
                    ],
                    selected: {_isLogin},
                    onSelectionChanged: (value) {
                      setState(() => _isLogin = value.first);
                    },
                  ),
                  const SizedBox(height: 20),
                  if (state.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ErrorBanner(message: state.error!),
                    ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: _isLogin ? _buildLogin(context, state) : _buildRegister(context, state),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Demo roles supported by backend: customer, artisan, admin',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogin(BuildContext context, AppState state) {
    return Form(
      key: _loginFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _loginEmail,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _loginPassword,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            validator: (v) => (v == null || v.isEmpty) ? 'Enter your password' : null,
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: state.isBusy
                ? null
                : () async {
                    if (!_loginFormKey.currentState!.validate()) return;
                    try {
                      await context.read<AppState>().login(_loginEmail.text.trim(), _loginPassword.text.trim());
                    } catch (_) {
                      if (!context.mounted) return;
                      _showSnack(context, state.error ?? 'Login failed');
                    }
                  },
            child: Text(state.isBusy ? 'Please wait...' : 'Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildRegister(BuildContext context, AppState state) {
    return Form(
      key: _registerFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Full name'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your full name' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _email,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _password,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password'),
            validator: (v) => (v == null || v.length < 8) ? 'Minimum 8 characters' : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _role,
            decoration: const InputDecoration(labelText: 'Role'),
            items: const [
              DropdownMenuItem(value: 'customer', child: Text('Customer')),
              DropdownMenuItem(value: 'artisan', child: Text('Artisan')),
              DropdownMenuItem(value: 'admin', child: Text('Admin')),
            ],
            onChanged: (v) => setState(() => _role = v ?? 'customer'),
          ),
          const SizedBox(height: 12),
          TextFormField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone')),
          const SizedBox(height: 12),
          TextFormField(controller: _address, decoration: const InputDecoration(labelText: 'Address')),
          const SizedBox(height: 12),
          TextFormField(controller: _city, decoration: const InputDecoration(labelText: 'City')),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: state.isBusy
                ? null
                : () async {
                    if (!_registerFormKey.currentState!.validate()) return;
                    try {
                      await context.read<AppState>().register(
                            fullName: _name.text.trim(),
                            email: _email.text.trim(),
                            password: _password.text.trim(),
                            role: _role,
                            phone: _phone.text.trim(),
                            address: _address.text.trim(),
                            city: _city.text.trim(),
                          );
                    } catch (_) {
                      if (!context.mounted) return;
                      _showSnack(context, state.error ?? 'Registration failed');
                    }
                  },
            child: Text(state.isBusy ? 'Please wait...' : 'Create account'),
          ),
        ],
      ),
    );
  }
}

// ── Legacy CustomerHomeScreen (kept for any internal references) ───────────────
// Customers are routed to BuyerHomeScreen via RootScreen — this is not shown.
class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final _search = TextEditingController();
  String _category = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().refreshAll();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final categories = ['All', ...state.categories];
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${state.user?.fullName.split(' ').first ?? 'Customer'}'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
              context.read<AppState>().logout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<AppState>().refreshAll(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _search,
                    decoration: InputDecoration(
                      hintText: 'Search products',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () => context.read<AppState>().loadProducts(search: _search.text, category: _category),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _category,
                  items: categories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) {
                    setState(() => _category = v ?? 'All');
                    context.read<AppState>().loadProducts(search: _search.text, category: v);
                  },
                )
              ],
            ),
            const SizedBox(height: 16),
            if (state.products.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(child: Text('No products found yet.')),
              )
            else
              ...state.products.map(
                (product) => Card(
                  child: ListTile(
                    leading: _ProductThumb(imageUrl: product.imageUrl),
                    title: Text(product.name),
                    subtitle: Text('${product.category} • ${product.artisanName}\nStock: ${product.stock}'),
                    isThreeLine: true,
                    trailing: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Rs ${product.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        SizedBox(
                          height: 28,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              visualDensity: VisualDensity.compact,
                            ),
                            onPressed: product.stock <= 0
                                ? null
                                : () async {
                                    try {
                                      await context.read<AppState>().addToCart(product);
                                      if (!context.mounted) return;
                                      _showSnack(context, '${product.name} added to cart');
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      _showSnack(context, e.toString().replaceFirst('Exception: ', ''));
                                    }
                                  },
                            child: const Text('Add'),
                          ),
                        )
                      ],
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
                    ),
                  ),
                ),
              )
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

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (state.cart.items.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 48),
              child: Center(child: Text('Your cart is empty.')),
            )
          else ...[
            ...state.cart.items.map((item) => Card(
                  child: ListTile(
                    title: Text(item.name),
                    subtitle: Text('Rs ${item.price.toStringAsFixed(0)} each'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, size: 20),
                          onPressed: () => context.read<AppState>().updateCartQuantity(item.productId, item.quantity - 1),
                        ),
                        Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, size: 20),
                          onPressed: () => context.read<AppState>().updateCartQuantity(item.productId, item.quantity + 1),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => context.read<AppState>().removeFromCart(item.productId),
                        ),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('Rs ${state.cart.total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen())),
                      child: const Text('Proceed to checkout'),
                    )
                  ],
                ),
              ),
            )
          ]
        ],
      ),
    );
  }
}

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _address = TextEditingController();
  String _paymentMethod = 'cod';

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    _address.text = _address.text.isEmpty ? (state.user?.address ?? '') : _address.text;
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _address,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Shipping address'),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _paymentMethod,
            decoration: const InputDecoration(labelText: 'Payment method'),
            items: const [
              DropdownMenuItem(value: 'cod', child: Text('Cash on delivery')),
              DropdownMenuItem(value: 'card', child: Text('Card')),
            ],
            onChanged: (v) => setState(() => _paymentMethod = v ?? 'cod'),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Order total: Rs ${state.cart.total.toStringAsFixed(0)}'),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: state.cart.items.isEmpty
                ? null
                : () async {
                    if (_address.text.trim().isEmpty) {
                      _showSnack(context, 'Please enter shipping address');
                      return;
                    }
                    try {
                      await context.read<AppState>().checkout(
                            paymentMethod: _paymentMethod,
                            shippingAddress: _address.text.trim(),
                          );
                      if (!context.mounted) return;
                      Navigator.popUntil(context, (route) => route.isFirst);
                      _showSnack(context, 'Order placed successfully');
                    } catch (e) {
                      if (!context.mounted) return;
                      _showSnack(context, e.toString().replaceFirst('Exception: ', ''));
                    }
                  },
            child: const Text('Place order'),
          )
        ],
      ),
    );
  }
}

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<AppState>().orders;
    return Scaffold(
      appBar: AppBar(title: const Text('Order History')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: orders.isEmpty
            ? [const Padding(padding: EdgeInsets.only(top: 48), child: Center(child: Text('No orders yet.')))]
            : orders
                .map((order) => Card(
                      child: ExpansionTile(
                        title: Text('Order ${order.id.substring(0, 6)} • ${order.status}'),
                        subtitle: Text('Rs ${order.totalAmount.toStringAsFixed(0)}'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Address: ${order.shippingAddress}'),
                                const SizedBox(height: 8),
                                ...order.items.map((item) => Text('${item.name} x ${item.quantity}')),
                              ],
                            ),
                          )
                        ],
                      ),
                    ))
                .toList(),
      ),
    );
  }
}

class ArtisanHomeScreen extends StatefulWidget {
  const ArtisanHomeScreen({super.key});

  @override
  State<ArtisanHomeScreen> createState() => _ArtisanHomeScreenState();
}

class _ArtisanHomeScreenState extends State<ArtisanHomeScreen> with SingleTickerProviderStateMixin {
  late final TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().refreshAll();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Artisan Studio • ${state.user?.fullName ?? ''}'),
        bottom: TabBar(controller: _controller, tabs: const [Tab(text: 'Products'), Tab(text: 'Orders')]),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/edit-product'),
            icon: const Icon(Icons.add_box_outlined),
          ),
          IconButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
              context.read<AppState>().logout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: TabBarView(
        controller: _controller,
        children: const [ArtisanProductsTab(), ArtisanOrdersTab()],
      ),
    );
  }
}

class ArtisanProductsTab extends StatelessWidget {
  const ArtisanProductsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final products = context.watch<AppState>().sellerProducts;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: products.isEmpty
          ? [const Padding(padding: EdgeInsets.only(top: 48), child: Center(child: Text('No products listed yet.')))]
          : products
              .map(
                (product) => Card(
                  child: ListTile(
                    leading: _ProductThumb(imageUrl: product.imageUrl),
                    title: Text(product.name),
                    subtitle: Text('${product.category} • Stock ${product.stock}'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          Navigator.pushNamed(context, '/edit-product', arguments: product);
                        } else {
                          await context.read<AppState>().deleteProduct(product.id);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }
}

class ArtisanOrdersTab extends StatelessWidget {
  const ArtisanOrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final artisanId = state.user?.id ?? '';
    final orders = state.artisanOrders;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: orders.isEmpty
          ? [const Padding(padding: EdgeInsets.only(top: 48), child: Center(child: Text('No artisan orders yet.')))]
          : orders.map((order) {
              // Only show this artisan's items
              final myItems = order.items.where((i) => i.artisanId == artisanId).toList();
              if (myItems.isEmpty) return const SizedBox.shrink();
              final myTotal = myItems.fold(0.0, (s, i) => s + i.lineTotal);
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Order ${order.id.substring(0, 6)}',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(order.status.toUpperCase()),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Customer: ${order.customerName}'),
                      const SizedBox(height: 4),
                      ...myItems.map((item) =>
                          Text('${item.name} x ${item.quantity} — Rs ${item.lineTotal.toStringAsFixed(0)}')),
                      const SizedBox(height: 4),
                      Text('Your subtotal: Rs ${myTotal.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: ['pending', 'processing', 'completed', 'cancelled']
                            .map(
                              (status) => ChoiceChip(
                                label: Text(status),
                                selected: order.status == status,
                                onSelected: (_) =>
                                    context.read<AppState>().updateOrderStatus(order.id, status),
                              ),
                            )
                            .toList(),
                      )
                    ],
                  ),
                ),
              );
            }).toList(),
    );
  }
}

// ── Admin Dashboard ───────────────────────────────────────────────────────────
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadAdminDashboard();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final dashboard = state.dashboard;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Admin Portal'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
              context.read<AppState>().logout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Customers'),
            Tab(text: 'Artisans'),
          ],
        ),
      ),
      body: state.isBusy && dashboard == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => state.loadAdminDashboard(),
              child: TabBarView(
                controller: _tabController,
                children: [
                  _AdminOverviewTab(dashboard: dashboard),
                  _AdminUsersTab(
                    users: state.adminUsers.where((u) => u.role == 'customer').toList(),
                  ),
                  _AdminArtisansTab(artisans: state.artisanRevenues),
                ],
              ),
            ),
    );
  }
}

class _AdminOverviewTab extends StatelessWidget {
  final AdminDashboard? dashboard;
  const _AdminOverviewTab({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    if (dashboard == null) return const Center(child: CircularProgressIndicator());
    final d = dashboard!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Marketplace Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryRed,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Total Revenue', style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 8),
              Text('Rs ${d.revenue.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('Across ${d.orders} orders',
                  style: const TextStyle(color: Colors.white60, fontSize: 13)),
            ]),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _AdminStatTile(icon: Icons.people_outline, label: 'Total Users', value: d.users.toString(), color: const Color(0xFF7B61FF)),
              _AdminStatTile(icon: Icons.store_outlined, label: 'Artisans', value: d.artisans.toString(), color: Colors.orange),
              _AdminStatTile(icon: Icons.person_outline, label: 'Customers', value: d.customers.toString(), color: Colors.blue),
              _AdminStatTile(icon: Icons.inventory_2_outlined, label: 'Products', value: d.products.toString(), color: Colors.green),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminStatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _AdminStatTile({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ]),
      ]),
    );
  }
}

class _AdminUsersTab extends StatelessWidget {
  final List<AdminUser> users;
  const _AdminUsersTab({required this.users});

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.people_outline, size: 48, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Text('No customers yet.', style: TextStyle(color: Colors.grey.shade500)),
      ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: users.length,
      itemBuilder: (context, i) {
        final u = users[i];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
          child: Row(children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.blue.shade50,
              backgroundImage: u.profilePicture.isNotEmpty ? NetworkImage(u.profilePicture) : null,
              child: u.profilePicture.isEmpty
                  ? Text(u.fullName.isNotEmpty ? u.fullName[0].toUpperCase() : '?',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.blue.shade700))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(u.fullName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              Text(u.email, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              if (u.city.isNotEmpty)
                Text(u.city, style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
              child: const Text('customer', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.blue)),
            ),
          ]),
        );
      },
    );
  }
}

class _AdminArtisansTab extends StatelessWidget {
  final List<ArtisanRevenue> artisans;
  const _AdminArtisansTab({required this.artisans});

  @override
  Widget build(BuildContext context) {
    if (artisans.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.store_outlined, size: 48, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Text('No artisans yet.', style: TextStyle(color: Colors.grey.shade500)),
      ]));
    }
    final totalRevenue = artisans.fold(0.0, (sum, a) => sum + a.revenue);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppTheme.navyBlue, borderRadius: BorderRadius.circular(12)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Total Artisan Revenue', style: TextStyle(color: Colors.white70, fontSize: 13)),
            Text('Rs ${totalRevenue.toStringAsFixed(0)}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
          ]),
        ),
        const SizedBox(height: 16),
        ...artisans.asMap().entries.map((entry) {
          final rank = entry.key + 1;
          final a = entry.value;
          final share = totalRevenue > 0 ? a.revenue / totalRevenue : 0.0;
          final rankColor = rank == 1
              ? const Color(0xFFFFD700)
              : rank == 2 ? Colors.grey.shade400 : Colors.brown.shade300;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(color: rankColor, shape: BoxShape.circle),
                  child: Center(child: Text('#$rank', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800))),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.orange.shade50,
                  backgroundImage: a.profilePicture.isNotEmpty ? NetworkImage(a.profilePicture) : null,
                  child: a.profilePicture.isEmpty
                      ? Text(a.fullName.isNotEmpty ? a.fullName[0].toUpperCase() : '?',
                          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.orange.shade700))
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(a.fullName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  Text(a.email, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                ])),
                Text('Rs ${a.revenue.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.primaryRed)),
              ]),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: share, minHeight: 6,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryRed.withValues(alpha: 0.7)),
                ),
              ),
              const SizedBox(height: 8),
              Row(children: [
                _MiniStat(icon: Icons.inventory_2_outlined, label: '${a.productCount} products'),
                const SizedBox(width: 16),
                _MiniStat(icon: Icons.receipt_long_outlined, label: '${a.orderCount} orders'),
                if (a.city.isNotEmpty) ...[
                  const SizedBox(width: 16),
                  _MiniStat(icon: Icons.location_on_outlined, label: a.city),
                ],
              ]),
            ]),
          );
        }),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MiniStat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: Colors.grey.shade500),
      const SizedBox(width: 3),
      Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
    ]);
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ]),
        ),
      ),
    );
  }
}

class _ProductThumb extends StatelessWidget {
  const _ProductThumb({required this.imageUrl});
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52, height: 52,
      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: imageUrl.isEmpty
            ? const Icon(Icons.image_outlined)
            : CachedNetworkImage(
                imageUrl: resolveImageUrl(imageUrl),
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
              ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
      child: Text(message, style: TextStyle(color: Colors.red.shade800)),
    );
  }
}

void _showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}