// lib/features/auth/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // ── Tab ──────────────────────────────────────────────────────────────────
  int _activeTab = 0; // 0 = Login, 1 = Sign Up

  // ── Login fields ─────────────────────────────────────────────────────────
  final _loginEmailCtrl = TextEditingController();
  final _loginPasswordCtrl = TextEditingController();
  bool _loginPasswordVisible = false;
  final _loginFormKey = GlobalKey<FormState>();

  // ── Sign Up fields ────────────────────────────────────────────────────────
  final _signUpNameCtrl = TextEditingController();
  final _signUpEmailCtrl = TextEditingController();
  final _signUpPasswordCtrl = TextEditingController();
  final _signUpConfirmCtrl = TextEditingController();
  bool _signUpPasswordVisible = false;
  bool _signUpConfirmVisible = false;
  final _signUpFormKey = GlobalKey<FormState>();

  // ── Loading ───────────────────────────────────────────────────────────────
  bool _isLoading = false;

  @override
  void dispose() {
    _loginEmailCtrl.dispose();
    _loginPasswordCtrl.dispose();
    _signUpNameCtrl.dispose();
    _signUpEmailCtrl.dispose();
    _signUpPasswordCtrl.dispose();
    _signUpConfirmCtrl.dispose();
    super.dispose();
  }

  void _onSignIn() async {
    if (!(_loginFormKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() => _isLoading = false);
      context.push('/address-setup');
    }
  }

  void _onCreateAccount() async {
    if (!(_signUpFormKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() => _isLoading = false);
      context.push('/address-setup');
    }
  }

  void _onGoogleSignIn() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) {
      setState(() => _isLoading = false);
      context.push('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          topPad + AppSpacing.xl,
          AppSpacing.lg,
          bottomPad + AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top bar ──────────────────────────────────────────────
            _TopBar(onSkip: () => context.push('/home')),

            const SizedBox(height: AppSpacing.xxl),

            // ── Auth card ────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: AppShadows.card,
              ),
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tab switcher
                  _AuthTabSwitcher(
                    activeIndex: _activeTab,
                    onChanged: (i) => setState(() => _activeTab = i),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Form
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: child,
                    ),
                    child: _activeTab == 0
                        ? _LoginForm(
                      key: const ValueKey('login'),
                      formKey: _loginFormKey,
                      emailCtrl: _loginEmailCtrl,
                      passwordCtrl: _loginPasswordCtrl,
                      passwordVisible: _loginPasswordVisible,
                      onTogglePassword: () => setState(
                              () => _loginPasswordVisible =
                          !_loginPasswordVisible),
                      isLoading: _isLoading,
                      onSignIn: _onSignIn,
                    )
                        : _SignUpForm(
                      key: const ValueKey('signup'),
                      formKey: _signUpFormKey,
                      nameCtrl: _signUpNameCtrl,
                      emailCtrl: _signUpEmailCtrl,
                      passwordCtrl: _signUpPasswordCtrl,
                      confirmCtrl: _signUpConfirmCtrl,
                      passwordVisible: _signUpPasswordVisible,
                      confirmVisible: _signUpConfirmVisible,
                      onTogglePassword: () => setState(
                              () => _signUpPasswordVisible =
                          !_signUpPasswordVisible),
                      onToggleConfirm: () => setState(
                              () => _signUpConfirmVisible =
                          !_signUpConfirmVisible),
                      isLoading: _isLoading,
                      onCreateAccount: _onCreateAccount,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // OR divider
                  _OrDivider(),

                  const SizedBox(height: AppSpacing.lg),

                  // Google button
                  _GoogleButton(
                    isLoading: _isLoading,
                    onTap: _onGoogleSignIn,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── Legal text ───────────────────────────────────────────
            _LegalText(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top Bar
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final VoidCallback onSkip;
  const _TopBar({required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Logo
        const Icon(Icons.restaurant_menu_rounded,
            color: AppColors.primary, size: 28),
        const SizedBox(width: 8),
        Text(
          'QuickBite',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),

        const Spacer(),

        // Skip
        GestureDetector(
          onTap: onSkip,
          child: Text(
            'Skip for Now',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Auth Tab Switcher
// ─────────────────────────────────────────────────────────────────────────────

class _AuthTabSwitcher extends StatelessWidget {
  final int activeIndex;
  final void Function(int) onChanged;

  const _AuthTabSwitcher({
    required this.activeIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        children: [
          _AuthTabPill(
              label: 'Login',
              isActive: activeIndex == 0,
              onTap: () => onChanged(0)),
          _AuthTabPill(
              label: 'Sign Up',
              isActive: activeIndex == 1,
              onTap: () => onChanged(1)),
        ],
      ),
    );
  }
}

class _AuthTabPill extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _AuthTabPill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isActive ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            boxShadow: isActive ? AppShadows.subtle : [],
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared: labelled input field
// ─────────────────────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;
  final String? trailing;
  final VoidCallback? onTrailingTap;

  const _FieldLabel({
    required this.label,
    this.trailing,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        if (trailing != null) ...[
          const Spacer(),
          GestureDetector(
            onTap: onTrailingTap,
            child: Text(
              trailing!,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final bool obscure;
  final Widget? suffix;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;

  const _AuthTextField({
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.obscure = false,
    this.suffix,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.textInputAction = TextInputAction.next,
  });

  @override
  State<_AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<_AuthTextField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: _focused ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: TextFormField(
          controller: widget.controller,
          obscureText: widget.obscure,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          validator: widget.validator,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textHint,
            ),
            prefixIcon: Icon(widget.prefixIcon,
                color: AppColors.textHint, size: 20),
            suffixIcon: widget.suffix,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: 14),
            errorStyle: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Login Form
// ─────────────────────────────────────────────────────────────────────────────

class _LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final bool passwordVisible;
  final VoidCallback onTogglePassword;
  final bool isLoading;
  final VoidCallback onSignIn;

  const _LoginForm({
    super.key,
    required this.formKey,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.passwordVisible,
    required this.onTogglePassword,
    required this.isLoading,
    required this.onSignIn,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email
          const _FieldLabel(label: 'Email address'),
          const SizedBox(height: AppSpacing.sm),
          _AuthTextField(
            controller: emailCtrl,
            hint: 'name@example.com',
            prefixIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email is required';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),

          const SizedBox(height: AppSpacing.lg),

          // Password
          _FieldLabel(
            label: 'Password',
            trailing: 'Forgot?',
            onTrailingTap: () {},
          ),
          const SizedBox(height: AppSpacing.sm),
          _AuthTextField(
            controller: passwordCtrl,
            hint: '••••••••',
            prefixIcon: Icons.lock_outline_rounded,
            obscure: !passwordVisible,
            textInputAction: TextInputAction.done,
            suffix: GestureDetector(
              onTap: onTogglePassword,
              child: Icon(
                passwordVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textHint,
                size: 20,
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              if (v.length < 6) return 'Minimum 6 characters';
              return null;
            },
          ),

          const SizedBox(height: AppSpacing.xl),

          // CTA
          _AuthCTA(
            label: 'Sign In to QuickBite',
            isLoading: isLoading,
            onTap: onSignIn,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sign Up Form
// ─────────────────────────────────────────────────────────────────────────────

class _SignUpForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController confirmCtrl;
  final bool passwordVisible;
  final bool confirmVisible;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirm;
  final bool isLoading;
  final VoidCallback onCreateAccount;

  const _SignUpForm({
    super.key,
    required this.formKey,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.confirmCtrl,
    required this.passwordVisible,
    required this.confirmVisible,
    required this.onTogglePassword,
    required this.onToggleConfirm,
    required this.isLoading,
    required this.onCreateAccount,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full Name
          const _FieldLabel(label: 'Full name'),
          const SizedBox(height: AppSpacing.sm),
          _AuthTextField(
            controller: nameCtrl,
            hint: 'Ali Hassan',
            prefixIcon: Icons.person_outline_rounded,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Name is required';
              }
              return null;
            },
          ),

          const SizedBox(height: AppSpacing.lg),

          // Email
          const _FieldLabel(label: 'Email address'),
          const SizedBox(height: AppSpacing.sm),
          _AuthTextField(
            controller: emailCtrl,
            hint: 'name@example.com',
            prefixIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email is required';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),

          const SizedBox(height: AppSpacing.lg),

          // Password
          const _FieldLabel(label: 'Password'),
          const SizedBox(height: AppSpacing.sm),
          _AuthTextField(
            controller: passwordCtrl,
            hint: '••••••••',
            prefixIcon: Icons.lock_outline_rounded,
            obscure: !passwordVisible,
            suffix: GestureDetector(
              onTap: onTogglePassword,
              child: Icon(
                passwordVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textHint,
                size: 20,
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              if (v.length < 6) return 'Minimum 6 characters';
              return null;
            },
          ),

          const SizedBox(height: AppSpacing.lg),

          // Confirm Password
          const _FieldLabel(label: 'Confirm password'),
          const SizedBox(height: AppSpacing.sm),
          _AuthTextField(
            controller: confirmCtrl,
            hint: '••••••••',
            prefixIcon: Icons.lock_outline_rounded,
            obscure: !confirmVisible,
            textInputAction: TextInputAction.done,
            suffix: GestureDetector(
              onTap: onToggleConfirm,
              child: Icon(
                confirmVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textHint,
                size: 20,
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) {
                return 'Please confirm your password';
              }
              if (v != passwordCtrl.text) return 'Passwords do not match';
              return null;
            },
          ),

          const SizedBox(height: AppSpacing.xl),

          // CTA
          _AuthCTA(
            label: 'Create Account',
            isLoading: isLoading,
            onTap: onCreateAccount,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Auth CTA Button
// ─────────────────────────────────────────────────────────────────────────────

class _AuthCTA extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  const _AuthCTA({
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE53935), Color(0xFFC62828)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.40),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.5,
            ),
          )
              : Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OR Divider
// ─────────────────────────────────────────────────────────────────────────────

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'OR CONTINUE WITH',
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.divider)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Google Button
// ─────────────────────────────────────────────────────────────────────────────

class _GoogleButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _GoogleButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.divider, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google colourful G icon
            _GoogleIcon(),
            const SizedBox(width: AppSpacing.md),
            Text(
              'Continue with Google',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          'G',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            foreground: Paint()
              ..shader = const LinearGradient(
                colors: [
                  Color(0xFF4285F4),
                  Color(0xFFEA4335),
                  Color(0xFFFBBC04),
                  Color(0xFF34A853),
                ],
              ).createShader(const Rect.fromLTWH(0, 0, 28, 28)),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Legal Text
// ─────────────────────────────────────────────────────────────────────────────

class _LegalText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textSecondary,
            height: 1.6,
          ),
          children: [
            const TextSpan(text: "By continuing, you agree to QuickBite's\n"),
            TextSpan(
              text: 'Terms of Service',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()..onTap = () {},
            ),
            const TextSpan(text: ' and '),
            TextSpan(
              text: 'Privacy Policy',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()..onTap = () {},
            ),
            const TextSpan(text: '.'),
          ],
        ),
      ),
    );
  }
}