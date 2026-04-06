import 'package:flutter/material.dart';
import '../services/book_service.dart';
import '../services/review_service.dart';

abstract final class _DetailColors {
  static const Color background = Color(0xFFF5FAF7);
  static const Color darkText = Color(0xFF2D4150);
  static const Color greyText = Color(0xFF6B7A85);
  static const Color mintAccent = Color(0xFF8BC3A3);
  static const Color purpleAccent = Color(0xFF9B8FD1);
  static const Color placeholderCover = Color(0xFFE4E8E6);
  static const Color star = Color(0xFFE8A23C);
}

class BookDetailScreen extends StatefulWidget {
  final Book book;
  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final _reviewService = ReviewService();
  List<Review> _reviews = [];
  bool _isLoadingReviews = true;
  bool _isSubmitting = false;

  final _reviewController = TextEditingController();
  int _selectedRating = 5;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    try {
      final reviews = await _reviewService.getReviews(widget.book.bookId);
      setState(() {
        _reviews = reviews;
        _isLoadingReviews = false;
      });
    } catch (e) {
      setState(() => _isLoadingReviews = false);
    }
  }

  Future<void> _submitReview() async {
    if (_reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yorum boş bırakılamaz.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _reviewService.addReview(
        bookId: widget.book.bookId,
        reviewText: _reviewController.text.trim(),
        rating: _selectedRating,
      );
      _reviewController.clear();
      setState(() => _selectedRating = 5);
      await _loadReviews();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yorumunuz eklendi!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    return Scaffold(
      backgroundColor: _DetailColors.background,
      appBar: AppBar(
        backgroundColor: _DetailColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: _DetailColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          book.title,
          style: const TextStyle(
            color: _DetailColors.darkText,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kitap kapak + bilgi
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: book.coverUrl != null
                    ? Image.network(
                        book.coverUrl!,
                        width: 100,
                        height: 140,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 100, height: 140,
                          color: _DetailColors.placeholderCover,
                        ),
                      )
                    : Container(
                        width: 100, height: 140,
                        color: _DetailColors.placeholderCover,
                      ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(book.title,
                        style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700,
                          color: _DetailColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(book.author,
                        style: const TextStyle(
                          fontSize: 14, color: _DetailColors.greyText,
                        ),
                      ),
                      if (book.genre != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _DetailColors.mintAccent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(book.genre!,
                            style: const TextStyle(
                              fontSize: 12, color: _DetailColors.mintAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      if (book.avgRating != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: _DetailColors.star, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              book.avgRating!.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700,
                                color: _DetailColors.darkText,
                              ),
                            ),
                            if (book.reviewCount != null)
                              Text(
                                ' • ${book.reviewCount} yorum',
                                style: const TextStyle(fontSize: 12, color: _DetailColors.greyText),
                              ),
                          ],
                        ),
                      ],
                      if (book.publicationYear != null) ...[
                        const SizedBox(height: 4),
                        Text('${book.publicationYear}',
                          style: const TextStyle(fontSize: 12, color: _DetailColors.greyText),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            // Açıklama
            if (book.description != null) ...[
              const SizedBox(height: 24),
              const Text('Açıklama',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _DetailColors.darkText),
              ),
              const SizedBox(height: 8),
              Text(book.description!,
                style: const TextStyle(fontSize: 14, color: _DetailColors.greyText, height: 1.5),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // Yorum ekle
            const SizedBox(height: 24),
            const Text('Yorum Ekle',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _DetailColors.darkText),
            ),
            const SizedBox(height: 12),
            // Yıldız seçimi
            Row(
              children: List.generate(5, (i) => GestureDetector(
                onTap: () => setState(() => _selectedRating = i + 1),
                child: Icon(
                  i < _selectedRating ? Icons.star_rounded : Icons.star_border_rounded,
                  color: _DetailColors.star,
                  size: 32,
                ),
              )),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reviewController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Düşüncelerinizi yazın...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _DetailColors.mintAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 0,
                ),
                child: _isSubmitting
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Yorumu Gönder', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),

            // Yorumlar listesi
            const SizedBox(height: 24),
            const Text('Yorumlar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _DetailColors.darkText),
            ),
            const SizedBox(height: 12),
            _isLoadingReviews
              ? const Center(child: CircularProgressIndicator())
              : _reviews.isEmpty
                ? const Text('Henüz yorum yok. İlk yorumu sen yaz!',
                    style: TextStyle(color: _DetailColors.greyText))
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _reviews.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => _ReviewCard(review: _reviews[i]),
                  ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});
  final Review review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Row(
                children: List.generate(5, (i) => Icon(
                  i < (review.rating ?? 0) ? Icons.star_rounded : Icons.star_border_rounded,
                  color: const Color(0xFFE8A23C),
                  size: 16,
                )),
              ),
              const Spacer(),
              Text(
                review.username ?? 'Kullanıcı',
                style: const TextStyle(fontSize: 12, color: _DetailColors.greyText),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.reviewText ?? '',
            style: const TextStyle(fontSize: 14, color: _DetailColors.darkText, height: 1.4),
          ),
        ],
      ),
    );
  }
}