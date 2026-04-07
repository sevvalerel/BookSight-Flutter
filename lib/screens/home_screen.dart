import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/book_service.dart';
import 'profile_screen.dart';

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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;
  final _searchController = TextEditingController();
  final _bookService = BookService();
  List<Book> _books = [];
  List<Book> _searchResults = [];
  bool _isLoading = true;
  bool _isSearching = false;
  String? _selectedGenre;
  int _searchRequestId = 0;
  

  static const List<String> _trendTags = [
    'Roman', 'Klasik', 'Distopya', 'Bilim',
  ];

  @override
  void initState() {
    super.initState();
    _loadBooks();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadBooks() async {
    try {
      final books = await _bookService.getBooks();
      setState(() {
        _books = books;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }
  Future<void> _loadBooksByGenre(String? genre) async {
  setState(() => _isLoading = true);
  try {
    final books = await _bookService.getBooks(genre: genre);
    setState(() {
      _books = books;
      _isLoading = false;
    });
  } catch (e) {
    setState(() => _isLoading = false);
  }
}

  void _onSearchChanged() async {
    final query = _searchController.text.trim();
    final currentRequestId = ++_searchRequestId;

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final results = await _bookService.getBooks(search: query);
      if (!mounted || currentRequestId != _searchRequestId) return;
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (_) {
      if (!mounted || currentRequestId != _searchRequestId) return;
      setState(() => _isSearching = false);
    }
  }

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
      body: SafeArea(bottom: false, child: _bodyForNav()),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _bodyForNav() {
    switch (_navIndex) {
      case 0: return _buildSearchHome();
      case 1: return _buildPlaceholderTab('AI önerileri', Icons.auto_awesome_outlined);
      case 2: return _buildPlaceholderTab('Kütüphane', Icons.menu_book_outlined);
      case 3: return ProfileScreen(onLogout: _logout);
      default: return _buildSearchHome();
    }
  }

  Widget _buildSearchHome() {
    final hasQuery = _searchController.text.trim().isNotEmpty;
    final listToShow = hasQuery ? _searchResults : _books;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: _buildSearchRow(),
          ),
        ),
        if (!hasQuery) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text('Trend Aramalar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _HomeColors.darkText)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Wrap(
                spacing: 8, runSpacing: 8,
                children: _trendTags.map((t) => _TrendChip(
                  label: t,
                  selected: _selectedGenre == t,
                  onTap: () {
                    setState(() {
                      _selectedGenre = _selectedGenre == t ? null : t;
                      _searchController.clear();
                    });
                    _loadBooksByGenre(_selectedGenre);
                  },
                )).toList(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 12, 0),
              child: Row(
                children: [
                  Expanded(child: Text('Senin için popüler',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _HomeColors.darkText))),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(foregroundColor: _HomeColors.mintAccent, padding: const EdgeInsets.symmetric(horizontal: 8)),
                    child: const Text('Tümünü gör >'),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 268,
              child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _books.isEmpty
                  ? const Center(child: Text('Kitap bulunamadı'))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      scrollDirection: Axis.horizontal,
                      itemCount: _books.length > 10 ? 10 : _books.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (context, i) => _PopularBookCard(book: _books[i]),
                    ),
            ),
          ),
        ],
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
            child: Text(
            hasQuery ? 'Arama Sonuçları' : 'Tüm Kitaplar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _HomeColors.darkText),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          sliver: hasQuery && _isSearching
              ? const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              : hasQuery && _searchResults.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text('Sonuc bulunamadi', style: TextStyle(color: Color(0xFF6B7A85))),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= listToShow.length) return null;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _SearchResultRow(book: listToShow[index]),
                          );
                        },
                        childCount: listToShow.length,
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
              hintStyle: TextStyle(color: _HomeColors.greyText.withValues(alpha: 0.8), fontSize: 15),
              prefixIcon: Icon(Icons.search_rounded, color: _HomeColors.greyText.withValues(alpha: 0.85), size: 24),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
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
            child: const SizedBox(width: 52, height: 52,
              child: Icon(Icons.tune_rounded, color: Colors.white, size: 24)),
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
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _HomeColors.darkText)),
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
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 20, offset: const Offset(0, 6))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(icon: Icons.search_rounded, label: 'Ara', selected: _navIndex == 0, onTap: () => setState(() => _navIndex = 0)),
            _NavItem(icon: Icons.auto_awesome_rounded, label: 'AI', selected: _navIndex == 1, onTap: () => setState(() => _navIndex = 1)),
            _NavItem(icon: Icons.menu_book_rounded, label: 'Kütüphane', selected: _navIndex == 2, onTap: () => setState(() => _navIndex = 2)),
            _NavItem(icon: Icons.person_outline_rounded, label: 'Profil', selected: _navIndex == 3, onTap: () => setState(() => _navIndex = 3)),
          ],
        ),
      ),
    );
  }
}

class _TrendChip extends StatelessWidget {
  const _TrendChip({required this.label, required this.onTap, this.selected = false});
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? _HomeColors.mintAccent : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? _HomeColors.mintAccent : _HomeColors.chipBorder,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: selected ? Colors.white : _HomeColors.darkText,
            ),
          ),
        ),
      ),
    );
  }
}

class _PopularBookCard extends StatelessWidget {
  const _PopularBookCard({required this.book});
  final Book book;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/book-detail', arguments: book),
      child: SizedBox(
        width: 158,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 14, offset: const Offset(0, 4))],
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
                      child: book.coverUrl != null
                        ? Image.network(book.coverUrl!, width: double.infinity, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: _HomeColors.placeholderCover))
                        : Container(width: double.infinity, color: _HomeColors.placeholderCover),
                    ),
                    Positioned(
                      top: 6, right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: _HomeColors.purpleAccent, borderRadius: BorderRadius.circular(10)),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text('AI önerisi', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _HomeColors.darkText, height: 1.2)),
              const SizedBox(height: 4),
              Text(book.author, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: _HomeColors.greyText)),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: _HomeColors.star, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    book.avgRating != null ? book.avgRating!.toStringAsFixed(1) : '—',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _HomeColors.darkText),
                  ),
                  if (book.reviewCount != null)
                    Expanded(
                      child: Text(' • ${book.reviewCount} yorum', maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: _HomeColors.greyText)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchResultRow extends StatelessWidget {
  const _SearchResultRow({required this.book});
  final Book book;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/book-detail', arguments: book),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: book.coverUrl != null
                ? Image.network(book.coverUrl!, width: 56, height: 72, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(width: 56, height: 72, color: _HomeColors.placeholderCover))
                : Container(width: 56, height: 72, color: _HomeColors.placeholderCover),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.title, style: const TextStyle(fontWeight: FontWeight.w700, color: _HomeColors.darkText)),
                  const SizedBox(height: 4),
                  Text(book.author, style: TextStyle(fontSize: 12, color: _HomeColors.greyText.withValues(alpha: 0.95))),
                  if (book.genre != null) ...[
                    const SizedBox(height: 4),
                    Text(book.genre!, style: const TextStyle(fontSize: 11, color: _HomeColors.greyText)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label, required this.selected, required this.onTap});
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
                color: selected ? _HomeColors.mintAccent.withValues(alpha: 0.22) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: color)),
          ],
        ),
      ),
    );
  }
}