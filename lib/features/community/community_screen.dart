import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/feed_providers.dart';
import '../../shared/widgets/feed_post_card.dart';
import '../../theme/app_theme.dart';

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(feedPostsProvider);

    return Scaffold(
      backgroundColor: TinyBurnColors.background,
      appBar: AppBar(
        title: const Text('社区'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
      body: postsAsync.when(
        data: (posts) {
          if (posts.isEmpty) {
            return const Center(child: Text('还没有动态，去发布一条吧～'));
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            itemCount: posts.length,
            separatorBuilder: (context, _) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              return FeedPostCard(post: posts[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败：$e')),
      ),
    );
  }
}
