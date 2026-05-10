import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';

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
        return const CustomerHomeScreen();
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
                    onSelectionChanged: (value) => setState(() => _isLogin = value.first),
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
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
            icon: Badge.count(count: state.cart.items.length, child: const Icon(Icons.shopping_cart_outlined)),
          ),
          IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen())), icon: const Icon(Icons.receipt_long_outlined)),
          IconButton(onPressed: () => context.read<AppState>().logout(), icon: const Icon(Icons.logout)),
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Rs ${product.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        OutlinedButton(
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
    );
  }
}

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
              image: product.imageUrl.isEmpty ? null : DecorationImage(image: NetworkImage(product.imageUrl), fit: BoxFit.cover),
            ),
            child: product.imageUrl.isEmpty ? const Icon(Icons.image, size: 50) : null,
          ),
          const SizedBox(height: 16),
          Text(product.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Rs ${product.price.toStringAsFixed(0)}', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('By ${product.artisanName}'),
          const SizedBox(height: 8),
          Text('Category: ${product.category}'),
          const SizedBox(height: 8),
          Text('Stock: ${product.stock}'),
          const SizedBox(height: 16),
          Text(product.description.isEmpty ? 'No description yet.' : product.description),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: product.stock <= 0
                ? null
                : () async {
                    try {
                      await context.read<AppState>().addToCart(product);
                      if (!context.mounted) return;
                      _showSnack(context, 'Added to cart');
                    } catch (e) {
                      if (!context.mounted) return;
                      _showSnack(context, e.toString().replaceFirst('Exception: ', ''));
                    }
                  },
            icon: const Icon(Icons.shopping_cart_checkout),
            label: const Text('Add to cart'),
          ),
        ],
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
                    subtitle: Text('Qty ${item.quantity} • Rs ${item.price.toStringAsFixed(0)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => context.read<AppState>().removeFromCart(item.productId),
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
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductFormScreen())),
            icon: const Icon(Icons.add_box_outlined),
          ),
          IconButton(onPressed: () => context.read<AppState>().logout(), icon: const Icon(Icons.logout)),
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
                          Navigator.push(context, MaterialPageRoute(builder: (_) => ProductFormScreen(product: product)));
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
    final orders = context.watch<AppState>().artisanOrders;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: orders.isEmpty
          ? [const Padding(padding: EdgeInsets.only(top: 48), child: Center(child: Text('No artisan orders yet.')))]
          : orders
              .map(
                (order) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Order ${order.id.substring(0, 6)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(order.status.toUpperCase()),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Customer: ${order.customerName}'),
                        const SizedBox(height: 8),
                        ...order.items.map((item) => Text('${item.name} x ${item.quantity}')),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: ['pending', 'processing', 'completed', 'cancelled']
                              .map(
                                (status) => ChoiceChip(
                                  label: Text(status),
                                  selected: order.status == status,
                                  onSelected: (_) => context.read<AppState>().updateOrderStatus(order.id, status),
                                ),
                              )
                              .toList(),
                        )
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }
}

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.product});

  final Product? product;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late final TextEditingController _stock;
  late final TextEditingController _imageUrl;
  final ImagePicker _picker = ImagePicker();
  String _category = 'General';
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _name = TextEditingController(text: product?.name ?? '');
    _description = TextEditingController(text: product?.description ?? '');
    _price = TextEditingController(text: product == null ? '' : product.price.toString());
    _stock = TextEditingController(text: product == null ? '' : product.stock.toString());
    _imageUrl = TextEditingController(text: product?.imageUrl ?? '');
    _category = product?.category ?? 'General';
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    _stock.dispose();
    _imageUrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: Text(widget.product == null ? 'Add Product' : 'Edit Product')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Product name'), validator: _required),
            const SizedBox(height: 12),
            TextFormField(controller: _description, maxLines: 4, decoration: const InputDecoration(labelText: 'Description'), validator: _required),
            const SizedBox(height: 12),
            TextFormField(controller: _price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price'), validator: _required),
            const SizedBox(height: 12),
            TextFormField(controller: _stock, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stock'), validator: _required),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _category,
              items: appState.categories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _category = v ?? 'General'),
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 12),
            TextFormField(controller: _imageUrl, decoration: const InputDecoration(labelText: 'Image URL (optional if you upload below)')),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: appState.isUploadingImage ? null : _pickAndUploadImage,
              icon: const Icon(Icons.upload_file),
              label: Text(appState.isUploadingImage ? 'Uploading image...' : (_selectedImage == null ? 'Pick product image' : 'Replace product image')),
            ),
            if (_imageUrl.text.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _imageUrl.text.trim(),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: const Text('Image preview unavailable'),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                try {
                  if (_imageUrl.text.trim().isEmpty) {
                    _showSnack(context, 'Please upload an image or paste an image URL');
                    return;
                  }
                  if (widget.product == null) {
                    await context.read<AppState>().createProduct(
                          name: _name.text.trim(),
                          description: _description.text.trim(),
                          price: double.parse(_price.text.trim()),
                          stock: int.parse(_stock.text.trim()),
                          category: _category,
                          imageUrl: _imageUrl.text.trim(),
                        );
                  } else {
                    await context.read<AppState>().updateProduct(
                          id: widget.product!.id,
                          name: _name.text.trim(),
                          description: _description.text.trim(),
                          price: double.parse(_price.text.trim()),
                          stock: int.parse(_stock.text.trim()),
                          category: _category,
                          imageUrl: _imageUrl.text.trim(),
                        );
                  }
                  if (!context.mounted) return;
                  Navigator.pop(context);
                } catch (e) {
                  if (!context.mounted) return;
                  _showSnack(context, e.toString().replaceFirst('Exception: ', ''));
                }
              },
              child: Text(widget.product == null ? 'Create product' : 'Save changes'),
            )
          ],
        ),
      ),
    );
  }



  Future<void> _pickAndUploadImage() async {
    try {
      final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (file == null || !mounted) return;
      setState(() => _selectedImage = file);
      final uploadedUrl = await context.read<AppState>().uploadProductImage(file);
      _imageUrl.text = uploadedUrl;
      if (!mounted) return;
      _showSnack(context, 'Image uploaded');
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      _showSnack(context, e.toString().replaceFirst('Exception: ', ''));
    }
  }

  String? _required(String? value) => (value == null || value.trim().isEmpty) ? 'Required' : null;
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadAdminDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final dashboard = state.dashboard;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Portal'),
        actions: [IconButton(onPressed: () => context.read<AppState>().logout(), icon: const Icon(Icons.logout))],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<AppState>().loadAdminDashboard(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Supervisor view for marketplace activity', style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(height: 16),
            if (dashboard == null)
              const Center(child: Padding(padding: EdgeInsets.only(top: 40), child: CircularProgressIndicator()))
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _StatCard(label: 'Users', value: dashboard.users.toString()),
                  _StatCard(label: 'Artisans', value: dashboard.artisans.toString()),
                  _StatCard(label: 'Customers', value: dashboard.customers.toString()),
                  _StatCard(label: 'Products', value: dashboard.products.toString()),
                  _StatCard(label: 'Orders', value: dashboard.orders.toString()),
                  _StatCard(label: 'Revenue', value: 'Rs ${dashboard.revenue.toStringAsFixed(0)}'),
                ],
              ),
          ],
        ),
      ),
    );
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
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
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
        image: imageUrl.isEmpty ? null : DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
      ),
      child: imageUrl.isEmpty ? const Icon(Icons.image_outlined) : null,
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
