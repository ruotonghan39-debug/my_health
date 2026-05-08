import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../shared/mock/mock_data.dart';
import '../../theme/app_theme.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool _seven = true;

  @override
  Widget build(BuildContext context) {
    final series = _seven ? mockWeightLast7Days : mockWeightLast30Days;
    final spots = List<FlSpot>.generate(
      series.length,
      (i) => FlSpot(i.toDouble(), series[i]),
    );

    return Scaffold(
      backgroundColor: TinyBurnColors.background,
      appBar: AppBar(
        title: const Text('数据'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        children: [
          ToggleButtons(
            borderRadius: BorderRadius.circular(TinyBurnRadii.card),
            isSelected: [_seven, !_seven],
            onPressed: (i) => setState(() => _seven = i == 0),
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('近 7 天'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('近 30 天'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: tinyBurnCardDecoration(),
            height: 220,
            child: LineChart(
              LineChartData(
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: _seven ? 1 : 5,
                      getTitlesWidget: (v, m) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            v.toInt().toString(),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: TinyBurnColors.textSecondary,
                                ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (v, m) => Text(
                        v.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: TinyBurnColors.textSecondary,
                            ),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 0.5,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.grey.shade200,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                minY: series.reduce((a, b) => a < b ? a : b) - 0.5,
                maxY: series.reduce((a, b) => a > b ? a : b) + 0.3,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: TinyBurnColors.primary,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (s, p, b, i) => FlDotCirclePainter(
                        radius: 3,
                        color: TinyBurnColors.primary,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          TinyBurnColors.primary.withValues(alpha: 0.25),
                          TinyBurnColors.primary.withValues(alpha: 0.02),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _StatHighlightCard(
                  title: '平均摄入',
                  value: '${kTodayStats.intakeKcal}',
                  unit: ' kcal / 天',
                  emoji: '🍱',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatHighlightCard(
                  title: '平均消耗',
                  value: '${kTodayStats.burnKcal}',
                  unit: ' kcal / 天',
                  emoji: '🔥',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: tinyBurnCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '打卡进度',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 14),
                _ProgressRow(
                  label: '连续打卡',
                  value: '${kTodayStats.streakDays} 天',
                  progress: (kTodayStats.streakDays / 14).clamp(0.0, 1.0),
                ),
                const SizedBox(height: 12),
                _ProgressRow(
                  label: '本月记录次数',
                  value: '18 次',
                  progress: 18 / 30,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatHighlightCard extends StatelessWidget {
  const _StatHighlightCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.emoji,
  });

  final String title;
  final String value;
  final String unit;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: tinyBurnCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: TinyBurnColors.textSecondary,
                ),
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
              children: [
                TextSpan(text: value),
                TextSpan(
                  text: unit,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: TinyBurnColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.label,
    required this.value,
    required this.progress,
  });

  final String label;
  final String value;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: TinyBurnColors.textSecondary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 10,
            value: progress,
            backgroundColor: TinyBurnColors.background,
            valueColor: const AlwaysStoppedAnimation<Color>(TinyBurnColors.primary),
          ),
        ),
      ],
    );
  }
}
