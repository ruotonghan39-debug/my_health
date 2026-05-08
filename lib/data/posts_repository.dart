import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/env.dart';
import '../domain/feed_post.dart';
import '../domain/post_types.dart';

class PostsRepository {
  PostsRepository(this._client);

  final SupabaseClient _client;

  bool get _ok => SupabaseEnv.isConfigured;

  Future<List<FeedPost>> fetchPosts({int limit = 50}) async {
    if (!_ok) return const [];

    final rows = await _client
        .from('posts')
        .select()
        .order('created_at', ascending: false)
        .limit(limit);

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

    return list.map((row) => _mapPost(row, profMap[row['user_id'] as String])).toList();
  }

  FeedPost _mapPost(Map<String, dynamic> row, Map<String, dynamic>? profile) {
    final imagesRaw = row['images'];
    final urls = <String>[];
    if (imagesRaw is List) {
      for (final x in imagesRaw) {
        if (x is String) urls.add(x);
      }
    }
    final meta = Map<String, dynamic>.from(row['meta'] as Map? ?? {});
    final type = PostType.fromDb(row['type'] as String);
    double? delta;
    if (type == PostType.weight) {
      final d = meta['delta'];
      if (d is num) delta = d.toDouble();
    }

    return FeedPost(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      userName: (profile?['nickname'] as String?)?.trim().isNotEmpty == true
          ? profile!['nickname'] as String
          : '用户',
      avatarUrl: profile?['avatar'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
      type: type,
      content: row['content'] as String? ?? '',
      calories: row['calories'] as int?,
      imageUrls: urls,
      weightDelta: delta,
      meta: meta,
    );
  }

  Future<FeedPost?> fetchPostById(String id) async {
    if (!_ok) return null;

    final row = await _client.from('posts').select().eq('id', id).maybeSingle();
    if (row == null) return null;
    final m = Map<String, dynamic>.from(row);
    final uid = m['user_id'] as String;
    final prof = await _client.from('profiles').select().eq('id', uid).maybeSingle();
    return _mapPost(m, prof == null ? null : Map<String, dynamic>.from(prof));
  }

  Future<void> createPost({
    required PostType type,
    required String content,
    List<String> imageUrls = const [],
    int? calories,
    Map<String, dynamic> meta = const {},
  }) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw StateError('Not signed in');

    await _client.from('posts').insert({
      'user_id': uid,
      'type': type.dbValue,
      'content': content,
      'images': imageUrls,
      'calories': calories,
      'meta': meta,
    });
  }
}
