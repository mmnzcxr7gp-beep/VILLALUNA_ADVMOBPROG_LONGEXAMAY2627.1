import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/user.dart';
import '../widgets/custom_dialogs.dart';
import '../widgets/custom_font.dart';

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final String timeAgo;
  final IconData icon;
  final Color iconColor;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.icon,
    required this.iconColor,
    this.isRead = false,
  });
}

class NotificationScreen extends StatefulWidget {
  final User? currentUser;

  const NotificationScreen({super.key, this.currentUser});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late List<NotificationItem> _notifications;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _notifications = [
      NotificationItem(
        id: '1',
        title: 'SYNERTECH Admin',
        description: 'posted a new announcement: "Midterm Evaluation Schedule"',
        timeAgo: '10m ago',
        icon: Icons.campaign_rounded,
        iconColor: AppColors.nuGold,
        isRead: false,
      ),
      NotificationItem(
        id: '2',
        title: 'James Davis',
        description: 'liked your recent post in the SYNERTECH community feed.',
        timeAgo: '1h ago',
        icon: Icons.thumb_up,
        iconColor: AppColors.fbBlue,
        isRead: false,
      ),
      NotificationItem(
        id: '3',
        title: 'Olivia Wilson',
        description: 'commented: "Great implementation on the project!"',
        timeAgo: '3h ago',
        icon: Icons.chat_bubble,
        iconColor: AppColors.success,
        isRead: false,
      ),
      NotificationItem(
        id: '4',
        title: 'Alexander Jones',
        description: 'started following your SYNERTECH developer profile.',
        timeAgo: '5h ago',
        icon: Icons.person_add_rounded,
        iconColor: AppColors.nuBlue,
        isRead: true,
      ),
      NotificationItem(
        id: '5',
        title: 'Ethan Martinez',
        description: 'shared your post to the main discussion board.',
        timeAgo: '1d ago',
        icon: Icons.share_rounded,
        iconColor: AppColors.nuGold,
        isRead: true,
      ),
    ];
  }

  void _markAllAsRead() {
    setState(() {
      for (var n in _notifications) {
        n.isRead = true;
      }
    });
    CustomDialogs.showSnackBar(
      context,
      message: 'All notifications marked as read.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final filteredList = _selectedFilter == 'All'
        ? _notifications
        : _notifications.where((n) => !n.isRead).toList();

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.scaffoldDark : AppColors.scaffoldLight,
      body: Column(
        children: [
          // Filter Chips & Mark Read Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: isDark ? AppColors.cardDark : Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildFilterChip('All', isDark),
                    const SizedBox(width: 8),
                    _buildFilterChip('Unread', isDark),
                  ],
                ),
                TextButton(
                  onPressed: _markAllAsRead,
                  child: const CustomFont.frutiger(
                    text: 'Mark all as read',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.nuBlue,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // Notifications List
          Expanded(
            child: filteredList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 48,
                          color: isDark ? Colors.white24 : Colors.black26,
                        ),
                        const SizedBox(height: 10),
                        CustomFont.klavika(
                          text: 'No notifications',
                          fontSize: 16,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: filteredList.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      thickness: 0.8,
                      color: isDark
                          ? AppColors.darkDivider
                          : const Color(0xFFE4E6EB),
                    ),
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      return InkWell(
                        onTap: () {
                          setState(() {
                            item.isRead = true;
                          });
                          CustomDialogs.showSnackBar(
                            context,
                            message: 'Notification from ${item.title}',
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          color: item.isRead
                              ? (isDark
                                  ? AppColors.cardDark
                                  : Colors.white)
                              : (isDark
                                  ? const Color(0xFF2C384A)
                                  : const Color(0xFFE7F3FF)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor:
                                        item.iconColor.withValues(alpha: 0.15),
                                    child: Icon(
                                      item.icon,
                                      color: item.iconColor,
                                      size: 22,
                                    ),
                                  ),
                                  if (!item.isRead)
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: const BoxDecoration(
                                          color: AppColors.fbBlue,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          fontFamily: AppFonts.frutiger,
                                          fontSize: 13.5,
                                          height: 1.3,
                                          color: isDark
                                              ? AppColors.textPrimaryDark
                                              : AppColors.textPrimary,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: '${item.title} ',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(text: item.description),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    CustomFont.frutiger(
                                      text: item.timeAgo,
                                      fontSize: 11,
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isDark) {
    final isSelected = _selectedFilter == label;
    return ChoiceChip(
      label: CustomFont.frutiger(
        text: label,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected
            ? Colors.white
            : (isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary),
      ),
      selected: isSelected,
      selectedColor: AppColors.nuBlue,
      backgroundColor:
          isDark ? const Color(0xFF3A3B3C) : const Color(0xFFF0F2F5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      onSelected: (bool selected) {
        if (selected) {
          setState(() {
            _selectedFilter = label;
          });
        }
      },
    );
  }
}
