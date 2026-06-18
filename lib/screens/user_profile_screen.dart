import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../widgets/book_cover.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key, required this.username});
  final String username;

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late Future<PublicUserProfile> _future;

  @override
  void initState() {
    super.initState();
    _future = UserService().getUserPublicProfile(widget.username);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAF9),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          widget.username,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D4150),
          ),
        ),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF2D4150)),
      ),
      body: FutureBuilder<PublicUserProfile>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }
          final profile = snapshot.data!;
          return _ProfileBody(profile: profile);
        },
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.profile});
  final PublicUserProfile profile;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildStats(),
          if (profile.favoriteGenres.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildGenres(),
          ],
          if (profile.reviews.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Yorumları',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D4150),
              ),
            ),
            const SizedBox(height: 12),
            ...profile.reviews.map((r) => _ReviewCard(review: r)),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5EAEE)),
      ),
      child: Column(
        children: [
          _AvatarLarge(username: profile.username, avatarUrl: profile.avatarUrl),
          const SizedBox(height: 14),
          Text(
            profile.username,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D4150),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        _StatCard(value: '${profile.totalPoints}', label: 'Puan', color: const Color(0xFF8BC3A3)),
        const SizedBox(width: 12),
        _StatCard(value: '${profile.streak}', label: 'Seri 🔥', color: const Color(0xFFE8A23C)),
        const SizedBox(width: 12),
        _StatCard(value: '${profile.readCount}', label: 'Okunan', color: const Color(0xFFB8A9E0)),
        const SizedBox(width: 12),
        _StatCard(value: '${profile.reviewCount}', label: 'Yorum', color: const Color(0xFF9B8FD1)),
      ],
    );
  }

  Widget _buildGenres() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Favori Türler',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D4150),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: profile.favoriteGenres
              .map((g) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F4EE),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFB8DEC8)),
                    ),
                    child: Text(
                      g,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2D4150),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label, required this.color});
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5EAEE)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF6B7A85)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});
  final PublicUserReview review;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5EAEE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BookCover(coverUrl: review.bookCoverUrl, width: 50, height: 72, borderRadius: 8),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (review.bookTitle != null)
                  Text(
                    review.bookTitle!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D4150),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (review.rating != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        i < (review.rating ?? 0)
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 14,
                        color: const Color(0xFFE8A23C),
                      ),
                    ),
                  ),
                ],
                if (review.reviewText != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    review.reviewText!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7A85),
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarLarge extends StatelessWidget {
  const _AvatarLarge({required this.username, this.avatarUrl});
  final String username;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl?.trim();
    if (url != null && url.isNotEmpty) {
      if (url.startsWith('assets/')) {
        return ClipOval(
          child: Image.asset(url, width: 88, height: 88, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _initials()),
        );
      }
      final netUrl = url.startsWith('http://')
          ? url.replaceFirst('http://', 'https://')
          : url;
      return ClipOval(
        child: Image.network(netUrl, width: 88, height: 88, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _initials()),
      );
    }
    return _initials();
  }

  Widget _initials() {
    return Container(
      width: 88,
      height: 88,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF8BC3A3), Color(0xFFB8A9E0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          username.isNotEmpty ? username[0].toUpperCase() : '?',
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
