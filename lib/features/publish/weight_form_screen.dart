import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/shell_insets.dart';
import '../../core/env.dart';
import '../../domain/post_types.dart';
import '../../providers/feed_providers.dart';
import '../../providers/repositories.dart';
import '../../shared/mock/mock_data.dart';
import '../../theme/app_theme.dart';

class WeightFormScreen extends ConsumerStatefulWidget {
  const WeightFormScreen({super.key});

  @override
  ConsumerState<WeightFormScreen> createState() => _WeightFormScreenState();
}

class _WeightFormScreenState extends ConsumerState<WeightFormScreen> {
  late final TextEditingController _controller;

  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: kTodayStats.weightKg.toStringAsFixed(1),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final w = double.tryParse(_controller.text.trim());
    if (w == null || w <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效体重')),
      );
      return;
    }

    final posts = ref.read(postsRepositoryProvider);
    final weights = ref.read(weightRepositoryProvider);

    if (!SupabaseEnv.isConfigured || posts == null || weights == null) {
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
      final prev = await weights.fetchLatestWeightKg();
      await weights.insertWeight(w);
      final delta = prev != null ? w - prev : null;
      final msg = delta != null
          ? '体重 ${w.toStringAsFixed(1)} kg（较上次 ${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(1)} kg）'
          : '体重 ${w.toStringAsFixed(1)} kg';

      final meta = <String, dynamic>{'weight': w};
      if (delta != null) meta['delta'] = delta;

      await posts.createPost(
        type: PostType.weight,
        content: msg,
        meta: meta,
      );

      ref.invalidate(feedPostsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已记录')),
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
    final yesterday = kTodayStats.weightKg - kTodayStats.deltaFromYesterday;
    final bottomPad = mainShellBottomContentPadding(context);

    return Scaffold(
      backgroundColor: TinyBurnColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('记录体重'),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '本地示例昨日参考：${yesterday.toStringAsFixed(1)} kg',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: TinyBurnColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: '今日体重 (kg)',
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: tinyBurnCardDecoration(),
              child: Text(
                SupabaseEnv.isConfigured
                    ? '连接 Supabase 后将写入 weight_records，并发布一条体重动态。'
                    : '未连接后端时为演示模式。',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: TinyBurnColors.textSecondary,
                    ),
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: _busy ? null : _save,
              child: _busy
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}
