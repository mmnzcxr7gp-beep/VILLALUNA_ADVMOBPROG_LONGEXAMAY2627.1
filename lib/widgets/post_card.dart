import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../screens/detail_screen.dart';
import '../services/user_service.dart';
import 'custom_dialogs.dart';
import 'custom_font.dart';
import 'custom_inkwell_button.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final User? currentUser;
  final VoidCallback? onPostUpdated;

  const PostCard({
    super.key,
    required this.post,
    this.currentUser,
    this.onPostUpdated,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool _isLiked;
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked;
    _likeCount = widget.post.likes;
  }

  @override
  void didUpdateWidget(covariant PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.likes != widget.post.likes ||
        oldWidget.post.isLiked != widget.post.isLiked) {
      _isLiked = widget.post.isLiked;
      _likeCount = widget.post.likes;
    }
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _likeCount += 1;
      } else {
        _likeCount = (_likeCount > 0) ? _likeCount - 1 : 0;
      }
      widget.post.isLiked = _isLiked;
      widget.post.likes = _likeCount;
    });

    if (widget.onPostUpdated != null) {
      widget.onPostUpdated!();
    }
  }

  void _openDetails() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailScreen(
          post: widget.post,
          currentUser: widget.currentUser,
        ),
      ),
    ).then((_) {
      if (mounted) {
        setState(() {
          _isLiked = widget.post.isLiked;
          _likeCount = widget.post.likes;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final authorName = (widget.currentUser != null &&
            widget.post.userId == widget.currentUser!.id)
        ? widget.currentUser!.fullName
        : UserService.getUserNameById(widget.post.userId);
    final userAvatarUrl = 'https://i.pravatar.cc/150?u=${widget.post.userId}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar, Author, Timestamp, More button
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    imageUrl: userAvatarUrl,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 40,
                      height: 40,
                      color: AppColors.nuBlue.withValues(alpha: 0.2),
                      child: const Center(
                        child: Icon(Icons.person, color: AppColors.nuBlue, size: 22),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 40,
                      height: 40,
                      color: AppColors.nuBlue.withValues(alpha: 0.2),
                      child: const Center(
                        child: Icon(Icons.person, color: AppColors.nuBlue, size: 22),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomFont.klavika(
                        text: authorName,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                      Row(
                        children: [
                          CustomFont.frutiger(
                            text: 'Post #${widget.post.id} • SYNERTECH',
                            fontSize: 11,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.public,
                            size: 11,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.more_horiz,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () {
                    CustomDialogs.showSnackBar(
                      context,
                      message: 'Post options for #${widget.post.id}',
                    );
                  },
                ),
              ],
            ),
          ),

          // Post Title (if exists)
          if (widget.post.title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: GestureDetector(
                onTap: _openDetails,
                child: CustomFont.klavika(
                  text: widget.post.title,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
            ),

          // Post Body
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: GestureDetector(
              onTap: _openDetails,
              child: CustomFont.frutiger(
                text: widget.post.body,
                fontSize: 14,
                height: 1.4,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
          ),

          // Tags Chips
          if (widget.post.tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: widget.post.tags.map((tag) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF3A3B3C)
                          : const Color(0xFFE7F3FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomFont.frutiger(
                      text: '#$tag',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.nuGold : AppColors.fbBlue,
                    ),
                  );
                }).toList(),
              ),
            ),

          const SizedBox(height: 6),

          // Metrics Bar: Reactions count & Comments count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.fbBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.thumb_up,
                        size: 11,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    CustomFont.frutiger(
                      text: '$_likeCount',
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _openDetails,
                  child: CustomFont.frutiger(
                    text: 'View comments & details',
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          Divider(
            height: 1,
            thickness: 0.8,
            color: isDark ? AppColors.darkDivider : const Color(0xFFE4E6EB),
          ),

          // Action Buttons: Like, Comment, Share
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              children: [
                Expanded(
                  child: CustomInkwellButton(
                    onTap: _toggleLike,
                    icon: _isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                    label: 'Like',
                    iconColor: _isLiked
                        ? AppColors.fbBlue
                        : (isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary),
                    textColor: _isLiked
                        ? AppColors.fbBlue
                        : (isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary),
                  ),
                ),
                Expanded(
                  child: CustomInkwellButton(
                    onTap: _openDetails,
                    icon: Icons.chat_bubble_outline,
                    label: 'Comment',
                  ),
                ),
                Expanded(
                  child: CustomInkwellButton(
                    onTap: () {
                      CustomDialogs.showSnackBar(
                        context,
                        message: 'Post #${widget.post.id} shared to feed!',
                      );
                    },
                    icon: Icons.share_outlined,
                    label: 'Share',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
