import 'package:flutter/material.dart';
import '../theme.dart';

class CategoryIcon extends StatelessWidget {
  final IconData icon;
  final int colorIndex;
  final double size;

  const CategoryIcon({
    super.key,
    required this.icon,
    required this.colorIndex,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.categoryColors[colorIndex % AppColors.categoryColors.length];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(size * 0.3),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Icon(icon, color: color, size: size * 0.48),
    );
  }
}
