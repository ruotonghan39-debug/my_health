import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/feed_post.dart';
import '../../domain/post_types.dart';
import '../../theme/app_theme.dart';
import 'app_card.dart';

class FeedPostCard extends StatefulWidget {
  const FeedPostCard({
    super.key,
    required this.post,
    this.compact = false,
    this.initialLikeCount,
  });

  final FeedPost post;
  final bool compact;
  final int? initialLikeCount;

  @override
  State<FeedPostCard> createState() => _FeedPostCardState();
}

String _initial(String name) =>
    name.isEmpty ? '?' : String.fromCharCode(name.runes.first);

class _FeedPostCardState extends State<FeedPostCard> {
  static const Map<String, int> _defaultLikes = {
    '1': 14,
    '2': 9,
    '3': 21,
    '4': 6,
  };

  late int _likes;
  bool _liked = false;

  @override
  void initState() {
    super.initState();
    _likes = widget.initialLikeCount ?? _defaultLikes[widget.post.id] ?? 3;
  }

  void _toggleLike() {
    setState(() {
      if (_liked) {
        _liked = false;
        _likes -= 1;
      } else {
        _liked = true;
        _likes += 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final typeLabel = switch (widget.post.type) {
      PostType.diet => '饮食',
      PostType.exercise => '运动',
      PostType.weight => '体重',
    };

    final typeColor = switch (widget.post.type) {
      PostType.diet => TinyBurnColors.accentYellow.withValues(alpha: 0.35),
      PostType.exercise => TinyBurnColors.accentBlue.withValues(alpha: 0.25),
      PostType.weight => TinyBurnColors.primary.withValues(alpha: 0.4),
    };

    return AppCard(
      padding: EdgeInsets.all(widget.compact ? 14 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: widget.compact ? 18 : 20,
                backgroundColor: TinyBurnColors.primary.withValues(alpha: 0.4),
                backgroundImage: widget.post.avatarUrl != null &&
                        widget.post.avatarUrl!.startsWith('http')
                    ? NetworkImage(widget.post.avatarUrl!)
                    : null,
                child: widget.post.avatarUrl != null &&
                        widget.post.avatarUrl!.startsWith('http')
                    ? null
                    : Text(
                        _initial(widget.post.userName),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: TinyBurnColors.textPrimary,
                        ),
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post.userName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      _formatTime(widget.post.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: TinyBurnColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: typeColor,
                  borderRadius: BorderRadius.circular(TinyBurnRadii.chip),
                ),
                child: Text(
                  typeLabel,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.post.content,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (widget.post.calories != null) ...[
            const SizedBox(height: 6),
            Text(
              '${widget.post.calories} kcal',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: TinyBurnColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
          if (widget.post.weightDelta != null) ...[
            const SizedBox(height: 6),
            Text(
              '变化 ${widget.post.weightDelta! > 0 ? '+' : ''}${widget.post.weightDelta} kg',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: TinyBurnColors.primary,
                  ),
            ),
          ],
          if (widget.post.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                height: widget.compact ? 72 : 88,
                child: Row(
                  children: [
                    for (final url in widget.post.imageUrls.take(3))
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Image.network(
                            url,
                            fit: BoxFit.cover,
                            height: widget.compact ? 72 : 88,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: TinyBurnColors.primary.withValues(alpha: 0.2),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
          if (widget.post.tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: widget.post.tags
                  .map(
                    (t) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: TinyBurnColors.background,
                        borderRadius: BorderRadius.circular(TinyBurnRadii.chip),
                      ),
                      child: Text(
                        t,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              _ActionChip(
                icon: Icon(
                  _liked ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                  color: _liked ? Colors.redAccent : TinyBurnColors.textSecondary,
                ),
                label: '$_likes',
                onTap: _toggleLike,
              ),
              const SizedBox(width: 16),
              _ActionChip(
                icon: const Icon(Icons.chat_bubble_outline, size: 18),
                label: '评论',
                onTap: () => context.push('/post/${widget.post.id}'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 60) return '${diff.inMinutes} 分钟前';
    if (diff.inHours < 24) return '${diff.inHours} 小时前';
    return '${t.month}/${t.day}';
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Widget icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: TinyBurnColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
