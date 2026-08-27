import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Host API configuration
String get host => dotenv.env['HOST'] ?? 'https://dummyjson.com';

// SharedPreferences Keys
class AppPreferences {
  static const String keyUser = 'user_session';
  static const String keyToken = 'auth_token';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyIsDarkMode = 'is_dark_mode';
}

// Typography / Font Family Names
class AppFonts {
  static const String klavika = 'Klavika';
  static const String frutiger = 'Frutiger';
}

// Brand Colors
class AppColors {
  // NU Brand Palette
  static const Color nuBlue = Color(0xFF354898);
  static const Color nuDarkBlue = Color(0xFF17233C);
  static const Color nuGold = Color(0xFFFFB800);
  static const Color nuGoldLight = Color(0xFFFFF3D6);

  // Facebook & Social UI Palette
  static const Color fbBlue = Color(0xFF1877F2);
  static const Color fbBlueLight = Color(0xFFE7F3FF);
  static const Color likedBlue = Color(0xFF1877F2);
  static const Color likePink = Color(0xFFE41E3F);

  // Backgrounds & Surfaces
  static const Color scaffoldLight = Color(0xFFF0F2F5);
  static const Color cardLight = Colors.white;
  static const Color scaffoldDark = Color(0xFF18191A);
  static const Color cardDark = Color(0xFF242526);
  static const Color darkDivider = Color(0xFF3A3B3C);

  // Text Colors
  static const Color textPrimary = Color(0xFF050505);
  static const Color textSecondary = Color(0xFF65676B);
  static const Color textPrimaryDark = Color(0xFFE4E6EB);
  static const Color textSecondaryDark = Color(0xFFB0B3B8);

  // Utilities
  static const Color borderLight = Color(0xFFCED0D4);
  static const Color success = Color(0xFF42B72A);
  static const Color error = Color(0xFFFA383E);
}

// 2027 Filipino Celebrities & Content Creators Data
class CreatorInfo {
  final int id;
  final String name;
  final String handle;
  final String role;
  final String avatarUrl;

  const CreatorInfo({
    required this.id,
    required this.name,
    required this.handle,
    required this.role,
    required this.avatarUrl,
  });
}

class FilipinoCreators {
  static const List<CreatorInfo> list = [
    CreatorInfo(
      id: 1,
      name: 'Cong TV',
      handle: '@congtv',
      role: 'Team Payaman Founder • Creator',
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&auto=format&fit=crop&q=80',
    ),
    CreatorInfo(
      id: 2,
      name: 'Ivana Alawi',
      handle: '@ivanaalawi',
      role: 'Content Creator • Actress',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&auto=format&fit=crop&q=80',
    ),
    CreatorInfo(
      id: 3,
      name: 'Niana Guerrero',
      handle: '@nianaguerrero',
      role: 'Global TikTok Dance Icon',
      avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150&auto=format&fit=crop&q=80',
    ),
    CreatorInfo(
      id: 4,
      name: 'Donny Pangilinan',
      handle: '@donnypangilinan',
      role: 'Actor • Gen Z Heartthrob',
      avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&auto=format&fit=crop&q=80',
    ),
    CreatorInfo(
      id: 5,
      name: 'Belle Mariano',
      handle: '@bellemariano',
      role: 'Actress • Pop Sensation',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80',
    ),
    CreatorInfo(
      id: 6,
      name: 'Vice Ganda',
      handle: '@vicegandako',
      role: 'Unkabogable Host • Phenomenal Star',
      avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&auto=format&fit=crop&q=80',
    ),
    CreatorInfo(
      id: 7,
      name: 'Mimiyuuuh',
      handle: '@mimiyuuuh',
      role: 'Vlogger • Fashion Trendsetter',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80',
    ),
    CreatorInfo(
      id: 8,
      name: 'BINI Maloi',
      handle: '@bini_maloi',
      role: "Nation's Girl Group Visual & Main Vocal",
      avatarUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=150&auto=format&fit=crop&q=80',
    ),
    CreatorInfo(
      id: 9,
      name: 'Andrea Brillantes',
      handle: '@blythe',
      role: 'Actress • Digital Powerhouse',
      avatarUrl: 'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=150&auto=format&fit=crop&q=80',
    ),
    CreatorInfo(
      id: 10,
      name: 'Esnyr Ranollo',
      handle: '@esnyrr',
      role: 'Classroom POV King • Creator',
      avatarUrl: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150&auto=format&fit=crop&q=80',
    ),
    CreatorInfo(
      id: 11,
      name: 'Viy Cortez',
      handle: '@viycortez',
      role: 'Beauty Entrepreneur • VIYLine CEO',
      avatarUrl: 'https://images.unsplash.com/photo-1548142813-c348350df52b?w=150&auto=format&fit=crop&q=80',
    ),
    CreatorInfo(
      id: 12,
      name: 'Joshua Garcia',
      handle: '@garciajoshuae',
      role: 'Leading Man • TikTok Star',
      avatarUrl: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=150&auto=format&fit=crop&q=80',
    ),
    CreatorInfo(
      id: 13,
      name: 'Kathryn Bernardo',
      handle: '@bernardokath',
      role: 'Box Office Queen • Super Star',
      avatarUrl: 'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=150&auto=format&fit=crop&q=80',
    ),
    CreatorInfo(
      id: 14,
      name: 'BINI Mikha',
      handle: '@bini_mikha',
      role: "Nation's Girl Group Main Rapper",
      avatarUrl: 'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=150&auto=format&fit=crop&q=80',
    ),
    CreatorInfo(
      id: 15,
      name: 'SB19 Stell',
      handle: '@stellvester_',
      role: 'Heavenly Voice • P-Pop King',
      avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150&auto=format&fit=crop&q=80',
    ),
  ];

  static CreatorInfo getCreator(int id) {
    if (id <= 0) return list.first;
    final index = (id - 1) % list.length;
    return list[index];
  }
}
