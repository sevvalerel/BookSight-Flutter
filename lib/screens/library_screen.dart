import 'package:flutter/material.dart';
import '../services/reading_status_service.dart';
import '../widgets/book_cover.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ReadingStatusService _service = ReadingStatusService();
  List<LibraryEntry> _allBooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadLibrary();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLibrary() async {
    setState(() => _isLoading = true);
    try {
      final books = await _service.getMyLibrary();
      setState(() => _allBooks = books);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<LibraryEntry> _filterByStatus(String status) {
    return _allBooks.where((b) => b.status == status).toList();
  }

  Future<void> _changeStatus(int bookId, String newStatus) async {
    try {
      await _service.addOrUpdate(bookId, newStatus);
      await _loadLibrary();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  Future<void> _removeBook(int bookId) async {
    try {
      await _service.remove(bookId);
      await _loadLibrary();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kitap kütüphaneden çıkarıldı.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  void _showStatusMenu(BuildContext context, LibraryEntry book) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              book.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Divider(),
            _statusTile('Okuyorum', 'READING', book),
            _statusTile('Okuyacağım', 'WILL_READ', book),
            _statusTile('Okudum', 'READ', book),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text(
                'Kütüphaneden Çıkar',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _removeBook(book.bookId);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _statusTile(String label, String value, LibraryEntry book) {
    final isActive = book.status == value;
    return ListTile(
      leading: Icon(
        isActive ? Icons.check_circle : Icons.radio_button_unchecked,
        color: isActive ? const Color(0xFF6B4EFF) : Colors.grey,
      ),
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        if (!isActive) _changeStatus(book.bookId, value);
      },
    );
  }

  Widget _buildBookList(List<LibraryEntry> books) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (books.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'Henüz kitap eklemediniz',
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Kitap detayından ekleyebilirsiniz',
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadLibrary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey[200]!),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: BookCover(
                coverUrl: book.coverUrl,
                width: 50,
                height: 70,
              ),
              title: Text(
                book.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                book.author,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showStatusMenu(context, book),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'KÜTÜPHANEm'.toUpperCase(),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF2D4150),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B4EFF),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${_allBooks.length} kitap',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7A85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Row(
        children: [
          _statPill(
            '${_filterByStatus('READING').length}',
            'Okuyorum',
            const Color(0xFF0F6E56),
            const Color(0xFFE1F5EE),
          ),
          const SizedBox(width: 10),
          _statPill(
            '${_filterByStatus('WILL_READ').length}',
            'Okuyacağım',
            const Color(0xFF534AB7),
            const Color(0xFFEEEDFE),
          ),
          const SizedBox(width: 10),
          _statPill(
            '${_filterByStatus('READ').length}',
            'Okudum',
            const Color(0xFF3B6D11),
            const Color(0xFFEAF3DE),
          ),
        ],
      ),
    );
  }

  Widget _statPill(String count, String label, Color textColor, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: textColor.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8EDE9), width: 0.5),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: const Color(0xFF6B4EFF),
            borderRadius: BorderRadius.circular(10),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF6B7A85),
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          tabs: const [
            Tab(text: 'Okuyorum'),
            Tab(text: 'Okuyacağım'),
            Tab(text: 'Okudum'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF7),
      body: Column(
        children: [
          _buildHeader(),
          _buildStatRow(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBookList(_filterByStatus('READING')),
                _buildBookList(_filterByStatus('WILL_READ')),
                _buildBookList(_filterByStatus('READ')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
