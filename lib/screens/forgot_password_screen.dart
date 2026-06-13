import 'package:flutter/material.dart';
import '../services/auth_service.dart';

abstract final class _FPColors {
  static const Color background = Color(0xFFF8FAF9);
  static const Color primaryGreen = Color(0xFF8BC3A3);
  static const Color darkText = Color(0xFF2D4150);
  static const Color greyText = Color(0xFF757575);
  static const Color filledInput = Color(0xFFB2BCC6);
  static const Color passwordBorder = Color(0xFFE0E4E8);
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  int _step = 0; // 0: email, 1: kod, 2: yeni şifre

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showError('E-posta adresi giriniz.');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _authService.forgotPassword(email);
      if (mounted) {
        setState(() => _step = 1);
        _showSuccess('Doğrulama kodu e-posta adresinize gönderildi.');
      }
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyAndReset() async {
    final code = _codeController.text.trim();
    if (code.isEmpty || code.length != 6) {
      _showError('6 haneli kodu giriniz.');
      return;
    }
    setState(() => _step = 2);
  }

  Future<void> _resetPassword() async {
    final code = _codeController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    if (newPass.isEmpty || newPass.length < 6) {
      _showError('Şifre en az 6 karakter olmalı.');
      return;
    }
    if (newPass != confirmPass) {
      _showError('Şifreler eşleşmiyor.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.resetPassword(code, newPass);
      if (mounted) {
        _showSuccess('Şifreniz başarıyla güncellendi!');
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade400),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: _FPColors.primaryGreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _FPColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(28, 36, 28, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (_step > 0) {
                              setState(() => _step--);
                            } else {
                              Navigator.pop(context);
                            }
                          },
                          child: const Icon(Icons.arrow_back_ios_rounded,
                              color: _FPColors.darkText, size: 20),
                        ),
                        const Spacer(),
                        Text(
                          _step == 0
                              ? 'Şifremi Unuttum'
                              : _step == 1
                                  ? 'Kodu Gir'
                                  : 'Yeni Şifre',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: _FPColors.darkText,
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 20),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _step == 0
                          ? 'Kayıtlı e-posta adresini gir, sana bir doğrulama kodu gönderelim.'
                          : _step == 1
                              ? 'E-postana gelen 6 haneli kodu gir.'
                              : 'Yeni şifreni belirle.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: _FPColors.greyText,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),
                    if (_step == 0) ...[
                      _buildInput(
                        controller: _emailController,
                        hint: 'E-posta adresin',
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 24),
                      _buildButton('Kod Gönder', _sendCode),
                    ] else if (_step == 1) ...[
                      _buildInput(
                        controller: _codeController,
                        hint: '6 haneli kod',
                        icon: Icons.pin_outlined,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _isLoading ? null : _sendCode,
                          child: const Text(
                            'Kodu tekrar gönder',
                            style: TextStyle(
                              fontSize: 13,
                              color: _FPColors.primaryGreen,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildButton('Doğrula', _verifyAndReset),
                    ] else ...[
                      _buildPasswordInput(
                        controller: _newPasswordController,
                        hint: 'Yeni şifre',
                        obscure: _obscureNew,
                        onToggle: () =>
                            setState(() => _obscureNew = !_obscureNew),
                      ),
                      const SizedBox(height: 16),
                      _buildPasswordInput(
                        controller: _confirmPasswordController,
                        hint: 'Yeni şifre (tekrar)',
                        obscure: _obscureConfirm,
                        onToggle: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                      const SizedBox(height: 24),
                      _buildButton('Şifreyi Güncelle', _resetPassword),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      style: const TextStyle(fontSize: 15, color: _FPColors.darkText),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: _FPColors.greyText.withValues(alpha: 0.7)),
        prefixIcon: Icon(icon, color: _FPColors.greyText, size: 22),
        counterText: '',
        filled: true,
        fillColor: const Color(0xFFF5F7F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: _FPColors.passwordBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: _FPColors.passwordBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide:
              const BorderSide(color: _FPColors.primaryGreen, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildPasswordInput({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(fontSize: 15, color: _FPColors.darkText),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: _FPColors.greyText.withValues(alpha: 0.7)),
        prefixIcon: const Icon(Icons.lock_outline_rounded,
            color: _FPColors.greyText, size: 22),
        suffixIcon: IconButton(
          icon: Icon(
            obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: _FPColors.greyText,
            size: 22,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: const Color(0xFFF5F7F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: _FPColors.passwordBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: _FPColors.passwordBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide:
              const BorderSide(color: _FPColors.primaryGreen, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _FPColors.primaryGreen,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              _FPColors.primaryGreen.withValues(alpha: 0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Text(
                label,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 16),
              ),
      ),
    );
  }
}