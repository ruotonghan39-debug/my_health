import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/shell_insets.dart';
import '../../core/env.dart';
import '../../domain/post_types.dart';
import '../../providers/feed_providers.dart';
import '../../providers/repositories.dart';
import '../../theme/app_theme.dart';

class ExerciseFormScreen extends ConsumerStatefulWidget {
  const ExerciseFormScreen({super.key});

  @override
  ConsumerState<ExerciseFormScreen> createState() => _ExerciseFormScreenState();
}

class _ExerciseFormScreenState extends ConsumerState<ExerciseFormScreen> {
  String _type = '跑步';
  final _durationController = TextEditingController(text: '32');
  final _kcalController = TextEditingController(text: '328');
  final _distanceController = TextEditingController(text: '5.02');

  static const _types = ['跑步', '健身', '骑行', '游泳', '散步'];

  int _moodIndex = 2;
  bool _busy = false;

  @override
  void dispose() {
    _durationController.dispose();
    _kcalController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final posts = ref.read(postsRepositoryProvider);

    if (!SupabaseEnv.isConfigured || posts == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('未配置 Supabase：演示保存')),
        );
        context.go('/publish');
      }
      return;
    }

    setState(() => _busy = true);
    try {
      final dur = int.tryParse(_durationController.text.trim());
      final dist = double.tryParse(_distanceController.text.trim());
      final meta = <String, dynamic>{
        'sport': _type,
        'mood': _moodIndex,
      };
      if (dur != null) meta['duration_min'] = dur;
      if (dist != null) meta['distance_km'] = dist;

      await posts.createPost(
        type: PostType.exercise,
        content: '$_type · ${dur ?? '-'} 分钟 · ${dist ?? '-'} km',
        calories: int.tryParse(_kcalController.text.trim()),
        meta: meta,
      );
      ref.invalidate(feedPostsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已发布')),
        );
        context.go('/publish');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败：$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = mainShellBottomContentPadding(context);

    return Scaffold(
      backgroundColor: TinyBurnColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('添加运动'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(TinyBurnRadii.card),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: TinyBurnColors.accentBlue.withValues(alpha: 0.2),
                      child: const Icon(Icons.directions_run_rounded, size: 72),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownMenu<String>(
              initialSelection: _type,
              label: const Text('运动类型'),
              dropdownMenuEntries: [
                for (final t in _types)
                  DropdownMenuEntry(value: t, label: t),
              ],
              onSelected: (v) => setState(() => _type = v ?? _type),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '时长 (分钟)',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _kcalController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '热量 (kcal)',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _distanceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: '距离 (km)',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              '心情',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (i) {
                final selected = _moodIndex == i;
                return GestureDetector(
                  onTap: () => setState(() => _moodIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: selected
                          ? TinyBurnColors.primary.withValues(alpha: 0.35)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      ['😆', '😊', '🙂', '😮‍💨', '😵'][i],
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _busy ? null : _save,
              child: _busy
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('保存记录'),
            ),
          ],
        ),
      ),
    );
  }
}
