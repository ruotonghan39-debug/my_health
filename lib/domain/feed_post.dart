import 'post_types.dart';

/// Unified feed card model (Supabase + optional mock).
class FeedPost {
  const FeedPost({
    required this.id,
    required this.userId,
    required this.userName,
    required this.createdAt,
    required this.type,
    required this.content,
    this.avatarUrl,
    this.calories,
    this.tags = const [],
    this.imageUrls = const [],
    this.weightDelta,
    this.meta = const {},
  });

  final String id;
  final String userId;
  final String userName;
  final DateTime createdAt;
  final PostType type;
  final String content;
  final String? avatarUrl;
  final int? calories;
  final List<String> tags;
  final List<String> imageUrls;
  final double? weightDelta;
  final Map<String, dynamic> meta;
}
