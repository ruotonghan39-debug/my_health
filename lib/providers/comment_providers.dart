import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/feed_comment.dart';
import 'repositories.dart';

final postCommentsProvider =
    FutureProvider.autoDispose.family<List<FeedComment>, String>((ref, postId) async {
  final repo = ref.watch(commentsRepositoryProvider);
  if (repo == null) {
    return const <FeedComment>[];
  }
  return repo.fetchForPost(postId);
});
