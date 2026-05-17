import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../utils/error_message.dart';
import '../widgets/screen_header.dart';

abstract final class _EditProfileColors {
  static const Color background = Color(0xFFF5FAF7);
  static const Color darkText = Color(0xFF2D4150);
  static const Color greyText = Color(0xFF6B7A85);
  static const Color mintAccent = Color(0xFF8BC3A3);
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.profile});

  final UserProfile profile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _userService = UserService();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;
  late final TextEditingController _avatarUrlController;
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _showPasswordSection = false;
  bool _isSaving = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.profile.username);
    _bioController = TextEditingController(text: widget.profile.bio ?? '');
    _avatarUrlController = TextEditingController(text: widget.profile.avatarUrl ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    _avatarUrlController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final newPassword = _newPasswordController.text.trim();
    final currentPassword = _currentPasswordController.text.trim();
    final wantsPasswordChange =
        newPassword.isNotEmpty || currentPassword.isNotEmpty;

    if (wantsPasswordChange) {
      if (currentPassword.isEmpty || newPassword.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Şifre değiştirmek için mevcut ve yeni şifreyi girin.'),
          ),
        );
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      final usernameChanged =
          _usernameController.text.trim() != widget.profile.username;
      final bioChanged = _bioController.text != (widget.profile.bio ?? '');
      final avatarChanged =
          _avatarUrlController.text.trim() != (widget.profile.avatarUrl ?? '');

      await _userService.updateProfile(
        username: usernameChanged ? _usernameController.text.trim() : null,
        bio: bioChanged ? _bioController.text : null,
        avatarUrl: avatarChanged ? _avatarUrlController.text.trim() : null,
        currentPassword: wantsPasswordChange ? currentPassword : null,
        newPassword: wantsPasswordChange ? newPassword : null,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil güncellendi!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(cleanErrorMessage(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _EditProfileColors.background,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 20),
          children: [
            SafeArea(
              bottom: false,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded,
                        color: _EditProfileColors.darkText),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: ScreenHeader(
                      title: 'Profili Düzenle',
                      padding: EdgeInsets.fromLTRB(0, 12, 20, 16),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
            TextFormField(
              controller: _usernameController,
              decoration: _inputDecoration('Kullanıcı adı'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Kullanıcı adı boş olamaz';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bioController,
              maxLines: 4,
              maxLength: 500,
              decoration: _inputDecoration('Biyografi'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _avatarUrlController,
              decoration: _inputDecoration('Avatar URL (isteğe bağlı)'),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 24),
            InkWell(
              onTap: () => setState(() => _showPasswordSection = !_showPasswordSection),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      _showPasswordSection ? Icons.expand_less : Icons.expand_more,
                      color: _EditProfileColors.mintAccent,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Şifre değiştir',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _EditProfileColors.darkText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_showPasswordSection) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _currentPasswordController,
                obscureText: _obscureCurrent,
                decoration: _inputDecoration('Mevcut şifre').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureCurrent ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureNew,
                decoration: _inputDecoration('Yeni şifre').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNew ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _EditProfileColors.mintAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Kaydet',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
              ),
            ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }
}
