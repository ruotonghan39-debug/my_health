import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/feed_providers.dart';
import '../../shared/mock/mock_data.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/feed_post_card.dart';
import '../../theme/app_theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late String _greeting;

  @override
  void initState() {
    super.initState();
    final i = DateTime.now().day % homeGreetings.length;
    _greeting = homeGreetings[i];
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(feedPostsProvider);

    return Scaffold(
      backgroundColor: TinyBurnColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: _Header(
                  greeting: _greeting,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _TodaySummaryCard(stats: kTodayStats),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: _WeightCard(
                  weight: kTodayStats.weightKg,
                  delta: kTodayStats.deltaFromYesterday,
                  series: mockWeightLast7Days,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: _DietIntakeCard(
                  current: kTodayStats.intakeKcal,
                  goal: kTodayStats.intakeGoal,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: _ExerciseBurnCard(
                  current: kTodayStats.burnKcal,
                  goal: kTodayStats.burnGoal,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: SectionHeader(
                  title: '快捷记录',
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _QuickActions(
                  onDiet: () => context.go('/publish/diet'),
                  onExercise: () => context.go('/publish/exercise'),
                  onWeight: () => context.go('/publish/weight'),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: SectionHeader(
                  title: '最近动态',
                  action: TextButton(
                    onPressed: () => context.go('/community'),
                    child: const Text('去社区'),
                  ),
                ),
              ),
            ),
            postsAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text('动态加载失败：$e'),
                ),
              ),
              data: (posts) {
                final slice = posts.take(3).toList();
                return SliverList.separated(
                  itemCount: slice.length,
                  separatorBuilder: (context, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final post = slice[index];
                    return Padding(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        0,
                        20,
                        index == slice.length - 1 ? 24 : 0,
                      ),
                      child: FeedPostCard(post: post, compact: true),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.greeting});

  final String greeting;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi，$greeting',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '和小燃一起轻盈打卡～',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: TinyBurnColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded),
          color: TinyBurnColors.textPrimary,
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            'assets/images/mascot.png',
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: TinyBurnColors.primary.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.eco_outlined),
            ),
          ),
        ),
      ],
    );
  }
}

class _TodaySummaryCard extends StatelessWidget {
  const _TodaySummaryCard({required this.stats});

  final MockDailyStats stats;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '今日状态',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _miniStat(context, '摄入', '${stats.intakeKcal}', ' kcal'),
              _miniStat(context, '消耗', '${stats.burnKcal}', ' kcal'),
              _miniStat(context, '体重', stats.weightKg.toStringAsFixed(1), ' kg'),
              _miniStat(context, '连续', '${stats.streakDays}', ' 天'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(BuildContext context, String label, String value, String unit) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: TinyBurnColors.textSecondary,
                ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: TinyBurnColors.textPrimary,
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

class _WeightCard extends StatelessWidget {
  const _WeightCard({
    required this.weight,
    required this.delta,
    required this.series,
  });

  final double weight;
  final double delta;
  final List<double> series;

  @override
  Widget build(BuildContext context) {
    final spots = List<FlSpot>.generate(
      series.length,
      (i) => FlSpot(i.toDouble(), series[i]),
    );

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${weight.toStringAsFixed(1)} kg',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: TinyBurnColors.primary.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  delta <= 0
                      ? '比昨天 ↓ ${delta.abs().toStringAsFixed(1)}'
                      : '比昨天 ↑ ${delta.toStringAsFixed(1)}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '近 7 天趋势',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: TinyBurnColors.textSecondary,
                ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 100,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(show: false),
                lineTouchData: const LineTouchData(enabled: false),
                minY: series.reduce((a, b) => a < b ? a : b) - 0.4,
                maxY: series.reduce((a, b) => a > b ? a : b) + 0.2,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: TinyBurnColors.primary,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          TinyBurnColors.primary.withValues(alpha: 0.35),
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
        ],
      ),
    );
  }
}

class _DietIntakeCard extends StatelessWidget {
  const _DietIntakeCard({
    required this.current,
    required this.goal,
  });

  final int current;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final ratio = (current / goal).clamp(0.0, 1.0);
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '饮食摄入',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$current / $goal kcal',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 10,
                    backgroundColor: TinyBurnColors.background,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      TinyBurnColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '宏量营养（示例）',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: TinyBurnColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 86,
            height: 86,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 22,
                sections: [
                  PieChartSectionData(
                    value: kMacroFractions['碳水']!,
                    title: '',
                    color: TinyBurnColors.primary,
                    radius: 14,
                  ),
                  PieChartSectionData(
                    value: kMacroFractions['蛋白']!,
                    title: '',
                    color: TinyBurnColors.accentBlue,
                    radius: 14,
                  ),
                  PieChartSectionData(
                    value: kMacroFractions['脂肪']!,
                    title: '',
                    color: TinyBurnColors.accentYellow,
                    radius: 14,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseBurnCard extends StatelessWidget {
  const _ExerciseBurnCard({
    required this.current,
    required this.goal,
  });

  final int current;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final ratio = (current / goal).clamp(0.0, 1.0);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '运动消耗',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              const Icon(
                Icons.directions_run_rounded,
                color: TinyBurnColors.accentBlue,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$current / $goal kcal',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 10,
              backgroundColor: TinyBurnColors.background,
              valueColor: const AlwaysStoppedAnimation<Color>(
                TinyBurnColors.accentBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onDiet,
    required this.onExercise,
    required this.onWeight,
  });

  final VoidCallback onDiet;
  final VoidCallback onExercise;
  final VoidCallback onWeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _QuickTile(
                icon: Icons.camera_alt_outlined,
                label: '饮食记录',
                sub: '拍照打卡',
                color: TinyBurnColors.accentYellow.withValues(alpha: 0.45),
                onTap: onDiet,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickTile(
                icon: Icons.directions_run,
                label: '运动记录',
                sub: '轻量就好',
                color: TinyBurnColors.accentBlue.withValues(alpha: 0.25),
                onTap: onExercise,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _QuickTile(
          icon: Icons.monitor_weight_outlined,
          label: '体重记录',
          sub: '自动对比昨日',
          color: TinyBurnColors.primary.withValues(alpha: 0.35),
          onTap: onWeight,
          fullWidth: true,
        ),
      ],
    );
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.icon,
    required this.label,
    required this.sub,
    required this.color,
    required this.onTap,
    this.fullWidth = false,
  });

  final IconData icon;
  final String label;
  final String sub;
  final Color color;
  final VoidCallback onTap;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TinyBurnRadii.card),
        child: Ink(
          decoration: tinyBurnCardDecoration(color: Colors.white),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: TinyBurnColors.textPrimary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sub,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: TinyBurnColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.add_circle_outline, color: TinyBurnColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
