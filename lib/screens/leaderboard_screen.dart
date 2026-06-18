import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../navigation/app_page_route.dart';
import 'user_profile_screen.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key, required this.currentUsername});
  final String? currentUsername;

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late Future<List<LeaderboardEntry>> _future;

  @override
  void initState() {
    super.initState();
    _future = UserService().getLeaderboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAF9),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Sıralama',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D4150),
          ),
        ),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF2D4150)),
      ),
      body: FutureBuilder<List<LeaderboardEntry>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }
          final entries = snapshot.data ?? [];
          if (entries.isEmpty) {
            return const Center(child: Text('Henüz sıralama verisi yok.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              final isMe = entry.username == widget.currentUsername;
              final rank = index + 1;
              return _LeaderboardRow(
                entry: entry,
                rank: rank,
                isMe: isMe,
                onTap: isMe
                    ? null
                    : () => Navigator.push(
                          context,
                          AppPageRoute(
                            page: UserProfileScreen(username: entry.username),
                          ),
                        ),
              );
            },
          );
        },
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({
    required this.entry,
    required this.rank,
    required this.isMe,
    this.onTap,
  });
  final LeaderboardEntry entry;
  final int rank;
  final bool isMe;
  final VoidCallback? onTap;

  static const _medals = {1: '🥇', 2: '🥈', 3: '🥉'};
  static const _medalColors = {
    1: Color(0xFFFFD700),
    2: Color(0xFFB8B8B8),
    3: Color(0xFFCD7F32),
  };

  @override
  Widget build(BuildContext context) {
    final medal = _medals[rank];
    final medalColor = _medalColors[rank];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe
              ? const Color(0xFF8BC3A3).withValues(alpha: 0.15)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isMe
                ? const Color(0xFF8BC3A3)
                : const Color(0xFFE5EAEE),
            width: isMe ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 36,
              child: medal != null
                  ? Text(medal,
                      style: TextStyle(
                          fontSize: 22,
                          color: medalColor,
                          shadows: medalColor != null
                              ? [Shadow(color: medalColor.withValues(alpha: 0.4), blurRadius: 4)]
                              : null))
                  : Text(
                      '$rank',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6B7A85),
                      ),
                    ),
            ),
            _AvatarCircle(username: entry.username, avatarUrl: entry.avatarUrl, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        entry.username,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isMe
                              ? const Color(0xFF5A9E7A)
                              : const Color(0xFF2D4150),
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8BC3A3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Sen',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '🔥 ${entry.streak} günlük seri',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF6B7A85)),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${entry.totalPoints}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: medalColor ?? const Color(0xFF8BC3A3),
                  ),
                ),
                const Text(
                  'puan',
                  style: TextStyle(fontSize: 11, color: Color(0xFF6B7A85)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({
    required this.username,
    this.avatarUrl,
    this.size = 40,
  });
  final String username;
  final String? avatarUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl?.trim();
    if (url != null && url.isNotEmpty) {
      if (url.startsWith('assets/')) {
        return ClipOval(
          child: Image.asset(url, width: size, height: size, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _initials()),
        );
      }
      final netUrl = url.startsWith('http://')
          ? url.replaceFirst('http://', 'https://')
          : url;
      return ClipOval(
        child: Image.network(netUrl, width: size, height: size, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _initials()),
      );
    }
    return _initials();
  }

  Widget _initials() {
    return Container(
      width: size,
      height: size,
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
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
