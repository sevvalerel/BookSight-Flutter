import 'package:flutter/material.dart';
import '../navigation/app_page_route.dart';
import '../services/recommendation_service.dart';
import '../widgets/book_cover.dart';
import '../widgets/screen_header.dart';
import 'book_detail_screen.dart';
import '../services/reading_status_service.dart';

abstract final class _RecommendationColors {
  static const Color background = Color(0xFFF5FAF7);
  static const Color darkText = Color(0xFF2D4150);
  static const Color greyText = Color(0xFF6B7A85);
  static const Color mintAccent = Color(0xFF8BC3A3);
  static const Color purpleAccent = Color(0xFF9B8FD1);
  static const Color placeholderCover = Color(0xFFE4E8E6);
}

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  final _recommendationService = RecommendationService();
  bool _isLoading = true;
  String? _error;
  List<BookRecommendation> _recommendations = [];
  int _analyzedReviews = 0;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _reanalyzeAndRefresh() async {
    setState(() => _isLoading = true);
    try {
      await _recommendationService.reanalyze();
    } catch (_) {}
    await _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _recommendationService.getRecommendations();
      if (!mounted) return;
      setState(() {
        _recommendations = data['recommendations'] as List<BookRecommendation>;
        _analyzedReviews = data['analyzedReviews'] as int;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _RecommendationColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _loadRecommendations,
          color: _RecommendationColors.mintAccent,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
            children: [
              const ScreenHeader(
                title: 'Sana Özel',
                padding: EdgeInsets.zero,
                fontSize: 23,
              ),
              const SizedBox(height: 18),
              _buildInsightCard(),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Önerilen Kitaplar',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: _RecommendationColors.darkText,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showHistory(context),
                    icon: const Icon(Icons.history_rounded, size: 18),
                    label: const Text('Geçmiş'),
                    style: TextButton.styleFrom(
                      foregroundColor: _RecommendationColors.purpleAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 26),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                _ErrorCard(message: _error!, onRetry: _loadRecommendations)
              else if (_recommendations.isEmpty)
                const _EmptyCard()
              else
                ..._recommendations.map(_RecommendationBookCard.new),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightCard() {
    final completed = _analyzedReviews;
    final progress = (completed / 10).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [Color(0xFF82D5C4), Color(0xFFA7ABFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.28),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 21,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Profilin Hazır',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      completed >= 10
                          ? '$completed kitap değerlendirildi'
                          : '$completed/10 kitap değerlendirildi',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.26),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            completed >= 10
                ? 'Öneriler senin zevkine göre kişiselleştirildi.'
                : 'Daha iyi öneriler için ${10 - completed} kitap daha puanla',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton(
                    onPressed: _reanalyzeAndRefresh,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF8B88FF), width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      backgroundColor: Colors.white,
                      foregroundColor: _RecommendationColors.purpleAccent,
                    ),
                    child: const Text(
                      'Tercihlerimi Güncelle',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 40,
                height: 40,
                child: FilledButton(
                  onPressed: _loadRecommendations,
                  style: FilledButton.styleFrom(
                    backgroundColor: _RecommendationColors.mintAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Icon(Icons.refresh_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  void _showHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) {
          return FutureBuilder<List<BookRecommendation>>(
            future: _recommendationService.getHistory(),
            builder: (context, snapshot) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Öneri Geçmişi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _RecommendationColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const Center(child: CircularProgressIndicator())
                    else if (snapshot.hasError)
                      Text('Hata: ${snapshot.error}')
                    else if (!snapshot.hasData || snapshot.data!.isEmpty)
                      const Text('Henüz öneri geçmişi yok.',
                          style: TextStyle(color: _RecommendationColors.greyText))
                    else
                      Expanded(
                        child: ListView.separated(
                          controller: scrollController,
                          itemCount: snapshot.data!.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final item = snapshot.data![i];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: item.coverUrl != null
                                    ? Image.network(item.coverUrl!,
                                        width: 40, height: 56, fit: BoxFit.cover)
                                    : Container(width: 40, height: 56,
                                        color: _RecommendationColors.placeholderCover),
                              ),
                              title: Text(item.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600, fontSize: 14)),
                              subtitle: Text(item.author,
                                  style: const TextStyle(fontSize: 12,
                                      color: _RecommendationColors.greyText)),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _RecommendationBookCard extends StatelessWidget {
  const _RecommendationBookCard(this.item);
  final BookRecommendation item;

  void _showStatusPicker(BuildContext context, BookRecommendation item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        Widget tile(String label, IconData icon, String status) {
          return ListTile(
            leading: Icon(icon, color: const Color(0xFF6B4EFF)),
            title: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            onTap: () async {
              Navigator.pop(sheetContext);
              try {
                await ReadingStatusService().addOrUpdate(item.bookId, status);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$label olarak eklendi!')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Hata: $e')),
                  );
                }
              }
            },
          );
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Kütüphaneye Ekle',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              const Divider(height: 1),
              tile('Okuyorum', Icons.auto_stories, 'READING'),
              tile('Okuyacağım', Icons.bookmark_outline, 'WILL_READ'),
              tile('Okudum', Icons.check_circle_outline, 'READ'),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BookCover(
                coverUrl: item.coverUrl,
                width: 66,
                height: 92,
                borderRadius: 14,
                heroTag: BookCover.heroTagFor(item.bookId),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _RecommendationColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.author,
                      style: const TextStyle(
                        fontSize: 14,
                        color: _RecommendationColors.greyText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFFF5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.reason,
                        style: const TextStyle(
                          color: _RecommendationColors.darkText,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (item.genre != null)
                _PillChip(
                  label: item.genre!,
                  color: _RecommendationColors.mintAccent,
                ),
              ...item.detectedLabels.map(
                (e) => _PillChip(
                  label: _turkishLabel(e),
                  color: const Color(0xFF9B8FD1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton(
                onPressed: () async {
                  try {
                    final msg = await RecommendationService().submitFeedback(item.bookId, true);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(msg), backgroundColor: _RecommendationColors.mintAccent),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Hata: $e')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.thumb_up_outlined, size: 20),
                color: _RecommendationColors.mintAccent,
                tooltip: 'Beğendim',
              ),
              IconButton(
                onPressed: () async {
                  try {
                    final msg = await RecommendationService().submitFeedback(item.bookId, false);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(msg), backgroundColor: Colors.orange),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Hata: $e')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.thumb_down_outlined, size: 20),
                color: _RecommendationColors.greyText,
                tooltip: 'Beğenmedim',
              ),
              const Spacer(),
              Text(
                'Bu öneriyi değerlendir',
                style: TextStyle(
                  fontSize: 11,
                  color: _RecommendationColors.greyText.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showStatusPicker(context, item),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFD4EDE1)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    foregroundColor: _RecommendationColors.mintAccent,
                  ),
                  child: const Text(
                    'Kaydet',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    final book = item.toBook();
                    Navigator.push(
                      context,
                      AppPageRoute(
                        settings: RouteSettings(name: '/book-detail', arguments: book),
                        page: BookDetailScreen(book: book),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: _RecommendationColors.mintAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Detaya Git',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PillChip extends StatelessWidget {
  const _PillChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _RecommendationColors.greyText),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onRetry,
            child: const Text('Tekrar dene'),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Text(
        'Henüz AI önerisi bulunamadı.',
        style: TextStyle(color: _RecommendationColors.greyText),
      ),
    );
  }
}
String _turkishLabel(String label) {
  const translations = {
    'felsefi': 'Felsefi',
    'psikolojik_derinlik': 'Psikolojik Derinlik',
    'duygusal_yogunluk': 'Duygusal Yoğunluk',
    'toplumsal_elestiri': 'Toplumsal Eleştiri',
    'tarihsel': 'Tarihsel',
    'karamsar': 'Karamsar',
    'akici_ve_surukleyici': 'Akıcı ve Sürükleyici',
    'ask': 'Aşk',
    'macera': 'Macera',
    'bilimkurgu_distopya': 'Bilim Kurgu / Distopya',
    'gizem_polisiye': 'Gizem / Polisiye',
    'ogretici_farkindalik': 'Öğretici / Farkındalık',
    'mizah': 'Mizah',
  };
  return translations[label] ?? label.replaceAll('_', ' ');
}