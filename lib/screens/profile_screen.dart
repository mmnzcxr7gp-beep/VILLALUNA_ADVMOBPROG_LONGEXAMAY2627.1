import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../providers/theme_provider.dart';
import '../services/post_service.dart';
import '../widgets/custom_dialogs.dart';
import '../widgets/custom_font.dart';
import '../widgets/custom_info.dart';
import '../widgets/post_card.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  final User? currentUser;

  const ProfileScreen({super.key, this.currentUser});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final PostService _postService = PostService();

  List<Post> _userPosts = [];
  bool _isLoadingPosts = true;
  String? _errorMessage;
  int _selectedTabIndex = 0;

  final List<String> _userPhotos = [
    'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=400&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?w=400&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1531403009284-440f080d1e12?w=400&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1523240795612-9a054b0db644?w=400&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=400&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=400&auto=format&fit=crop&q=80',
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserPosts();
  }

  Future<void> _fetchUserPosts() async {
    final userId = widget.currentUser?.id ?? 1;

    setState(() {
      _isLoadingPosts = true;
      _errorMessage = null;
    });

    try {
      final posts = await _postService.getPostsByUserId(userId);
      if (mounted) {
        setState(() {
          _userPosts = posts;
          _isLoadingPosts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoadingPosts = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;
    final user = widget.currentUser;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.scaffoldDark : AppColors.scaffoldLight,
      body: RefreshIndicator(
        onRefresh: _fetchUserPosts,
        color: AppColors.nuBlue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cover Photo & Avatar Header
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  // Cover Banner
                  Container(
                    height: 140,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.nuBlue,
                          AppColors.nuDarkBlue,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12, right: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/images/owl.jpg',
                                width: 16,
                                height: 16,
                                errorBuilder: (c, e, s) => const SizedBox(),
                              ),
                              const SizedBox(width: 4),
                              const CustomFont.klavika(
                                text: 'SYNERTECH',
                                fontSize: 11,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // User Avatar
                  Positioned(
                    bottom: -45,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 46,
                        backgroundColor: AppColors.nuBlue,
                        backgroundImage: (user?.image != null &&
                                user!.image.isNotEmpty)
                            ? CachedNetworkImageProvider(user.image)
                            : null,
                        child: (user?.image == null || user!.image.isEmpty)
                            ? const Icon(Icons.person,
                                size: 50, color: Colors.white)
                            : null,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 52),

              // Full Name & Username
              Center(
                child: Column(
                  children: [
                    CustomFont.klavika(
                      text: user?.fullName ?? 'Sam Irian Villaluna',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                    const SizedBox(height: 2),
                    CustomFont.frutiger(
                      text:
                          '@${user?.username ?? 'villaluna'} • ID #${user?.id ?? 1}',
                      fontSize: 13,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Profile Tabs: Posts | About | Photos
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(10),
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
                    _buildProfileTab('Posts', 0, isDark),
                    _buildProfileTab('About', 1, isDark),
                    _buildProfileTab('Photos', 2, isDark),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Tab Content Switcher
              if (_selectedTabIndex == 0)
                _buildPostsTab(isDark, user)
              else if (_selectedTabIndex == 1)
                _buildAboutTab(isDark, user)
              else
                _buildPhotosTab(isDark),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTab(String title, int index, bool isDark) {
    final isSelected = _selectedTabIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.nuGold : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Center(
            child: CustomFont.klavika(
              text: title,
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected
                  ? (isDark ? AppColors.nuGold : AppColors.nuBlue)
                  : (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }

  // TAB 1: Posts Tab
  Widget _buildPostsTab(bool isDark, User? user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CustomFont.klavika(
                    text: 'My Posts',
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.nuBlue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomFont.frutiger(
                      text: '${_userPosts.length}',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.nuBlue,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: _fetchUserPosts,
                icon: const Icon(Icons.refresh, size: 16),
                label: const CustomFont.frutiger(
                  text: 'Refresh',
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        if (_isLoadingPosts)
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
                    text: 'Unable to load user posts',
                    color: AppColors.error,
                  ),
                  TextButton(
                    onPressed: _fetchUserPosts,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          )
        else if (_userPosts.isEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.article_outlined,
                      size: 40,
                      color: isDark ? Colors.white24 : Colors.black26),
                  const SizedBox(height: 8),
                  CustomFont.frutiger(
                    text:
                        'No posts published yet by User #${user?.id ?? 1}',
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
            itemCount: _userPosts.length,
            itemBuilder: (context, index) {
              final post = _userPosts[index];
              return PostCard(
                post: post,
                currentUser: widget.currentUser,
              );
            },
          ),
      ],
    );
  }

  // TAB 2: About Tab
  Widget _buildAboutTab(bool isDark, User? user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Student Info Card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(12),
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
              CustomFont.klavika(
                text: 'Student Information',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color:
                    isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
              const Divider(height: 16),
              CustomInfoTile(
                icon: Icons.school_outlined,
                label: 'College & University',
                value:
                    '${user?.department ?? 'CCIT'} • ${user?.university ?? 'National University'}',
                iconColor: AppColors.nuBlue,
              ),
              CustomInfoTile(
                icon: Icons.email_outlined,
                label: 'Email Address',
                value: user?.email ?? 'samirianvillaluna@students.nu.edu.ph',
                iconColor: AppColors.nuGold,
              ),
              CustomInfoTile(
                icon: Icons.phone_outlined,
                label: 'Phone Number',
                value: user?.phone ?? '+63 912 345 6789',
                iconColor: AppColors.success,
              ),
              CustomInfoTile(
                icon: Icons.person_pin_outlined,
                label: 'Gender / Role',
                value:
                    '${user?.gender.isNotEmpty == true ? user!.gender.toUpperCase() : 'N/A'} • ${user?.role ?? 'Student'}',
                iconColor: AppColors.fbBlue,
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Settings Navigation Tile
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        SettingsScreen(currentUser: widget.currentUser),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.nuGold : AppColors.nuBlue)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.settings_outlined,
                        size: 22,
                        color: isDark ? AppColors.nuGold : AppColors.nuBlue,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomFont.klavika(
                            text: 'User Preferences & Settings',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),
                          const SizedBox(height: 2),
                          CustomFont.frutiger(
                            text: 'Dark mode, notifications, security & sign out',
                            fontSize: 11,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // TAB 3: Photos Tab
  Widget _buildPhotosTab(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomFont.klavika(
                text: 'Photo Gallery',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color:
                    isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
              CustomFont.frutiger(
                text: '${_userPhotos.length + 1} photos',
                fontSize: 12,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ],
          ),
          const Divider(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _userPhotos.length + 1,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              if (index == 0) {
                return GestureDetector(
                  onTap: () {
                    CustomDialogs.showSnackBar(
                      context,
                      message: 'Viewing Official Owl Mascot Photo',
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/owl.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        color: AppColors.nuBlue.withValues(alpha: 0.2),
                        child: const Icon(Icons.photo, color: AppColors.nuBlue),
                      ),
                    ),
                  ),
                );
              }

              final photoUrl = _userPhotos[index - 1];
              return GestureDetector(
                onTap: () {
                  CustomDialogs.showSnackBar(
                    context,
                    message: 'Viewing gallery photo #$index',
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: photoUrl,
                    fit: BoxFit.cover,
                    placeholder: (c, u) => Container(
                      color: AppColors.nuBlue.withValues(alpha: 0.1),
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (c, u, e) => Container(
                      color: AppColors.nuBlue.withValues(alpha: 0.2),
                      child: const Icon(Icons.broken_image,
                          color: AppColors.nuBlue),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
