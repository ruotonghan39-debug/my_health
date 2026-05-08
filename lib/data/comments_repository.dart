import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/env.dart';
import '../domain/feed_comment.dart';

class CommentsRepository {
  CommentsRepository(this._client);

  final SupabaseClient _client;

  bool get _ok => SupabaseEnv.isConfigured;

  Future<List<FeedComment>> fetchForPost(String postId) async {
    if (!_ok) return const [];

    final rows = await _client
        .from('comments')
        .select()
        .eq('post_id', postId)
        .order('created_at', ascending: true);

    final list = (rows as List<dynamic>)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    if (list.isEmpty) return const [];

    final userIds = list.map((e) => e['user_id'] as String).toSet().toList();
    final profRows = await _client.from('profiles').select().inFilter('id', userIds);
    final profiles = (profRows as List<dynamic>)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    final profMap = {for (final p in profiles) p['id'] as String: p};

    return list
        .map(
          (row) => FeedComment(
            id: row['id'] as String,
            userId: row['user_id'] as String,
            userName: profMap[row['user_id']]?['nickname'] as String? ?? '用户',
            avatarUrl: profMap[row['user_id']]?['avatar'] as String?,
            content: row['content'] as String,
            createdAt: DateTime.parse(row['created_at'] as String),
          ),
        )
        .toList();
  }

  Future<void> addComment({required String postId, required String content}) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw StateError('Not signed in');

    await _client.from('comments').insert({
      'post_id': postId,
      'user_id': uid,
      'content': content.trim(),
    });
  }
}
