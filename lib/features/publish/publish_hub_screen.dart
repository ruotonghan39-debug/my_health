import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';

class PublishHubScreen extends StatelessWidget {
  const PublishHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TinyBurnColors.background,
      appBar: AppBar(
        title: const Text('发布记录'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '选一个方式，15 秒内搞定 ✨',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 18),
            _PublishChoiceCard(
              icon: Icons.camera_alt_outlined,
              title: '饮食',
              subtitle: '拍照 + 填写热量',
              color: TinyBurnColors.accentYellow.withValues(alpha: 0.45),
              onTap: () => context.push('/publish/diet'),
            ),
            const SizedBox(height: 12),
            _PublishChoiceCard(
              icon: Icons.directions_run_rounded,
              title: '运动',
              subtitle: '类型 + 时长 + 热量',
              color: TinyBurnColors.accentBlue.withValues(alpha: 0.25),
              onTap: () => context.push('/publish/exercise'),
            ),
            const SizedBox(height: 12),
            _PublishChoiceCard(
              icon: Icons.monitor_weight_outlined,
              title: '体重',
              subtitle: '输入体重，自动对比昨日',
              color: TinyBurnColors.primary.withValues(alpha: 0.35),
              onTap: () => context.push('/publish/weight'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PublishChoiceCard extends StatelessWidget {
  const _PublishChoiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TinyBurnRadii.card),
        child: Ink(
          decoration: tinyBurnCardDecoration(),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: TinyBurnColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
