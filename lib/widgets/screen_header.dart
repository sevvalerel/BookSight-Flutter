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
    final isMultiLine = maxLines > 1;

    return Padding(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth),
              child: Text(
                title,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2D4150),
                  letterSpacing: -0.5,
                  height: isMultiLine ? 1.25 : null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}