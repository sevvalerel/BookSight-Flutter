import 'package:flutter/material.dart';
import '../navigation/app_page_route.dart';
import '../services/book_service.dart';
import '../services/reading_status_service.dart';
import '../widgets/book_cover.dart';
import 'book_detail_screen.dart';

class ReadBooksScreen extends StatelessWidget {
  const ReadBooksScreen({super.key, required this.books});
  final List<LibraryEntry> books;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAF9),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Okuduklarım (${books.length})',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D4150),
          ),
        ),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF2D4150)),
      ),
      body: books.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    'Henüz okuma kaydınız yok',
                    style: TextStyle(color: Colors.grey[500], fontSize: 16),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
                childAspectRatio: 0.62,
              ),
              itemCount: books.length,
              itemBuilder: (context, index) {
                final entry = books[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    AppPageRoute(
                      page: BookDetailScreen(
                        book: Book(
                          bookId: entry.bookId,
                          title: entry.title,
                          author: entry.author,
                          coverUrl: entry.coverUrl,
                        ),
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: BookCover(
                          coverUrl: entry.coverUrl,
                          borderRadius: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        entry.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D4150),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        entry.author,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7A85),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
