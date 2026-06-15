import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/house_model.dart';

class DashboardCharts extends StatelessWidget {
  final List<HouseModel> houses;

  const DashboardCharts({super.key, required this.houses});

  @override
  Widget build(BuildContext context) {
    if (houses.isEmpty) return const SizedBox.shrink();

    final activeCount = houses.where((h) => h.aktif).length;
    final inactiveCount = houses.length - activeCount;

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: _buildPieChartCard(context, activeCount, inactiveCount),
      ),
    );
  }

  Widget _buildPieChartCard(BuildContext context, int activeCount, int inactiveCount) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status Rumah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color)),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      color: const Color(0xFF27AE60),
                      value: activeCount.toDouble(),
                      title: '$activeCount',
                      radius: 50,
                      titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    PieChartSectionData(
                      color: const Color(0xFFE74C3C),
                      value: inactiveCount.toDouble(),
                      title: '$inactiveCount',
                      radius: 50,
                      titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Indicator(color: const Color(0xFF27AE60), text: 'Aktif'),
                const SizedBox(width: 16),
                _Indicator(color: const Color(0xFFE74C3C), text: 'Kosong'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  final Color color;
  final String text;

  const _Indicator({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 16, height: 16, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }
}
