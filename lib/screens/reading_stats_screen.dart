import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../services/stats_service.dart';
import '../widgets/screen_header.dart';

abstract final class _StatsColors {
  static const Color background = Color(0xFFF5FAF7);
  static const Color darkText = Color(0xFF2D4150);
  static const Color greyText = Color(0xFF6B7A85);
  static const Color mintAccent = Color(0xFF8BC3A3);
  static const Color purpleAccent = Color(0xFF9B8FD1);
  static const Color chipBorder = Color(0xFFE5EAEE);
  static const Color star = Color(0xFFE8A23C);

  static const List<Color> chartPalette = [
    Color(0xFF8BC3A3),
    Color(0xFF9B8FD1),
    Color(0xFF6B4EFF),
    Color(0xFFE8A23C),
    Color(0xFF82D5C4),
    Color(0xFFA7ABFF),
    Color(0xFF5B8DEF),
    Color(0xFF6B7A85),
  ];

  static BoxDecoration chartCardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: chipBorder),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 18,
        offset: const Offset(0, 6),
      ),
    ],
  );

  static LinearGradient barGradient(Color base) => LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          base.withValues(alpha: 0.55),
          base,
        ],
      );

  static LinearGradient pieGradient(Color base) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          base.withValues(alpha: 0.85),
          base,
        ],
      );
}

class ReadingStatsScreen extends StatefulWidget {
  const ReadingStatsScreen({super.key});

  @override
  State<ReadingStatsScreen> createState() => _ReadingStatsScreenState();
}

class _ReadingStatsScreenState extends State<ReadingStatsScreen> {
  final _statsService = StatsService();
  ReadingStats? _stats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final stats = await _statsService.getMyStats();
      if (!mounted) return;
      setState(() {
        _stats = stats;
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
      backgroundColor: _StatsColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorView(message: _error!, onRetry: _loadStats)
              : ListView(
                  padding: const EdgeInsets.only(bottom: 32),
                  children: [
                    SafeArea(
                      bottom: false,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_rounded,
                                color: _StatsColors.darkText),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Expanded(
                            child: ScreenHeader(
                              title: 'Okuma İstatistikleri',
                              padding: EdgeInsets.fromLTRB(0, 12, 20, 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SummaryGrid(stats: _stats!),
                          const SizedBox(height: 24),
                          const _SectionTitle(title: 'Tür Dağılımı'),
                          const SizedBox(height: 12),
                          _GenreChartCard(stats: _stats!),
                          const SizedBox(height: 24),
                          const _SectionTitle(title: 'Aylık Trend'),
                          const SizedBox(height: 12),
                          _MonthlyTrendCard(stats: _stats!),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.stats});
  final ReadingStats stats;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: [
        _SummaryCard(
          label: 'Bu Ay',
          value: stats.reviewsThisMonth.toString(),
          accent: _StatsColors.mintAccent,
          icon: Icons.calendar_today_rounded,
        ),
        _SummaryCard(
          label: 'Bu Yıl',
          value: stats.reviewsThisYear.toString(),
          accent: _StatsColors.purpleAccent,
          icon: Icons.date_range_rounded,
        ),
        _SummaryCard(
          label: 'Toplam Yorum',
          value: stats.totalReviews.toString(),
          accent: const Color(0xFF6B4EFF),
          icon: Icons.rate_review_outlined,
        ),
        _SummaryCard(
          label: 'Ortalama Puan',
          value: stats.averageRating.toStringAsFixed(1),
          accent: _StatsColors.star,
          icon: Icons.star_rounded,
          suffix: '★',
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.accent,
    required this.icon,
    this.suffix,
  });

  final String label;
  final String value;
  final Color accent;
  final IconData icon;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            accent.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accent.withValues(alpha: 0.85),
                      accent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const Spacer(),
            ],
          ),
          const Spacer(),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _StatsColors.greyText,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: _StatsColors.darkText,
                    height: 1,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              if (suffix != null)
                Text(
                  suffix!,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: _StatsColors.darkText,
      ),
    );
  }
}

class _GenreChartCard extends StatefulWidget {
  const _GenreChartCard({required this.stats});
  final ReadingStats stats;

  @override
  State<_GenreChartCard> createState() => _GenreChartCardState();
}

class _GenreChartCardState extends State<_GenreChartCard> {
  int _touchedIndex = -1;

  int get _total =>
      widget.stats.genreDistribution.fold(0, (sum, item) => sum + item.count);

  @override
  Widget build(BuildContext context) {
    final hasData = widget.stats.genreDistribution.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: _StatsColors.chartCardDecoration,
      child: !hasData
          ? const _EmptyGenreState()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_total yorum · ${widget.stats.genreDistribution.length} tür',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _StatsColors.greyText.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 20),
                AspectRatio(
                  aspectRatio: 1.1,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          startDegreeOffset: -90,
                          sectionsSpace: 2,
                          centerSpaceRadius: 64,
                          pieTouchData: PieTouchData(
                            touchCallback: (event, response) {
                              setState(() {
                                if (!event.isInterestedForInteractions ||
                                    response?.touchedSection == null) {
                                  _touchedIndex = -1;
                                  return;
                                }
                                _touchedIndex =
                                    response!.touchedSection!.touchedSectionIndex;
                              });
                            },
                          ),
                          sections: _buildSections(),
                        ),
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutCubic,
                      ),
                      _DonutCenterLabel(
                        stats: widget.stats,
                        touchedIndex: _touchedIndex,
                        total: _total,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _GenreLegend(
                  items: widget.stats.genreDistribution,
                  total: _total,
                  touchedIndex: _touchedIndex,
                  onItemTap: (index) =>
                      setState(() => _touchedIndex = index),
                ),
              ],
            ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    return List.generate(widget.stats.genreDistribution.length, (index) {
      final item = widget.stats.genreDistribution[index];
      final color =
          _StatsColors.chartPalette[index % _StatsColors.chartPalette.length];
      final isTouched = index == _touchedIndex;
      final isDimmed = _touchedIndex != -1 && !isTouched;

      return PieChartSectionData(
        value: item.count.toDouble(),
        gradient: _StatsColors.pieGradient(color),
        radius: isTouched ? 72 : 68,
        title: '',
        badgeWidget: null,
        showTitle: false,
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: isDimmed ? 0.4 : 1),
          width: 2,
        ),
        titleStyle: const TextStyle(fontSize: 0),
      );
    });
  }
}

class _DonutCenterLabel extends StatelessWidget {
  const _DonutCenterLabel({
    required this.stats,
    required this.touchedIndex,
    required this.total,
  });

  final ReadingStats stats;
  final int touchedIndex;
  final int total;

  @override
  Widget build(BuildContext context) {
    if (touchedIndex >= 0 && touchedIndex < stats.genreDistribution.length) {
      final item = stats.genreDistribution[touchedIndex];
      final pct = total == 0 ? 0.0 : (item.count / total) * 100;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${pct.toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: _StatsColors.darkText,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.genre,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _StatsColors.greyText,
                height: 1.25,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          total.toString(),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: _StatsColors.darkText,
            height: 1,
          ),
        ),
        const SizedBox(height: 3),
        const Text(
          'toplam yorum',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _StatsColors.greyText,
          ),
        ),
      ],
    );
  }
}

class _GenreLegend extends StatelessWidget {
  const _GenreLegend({
    required this.items,
    required this.total,
    required this.touchedIndex,
    required this.onItemTap,
  });

  final List<GenreCount> items;
  final int total;
  final int touchedIndex;
  final ValueChanged<int> onItemTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(items.length, (index) {
        final item = items[index];
        final color = _StatsColors.chartPalette[index % _StatsColors.chartPalette.length];
        final pct = total == 0 ? 0.0 : (item.count / total) * 100;
        final isActive = index == touchedIndex;

        return Padding(
          padding: EdgeInsets.only(top: index == 0 ? 0 : 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onItemTap(index),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isActive ? color.withValues(alpha: 0.1) : _StatsColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isActive
                        ? color.withValues(alpha: 0.35)
                        : _StatsColors.chipBorder.withValues(alpha: 0.7),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.genre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                          color: _StatsColors.darkText,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${item.count}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 36,
                      child: Text(
                        '${pct.toStringAsFixed(0)}%',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isActive ? color : _StatsColors.darkText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _EmptyGenreState extends StatelessWidget {
  const _EmptyGenreState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 48,
            color: _StatsColors.mintAccent.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 12),
          const Text(
            'Henüz yorum yapmadınız,\nkitap okumaya başlayın!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _StatsColors.greyText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyTrendCard extends StatefulWidget {
  const _MonthlyTrendCard({required this.stats});
  final ReadingStats stats;

  @override
  State<_MonthlyTrendCard> createState() => _MonthlyTrendCardState();
}

class _MonthlyTrendCardState extends State<_MonthlyTrendCard> {
  int? _touchedIndex;

  static const _monthLabels = [
    'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
    'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
  ];

  String _formatMonth(String month) {
    final parts = month.split('-');
    if (parts.length != 2) return month;
    final index = int.tryParse(parts[1]);
    if (index == null || index < 1 || index > 12) return month;
    return _monthLabels[index - 1];
  }

  bool _isCurrentMonth(String month) {
    final now = DateTime.now();
    final current = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    return month == current;
  }

  @override
  Widget build(BuildContext context) {
    final trend = widget.stats.monthlyTrend;
    final maxCount = trend.fold<int>(
      0,
      (max, item) => item.count > max ? item.count : max,
    );
    final maxY = maxCount == 0 ? 4.0 : (maxCount * 1.25).ceilToDouble();
    final touched = _touchedIndex;
    final touchedCount =
        touched != null && touched >= 0 && touched < trend.length
            ? trend[touched].count
            : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 12, 16),
      decoration: _StatsColors.chartCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Son ${trend.length} ay',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _StatsColors.greyText.withValues(alpha: 0.9),
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: touchedCount != null
                    ? Container(
                        key: ValueKey(touched),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _StatsColors.mintAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_formatMonth(trend[touched!].month)}: $touchedCount yorum',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _StatsColors.darkText,
                          ),
                        ),
                      )
                    : const Text(
                        'Dokunarak detay gör',
                        key: ValueKey('hint'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: _StatsColors.greyText,
                        ),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 230,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                minY: 0,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => _StatsColors.darkText,
                    tooltipBorderRadius: BorderRadius.circular(10),
                    tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${_formatMonth(trend[groupIndex].month)}\n',
                        const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          TextSpan(
                            text: '${rod.toY.toInt()} yorum',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  touchCallback: (event, response) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          response?.spot == null) {
                        _touchedIndex = null;
                        return;
                      }
                      _touchedIndex = response!.spot!.touchedBarGroupIndex;
                    });
                  },
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY <= 4 ? 1 : (maxY / 4).ceilToDouble(),
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: _StatsColors.chipBorder.withValues(alpha: 0.85),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: maxY <= 4 ? 1 : (maxY / 4).ceilToDouble(),
                      getTitlesWidget: (value, meta) {
                        if (value != value.roundToDouble() || value < 0) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _StatsColors.greyText.withValues(alpha: 0.8),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= trend.length) {
                          return const SizedBox.shrink();
                        }
                        final isCurrent = _isCurrentMonth(trend[index].month);
                        final isTouched = index == _touchedIndex;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _formatMonth(trend[index].month),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isCurrent || isTouched
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: isCurrent
                                  ? _StatsColors.purpleAccent
                                  : isTouched
                                      ? _StatsColors.darkText
                                      : _StatsColors.greyText,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(trend.length, (index) {
                  final count = trend[index].count.toDouble();
                  final isCurrent = _isCurrentMonth(trend[index].month);
                  final isTouched = index == _touchedIndex;
                  final baseColor = isCurrent
                      ? _StatsColors.purpleAccent
                      : _StatsColors.mintAccent;

                  return BarChartGroupData(
                    x: index,
                    barsSpace: 4,
                    barRods: [
                      BarChartRodData(
                        fromY: 0,
                        toY: count,
                        width: isTouched ? 22 : 18,
                        gradient: _StatsColors.barGradient(baseColor),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY,
                          color: _StatsColors.background,
                        ),
                      ),
                    ],
                  );
                }),
              ),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _StatsColors.greyText),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: _StatsColors.mintAccent,
                side: BorderSide(color: _StatsColors.mintAccent.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Tekrar dene'),
            ),
          ],
        ),
      ),
    );
  }
}
