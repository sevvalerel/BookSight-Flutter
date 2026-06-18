import 'package:flutter/material.dart';
import '../navigation/app_page_route.dart';
import '../services/book_service.dart';
import '../services/reading_status_service.dart';
import '../services/review_service.dart';
import '../widgets/book_cover.dart';
import 'book_detail_screen.dart';

class MyReviewsScreen extends StatelessWidget {
  const MyReviewsScreen({
    super.key,
    required this.reviews,
    required this.libraryMap,
  });
  final List<Review> reviews;
  final Map<int, LibraryEntry> libraryMap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAF9),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Yorumlarım',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D4150),
          ),
        ),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF2D4150)),
      ),
      body: reviews.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.rate_review_outlined,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    'Henüz yorum yazmadınız',
                    style: TextStyle(color: Colors.grey[500], fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              itemCount: reviews.length,
              itemBuilder: (context, index) => _ReviewCard(
                review: reviews[index],
                libraryMap: libraryMap,
              ),
            ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review, required this.libraryMap});
  final Review review;
  final Map<int, LibraryEntry> libraryMap;

  LibraryEntry? get _entry =>
      review.bookId != null ? libraryMap[review.bookId] : null;

  String? get _title => review.bookTitle ?? _entry?.title;
  String? get _coverUrl => review.bookCoverUrl ?? _entry?.coverUrl;
  String? get _author => _entry?.author;
  int? get _resolvedBookId => review.bookId ?? _entry?.bookId;

  void _openBook(BuildContext context) {
    final bookId = _resolvedBookId;
    if (bookId == null) return;
    Navigator.push(
      context,
      AppPageRoute(
        page: BookDetailScreen(
          book: Book(
            bookId: bookId,
            title: _title ?? 'Kitap',
            author: _author ?? '',
            coverUrl: _coverUrl,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE5EAEE)),
      ),
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _resolvedBookId != null ? () => _openBook(context) : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BookCover(
                coverUrl: _coverUrl,
                width: 56,
                height: 80,
                borderRadius: 10,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_title != null)
                      Text(
                        _title!,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D4150),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (_author != null && _author!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        _author!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7A85),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (review.rating != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < (review.rating ?? 0)
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 16,
                            color: const Color(0xFFF5A623),
                          ),
                        ),
                      ),
                    ],
                    if (review.reviewText != null &&
                        review.reviewText!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        review.reviewText!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7A85),
                          height: 1.45,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
