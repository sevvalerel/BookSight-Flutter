import 'package:flutter/material.dart';

import '../services/auth_service.dart';

abstract final class _HomeColors {
  static const Color background = Color(0xFFF5FAF7);
  static const Color darkText = Color(0xFF2D4150);
  static const Color greyText = Color(0xFF6B7A85);
  static const Color mintAccent = Color(0xFF8BC3A3);
  static const Color purpleAccent = Color(0xFF9B8FD1);
  static const Color chipBorder = Color(0xFFE5EAEE);
  static const Color placeholderCover = Color(0xFFE4E8E6);
  static const Color star = Color(0xFFE8A23C);
}

class _PopularBook {
  const _PopularBook({
    required this.title,
    required this.author,
    required this.rating,
    required this.reviewLabel,
  });

  final String title;
  final String author;
  final String rating;
  final String reviewLabel;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;
  final _searchController = TextEditingController();

  static const List<String> _trendTags = [
    'Fantastik',
    'Polisiye',
    'Klasikler',
    'Kişisel Gelişim',
    'Bilim Kurgu',
  ];

  static const List<_PopularBook> _popularBooks = [
    _PopularBook(
      title: 'Suç ve Ceza',
      author: 'Fyodor Dostoyevski',
      rating: '4.7',
      reviewLabel: '1.2k değerlendirme',
    ),
    _PopularBook(
      title: '1984',
      author: 'George Orwell',
      rating: '4.6',
      reviewLabel: '980 değerlendirme',
    ),
    _PopularBook(
      title: 'Simyacı',
      author: 'Paulo Coelho',
      rating: '4.5',
      reviewLabel: '2.1k değerlendirme',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _HomeColors.background,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: _bodyForNav(),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _bodyForNav() {
    switch (_navIndex) {
      case 0:
        return _buildSearchHome();
      case 1:
        return _buildPlaceholderTab('AI önerileri', Icons.auto_awesome_outlined);
      case 2:
        return _buildPlaceholderTab('Kütüphane', Icons.menu_book_outlined);
      case 3:
        return _buildProfileTab();
      default:
        return _buildSearchHome();
    }
  }

  Widget _buildSearchHome() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: _buildSearchRow(),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Text(
              'Trend Aramalar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _HomeColors.darkText,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _trendTags
                  .map((t) => _TrendChip(label: t))
                  .toList(),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Senin için popüler',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _HomeColors.darkText,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: _HomeColors.mintAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Text('Tümünü gör >'),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 268,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              scrollDirection: Axis.horizontal,
              itemCount: _popularBooks.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, i) => _PopularBookCard(book: _popularBooks[i]),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
            child: Text(
              'Arama Sonuçları',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _HomeColors.darkText,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SearchResultRow(index: index),
              ),
              childCount: 3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchRow() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Kitap adı veya yazar',
              hintStyle: TextStyle(
                color: _HomeColors.greyText.withValues(alpha: 0.8),
                fontSize: 15,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: _HomeColors.greyText.withValues(alpha: 0.85),
                size: 24,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Material(
          color: _HomeColors.purpleAccent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {},
            child: const SizedBox(
              width: 52,
              height: 52,
              child: Icon(Icons.tune_rounded, color: Colors.white, size: 24),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderTab(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: _HomeColors.greyText),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _HomeColors.darkText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          const Icon(Icons.person_outline_rounded, size: 64, color: _HomeColors.greyText),
          const SizedBox(height: 16),
          const Text(
            'Profil',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _HomeColors.darkText,
            ),
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Çıkış yap'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _HomeColors.darkText,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 88),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.paddingOf(context).bottom + 12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.search_rounded,
              label: 'Ara',
              selected: _navIndex == 0,
              onTap: () => setState(() => _navIndex = 0),
            ),
            _NavItem(
              icon: Icons.auto_awesome_rounded,
              label: 'AI',
              selected: _navIndex == 1,
              onTap: () => setState(() => _navIndex = 1),
            ),
            _NavItem(
              icon: Icons.menu_book_rounded,
              label: 'Kütüphane',
              selected: _navIndex == 2,
              onTap: () => setState(() => _navIndex = 2),
            ),
            _NavItem(
              icon: Icons.person_outline_rounded,
              label: 'Profil',
              selected: _navIndex == 3,
              onTap: () => setState(() => _navIndex = 3),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendChip extends StatelessWidget {
  const _TrendChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _HomeColors.chipBorder),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _HomeColors.darkText,
            ),
          ),
        ),
      ),
    );
  }
}

class _PopularBookCard extends StatelessWidget {
  const _PopularBookCard({required this.book});

  final _PopularBook book;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 158,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      color: _HomeColors.placeholderCover,
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _HomeColors.purpleAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'AI önerisi',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              book.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _HomeColors.darkText,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              book.author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: _HomeColors.greyText,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.star_rounded, color: _HomeColors.star, size: 16),
                const SizedBox(width: 4),
                Text(
                  book.rating,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _HomeColors.darkText,
                  ),
                ),
                Expanded(
                  child: Text(
                    ' • ${book.reviewLabel}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: _HomeColors.greyText),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultRow extends StatelessWidget {
  const _SearchResultRow({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 56,
              height: 72,
              color: _HomeColors.placeholderCover,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Örnek kitap ${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _HomeColors.darkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Yazar — API ile yüklenecek',
                  style: TextStyle(
                    fontSize: 12,
                    color: _HomeColors.greyText.withValues(alpha: 0.95),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? _HomeColors.mintAccent : _HomeColors.greyText;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: selected
                    ? _HomeColors.mintAccent.withValues(alpha: 0.22)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
