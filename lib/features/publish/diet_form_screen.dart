import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/shell_insets.dart';
import '../../core/env.dart';
import '../../domain/post_types.dart';
import '../../providers/feed_providers.dart';
import '../../providers/repositories.dart';
import '../../theme/app_theme.dart';

class DietFormScreen extends ConsumerStatefulWidget {
  const DietFormScreen({super.key});

  @override
  ConsumerState<DietFormScreen> createState() => _DietFormScreenState();
}

class _DietFormScreenState extends ConsumerState<DietFormScreen> {
  final _nameController = TextEditingController(text: '燕麦碗');
  final _kcalController = TextEditingController(text: '380');

  static const _tags = ['燕麦', '牛奶', '蓝莓', '香蕉', '鸡蛋'];

  final Set<String> _selected = {'燕麦', '蓝莓'};
  XFile? _picked;
  bool _busy = false;

  @override
  void dispose() {
    _nameController.dispose();
    _kcalController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (file != null) setState(() => _picked = file);
  }

  Future<void> _save() async {
    final posts = ref.read(postsRepositoryProvider);
    final storage = ref.read(storageServiceProvider);

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
      final urls = <String>[];
      if (_picked != null && storage != null) {
        urls.add(await storage.uploadPostImage(_picked!));
      }

      await posts.createPost(
        type: PostType.diet,
        content: _nameController.text.trim(),
        imageUrls: urls,
        calories: int.tryParse(_kcalController.text.trim()),
        meta: {'tags': _selected.toList()},
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
        title: const Text('添加饮食'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(TinyBurnRadii.card),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _picked == null
                        ? Container(
                            color: TinyBurnColors.primary.withValues(alpha: 0.25),
                            child: const Icon(Icons.restaurant_menu_rounded, size: 72),
                          )
                        : _pickedImage(),
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: FilledButton.tonal(
                        onPressed: _busy ? null : _pickImage,
                        child: const Text('更换照片'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '食物名称',
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '选择食材（示例）',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tags.map((t) {
                final on = _selected.contains(t);
                return FilterChip(
                  label: Text(t),
                  selected: on,
                  onSelected: (v) {
                    setState(() {
                      if (v) {
                        _selected.add(t);
                      } else {
                        _selected.remove(t);
                      }
                    });
                  },
                  selectedColor: TinyBurnColors.primary.withValues(alpha: 0.4),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _kcalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '热量 (kcal)',
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('记录时间'),
              subtitle: Text(
                TimeOfDay.now().format(context),
              ),
              trailing: const Icon(Icons.schedule_rounded),
            ),
            const SizedBox(height: 24),
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

  Widget _pickedImage() {
    if (kIsWeb) {
      return FutureBuilder<Uint8List>(
        future: _picked!.readAsBytes(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return Container(color: TinyBurnColors.primary.withValues(alpha: 0.2));
          }
          return Image.memory(
            snap.data!,
            fit: BoxFit.cover,
          );
        },
      );
    }
    return Image.file(
      File(_picked!.path),
      fit: BoxFit.cover,
    );
  }
}
