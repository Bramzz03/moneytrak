import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../theme.dart';

class DonutChart extends StatefulWidget {
  final Map<String, double> data;

  const DonutChart({super.key, required this.data});

  @override
  State<DonutChart> createState() => _DonutChartState();
}

class _DonutChartState extends State<DonutChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pie_chart_outline, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 8),
            const Text(
              'Belum ada pengeluaran\nbulan ini',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
        ),
      );
    }

    final entries = widget.data.entries.toList();
    final total = entries.fold(0.0, (s, e) => s + e.value);

    final sections = entries.asMap().entries.map((e) {
      final idx = e.key;
      final entry = e.value;
      final isTouched = idx == _touchedIndex;
      final color = AppColors.categoryColors[idx % AppColors.categoryColors.length];
      final pct = entry.value / total * 100;

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: isTouched ? '${pct.toStringAsFixed(1)}%' : '',
        radius: isTouched ? 58 : 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        badgeWidget: isTouched ? null : null,
      );
    }).toList();

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response == null ||
                        response.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex = response.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 3,
              centerSpaceRadius: 45,
              sections: sections,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: entries.asMap().entries.map((e) {
            final color = AppColors.categoryColors[e.key % AppColors.categoryColors.length];
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 5),
                Text(
                  e.value.key,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
