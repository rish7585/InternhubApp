import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final Map<String, dynamic> profile;

  const PostCard({
    super.key,
    required this.post,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final createdAt = DateTime.parse(post['created_at']);
    final timeAgo = timeago.format(createdAt, allowFromNow: true);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Semantics(
      container: true,
      label: 'Post by ${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}',
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
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
                  Semantics(
                    label: 'Profile picture of ${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}',
                    image: true,
                    child: CircleAvatar(
                      radius: 24,
                      backgroundImage: profile['profile_picture_url'] != null
                          ? NetworkImage('${profile['profile_picture_url']}?v=${DateTime.now().millisecondsSinceEpoch}')
                          : null,
                      backgroundColor: isDark ? Colors.grey[800] : Colors.grey.shade200,
                      child: profile['profile_picture_url'] == null
                          ? Icon(Icons.person, size: 24, color: isDark ? Colors.white : Colors.grey.shade600)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}',
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
            if (post['content'] != null && post['content'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Semantics(
                  label: 'Post content',
                  child: Text(
                    post['content'],
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
            if (post['image_url'] != null && post['image_url'].toString().isNotEmpty) ...[
              const SizedBox(height: 16),
              Semantics(
                label: 'Post image',
                image: true,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    post['image_url'],
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
                  _buildActionButton(
                    context: context,
                    icon: Icons.favorite_border,
                    label: 'Like',
                    onPressed: () {},
                    tooltip: 'Like post',
                  ),
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