import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../models/user.dart';

class UserService {
  final http.Client _client;

  UserService({http.Client? client}) : _client = client ?? http.Client();

  static List<User>? _cachedUsers;
  static final Map<int, String> _knownUserNames = {
    1: 'Emily Johnson',
    2: 'Michael Williams',
    3: 'Sophia Brown',
    4: 'James Davis',
    5: 'Emma Miller',
    6: 'Olivia Wilson',
    7: 'Alexander Jones',
    8: 'Ava Taylor',
    9: 'Ethan Martinez',
    10: 'Isabella Anderson',
  };

  static String getUserNameById(int id) {
    return _knownUserNames[id] ?? 'Student #$id';
  }

  /// Authenticates user against DummyJSON Auth API endpoint (`$host/auth/login`).
  Future<User> login({
    required String username,
    required String password,
  }) async {
    final trimmedUsername = username.trim();
    final trimmedPassword = password.trim();

    if (trimmedUsername.isEmpty || trimmedPassword.isEmpty) {
      throw const FormatException('Username and password cannot be empty.');
    }

    final Uri url = Uri.parse('$host/auth/login');

    try {
      final response = await _client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'username': trimmedUsername,
              'password': trimmedPassword,
              'expiresInMins': 60,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        User user = User.fromJson(data);

        // Populate CCIT institution details directly from login
        user = user.copyWith(
          role: user.role.isNotEmpty ? user.role : 'CCIT Student',
          department: user.department.isNotEmpty
              ? user.department
              : 'College of Computing and Information Technologies',
          university: user.university.isNotEmpty
              ? user.university
              : 'National University',
        );

        // Cache user info immediately
        if (user.id > 0 && user.fullName.isNotEmpty) {
          _knownUserNames[user.id] = user.fullName;
        }

        // Save session instantly
        await saveUserSession(user);
        return user;
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        try {
          final Map<String, dynamic> errorBody = jsonDecode(response.body);
          final String msg =
              errorBody['message']?.toString() ?? 'Invalid credentials.';
          throw Exception(
              msg.isNotEmpty ? msg : 'Invalid username or password.');
        } catch (e) {
          if (e is Exception && !e.toString().contains('FormatException')) {
            rethrow;
          }
          throw Exception('Invalid username or password.');
        }
      } else {
        throw Exception(
            'Server returned error status (${response.statusCode}). Please try again later.');
      }
    } on SocketException {
      throw Exception(
          'Unable to reach server. Please check your internet connection.');
    } on TimeoutException {
      throw Exception('Connection timed out. Please try again.');
    } on FormatException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected authentication error occurred.');
    }
  }

  /// Retrieves user profile details by ID from `$host/users/$id`.
  Future<User> getUserById(int id) async {
    final Uri url = Uri.parse('$host/users/$id');

    try {
      final response = await _client.get(
        url,
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        throw Exception(
            'Failed to load user profile (status ${response.statusCode}).');
      }
    } on SocketException {
      throw Exception(
          'Unable to reach server. Please check your network connection.');
    } on TimeoutException {
      throw Exception('Request timed out while loading user profile.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An error occurred while fetching the profile.');
    }
  }

  /// Retrieves list of users for avatars/stories with in-memory caching
  Future<List<User>> getUsers({int limit = 30, bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedUsers != null && _cachedUsers!.isNotEmpty) {
      return _cachedUsers!;
    }

    final Uri url = Uri.parse('$host/users?limit=$limit');
    try {
      final response = await _client.get(url).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List usersJson = data['users'] ?? [];
        final list = usersJson.map((u) => User.fromJson(u)).toList();
        _cachedUsers = list;
        for (final u in list) {
          if (u.id > 0 && u.fullName.isNotEmpty) {
            _knownUserNames[u.id] = u.fullName;
          }
        }
        return list;
      }
      return _cachedUsers ?? [];
    } catch (_) {
      return _cachedUsers ?? [];
    }
  }

  /// Saves user model and login state into SharedPreferences
  Future<bool> saveUserSession(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppPreferences.keyUser, jsonEncode(user.toJson()));
      await prefs.setString(AppPreferences.keyToken, user.token);
      await prefs.setBool(AppPreferences.keyIsLoggedIn, true);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Retrieves the saved user model from SharedPreferences
  Future<User?> getSavedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userJson = prefs.getString(AppPreferences.keyUser);
      final bool isLoggedIn =
          prefs.getBool(AppPreferences.keyIsLoggedIn) ?? false;

      if (!isLoggedIn || userJson == null || userJson.isEmpty) {
        return null;
      }

      final Map<String, dynamic> data = jsonDecode(userJson);
      return User.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  /// Clears user session from SharedPreferences on sign out
  Future<bool> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppPreferences.keyUser);
      await prefs.remove(AppPreferences.keyToken);
      await prefs.setBool(AppPreferences.keyIsLoggedIn, false);
      return true;
    } catch (_) {
      return false;
    }
  }
}
