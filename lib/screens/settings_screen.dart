import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/user.dart';
import '../providers/theme_provider.dart';
import '../services/user_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_dialogs.dart';
import '../widgets/custom_font.dart';
import 'signin_screen.dart';

class SettingsScreen extends StatefulWidget {
  final User? currentUser;

  const SettingsScreen({super.key, this.currentUser});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final UserService _userService = UserService();
  bool _pushNotifications = true;
  bool _dataSaver = false;

  Future<void> _handleSignOut() async {
    final confirmed = await CustomDialogs.showConfirmationDialog(
      context: context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out from your SYNERTECH account?',
      confirmText: 'Sign Out',
      confirmColor: AppColors.error,
      icon: Icons.logout,
    );

    if (confirmed == true) {
      await _userService.clearSession();
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SignInScreen()),
        (route) => false,
      );
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
      appBar: AppBar(
        title: const CustomFont.klavika(
          text: 'Settings & Preferences',
          fontSize: 19,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Header Box
            if (user != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
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
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.nuBlue,
                      backgroundImage: (user.image.isNotEmpty)
                          ? NetworkImage(user.image)
                          : null,
                      child: (user.image.isEmpty)
                          ? const Icon(Icons.person,
                              size: 32, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomFont.klavika(
                            text: user.fullName,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),
                          const SizedBox(height: 2),
                          CustomFont.frutiger(
                            text: user.email.isNotEmpty
                                ? user.email
                                : '@${user.username}',
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.nuBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const CustomFont.frutiger(
                              text: 'SYNERTECH Member',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.nuBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Section: Appearance & Theme
            _buildSectionHeader('Appearance & Theme', isDark),
            Material(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: SwitchListTile(
                value: isDark,
                onChanged: (val) => themeProvider.toggleTheme(),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.nuGold : AppColors.nuBlue)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode_outlined,
                    color: isDark ? AppColors.nuGold : AppColors.nuBlue,
                    size: 20,
                  ),
                ),
                title: CustomFont.frutiger(
                  text: 'Dark Mode',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color:
                      isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
                subtitle: CustomFont.frutiger(
                  text: isDark ? 'Dark theme active' : 'Light theme active',
                  fontSize: 11,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
                activeThumbColor: AppColors.nuGold,
              ),
            ),

            const SizedBox(height: 16),

            // Section: Preferences
            _buildSectionHeader('Preferences', isDark),
            Material(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  SwitchListTile(
                    value: _pushNotifications,
                    onChanged: (val) {
                      setState(() {
                        _pushNotifications = val;
                      });
                      CustomDialogs.showSnackBar(
                        context,
                        message: val
                            ? 'Push notifications enabled'
                            : 'Push notifications disabled',
                      );
                    },
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.fbBlue.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.notifications_active_outlined,
                        color: AppColors.fbBlue,
                        size: 20,
                      ),
                    ),
                    title: CustomFont.frutiger(
                      text: 'Push Notifications',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                    subtitle: const CustomFont.frutiger(
                      text: 'Receive updates on likes and replies',
                      fontSize: 11,
                    ),
                    activeThumbColor: AppColors.nuBlue,
                  ),
                  Divider(
                    height: 1,
                    color: isDark
                        ? AppColors.darkDivider
                        : const Color(0xFFE4E6EB),
                  ),
                  SwitchListTile(
                    value: _dataSaver,
                    onChanged: (val) {
                      setState(() {
                        _dataSaver = val;
                      });
                    },
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.data_saver_on_outlined,
                        color: AppColors.success,
                        size: 20,
                      ),
                    ),
                    title: CustomFont.frutiger(
                      text: 'Data Saver',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                    subtitle: const CustomFont.frutiger(
                      text: 'Compress media to reduce data usage',
                      fontSize: 11,
                    ),
                    activeThumbColor: AppColors.nuBlue,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Section: About
            _buildSectionHeader('System & About', isDark),
            Material(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListTile(
                    leading:
                        const Icon(Icons.api_outlined, color: AppColors.nuBlue),
                    title: const CustomFont.frutiger(
                      text: 'Backend API Endpoint',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                    subtitle: CustomFont.frutiger(
                      text: host,
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: isDark
                        ? AppColors.darkDivider
                        : const Color(0xFFE4E6EB),
                  ),
                  const ListTile(
                    leading:
                        Icon(Icons.info_outline, color: AppColors.nuGold),
                    title: CustomFont.frutiger(
                      text: 'App Version',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                    subtitle: CustomFont.frutiger(
                      text: 'v1.0.0 • SYNERTECH Villaluna',
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sign Out Button (Enhancement 2)
            CustomButton(
              text: 'Sign Out',
              icon: Icons.logout,
              backgroundColor: AppColors.error,
              onPressed: _handleSignOut,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: CustomFont.klavika(
        text: title,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
      ),
    );
  }
}
