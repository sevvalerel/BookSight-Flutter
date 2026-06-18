import 'package:flutter/material.dart';
import '../services/book_service.dart';
import '../services/review_service.dart';
import '../services/auth_service.dart';
import '../widgets/book_cover.dart';
import '../services/reading_status_service.dart';
import '../navigation/app_page_route.dart';
import 'user_profile_screen.dart';

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
  String? _currentUsername;
  

  final _readingStatusService = ReadingStatusService();
  String? _currentReadingStatus;
  bool _isStatusLoading = false;

  final _reviewController = TextEditingController();
  int _selectedRating = 5;
  Book? _fullBook;

  @override
  void initState() {
    super.initState();
    _loadReviews();
    _loadCurrentUser();
    _loadReadingStatus();
    _loadFullBook();
  }

  Future<void> _loadCurrentUser() async {
    final username = await AuthService().getUsername();
    setState(() => _currentUsername = username);
  }

  Future<void> _loadFullBook() async {
    if (widget.book.description != null) return; // zaten tam veri var
    try {
      final full = await BookService().getBookById(widget.book.bookId);
      if (mounted) setState(() => _fullBook = full);
    } catch (_) {
      // sessizce geç, eldeki veriyle göster
    }
  }

  Future<void> _loadReadingStatus() async {
    try {
      final library = await _readingStatusService.getMyLibrary();
      final found = library.where((b) => b.bookId == widget.book.bookId);
      if (mounted) {
        setState(() {
          _currentReadingStatus =
              found.isEmpty ? null : found.first.status;
        });
      }
    } catch (_) {}
  }

  Future<void> _setReadingStatus(String status) async {
    setState(() => _isStatusLoading = true);
    try {
      await _readingStatusService.addOrUpdate(widget.book.bookId, status);
      setState(() => _currentReadingStatus = status);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_statusLabel(status)} olarak eklendi!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isStatusLoading = false);
    }
  }

  Future<void> _removeReadingStatus() async {
    setState(() => _isStatusLoading = true);
    try {
      await _readingStatusService.remove(widget.book.bookId);
      setState(() => _currentReadingStatus = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kütüphaneden çıkarıldı.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isStatusLoading = false);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'READING':
        return 'Okuyorum';
      case 'WILL_READ':
        return 'Okuyacağım';
      case 'READ':
        return 'Okudum';
      default:
        return status;
    }
  }

  void _showLibrarySheet() {
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
            const SizedBox(height: 16),
            const Text(
              'Kütüphaneye Ekle',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Divider(),
            _sheetTile('Okuyorum', Icons.auto_stories, 'READING'),
            _sheetTile('Okuyacağım', Icons.bookmark_outline, 'WILL_READ'),
            _sheetTile('Okudum', Icons.check_circle_outline, 'READ'),
            if (_currentReadingStatus != null) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Kütüphaneden Çıkar',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _removeReadingStatus();
                },
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _sheetTile(String label, IconData icon, String value) {
    final isActive = _currentReadingStatus == value;
    return ListTile(
      leading: Icon(
        icon,
        color: isActive ? const Color(0xFF6B4EFF) : Colors.grey,
      ),
      title: Text(label),
      trailing: isActive
          ? const Icon(Icons.check, color: Color(0xFF6B4EFF))
          : null,
      onTap: () {
        Navigator.pop(context);
        if (!isActive) _setReadingStatus(value);
      },
    );
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    try {
      final reviews = await _reviewService.getReviews(widget.book.bookId);
      if (!mounted) return;
      setState(() {
        _reviews = reviews;
        _isLoadingReviews = false;
      });
    } catch (e) {
      if (!mounted) return;
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
    if (_reviewController.text.trim().length < 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yorum en az 50 karakter olmalıdır.')),
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

  Future<void> _deleteReview(int reviewId) async {
    try {
      await _reviewService.deleteReview(reviewId);
      await _loadReviews();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yorum silindi.')),
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

  Future<void> _editReview(Review review) async {
    final reviewId = review.reviewId;
    if (reviewId == null) return;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => _EditReviewDialog(
        review: review,
        reviewService: _reviewService,
      ),
    );

    if (saved != true || !mounted) return;
    await _loadReviews();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yorum güncellendi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = _fullBook ?? widget.book;
    return Scaffold(
      backgroundColor: _DetailColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: _DetailColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BookCover(
                  coverUrl: book.coverUrl,
                  width: 100,
                  height: 140,
                  heroTag: BookCover.heroTagFor(book.bookId),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(book.title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _DetailColors.darkText)),
                      const SizedBox(height: 6),
                      Text(book.author,
                        style: const TextStyle(fontSize: 14, color: _DetailColors.greyText)),
                      if (book.genre != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _DetailColors.mintAccent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(book.genre!,
                            style: const TextStyle(fontSize: 12, color: _DetailColors.mintAccent, fontWeight: FontWeight.w600)),
                        ),
                      ],
                      if (book.avgRating != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: _DetailColors.star, size: 18),
                            const SizedBox(width: 4),
                            Text(book.avgRating!.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _DetailColors.darkText)),
                            if (book.reviewCount != null)
                              Text(' • ${book.reviewCount} yorum',
                                style: const TextStyle(fontSize: 12, color: _DetailColors.greyText)),
                          ],
                        ),
                      ],
                      if (book.publicationYear != null) ...[
                        const SizedBox(height: 4),
                        Text('${book.publicationYear}',
                          style: const TextStyle(fontSize: 12, color: _DetailColors.greyText)),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            if (book.description != null) ...[
              const SizedBox(height: 24),
              const Text('Açıklama',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _DetailColors.darkText)),
              const SizedBox(height: 8),
              _DescriptionText(text: book.description!),
            ],

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _isStatusLoading ? null : _showLibrarySheet,
                icon: _isStatusLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        _currentReadingStatus != null
                            ? Icons.library_books
                            : Icons.library_add_outlined,
                        color: const Color(0xFF6B4EFF),
                      ),
                label: Text(
                  _currentReadingStatus != null
                      ? _statusLabel(_currentReadingStatus!)
                      : 'Kütüphaneye Ekle',
                  style: const TextStyle(
                    color: Color(0xFF6B4EFF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF6B4EFF)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Yorum Ekle',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _DetailColors.darkText)),
            const SizedBox(height: 12),
            Row(
              children: List.generate(5, (i) => GestureDetector(
                onTap: () => setState(() => _selectedRating = i + 1),
                child: Icon(
                  i < _selectedRating ? Icons.star_rounded : Icons.star_border_rounded,
                  color: _DetailColors.star, size: 32,
                ),
              )),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reviewController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Düşüncelerinizi yazın... (en az 50 karakter)',
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

            const SizedBox(height: 24),
            const Text('Yorumlar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _DetailColors.darkText)),
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
                    itemBuilder: (context, i) => _ReviewCard(
                      review: _reviews[i],
                      currentUsername: _currentUsername,
                      onEdit: () {
                        _editReview(_reviews[i]);
                      },
                      onDelete: () {
                        final reviewId = _reviews[i].reviewId;
                        if (reviewId != null) _deleteReview(reviewId);
                      },
                    ),
                  ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _EditReviewDialog extends StatefulWidget {
  const _EditReviewDialog({
    required this.review,
    required this.reviewService,
  });

  final Review review;
  final ReviewService reviewService;

  @override
  State<_EditReviewDialog> createState() => _EditReviewDialogState();
}

class _EditReviewDialogState extends State<_EditReviewDialog> {
  late final TextEditingController _reviewController;
  late int _selectedRating;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _reviewController = TextEditingController(text: widget.review.reviewText ?? '');
    _selectedRating = widget.review.rating ?? 5;
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final reviewId = widget.review.reviewId;
    if (reviewId == null) return;

    final text = _reviewController.text.trim();
    if (text.length < 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yorum en az 50 karakter olmalıdır.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await widget.reviewService.updateReview(
        reviewId: reviewId,
        reviewText: text,
        rating: _selectedRating,
      );
      if (!mounted) return;
      FocusManager.instance.primaryFocus?.unfocus();
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Yorumu Düzenle'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(
                5,
                (i) => GestureDetector(
                  onTap: _isSaving
                      ? null
                      : () => setState(() => _selectedRating = i + 1),
                  child: Icon(
                    i < _selectedRating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: _DetailColors.star,
                    size: 30,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reviewController,
              enabled: !_isSaving,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Yorumunuzu güncelleyin... (en az 50 karakter)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: _DetailColors.mintAccent,
            foregroundColor: Colors.white,
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Kaydet'),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review, required this.currentUsername, required this.onDelete, required this.onEdit});
  final Review review;
  final String? currentUsername;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  void _openUserProfile(BuildContext context) {
    final username = review.username;
    if (username == null || username == currentUsername) return;
    Navigator.push(
      context,
      AppPageRoute(page: UserProfileScreen(username: username)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = currentUsername != null && currentUsername == review.username;
    final username = review.username ?? 'Kullanıcı';
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
              GestureDetector(
                onTap: isOwner ? null : () => _openUserProfile(context),
                child: Row(
                  children: [
                    _MiniAvatar(username: username, avatarUrl: review.userAvatarUrl),
                    const SizedBox(width: 6),
                    Text(
                      username,
                      style: TextStyle(
                        fontSize: 12,
                        color: isOwner
                            ? _DetailColors.greyText
                            : _DetailColors.mintAccent,
                        fontWeight: isOwner ? FontWeight.normal : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (isOwner) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onEdit,
                  child: const Icon(Icons.edit_outlined, size: 18, color: _DetailColors.mintAccent),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                ),
              ],
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

class _MiniAvatar extends StatelessWidget {
  const _MiniAvatar({required this.username, this.avatarUrl});
  final String username;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl?.trim();
    if (url != null && url.isNotEmpty) {
      if (url.startsWith('assets/')) {
        return ClipOval(
          child: Image.asset(url, width: 22, height: 22, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _initials()),
        );
      }
      final netUrl = url.startsWith('http://')
          ? url.replaceFirst('http://', 'https://')
          : url;
      return ClipOval(
        child: Image.network(netUrl, width: 22, height: 22, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _initials()),
      );
    }
    return _initials();
  }

  Widget _initials() {
    return Container(
      width: 22,
      height: 22,
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
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _DescriptionText extends StatefulWidget {
  const _DescriptionText({required this.text});
  final String text;

  @override
  State<_DescriptionText> createState() => _DescriptionTextState();
}

class _DescriptionTextState extends State<_DescriptionText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final text = _cleanDescription(widget.text);
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text,
              style: const TextStyle(
                  fontSize: 14, color: _DetailColors.greyText, height: 1.5),
              maxLines: _expanded ? null : 5,
              overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(
            _expanded ? 'Daha az göster' : 'Devamını oku',
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: _DetailColors.mintAccent),
          ),
        ],
      ),
    );
  }

  String _cleanDescription(String raw) {
    final text = raw.trim();
    // Son tam cümle bitişini (. ! ?) bul
    final matches = RegExp(r'[.!?]').allMatches(text);
    if (matches.isNotEmpty) {
      final lastEnd = matches.last.end;
      // Eğer son cümle metnin yarısından fazlasını kapsıyorsa, oraya kadar göster
      if (lastEnd > text.length * 0.4) {
        return text.substring(0, lastEnd);
      }
    }
    // Cümle sonu bulunamadıysa, son tam kelimeye kadar kes
    final lastSpace = text.lastIndexOf(' ');
    if (lastSpace > 0) {
      return '${text.substring(0, lastSpace)}…';
    }
return text;
  }
}
