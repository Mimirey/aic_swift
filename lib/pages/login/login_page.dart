import 'package:flutter/material.dart';
import 'package:getx_setup/config/routes/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../components/buttons/primary_button.dart';
import '../../components/inputs/custom_text_field.dart';


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
    // TODO: ganti dengan pemanggilan API auth beneran.
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.of(context).pushReplacementNamed(AppRoutes.packageList);
  }

  @override
  Widget build(BuildContext context) {
    // Tinggi gambar header dibuat proporsional ke tinggi layar, dengan batas
    // atas & bawah biar tetap wajar di layar pendek (SE) maupun tinggi (Pro Max).
    final headerHeight = (context.screenHeight * 0.42).clamp(260.0, 380.0);

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SizedBox(
        height: context.screenHeight,
        child: Stack(
          children: [
            // Header: foto kurir + nama app
            SizedBox(
              height: headerHeight,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Placeholder foto kurir. Ganti dengan Image.asset('assets/images/courier.jpg')
                  // atau Image.network(url) begitu asset final tersedia.
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
                      child: Icon(Icons.local_shipping_rounded, size: 90, color: Colors.white24),
                    ),
                  ),
                  // Overlay gradasi biar teks "Swift" tetap kebaca
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

            // Panel putih (form) - pakai SingleChildScrollView biar aman
            // kalau keyboard muncul / layar pendek.
            Positioned(
              top: headerHeight - 28,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    context.horizontalPadding,
                    28,
                    context.horizontalPadding,
                    24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        label: 'Email Address',
                        hint: 'Enter your Email Address',
                        icon: Icons.email_outlined,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 18),
                      CustomTextField(
                        label: 'Password',
                        hint: 'Enter your Password',
                        icon: Icons.lock_outline,
                        isPassword: true,
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
                              activeColor: AppColors.primaryDark,
                              onChanged: (v) => setState(() => _rememberMe = v ?? false),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Remember For 30 Days',
                            style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      PrimaryButton(
                        label: 'Sign In',
                        isLoading: _isLoading,
                        onPressed: _handleSignIn,
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: AppColors.primaryLight,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
