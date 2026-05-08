class FeedComment {
  const FeedComment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
    this.avatarUrl,
  });

  final String id;
  final String userId;
  final String userName;
  final String content;
  final DateTime createdAt;
  final String? avatarUrl;
}
