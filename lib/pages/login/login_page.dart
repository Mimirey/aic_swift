import 'package:Swift/components/custom_spacing.dart';
import 'package:Swift/components/text_field/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Swift/core/theme/app_colors.dart';
import 'package:Swift/core/utils/responsive.dart';
import 'package:Swift/components/buttons/primary_button.dart';
import 'package:Swift/controllers/login_controller.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final headerHeight = (context.screenHeight * 0.42).clamp(260.0, 380.0);

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          _buildHeader(context, headerHeight),
          _buildLoginForm(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double headerHeight) {
    return SliverAppBar(
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
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return SliverToBoxAdapter(
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
              _buildWelcomeText(context),
              const SizedBox(height: 24),
              _buildEmailField(),
              const SizedBox(height: 18),
              _buildPasswordField(),
              const SizedBox(height: 10),
              _buildRememberMe(),
              const SizedBox(height: 18),
              _buildSignInButton(),
              _buildForgotPassword(),
              const CustomSpacing(height: 84),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText(BuildContext context) {
    return Center(
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
    );
  }

  Widget _buildEmailField() {
    return CustomTextField(
      label: 'Email Address',
      hint: 'Enter your Email Address',
      prefixIcon: const Icon(Icons.email_outlined),
      usePrefixIcon: true,
      controller: controller.emailController,
      textInputType: TextInputType.emailAddress,
    );
  }

  Widget _buildPasswordField() {
    return Obx(() => CustomTextField(
      label: 'Password',
      hint: 'Enter your Password',
      prefixIcon: const Icon(Icons.lock_outline),
      usePrefixIcon: true,
      textInputType: TextInputType.visiblePassword,
      controller: controller.passwordController,
      obscureText: controller.obscurePassword.value,
      suffixIcon: IconButton(
        icon: Icon(
          controller.obscurePassword.value
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          size: 20,
          color: AppColors.textSecondary,
        ),
        onPressed: controller.togglePasswordVisibility,
      ),
      useSuffixIcon: true,
    ));
  }

  Widget _buildRememberMe() {
    return Row(
      children: [
        SizedBox(
          height: 22,
          width: 22,
          child: Obx(() => Checkbox(
            value: controller.rememberMe.value,
            activeColor: AppColors.textSecondary,
            onChanged: controller.toggleRememberMe,
          )),
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
    );
  }

  Widget _buildSignInButton() {
    return Obx(() => PrimaryButton(
      label: 'Sign In',
      isLoading: controller.isLoading.value,
      onPressed: controller.handleSignIn,
    ));
  }

  Widget _buildForgotPassword() {
    return Center(
      child: TextButton(
        onPressed: controller.handleForgotPassword,
        child: const Text(
          'Forgot Password?',
          style: TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}