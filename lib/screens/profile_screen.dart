import 'package:flutter/material.dart';
import '../navigation/app_page_route.dart';
import '../services/review_service.dart';
import '../services/user_service.dart';
import 'edit_profile_screen.dart';
import 'reading_stats_screen.dart';
import '../widgets/screen_header.dart';

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

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.onLogout});
  final VoidCallback onLogout;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<List<dynamic>>? _profileFuture;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    setState(() {
      _profileFuture = Future.wait([
        UserService().getMyProfile(),
        ReviewService().getMyReviews(),
      ]);
    });
  }

  Future<void> _openEditProfile(UserProfile user) async {
    final updated = await Navigator.push<bool>(
      context,
      AppPageRoute(
        page: EditProfileScreen(profile: user),
      ),
    );
    if (updated == true) _loadProfile();
  }

  void _openReadingStats() {
    Navigator.push(
      context,
      AppPageRoute(page: const ReadingStatsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Hata: ${snapshot.error}'),
            ),
          );
        }

        final user = snapshot.data?[0] as UserProfile?;
        final myReviews = snapshot.data?[1] as List<Review>?;
        final reviewCount = myReviews?.length ?? 0;

        const likedThemes = ['Duygusal', 'Karakter Odaklı', 'Psikolojik', 'Klasik'];
        const favoriteGenres = ['Roman', 'Distopya', 'Felsefe'];

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ScreenHeader(title: 'Profilim'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      child: user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                user.avatarUrl!,
                                width: 88,
                                height: 88,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.person_outline_rounded,
                                  size: 44,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.person_outline_rounded,
                              size: 44,
                              color: Colors.white,
                            ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      user?.username ?? '...',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: _ProfileColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: _ProfileColors.greyText,
                      ),
                    ),
                    if (user?.bio != null && user!.bio!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        user.bio!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: _ProfileColors.greyText,
                          height: 1.4,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
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
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: user == null ? null : () => _openEditProfile(user),
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
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _openReadingStats,
                        icon: const Icon(Icons.bar_chart_rounded, size: 16),
                        label: const Text('İstatistiklerim'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _ProfileColors.purpleAccent,
                          side: BorderSide(
                            color: _ProfileColors.purpleAccent.withValues(alpha: 0.5),
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
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI Tercihlerim',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: _ProfileColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 16),
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
                        ...favoriteGenres
                            .map((g) => _ProfileChip(label: g, selected: false)),
                        _ProfileChip(label: '+ Ekle', selected: false, isAdd: true),
                      ],
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: widget.onLogout,
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
