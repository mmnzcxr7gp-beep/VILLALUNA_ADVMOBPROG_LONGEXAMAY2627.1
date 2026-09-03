import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../services/post_service.dart';
import '../services/user_service.dart';
import '../widgets/custom_dialogs.dart';
import '../widgets/custom_font.dart';
import '../widgets/post_card.dart';

class NewsfeedScreen extends StatefulWidget {
  final User? currentUser;

  const NewsfeedScreen({super.key, this.currentUser});

  @override
  State<NewsfeedScreen> createState() => _NewsfeedScreenState();
}

class _NewsfeedScreenState extends State<NewsfeedScreen> {
  static const _pageSize = 30;
  static const _maxWallPosts = 100;

  final PostService _postService = PostService();
  final UserService _userService = UserService();
  final ScrollController _scrollController = ScrollController();

  List<Post> _posts = [];
  final List<Post> _localPosts = [];
  List<User> _suggestedUsers = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMorePosts = true;
  int _nextApiSkip = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _fetchFeedData();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients ||
        _isLoading ||
        _isLoadingMore ||
        !_hasMorePosts) {
      return;
    }

    if (_scrollController.position.extentAfter < 500) {
      _loadMorePosts();
    }
  }

  List<Post> _withoutDuplicates(Iterable<Post> posts) {
    final seenIds = <int>{};
    return posts.where((post) => seenIds.add(post.id)).toList();
  }

  Future<void> _fetchFeedData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _hasMorePosts = true;
    });

    try {
      final postsFuture = _postService.getPosts(
        limit: _pageSize,
        forceRefresh: true,
      );
      final usersFuture = _userService.getUsers(limit: 10);

      final results = await Future.wait([postsFuture, usersFuture]);
      final firstPage = results[0] as List<Post>;
      var userPosts = <Post>[];
      if (widget.currentUser != null) {
        try {
          userPosts = await _postService.getPostsByUserId(widget.currentUser!.id);
        } catch (_) {
          // The main feed remains available if the user-post request fails.
        }
      }

      final mergedPosts = _withoutDuplicates([
        ..._localPosts,
        ...userPosts,
        ...firstPage,
      ]);
      if (mounted) {
        setState(() {
          _posts = mergedPosts.take(_maxWallPosts).toList();
          _suggestedUsers = results[1] as List<User>;
          _isLoading = false;
            _nextApiSkip = firstPage.length;
          _hasMorePosts = _posts.length < _maxWallPosts &&
              firstPage.length == _pageSize;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingMore || !_hasMorePosts || _posts.length >= _maxWallPosts) {
      return;
    }

    setState(() => _isLoadingMore = true);
    try {
      final nextPage = await _postService.getPosts(
        limit: _pageSize,
        skip: _nextApiSkip,
      );
      if (!mounted) return;

      setState(() {
        _posts = _withoutDuplicates([
          ..._posts,
          ...nextPage,
        ]).take(_maxWallPosts).toList();
        _nextApiSkip += nextPage.length;
        _isLoadingMore = false;
        _hasMorePosts = _posts.length < _maxWallPosts &&
            nextPage.length == _pageSize;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  Future<void> _handleCreatePost() async {
    final result = await CustomDialogs.showCreatePostDialog(
      context: context,
      userName: widget.currentUser?.fullName ?? 'Student',
      userImage: widget.currentUser?.image,
    );

    if (result != null) {
      try {
        final newPost = await _postService.addPost(
          title: result['title'] ?? '',
          body: result['body'] ?? '',
          userId: widget.currentUser?.id ?? 1,
        );

        if (mounted) {
          setState(() {
            _localPosts.insert(0, newPost);
            _posts.insert(0, newPost);
            _posts = _withoutDuplicates(_posts).take(_maxWallPosts).toList();
          });
          CustomDialogs.showSnackBar(
            context,
            message: 'Post created successfully!',
          );
        }
      } catch (_) {
        // Local fallback in case dummyjson API post fails
        final fallbackPost = Post(
          id: DateTime.now().millisecondsSinceEpoch,
          postId: DateTime.now().millisecondsSinceEpoch,
          userId: widget.currentUser?.id ?? 1,
          title: result['title'] ?? '',
          body: result['body'] ?? '',
          likes: 0,
          dislikes: 0,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        );

        if (mounted) {
          setState(() {
            _localPosts.insert(0, fallbackPost);
            _posts.insert(0, fallbackPost);
            _posts = _withoutDuplicates(_posts).take(_maxWallPosts).toList();
          });
          CustomDialogs.showSnackBar(
            context,
            message: 'Post created successfully!',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: _fetchFeedData,
      color: AppColors.nuBlue,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Create Post Header Box
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.nuBlue,
                    backgroundImage: (widget.currentUser?.image != null &&
                            widget.currentUser!.image.isNotEmpty)
                        ? NetworkImage(widget.currentUser!.image)
                        : null,
                    child: (widget.currentUser?.image == null ||
                            widget.currentUser!.image.isEmpty)
                        ? const Icon(Icons.person, color: Colors.white, size: 22)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: _handleCreatePost,
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF3A3B3C)
                              : const Color(0xFFF0F2F5),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkDivider
                                : AppColors.borderLight,
                            width: 0.8,
                          ),
                        ),
                        child: CustomFont.frutiger(
                          text: "What's on your mind?",
                          fontSize: 13,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.photo_library,
                        color: AppColors.success, size: 22),
                    onPressed: _handleCreatePost,
                    tooltip: 'Add Photo',
                  ),
                ],
              ),
            ),
          ),

          // Community Members Stories Carousel
          if (_suggestedUsers.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          const Icon(Icons.amp_stories_rounded,
                              size: 18, color: AppColors.nuGold),
                          const SizedBox(width: 6),
                          CustomFont.klavika(
                            text: 'SYNERTECH Stories & Members',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    CarouselSlider.builder(
                      itemCount: _suggestedUsers.length,
                      options: CarouselOptions(
                        height: 120,
                        viewportFraction: 0.28,
                        enableInfiniteScroll: false,
                        padEnds: false,
                      ),
                      itemBuilder: (context, index, realIndex) {
                        final user = _suggestedUsers[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [
                                AppColors.nuBlue.withValues(alpha: 0.8),
                                AppColors.nuDarkBlue,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl: user.image,
                                    fit: BoxFit.cover,
                                    errorWidget: (c, u, e) => Container(
                                      color: AppColors.nuBlue,
                                      child: const Icon(Icons.person,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.8),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 6,
                                left: 6,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.nuGold,
                                      width: 2,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 12,
                                    backgroundImage: NetworkImage(user.image),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 6,
                                left: 6,
                                right: 6,
                                child: CustomFont.klavika(
                                  text: user.firstName,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

          // Loading Indicator
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          // Error Message
          else if (_errorMessage != null)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off_rounded,
                          size: 48, color: AppColors.error),
                      const SizedBox(height: 12),
                      const CustomFont.klavika(
                        text: 'Failed to load posts',
                        fontSize: 16,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _fetchFeedData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          // Feed Posts
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == _posts.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: _isLoadingMore
                            ? const CircularProgressIndicator()
                            : CustomFont.frutiger(
                                text: _hasMorePosts
                                    ? 'Loading more posts...'
                                    : 'You have reached the latest 100 posts.',
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                              ),
                      ),
                    );
                  }

                  final post = _posts[index];
                  return PostCard(
                    post: post,
                    currentUser: widget.currentUser,
                  );
                },
                childCount: _posts.length + 1,
              ),
            ),
        ],
      ),
    );
  }
}
