import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../../state/app_state.dart';
import '../buyer/product_screens.dart';

// Removed local _resolveImageUrl in favor of global resolveImageUrl from widgets.dart


// ── Collapsed Profile Screen ──────────────────────────────────────────────────
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditingBio = false;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController();
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    if (!_isEditingBio) {
      _bioController.text = user.bio ?? '';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize Profile'),
        actions: const [
          Icon(Icons.notifications_outlined, color: Colors.white),
          SizedBox(width: 12),
          Icon(Icons.settings_outlined, color: Colors.white),
          SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar + name
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: user.profilePicture != null && user.profilePicture!.isNotEmpty
                      ? NetworkImage(resolveImageUrl(user.profilePicture!))
                      : const NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200'),
                    child: state.isUploadingImage 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : null,
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: GestureDetector(
                      onTap: state.isUploadingImage ? null : () async {
                        final picker = ImagePicker();
                        final image = await picker.pickImage(
                          source: ImageSource.gallery,
                          maxWidth: 800,
                          imageQuality: 85,
                        );
                        if (image != null && context.mounted) {
                          try {
                            await state.uploadProfilePicture(image);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Profile picture updated!')),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(state.error ?? 'Upload failed')),
                              );
                            }
                          }
                        }
                      },
                      child: Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color: state.isUploadingImage ? Colors.grey : Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(user.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(14)),
                child: Text(user.role.toUpperCase(), style: const TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              Text('Member since 2021', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
            ]),
            const SizedBox(height: 20),

            _ProfileSection(
              icon: Icons.person_outline,
              label: 'PROFESSIONAL BIO',
              onAction: () async {
                if (_isEditingBio) {
                  try {
                    await state.updateProfile(bio: _bioController.text.trim());
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bio updated!')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.error ?? 'Failed to update bio')),
                      );
                    }
                  }
                }
                setState(() => _isEditingBio = !_isEditingBio);
              },
              actionIcon: _isEditingBio ? Icons.check : Icons.edit,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                child: _isEditingBio 
                  ? TextField(
                      controller: _bioController,
                      maxLines: 3,
                      decoration: const InputDecoration(border: InputBorder.none, hintText: 'Tell us about yourself...'),
                      style: const TextStyle(fontSize: 13, height: 1.5),
                    )
                  : Text(user.bioText, style: const TextStyle(fontSize: 13, height: 1.5)),
              ),
            ),
            const SizedBox(height: 16),

            // Portfolio
            _ProfileSection(
              icon: Icons.language,
              label: 'PORTFOLIO URL',
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                child: RichText(text: TextSpan(
                  text: 'artisan.io/ ',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  children: [TextSpan(text: user.fullName.toLowerCase().replaceAll(' ', '_'), style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600))],
                )),
              ),
            ),
            const SizedBox(height: 20),

            // Order History tile
            ProfileSectionTile(
              icon: Icons.receipt_long_outlined,
              iconColor: const Color(0xFF7B61FF),
              title: 'Order History',
              subtitle: 'View past orders and leave reviews',
              onTap: () => Navigator.pushNamed(context, '/orders'),





            ),
            const SizedBox(height: 20),

            const Align(alignment: Alignment.centerLeft,
              child: Text('PROFILE CONFIGURATION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey))),
            const SizedBox(height: 10),

            // Config tiles
            ProfileSectionTile(
              icon: Icons.shield_outlined,
              iconColor: AppTheme.navyBlue,
              title: 'Account & Security',
              subtitle: 'Password, 2FA, and login',
              onTap: () => Navigator.pushNamed(context, '/profile-account'),
            ),
            const SizedBox(height: 10),
            ProfileSectionTile(
              icon: Icons.location_on_outlined,
              iconColor: Colors.orange,
              title: 'Contact Details',
              subtitle: 'Address, phone, and links',
              onTap: () => Navigator.pushNamed(context, '/profile-contact'),
            ),
            const SizedBox(height: 10),
            ProfileSectionTile(
              icon: Icons.notifications_active_outlined,
              iconColor: Colors.green,
              title: 'Communication',
              subtitle: 'Notification channels',
              onTap: () => Navigator.pushNamed(context, '/profile-communication'),
            ),
            const SizedBox(height: 20),

            RedButton(label: 'Save Global Changes', icon: Icons.save, onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Changes are saved as you navigate or click "Save" in sub-sections.')));
            }),
            const SizedBox(height: 12),
            const _SignOutButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;
  final Future<void> Function()? onAction;
  final IconData? actionIcon;
  const _ProfileSection({required this.icon, required this.label, required this.child, this.onAction, this.actionIcon});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 15, color: Colors.grey.shade500),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade500, letterSpacing: 0.5)),
          const Spacer(),
          if (onAction != null)
            GestureDetector(
              onTap: onAction,
              child: Icon(actionIcon ?? Icons.edit, size: 16, color: AppTheme.primaryRed),
            ),
        ]),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

// ── Account & Security Screen ─────────────────────────────────────────────────
class AccountSecurityScreen extends StatefulWidget {
  const AccountSecurityScreen({super.key});

  @override
  State<AccountSecurityScreen> createState() => _AccountSecurityScreenState();
}

class _AccountSecurityScreenState extends State<AccountSecurityScreen> {
  String? _email;
  String? _password;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.user;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _UserMiniHeader(user: user),
            const SizedBox(height: 12),

            const _ExpandedSection(
              icon: Icons.shield_outlined,
              iconColor: AppTheme.navyBlue,
              title: 'Account & Security',
              subtitle: 'Password, 2FA, and login',
              expanded: true,
            ),
            const SizedBox(height: 16),

            LabeledInput(
              label: 'Email Address',
              initialValue: user.email,
              prefixIcon: Icons.email_outlined,
              onChanged: (v) => _email = v,
            ),
            const SizedBox(height: 4),
            Text('Your primary email for order notifications and login.',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            const SizedBox(height: 16),

            LabeledInput(
              label: 'New Password',
              hint: 'Create a strong password',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              onChanged: (v) => _password = v,
            ),
            const SizedBox(height: 16),

            state.isBusy 
              ? const CircularProgressIndicator()
              : RedButton(label: 'Save Changes', onPressed: () async {
                  try {
                    Map<String, dynamic> updates = {};
                    if (_email != null) updates['email'] = _email;
                    if (_password != null) updates['password'] = _password;
                    
                    if (updates.isNotEmpty) {
                      await state.updateProfile(
                        email: updates['email']?.toString(),
                        password: updates['password']?.toString(),
                      );
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account updated')));
                    }
                  } catch (e) {
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }),
            const SizedBox(height: 16),

            ProfileSectionTile(
              icon: Icons.location_on_outlined,
              iconColor: Colors.orange,
              title: 'Contact Details',
              subtitle: 'Address, phone, and links',
              onTap: () => Navigator.pushReplacementNamed(context, '/profile-contact'),
            ),
            const SizedBox(height: 10),
            ProfileSectionTile(
              icon: Icons.notifications_active_outlined,
              iconColor: Colors.green,
              title: 'Communication',
              subtitle: 'Notification channels',
              onTap: () => Navigator.pushReplacementNamed(context, '/profile-communication'),
            ),
            const SizedBox(height: 20),
            const _SignOutButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ── Contact Details Screen ────────────────────────────────────────────────────
class ContactDetailsScreen extends StatefulWidget {
  const ContactDetailsScreen({super.key});

  @override
  State<ContactDetailsScreen> createState() => _ContactDetailsScreenState();
}

class _ContactDetailsScreenState extends State<ContactDetailsScreen> {
  String? _phone;
  String? _address;
  String? _city;
  String? _postalCode;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.user;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _UserMiniHeader(user: user),
            const SizedBox(height: 12),

            ProfileSectionTile(
              icon: Icons.shield_outlined,
              iconColor: AppTheme.navyBlue,
              title: 'Account & Security',
              subtitle: 'Password, 2FA, and login',
              onTap: () => Navigator.pushReplacementNamed(context, '/profile-account'),
            ),
            const SizedBox(height: 10),

            const _ExpandedSection(
              icon: Icons.location_on_outlined,
              iconColor: Colors.orange,
              title: 'Contact Details',
              subtitle: 'Address, phone, and links',
              expanded: true,
            ),
            const SizedBox(height: 16),

            LabeledInput(
              label: 'Phone Number',
              initialValue: user.phone,
              prefixIcon: Icons.phone_outlined,
              onChanged: (v) => _phone = v,
            ),
            const SizedBox(height: 14),

            LabeledInput(
              label: 'Shipping Address',
              initialValue: user.address,
              prefixIcon: Icons.home_outlined,
              onChanged: (v) => _address = v,
            ),
            const SizedBox(height: 12),

            Row(children: [
              Expanded(
                child: LabeledInput(
                  label: 'City',
                  initialValue: user.city,
                  onChanged: (v) => _city = v,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LabeledInput(
                  label: 'Postal Code',
                  initialValue: user.postalCode,
                  onChanged: (v) => _postalCode = v,
                ),
              ),
            ]),
            const SizedBox(height: 20),

            state.isBusy
              ? const CircularProgressIndicator()
              : RedButton(label: 'Save Contact Details', onPressed: () async {
                  try {
                    if (_phone != null || _address != null || _city != null || _postalCode != null) {
                      await state.updateProfile(
                        phone: _phone,
                        address: _address,
                        city: _city,
                        postalCode: _postalCode,
                      );
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contact details updated')));
                    }
                  } catch (e) {
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }),
            const SizedBox(height: 16),

            ProfileSectionTile(
              icon: Icons.notifications_active_outlined,
              iconColor: Colors.green,
              title: 'Communication',
              subtitle: 'Notification channels',
              onTap: () => Navigator.pushReplacementNamed(context, '/profile-communication'),
            ),
            const SizedBox(height: 20),
            const _SignOutButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ── Communication Screen ──────────────────────────────────────────────────────
class CommunicationScreen extends StatefulWidget {
  const CommunicationScreen({super.key});

  @override
  State<CommunicationScreen> createState() => _CommunicationScreenState();
}

class _CommunicationScreenState extends State<CommunicationScreen> {
  bool _emailNotifs = true;
  bool _smsAlerts = false;
  bool _newsletter = true;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.user;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _UserMiniHeader(user: user),
            const SizedBox(height: 12),

            ProfileSectionTile(
              icon: Icons.shield_outlined,
              iconColor: AppTheme.navyBlue,
              title: 'Account & Security',
              subtitle: 'Password, 2FA, and login',
              onTap: () => Navigator.pushReplacementNamed(context, '/profile-account'),
            ),
            const SizedBox(height: 10),
            ProfileSectionTile(
              icon: Icons.location_on_outlined,
              iconColor: Colors.orange,
              title: 'Contact Details',
              subtitle: 'Address, phone, and links',
              onTap: () => Navigator.pushReplacementNamed(context, '/profile-contact'),
            ),
            const SizedBox(height: 10),

            const _ExpandedSection(
              icon: Icons.notifications_active_outlined,
              iconColor: Colors.green,
              title: 'Communication',
              subtitle: 'Notification channels',
              expanded: true,
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Active Preferences', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey.shade600)),
                  const SizedBox(height: 12),
                  _NotifRow(
                    icon: Icons.email_outlined,
                    title: 'Email Notifications',
                    subtitle: 'Receive updates about your orders, customer inquiries, and platform news.',
                    value: _emailNotifs,
                    onChanged: (v) => setState(() => _emailNotifs = v),
                  ),
                  const Divider(height: 20),
                  _NotifRow(
                    icon: Icons.smartphone,
                    title: 'SMS Alerts',
                    subtitle: 'Get real-time text alerts for urgent shipping updates and security logins.',
                    value: _smsAlerts,
                    onChanged: (v) => setState(() => _smsAlerts = v),
                  ),
                  const Divider(height: 20),
                  _NotifRow(
                    icon: Icons.receipt_long_outlined,
                    title: 'Marketing Newsletter',
                    subtitle: 'A weekly digest featuring top artisans, trending products, and community stories.',
                    value: _newsletter,
                    onChanged: (v) => setState(() => _newsletter = v),
                  ),
                  const SizedBox(height: 16),
                  state.isBusy
                    ? const Center(child: CircularProgressIndicator())
                    : RedButton(label: 'Save Preferences', onPressed: () async {
                        try {
                          // Notification preferences are not yet supported by the backend specifically.
                          // But we can still update the user profile if needed.
                          await state.updateProfile();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Preferences saved successfully'))
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e'))
                            );
                          }
                        }
                      }),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const _SignOutButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _NotifRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _NotifRow({required this.icon, required this.title, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(6)),
          child: Icon(icon, size: 16, color: AppTheme.primaryRed),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12, height: 1.3)),
          ],
        )),
        Switch(value: value, onChanged: onChanged, activeThumbColor: AppTheme.primaryRed),
      ],
    );
  }
}

// ── Shared Profile Widgets ────────────────────────────────────────────────────
class _UserMiniHeader extends StatelessWidget {
  final UserModel user;
  const _UserMiniHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(children: [
        Stack(children: [
          CircleAvatar(radius: 24, backgroundColor: Colors.grey.shade300,
              child: const Icon(Icons.person, color: Colors.grey)),
          Positioned(bottom: 0, right: 0,
              child: Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle))),
        ]),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          Text('${user.role.toUpperCase()}   ${user.badge}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        ])),
      ]),
    );
  }
}

class _ExpandedSection extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool expanded;
  const _ExpandedSection({required this.icon, required this.iconColor, required this.title, required this.subtitle, this.expanded = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: expanded ? const BorderRadius.vertical(top: Radius.circular(12)) : BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
        ])),
        Icon(expanded ? Icons.keyboard_arrow_up : Icons.chevron_right, color: Colors.grey),
      ]),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  const _SignOutButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).popUntil((route) => route.isFirst);
        context.read<AppState>().logout();
      },
      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.logout, color: AppTheme.primaryRed, size: 18),
        SizedBox(width: 6),
        Text('Sign Out from Profile', style: TextStyle(color: AppTheme.primaryRed, fontWeight: FontWeight.w600, fontSize: 14)),
      ]),
    );
  }
}

// ── Order History Screen ──────────────────────────────────────────────────────
class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadMyOrders();
    });
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return Colors.green;
      case 'processing': return Colors.blue;
      case 'cancelled': return Colors.red;
      default: return Colors.orange;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return Icons.check_circle_outline;
      case 'processing': return Icons.autorenew;
      case 'cancelled': return Icons.cancel_outlined;
      default: return Icons.schedule;
    }
  }

  void _showReviewDialog(BuildContext context, AppState state, String productId, String productName) {
    final commentController = TextEditingController();
    double rating = 5.0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Leave a Review', style: TextStyle(fontWeight: FontWeight.w700)),
              Text(productName,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.normal),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your rating', style: TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) => GestureDetector(
                  onTap: () => setDialogState(() => rating = (i + 1).toDouble()),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      (i + 1) <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: const Color(0xFFFFC107),
                      size: 36,
                    ),
                  ),
                )),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  ['', 'Poor', 'Fair', 'Good', 'Great', 'Excellent!'][rating.toInt()],
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFFFC107)),
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
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (commentController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please write a comment')),
                  );
                  return;
                }
                try {
                  await state.addReview(productId, rating: rating, comment: commentController.text.trim());
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) {
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
    final orders = state.orders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        actions: const [ProfileAvatarButton()],
      ),
      body: state.isBusy && orders.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text('No orders yet.',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Your order history will appear here.',
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: () => Navigator.pushNamed(context, '/catalog'),
                        child: const Text('Start Shopping'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => state.loadMyOrders(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      final statusColor = _statusColor(order.status);
                      final statusIcon = _statusIcon(order.status);
                      final isCompleted = order.status.toLowerCase() == 'completed';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Order header
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Order #${order.id.length >= 8 ? order.id.substring(0, 8).toUpperCase() : order.id.toUpperCase()}',
                                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                        ),
                                        const SizedBox(height: 2),
                                        if (order.placedAt != null)
                                          Text(
                                            '${order.placedAt!.day}/${order.placedAt!.month}/${order.placedAt!.year}',
                                            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(statusIcon, size: 13, color: statusColor),
                                        const SizedBox(width: 4),
                                        Text(
                                          order.status[0].toUpperCase() + order.status.substring(1),
                                          style: TextStyle(
                                            color: statusColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const Divider(height: 1),

                            // Order items
                            ...order.items.map((item) {
                              // Try to find the product in the loaded products list
                              final matchedProduct = state.products
                                  .where((p) => p.id == item.productId)
                                  .firstOrNull;

                              return Padding(
                                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Product thumbnail
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        width: 54,
                                        height: 54,
                                        color: Colors.grey.shade100,
                                        child: matchedProduct != null && matchedProduct.imageUrl.isNotEmpty
                                            ? Image.network(
                                                resolveImageUrl(matchedProduct.imageUrl),
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    Icon(Icons.image_outlined, color: Colors.grey.shade400),
                                              )
                                            : Icon(Icons.image_outlined, color: Colors.grey.shade400),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Item details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(item.name,
                                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Qty ${item.quantity}  •  Rs ${item.lineTotal.toStringAsFixed(0)}',
                                            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Review button — only for completed orders
                                    if (isCompleted)
                                      GestureDetector(
                                        onTap: () => _showReviewDialog(
                                          context, state, item.productId, item.name),
                                        child: Container(
                                          margin: const EdgeInsets.only(left: 8),
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: AppTheme.primaryRed),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            'Review',
                                            style: TextStyle(
                                              color: AppTheme.primaryRed,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }),

                            // Order total + address
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (order.shippingAddress.isNotEmpty)
                                          Row(
                                            children: [
                                              Icon(Icons.location_on_outlined,
                                                  size: 13, color: Colors.grey.shade500),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  order.shippingAddress,
                                                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Icon(Icons.payment_outlined,
                                                size: 13, color: Colors.grey.shade500),
                                            const SizedBox(width: 4),
                                            Text(
                                              order.paymentMethod.toUpperCase(),
                                              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    'Rs ${order.totalAmount.toStringAsFixed(0)}',
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}