import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Swift/config/routes/route_names.dart';
import 'package:Swift/core/network/api_exception.dart';
import 'package:Swift/services/auth_service.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final authService = AuthService.instance;

  // Reactive state
  final RxBool rememberMe = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> handleSignIn() async {
    final username = emailController.text.trim();
    final password = passwordController.text;

    // Validasi input
    if (username.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Gagal',
        'Email dan password wajib diisi',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Validasi email format
    if (!GetUtils.isEmail(username)) {
      Get.snackbar(
        'Gagal',
        'Format email tidak valid',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Validasi password length
    if (password.length < 6) {
      Get.snackbar(
        'Gagal',
        'Password minimal 6 karakter',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;

    try {
      await authService.login(username: username, password: password);
      
      // Simpan remember me preference jika dicentang
      if (rememberMe.value) {
        // TODO: Simpan ke secure storage
        // await SecureStorage.write('remember_me', 'true');
        // await SecureStorage.write('email', username);
      }

      Get.offAllNamed(AppRoutes.map);
    } on ApiException catch (e) {
      Get.snackbar(
        'Login Gagal',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan tidak terduga',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void handleForgotPassword() {
    // TODO: Navigasi ke halaman forgot password
    Get.snackbar(
      'Info',
      'Fitur lupa password akan segera hadir',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}