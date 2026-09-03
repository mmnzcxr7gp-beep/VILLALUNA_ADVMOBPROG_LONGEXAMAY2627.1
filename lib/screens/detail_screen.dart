import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/comment.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../services/comment_service.dart';
import '../services/user_service.dart';
import '../widgets/custom_dialogs.dart';
import '../widgets/custom_font.dart';
import '../widgets/custom_inkwell_button.dart';

class DetailScreen extends StatefulWidget {
  final Post post;
  final User? currentUser;

  const DetailScreen({
    super.key,
    required this.post,
    this.currentUser,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final CommentService _commentService = CommentService();
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Comment> _comments = [];
  bool _isLoadingComments = true;
  bool _isSubmittingComment = false;
  String? _errorMessage;

  late bool _isPostLiked;
  late int _postLikes;

  @override
  void initState() {
    super.initState();
    _isPostLiked = widget.post.isLiked;
    _postLikes = widget.post.likes;
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() {
      _isLoadingComments = true;
      _errorMessage = null;
    });

    try {
      final comments =
          await _commentService.getCommentsByPostId(widget.post.id);
      if (mounted) {
        setState(() {
          _comments = comments;
          _isLoadingComments = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoadingComments = false;
        });
      }
    }
  }

  void _togglePostLike() {
    setState(() {
      _isPostLiked = !_isPostLiked;
      if (_isPostLiked) {
        _postLikes += 1;
      } else {
        _postLikes = (_postLikes > 0) ? _postLikes - 1 : 0;
      }
      widget.post.isLiked = _isPostLiked;
      widget.post.likes = _postLikes;
    });
  }

  void _toggleCommentLike(Comment comment) {
    setState(() {
      comment.isLiked = !comment.isLiked;
      if (comment.isLiked) {
        comment.likes += 1;
      } else {
        comment.likes = (comment.likes > 0) ? comment.likes - 1 : 0;
      }
    });
  }

  Future<void> _handleAddComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isSubmittingComment = true;
    });

    try {
      final currentUserId = widget.currentUser?.id ?? 1;
      final currentUsername = widget.currentUser?.username ?? 'me';
      final currentFullName = widget.currentUser?.fullName ?? 'You';

      Comment newComment;
      try {
        newComment = await _commentService.addComment(
          body: text,
          postId: widget.post.id,
          userId: currentUserId,
        );
      } catch (_) {
        // Local fallback in case DummyJSON POST is blocked
        newComment = Comment(
          id: DateTime.now().millisecondsSinceEpoch,
          body: text,
          postId: widget.post.id,
          likes: 0,
          user: CommentUser(
            id: currentUserId,
            username: currentUsername,
            fullName: currentFullName,
          ),
        );
      }

      if (!mounted) return;

      _commentController.clear();
      FocusScope.of(context).unfocus();

      setState(() {
        _comments.add(newComment);
        _isSubmittingComment = false;
      });

      CustomDialogs.showSnackBar(
        context,
        message: 'Comment posted successfully!',
      );

      // Scroll to the bottom to see new comment
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmittingComment = false;
        });
        CustomDialogs.showSnackBar(
          context,
          message: 'Failed to add comment',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.scaffoldDark : AppColors.scaffoldLight,
      appBar: AppBar(
        title: const CustomFont.klavika(
          text: 'Post Details',
          fontSize: 19,
        ),
      ),
      body: Column(
        children: [
          // Main Scrollable Content (Post + Comments)
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadComments,
              color: AppColors.nuBlue,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Post Card Box
                    Container(
                      color: isDark ? AppColors.cardDark : Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Author Row
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: CachedNetworkImage(
                                  imageUrl:
                                      'https://i.pravatar.cc/150?u=${widget.post.userId}',
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                  errorWidget: (c, u, e) => Container(
                                    width: 44,
                                    height: 44,
                                    color: AppColors.nuBlue
                                        .withValues(alpha: 0.2),
                                    child: const Icon(Icons.person,
                                        color: AppColors.nuBlue),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    CustomFont.klavika(
                                      text: (widget.currentUser != null &&
                                              widget.post.userId ==
                                                  widget.currentUser!.id)
                                          ? widget.currentUser!.fullName
                                          : UserService.getUserNameById(
                                              widget.post.userId),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimary,
                                    ),
                                    CustomFont.frutiger(
                                      text:
                                          'Post #${widget.post.id} • SYNERTECH',
                                      fontSize: 12,
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Post Title
                          if (widget.post.title.isNotEmpty) ...[
                            CustomFont.klavika(
                              text: widget.post.title,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                            ),
                            const SizedBox(height: 8),
                          ],

                          // Post Body
                          CustomFont.frutiger(
                            text: widget.post.body,
                            fontSize: 15,
                            height: 1.5,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),

                          // Tags
                          if (widget.post.tags.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: widget.post.tags.map((tag) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
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
                                    color: isDark
                                        ? AppColors.nuGold
                                        : AppColors.fbBlue,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],

                          const SizedBox(height: 14),

                          // Reactions & Metrics Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: AppColors.fbBlue,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.thumb_up,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  CustomFont.frutiger(
                                    text: '$_postLikes Likes',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary,
                                  ),
                                ],
                              ),
                              CustomFont.frutiger(
                                text: '${_comments.length} Comments',
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                              ),
                            ],
                          ),

                          const Divider(height: 20),

                          // Action Buttons Bar (Like & Share)
                          Row(
                            children: [
                              Expanded(
                                child: CustomInkwellButton(
                                  onTap: _togglePostLike,
                                  icon: _isPostLiked
                                      ? Icons.thumb_up
                                      : Icons.thumb_up_outlined,
                                  label: 'Like',
                                  iconColor: _isPostLiked
                                      ? AppColors.fbBlue
                                      : (isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary),
                                  textColor: _isPostLiked
                                      ? AppColors.fbBlue
                                      : (isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary),
                                ),
                              ),
                              Expanded(
                                child: CustomInkwellButton(
                                  onTap: () {
                                    CustomDialogs.showSnackBar(
                                      context,
                                      message:
                                          'Shared post #${widget.post.id}!',
                                    );
                                  },
                                  icon: Icons.share_outlined,
                                  label: 'Share',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Comments Header Section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Row(
                        children: [
                          CustomFont.klavika(
                            text: 'Comments',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.nuBlue.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: CustomFont.frutiger(
                              text: '${_comments.length}',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.nuBlue,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Comments List
                    if (_isLoadingComments)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_errorMessage != null)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              const CustomFont.frutiger(
                                text: 'Failed to load comments',
                                color: AppColors.error,
                              ),
                              TextButton(
                                onPressed: _loadComments,
                                child: const Text('Try Again'),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (_comments.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 40,
                                color: isDark
                                    ? Colors.white24
                                    : Colors.black26,
                              ),
                              const SizedBox(height: 8),
                              CustomFont.frutiger(
                                text:
                                    'No comments yet. Be the first to comment!',
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _comments.length,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        itemBuilder: (context, index) {
                          final comment = _comments[index];
                          return _buildCommentItem(comment, isDark);
                        },
                      ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Input Bar (Add comment field + Send button)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? AppColors.darkDivider
                      : const Color(0xFFE4E6EB),
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.nuBlue,
                    backgroundImage: (widget.currentUser?.image != null &&
                            widget.currentUser!.image.isNotEmpty)
                        ? NetworkImage(widget.currentUser!.image)
                        : null,
                    child: (widget.currentUser?.image == null ||
                            widget.currentUser!.image.isEmpty)
                        ? const Icon(Icons.person,
                            color: Colors.white, size: 20)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF3A3B3C)
                            : const Color(0xFFF0F2F5),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _commentController,
                        maxLines: null,
                        style: TextStyle(
                          fontFamily: AppFonts.frutiger,
                          fontSize: 14,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Write a comment...',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 10),
                          isDense: true,
                        ),
                        onSubmitted: (_) => _handleAddComment(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  _isSubmittingComment
                      ? const SizedBox(
                          width: 36,
                          height: 36,
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.send_rounded,
                              color: AppColors.nuBlue),
                          onPressed: _handleAddComment,
                          tooltip: 'Post Comment',
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Comment comment, bool isDark) {
    final displayName = comment.user.fullName.isNotEmpty
        ? comment.user.fullName
        : '@${comment.user.username}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.nuBlue.withValues(alpha: 0.2),
            child: Text(
              displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: AppColors.nuBlue,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF3A3B3C)
                        : const Color(0xFFF0F2F5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomFont.klavika(
                        text: displayName,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                      const SizedBox(height: 2),
                      CustomFont.frutiger(
                        text: comment.body,
                        fontSize: 13,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => _toggleCommentLike(comment),
                        child: CustomFont.frutiger(
                          text: 'Like',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: comment.isLiked
                              ? AppColors.fbBlue
                              : (isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary),
                        ),
                      ),
                      if (comment.likes > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: AppColors.fbBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.thumb_up,
                            size: 9,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        CustomFont.frutiger(
                          text: '${comment.likes}',
                          fontSize: 11,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ],
                    ],
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
