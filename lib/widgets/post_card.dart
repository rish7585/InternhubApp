import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  final Map<String, dynamic> profile;
  final int index;

  const PostCard({
    super.key,
    required this.post,
    required this.profile,
    required this.index,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _likeAnimationController;
  late Animation<double> _likeScaleAnimation;
  late Animation<Color?> _likeColorAnimation;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _likeScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _likeAnimationController,
      curve: Curves.elasticOut,
    ));
    _likeColorAnimation = ColorTween(
      begin: Colors.grey.shade600,
      end: Colors.red,
    ).animate(CurvedAnimation(
      parent: _likeAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    super.dispose();
  }

  void _handleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });
    
    if (_isLiked) {
      _likeAnimationController.forward().then((_) {
        _likeAnimationController.reverse();
      });
    } else {
      _likeAnimationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final createdAt = DateTime.parse(widget.post['created_at']);
    final timeAgo = timeago.format(createdAt, allowFromNow: true);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimationConfiguration.staggeredList(
      position: widget.index,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Semantics(
            container: true,
            label: 'Post by ${widget.profile['first_name'] ?? ''} ${widget.profile['last_name'] ?? ''}',
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Hero(
                          tag: 'profile_${widget.profile['id'] ?? widget.profile['user_id']}',
                          child: Semantics(
                            label: 'Profile picture of ${widget.profile['first_name'] ?? ''} ${widget.profile['last_name'] ?? ''}',
                            image: true,
                            child: CircleAvatar(
                              radius: 24,
                              backgroundImage: widget.profile['profile_picture_url'] != null
                                  ? NetworkImage('${widget.profile['profile_picture_url']}?v=${DateTime.now().millisecondsSinceEpoch}')
                                  : null,
                              backgroundColor: isDark ? Colors.grey[800] : Colors.grey.shade200,
                              child: widget.profile['profile_picture_url'] == null
                                  ? Icon(Icons.person, size: 24, color: isDark ? Colors.white : Colors.grey.shade600)
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.profile['first_name'] ?? ''} ${widget.profile['last_name'] ?? ''}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.grey.shade900,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              Text(
                                timeAgo,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? Colors.white54 : Colors.grey.shade500,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.more_horiz, color: isDark ? Colors.white54 : Colors.grey.shade500),
                          tooltip: 'More options',
                          onPressed: () {},
                          padding: const EdgeInsets.all(12),
                          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  if (widget.post['content'] != null && widget.post['content'].toString().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Semantics(
                        label: 'Post content',
                        child: Text(
                          widget.post['content'],
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.grey.shade800,
                            height: 1.5,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                  // Image
                  if (widget.post['image_url'] != null && widget.post['image_url'].toString().isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Semantics(
                      label: 'Post image',
                      image: true,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.post['image_url'],
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                              child: Icon(
                                Icons.image_not_supported,
                                size: 40,
                                color: isDark ? Colors.white24 : Colors.grey.shade400,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                  // Actions
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        _buildAnimatedLikeButton(context),
                        const SizedBox(width: 24),
                        _buildActionButton(
                          context: context,
                          icon: Icons.chat_bubble_outline,
                          label: 'Comment',
                          onPressed: () {},
                          tooltip: 'Comment on post',
                        ),
                        const SizedBox(width: 24),
                        _buildActionButton(
                          context: context,
                          icon: Icons.share_outlined,
                          label: 'Share',
                          onPressed: () {},
                          tooltip: 'Share post',
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.bookmark_border, color: isDark ? Colors.white54 : Colors.grey.shade500),
                          tooltip: 'Bookmark post',
                          onPressed: () {},
                          padding: const EdgeInsets.all(12),
                          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLikeButton(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _likeAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _likeScaleAnimation.value,
          child: Semantics(
            button: true,
            label: _isLiked ? 'Unlike post' : 'Like post',
            child: InkWell(
              onTap: _handleLike,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 24,
                      color: _likeColorAnimation.value ?? (isDark ? Colors.white70 : Colors.grey.shade600),
                      semanticLabel: _isLiked ? 'Liked' : 'Like',
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Like',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _likeColorAnimation.value ?? (isDark ? Colors.white70 : Colors.grey.shade600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                color: isDark ? Colors.white70 : Colors.grey.shade600,
                semanticLabel: label,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 