import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/feed_post.dart';
import '../shared/mock/mock_data.dart';
import 'repositories.dart';

/// Global feed: Supabase when configured, else PRD mock data.
final feedPostsProvider = FutureProvider.autoDispose<List<FeedPost>>((ref) async {
  final repo = ref.watch(postsRepositoryProvider);
  if (repo == null) {
    return mockFeedPosts;
  }
  return repo.fetchPosts();
});

final feedPostByIdProvider =
    FutureProvider.autoDispose.family<FeedPost?, String>((ref, id) async {
  final repo = ref.watch(postsRepositoryProvider);
  if (repo == null) {
    try {
      return mockFeedPosts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
  return repo.fetchPostById(id);
});
