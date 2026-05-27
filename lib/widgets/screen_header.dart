import 'package:flutter/material.dart';

class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 16),
    this.maxLines = 1,
    this.fontSize = 26,
  });

  final String title;
  final EdgeInsetsGeometry padding;
  final int maxLines;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              title.toUpperCase(),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
                color: Color(0xFF2D4150),
                letterSpacing: 1.5,
              ),
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
    );
  }
}
