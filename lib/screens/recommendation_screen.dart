import 'package:flutter/material.dart';
import '../services/recommendation_service.dart';

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

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
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
        _recommendations = data;
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
              const Text(
                'Sana Özel',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: _RecommendationColors.darkText,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Yorumların analiz edilerek önerildi',
                style: TextStyle(
                  fontSize: 16,
                  color: _RecommendationColors.greyText,
                ),
              ),
              const SizedBox(height: 18),
              _buildInsightCard(),
              const SizedBox(height: 20),
              const Text(
                'Önerilen Kitaplar',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: _RecommendationColors.darkText,
                ),
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
    final completed = _recommendations.length;
    final progress = completed == 0 ? 0.0 : (completed / 10).clamp(0.1, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
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
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.28),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Profilin Hazır!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '$completed/10 kitap değerlendirildi',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.26),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            completed >= 10
                ? 'Harika! AI profili hazır.'
                : 'Daha iyi öneriler için ${10 - completed} kitap daha puanla',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () {},
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
                width: 44,
                height: 44,
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
}

class _RecommendationBookCard extends StatelessWidget {
  const _RecommendationBookCard(this.item);
  final BookRecommendation item;

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
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: item.coverUrl != null
                    ? Image.network(
                        item.coverUrl!,
                        width: 66,
                        height: 92,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 66,
                          height: 92,
                          color: _RecommendationColors.placeholderCover,
                        ),
                      )
                    : Container(
                        width: 66,
                        height: 92,
                        color: _RecommendationColors.placeholderCover,
                      ),
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
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _RecommendationColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.author,
                      style: const TextStyle(
                        fontSize: 16,
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
          Row(
            children: [
              if (item.genre != null)
                _PillChip(label: item.genre!, color: _RecommendationColors.mintAccent),
              const SizedBox(width: 6),
              ...item.detectedLabels.take(2).map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: _PillChip(
                        label: e.replaceAll('_', ' '),
                        color: const Color(0xFF9B8FD1),
                      ),
                    ),
                  ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
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
                    Navigator.pushNamed(
                      context,
                      '/book-detail',
                      arguments: item.toBook(),
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
