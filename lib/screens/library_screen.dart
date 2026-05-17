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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kütüphanem',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF6B4EFF),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF6B4EFF),
          tabs: const [
            Tab(text: 'Okuyorum'),
            Tab(text: 'Okuyacağım'),
            Tab(text: 'Okudum'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookList(_filterByStatus('READING')),
          _buildBookList(_filterByStatus('WILL_READ')),
          _buildBookList(_filterByStatus('READ')),
        ],
      ),
    );
  }
}
