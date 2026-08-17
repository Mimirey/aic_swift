import 'package:Swift/components/custom_spacing.dart';
import 'package:Swift/components/text_field/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:Swift/config/routes/route_names.dart';
import 'package:get/get.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../components/buttons/primary_button.dart';
import '../../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    final username = _emailController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      Get.snackbar('Gagal', 'Email dan password wajib diisi');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService.instance.login(username: username, password: password);
      if (!mounted) return;
      Get.offNamed(AppRoutes.map);
    } on ApiException catch (e) {
      Get.snackbar('Login Gagal', e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final headerHeight = (context.screenHeight * 0.42).clamp(260.0, 380.0);

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: headerHeight,
            pinned: false,
            backgroundColor: AppColors.primaryDark,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primaryLight.withOpacity(0.9),
                          AppColors.primaryDark,
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.local_shipping_rounded,
                        size: 90,
                        color: Colors.white24,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.15),
                          Colors.black.withOpacity(0.35),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Swift',
                      style: TextStyle(
                        fontSize: context.scaled(40),
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  context.horizontalPadding,
                  28,
                  context.horizontalPadding,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Welcome Back',
                            style: TextStyle(
                              fontSize: context.scaled(22),
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Fill up the text field',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      label: 'Email Address',
                      hint: 'Enter your Email Address',
                      prefixIcon: Icon(Icons.email_outlined),
                      usePrefixIcon: true,
                      controller: _emailController,
                      textInputType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 18),
                    CustomTextField(
                      label: 'Password',
                      hint: 'Enter your Password',
                      prefixIcon: Icon(Icons.lock_outline),
                      usePrefixIcon: true,
                      textInputType: TextInputType.visiblePassword,
                      controller: _passwordController,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        SizedBox(
                          height: 22,
                          width: 22,
                          child: Checkbox(
                            value: _rememberMe,
                            activeColor: AppColors.textSecondary,
                            onChanged: (v) =>
                                setState(() => _rememberMe = v ?? false),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Remember For 30 Days',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    PrimaryButton(
                      label: 'Sign In',
                      isLoading: _isLoading,
                      onPressed: _handleSignIn,
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const CustomSpacing(height: 84),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
