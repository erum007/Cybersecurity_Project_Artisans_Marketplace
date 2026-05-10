import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';

// ── App Logo Widget ───────────────────────────────────────────────────────────
class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 60});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
          color: AppTheme.primaryRed, shape: BoxShape.circle),
      child: Icon(Icons.bolt, color: Colors.white, size: size * 0.55),
    );
  }
}

class AppLogoSmall extends StatelessWidget {
  const AppLogoSmall({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
          color: AppTheme.primaryRed, borderRadius: BorderRadius.circular(8)),
      child: const Icon(Icons.bolt, color: Colors.white, size: 22),
    );
  }
}

// ── Register Screen ───────────────────────────────────────────────────────────
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              ),
              const SizedBox(height: 8),
              const Center(child: AppLogoSmall()),
              const SizedBox(height: 24),
              const Center(child: AppLogo()),
              const SizedBox(height: 20),
              const Center(
                child: Text('Join our Community',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text('Start your journey with global artisans',
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              ),
              const SizedBox(height: 28),
              const LabeledInput(
                  label: 'Full Name',
                  hint: 'John Doe',
                  prefixIcon: Icons.person_outline),
              const SizedBox(height: 16),
              const LabeledInput(
                  label: 'Email Address',
                  hint: 'name@example.com',
                  prefixIcon: Icons.email_outlined),
              const SizedBox(height: 16),
              const LabeledInput(
                  label: 'Password',
                  obscureText: true,
                  prefixIcon: Icons.lock_outline),
              const SizedBox(height: 16),
              const LabeledInput(
                  label: 'Confirm Password',
                  obscureText: true,
                  prefixIcon: Icons.lock_outline),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                      value: false,
                      onChanged: (_) {},
                      activeColor: AppTheme.primaryRed),
                  Flexible(
                    child: RichText(
                      text: const TextSpan(
                        text: 'I agree to the ',
                        style: TextStyle(color: Colors.black87, fontSize: 13),
                        children: [
                          TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(color: AppTheme.primaryRed)),
                          TextSpan(text: ' and '),
                          TextSpan(
                              text: 'Privacy Policy.',
                              style: TextStyle(color: AppTheme.primaryRed)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              RedButton(
                label: 'Create Account',
                onPressed: () => Navigator.pushNamed(context, '/home'),
              ),
              const SizedBox(height: 16),
              Center(
                child: RichText(
                  text: TextSpan(
                    text: 'Already have an account?  ',
                    style: TextStyle(color: Colors.grey.shade700),
                    children: const [
                      TextSpan(
                          text: 'Log in',
                          style: TextStyle(
                              color: AppTheme.primaryRed,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.language, size: 14, color: Colors.grey),
                  SizedBox(width: 4),
                  Text('SUPPORT CENTER',
                      style: TextStyle(fontSize: 11, color: Colors.grey))
                ],
              )),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'By clicking Create Account, you acknowledge that your data\nwill be processed in accordance with our security guidelines\nto ensure a safe artisan ecosystem.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Forgot Password Screen ────────────────────────────────────────────────────
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Center(child: AppLogoSmall()),
              const Spacer(),
              const AppLogo(),
              const SizedBox(height: 16),
              Text('Welcome back to the heart of\nhandcrafted creativity.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              const SizedBox(height: 32),
              const LabeledInput(label: 'Enter Username'),
              const SizedBox(height: 16),
              const LabeledInput(
                label: 'Enter New Password',
                hint: 'name@example.com',
                prefixIcon: Icons.email_outlined,
                suffix: Icon(Icons.visibility_outlined,
                    size: 18, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              const LabeledInput(
                label: 'Re-enter New Password',
                hint: 'Enter your password',
                prefixIcon: Icons.lock_outline,
                suffix: Icon(Icons.visibility_outlined,
                    size: 18, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/verify'),
                  child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Change',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 18),
                      ]),
                ),
              ),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: Divider(color: Colors.grey.shade300)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('OR CONNECT WITH',
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                ),
                Expanded(child: Divider(color: Colors.grey.shade300)),
              ]),
              const SizedBox(height: 16),
              RichText(
                text: const TextSpan(
                  text: "Don't have an account?  ",
                  style: TextStyle(color: Colors.black87),
                  children: [
                    TextSpan(
                        text: 'Sign up',
                        style: TextStyle(
                            color: AppTheme.primaryRed,
                            fontWeight: FontWeight.w700))
                  ],
                ),
              ),
              const Spacer(),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.language, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text('GLOBAL MARKETPLACE',
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                const SizedBox(width: 20),
                Icon(Icons.support_agent,
                    size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text('SUPPORT CENTER',
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ]),
              const SizedBox(height: 8),
              Text(
                'By logging in, you agree to our Terms of Service and Privacy Policy. © 2026 Artisan Marketplace Inc.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Verify Code Screen ────────────────────────────────────────────────────────
class VerifyCodeScreen extends StatelessWidget {
  const VerifyCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Center(child: AppLogoSmall()),
              const Spacer(),
              const AppLogo(),
              const SizedBox(height: 16),
              Text('Welcome back to the heart of\nhandcrafted creativity.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              const SizedBox(height: 32),
              const Text(
                'Enter verification code sent to\ner*****07@gmail.com',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/home'),
                  child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Submit',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 18),
                      ]),
                ),
              ),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: Divider(color: Colors.grey.shade300)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('OR CONNECT WITH',
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                ),
                Expanded(child: Divider(color: Colors.grey.shade300)),
              ]),
              const SizedBox(height: 16),
              RichText(
                text: const TextSpan(
                  text: "Don't have an account?  ",
                  style: TextStyle(color: Colors.black87),
                  children: [
                    TextSpan(
                        text: 'Sign up',
                        style: TextStyle(
                            color: AppTheme.primaryRed,
                            fontWeight: FontWeight.w700))
                  ],
                ),
              ),
              const Spacer(),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.language, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text('GLOBAL MARKETPLACE',
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                const SizedBox(width: 20),
                Icon(Icons.support_agent,
                    size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text('SUPPORT CENTER',
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ]),
              const SizedBox(height: 8),
              Text(
                'By logging in, you agree to our Terms of Service and Privacy Policy. © 2026 Artisan Marketplace Inc.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
