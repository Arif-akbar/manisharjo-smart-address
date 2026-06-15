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

    // Group by RT
    final Map<String, int> rtDistribution = {};
    for (var h in houses) {
      if (h.rt.isNotEmpty) {
        final key = 'RT ${h.rt}';
        rtDistribution[key] = (rtDistribution[key] ?? 0) + 1;
      }
    }

    // Sort RTs (e.g., RT 01, RT 02)
    final sortedRtKeys = rtDistribution.keys.toList()..sort();

    // Use a responsive layout if the screen is narrow
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // Wrap in Column for mobile
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPieChartCard(context, activeCount, inactiveCount),
              const SizedBox(height: 24),
              _buildBarChartCard(context, sortedRtKeys, rtDistribution),
            ],
          );
        } else {
          // Wrap in Row for desktop
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: _buildPieChartCard(context, activeCount, inactiveCount),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 2,
                child: _buildBarChartCard(context, sortedRtKeys, rtDistribution),
              ),
            ],
          );
        }
      },
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

  Widget _buildBarChartCard(BuildContext context, List<String> sortedRtKeys, Map<String, int> rtDistribution) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Distribusi Rumah per RT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color)),
            const SizedBox(height: 24),
            SizedBox(
              height: 236, // Match height
              child: sortedRtKeys.isEmpty
                  ? const Center(child: Text('Data RT belum tersedia'))
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                if (value.toInt() >= 0 && value.toInt() < sortedRtKeys.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      sortedRtKeys[value.toInt()],
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: true, reservedSize: 28),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 5,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(color: Theme.of(context).dividerColor, strokeWidth: 1);
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(sortedRtKeys.length, (index) {
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: rtDistribution[sortedRtKeys[index]]!.toDouble(),
                                color: Theme.of(context).colorScheme.primary,
                                width: 20,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
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
