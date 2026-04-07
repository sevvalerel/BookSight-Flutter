import 'package:flutter/material.dart';
import '../services/review_service.dart';
import '../services/user_service.dart';

abstract final class _ProfileColors {
  static const Color background = Color(0xFFF5FAF7);
  static const Color darkText = Color(0xFF2D4150);
  static const Color greyText = Color(0xFF6B7A85);
  static const Color mintAccent = Color(0xFF8BC3A3);
  static const Color purpleAccent = Color(0xFF9B8FD1);
  static const Color chipBorder = Color(0xFFE5EAEE);
  static const Color chipSelected = Color(0xFFE8F4EE);
  static const Color chipUnselected = Color(0xFFF3F8F5);
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.onLogout});
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        UserService().getMyProfile(),
        ReviewService().getMyReviews(),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data?[0] as UserProfile?;
        final myReviews = snapshot.data?[1] as List<Review>?;
        final reviewCount = myReviews?.length ?? 0;

        const likedThemes = ['Duygusal', 'Karakter Odaklı', 'Psikolojik', 'Klasik'];
        const favoriteGenres = ['Roman', 'Distopya', 'Felsefe'];

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık
              const Text(
                'Profil',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: _ProfileColors.darkText,
                ),
              ),
              const SizedBox(height: 16),

              // Profil kartı
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _ProfileColors.chipBorder),
                ),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 88,
                      height: 88,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF8BC3A3), Color(0xFF9B8FD1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        size: 44,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // İsim
                    Text(
                      user?.username ?? '...',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: _ProfileColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Email
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: _ProfileColors.greyText,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // İstatistikler
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StatItem(
                          value: reviewCount.toString(),
                          label: 'Yorum',
                          color: _ProfileColors.purpleAccent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Profili Düzenle
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Profili Düzenle'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _ProfileColors.mintAccent,
                          side: BorderSide(
                            color: _ProfileColors.mintAccent.withValues(alpha: 0.5),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // AI Tercihlerim
              const Text(
                'AI Tercihlerim',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _ProfileColors.darkText,
                ),
              ),
              const SizedBox(height: 16),

              // Sevdiğim Temalar
              const Text(
                'Sevdiğim Temalar',
                style: TextStyle(
                  fontSize: 14,
                  color: _ProfileColors.greyText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: likedThemes
                    .map((t) => _ProfileChip(label: t, selected: true))
                    .toList(),
              ),

              const SizedBox(height: 16),

              // Favori Türlerim
              const Text(
                'Favori Türlerim',
                style: TextStyle(
                  fontSize: 14,
                  color: _ProfileColors.greyText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...favoriteGenres.map((g) => _ProfileChip(label: g, selected: false)),
                  _ProfileChip(label: '+ Ekle', selected: false, isAdd: true),
                ],
              ),

              const SizedBox(height: 28),

              // Çıkış yap
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onLogout,
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Çıkış yap'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _ProfileColors.darkText,
                    side: const BorderSide(color: Color(0xFFE5EAEE)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    required this.color,
  });
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: _ProfileColors.greyText,
          ),
        ),
      ],
    );
  }
}

class _ProfileChip extends StatelessWidget {
  const _ProfileChip({
    required this.label,
    required this.selected,
    this.isAdd = false,
  });
  final String label;
  final bool selected;
  final bool isAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFFE8F4EE)
            : isAdd
                ? Colors.transparent
                : const Color(0xFFF3F8F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAdd
              ? _ProfileColors.chipBorder
              : selected
                  ? const Color(0xFFB8DEC8)
                  : const Color(0xFFD8E7E0),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isAdd
              ? _ProfileColors.mintAccent
              : selected
                  ? _ProfileColors.darkText
                  : _ProfileColors.mintAccent,
        ),
      ),
    );
  }
}