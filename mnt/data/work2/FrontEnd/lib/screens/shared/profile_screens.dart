import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../../models/models.dart';

// ── Collapsed Profile Screen ──────────────────────────────────────────────────
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = SampleData.currentUser;
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
                    child: ClipOval(
                      child: Image.network(
                        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
                        width: 96, height: 96, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 48, color: Colors.grey),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      width: 24, height: 24,
                      decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                      child: const Icon(Icons.check, color: Colors.white, size: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(14)),
                child: Text(user.role, style: const TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              Text('Member since 2021', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
            ]),
            const SizedBox(height: 20),

            // Bio
            _ProfileSection(
              icon: Icons.person_outline,
              label: 'PROFESSIONAL BIO',
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                child: Text(user.bio, style: const TextStyle(fontSize: 13, height: 1.5)),
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
                  children: const [TextSpan(text: 'julian_rivers', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600))],
                )),
              ),
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

            RedButton(label: 'Save Global Changes', icon: Icons.save, onPressed: () {}),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/register', (_) => false),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.logout, color: AppTheme.primaryRed, size: 18),
                SizedBox(width: 6),
                Text('Sign Out from Profile', style: TextStyle(color: AppTheme.primaryRed, fontWeight: FontWeight.w600)),
              ]),
            ),
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
  const _ProfileSection({required this.icon, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 15, color: Colors.grey.shade500),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade500, letterSpacing: 0.5)),
        ]),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

// ── Account & Security Screen ─────────────────────────────────────────────────
class AccountSecurityScreen extends StatelessWidget {
  const AccountSecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = SampleData.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize Profile'),
        actions: const [
          Icon(Icons.notifications_outlined),
          SizedBox(width: 8),
          Icon(Icons.settings_outlined),
          SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User mini-header
            _UserMiniHeader(user: user),
            const SizedBox(height: 12),

            // Account section expanded
            const _ExpandedSection(
              icon: Icons.shield_outlined,
              iconColor: AppTheme.navyBlue,
              title: 'Account & Security',
              subtitle: 'Password, 2FA, and login',
              expanded: true,
            ),
            const SizedBox(height: 16),

            // Email
            LabeledInput(
              label: 'Email Address',
              initialValue: user.email,
              prefixIcon: Icons.email_outlined,
            ),
            const SizedBox(height: 4),
            Text('Your primary email for order notifications and login.',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            const SizedBox(height: 16),

            const LabeledInput(
              label: 'Current Password',
              obscureText: true,
              prefixIcon: Icons.lock_outline,
              suffix: Icon(Icons.visibility_outlined, size: 18, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            const LabeledInput(
              label: 'New Password',
              hint: 'Create a strong password',
              prefixIcon: Icons.lock_outline,
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
              child: Text(
                'Passwords must be at least 8 characters and include a mix of letters, numbers, and symbols.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
              ),
            ),
            const SizedBox(height: 16),

            RedButton(label: 'Save Changes', onPressed: () {}),
            const SizedBox(height: 16),

            // Other sections (collapsed)
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

            RedButton(label: 'Save Global Changes', icon: Icons.save, onPressed: () {}),
            const SizedBox(height: 12),
            _SignOutButton(context: context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ── Contact Details Screen ────────────────────────────────────────────────────
class ContactDetailsScreen extends StatelessWidget {
  const ContactDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = SampleData.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize Profile'),
        actions: const [
          Icon(Icons.notifications_outlined),
          SizedBox(width: 8),
          Icon(Icons.settings_outlined),
          SizedBox(width: 12),
        ],
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

            // Phone Number
            LabeledInput(
              label: 'Phone Number',
              initialValue: user.phoneNumber,
              prefixIcon: Icons.phone_outlined,
            ),
            const SizedBox(height: 14),

            // Shipping Address
            const Align(alignment: Alignment.centerLeft,
              child: Text('Shipping Address', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
            const SizedBox(height: 6),
            TextFormField(
              initialValue: user.address,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.home_outlined, size: 18, color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),

            Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('City', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  TextFormField(
                    initialValue: user.city,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Postal Code', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  TextFormField(
                    initialValue: user.postalCode,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ]),
              ),
            ]),
            const SizedBox(height: 12),

            // Verified email
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(children: [
                const Icon(Icons.email_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(user.email, style: const TextStyle(fontSize: 13)),
                const Spacer(),
                const Text('VERIFIED', style: TextStyle(color: AppTheme.primaryRed, fontWeight: FontWeight.w700, fontSize: 12)),
              ]),
            ),
            const SizedBox(height: 16),

            RedButton(label: 'Save Contact Details', onPressed: () {}),
            const SizedBox(height: 16),

            ProfileSectionTile(
              icon: Icons.notifications_active_outlined,
              iconColor: Colors.green,
              title: 'Communication',
              subtitle: 'Notification channels',
              onTap: () => Navigator.pushReplacementNamed(context, '/profile-communication'),
            ),
            const SizedBox(height: 20),

            RedButton(label: 'Save Global Changes', icon: Icons.save, onPressed: () {}),
            const SizedBox(height: 12),
            _SignOutButton(context: context),
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
    final user = SampleData.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize Profile'),
        actions: const [
          Icon(Icons.notifications_outlined),
          SizedBox(width: 8),
          Icon(Icons.settings_outlined),
          SizedBox(width: 12),
        ],
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
                  RedButton(label: 'Save Preferences', onPressed: () {}),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'You can unsubscribe from marketing emails at any time using the\nlink at the bottom of our emails.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            RedButton(label: 'Save Global Changes', icon: Icons.save, onPressed: () {}),
            const SizedBox(height: 12),
            _SignOutButton(context: context),
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
              backgroundImage: const NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100')),
          Positioned(bottom: 0, right: 0,
              child: Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle))),
        ]),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(user.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          Text('${user.role}   ${user.badge}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
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
          decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
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
  final BuildContext context;
  const _SignOutButton({required this.context});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/register', (_) => false),
      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.logout, color: AppTheme.primaryRed, size: 18),
        SizedBox(width: 6),
        Text('Sign Out from Profile', style: TextStyle(color: AppTheme.primaryRed, fontWeight: FontWeight.w600, fontSize: 14)),
      ]),
    );
  }
}
