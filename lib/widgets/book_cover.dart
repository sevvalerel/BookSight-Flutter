import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

abstract final class _BookCoverColors {
  static const Color placeholder = Color(0xFFE4E8E6);
  static const Color icon = Color(0xFF6B7A85);
}

class BookCover extends StatelessWidget {
  const BookCover({
    super.key,
    this.coverUrl,
    this.width,
    this.height,
    this.borderRadius = 12,
    this.fit = BoxFit.cover,
  });

  final String? coverUrl;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;

  String? get _normalizedUrl {
    final url = coverUrl?.trim();
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http://')) {
      return url.replaceFirst('http://', 'https://');
    }
    return url;
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: _BookCoverColors.placeholder,
      child: const Center(
        child: Icon(Icons.menu_book_rounded, color: _BookCoverColors.icon, size: 32),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final url = _normalizedUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: url == null
          ? _placeholder()
          : CachedNetworkImage(
              imageUrl: url,
              width: width,
              height: height,
              fit: fit,
              placeholder: (_, __) => Container(
                width: width,
                height: height,
                color: _BookCoverColors.placeholder,
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              errorWidget: (_, __, ___) => _placeholder(),
            ),
    );
  }
}
