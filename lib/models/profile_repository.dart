import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileRepository extends ChangeNotifier {
  ProfileRepository._();
  static final ProfileRepository instance = ProfileRepository._()
    .._loadFromPrefs();

  String name = 'Eri paper';
  String username = 'erik_p';
  String pronouns = '';
  String bio = 'potato';
  String avatarUrl = 'https://picsum.photos/seed/me/200/200';
  Uint8List? avatarBytes;
  String gender = 'Prefer not to say';
  String music = '';
  // Simple follower/following lists for UI demo (reduced for testing)
  final List<String> followers = ['junehxuk', 'cch991112'];
  final List<String> following = ['haetbaaan', 'cau_ai_', 'imwinter'];
  // Optional subscriptions list used by the followers/following tabs
  final List<String> subscriptions = <String>[];

  // Simple follow helpers
  bool isFollowing(String user) => following.contains(user);

  void followUser(String user) {
    if (!following.contains(user)) {
      following.add(user);
      notifyListeners();
    }
  }

  void unfollowUser(String user) {
    if (following.remove(user)) {
      notifyListeners();
    }
  }

  void update({
    String? name,
    String? username,
    String? pronouns,
    String? bio,
    String? avatarUrl,
    Uint8List? avatarBytes,
    String? gender,
    String? music,
  }) {
    if (name != null) this.name = name;
    if (username != null) this.username = username;
    if (pronouns != null) this.pronouns = pronouns;
    if (bio != null) this.bio = bio;
    if (avatarUrl != null) this.avatarUrl = avatarUrl;
    if (avatarBytes != null) this.avatarBytes = avatarBytes;
    if (gender != null) this.gender = gender;
    if (music != null) this.music = music;
    notifyListeners();
    // Persist changes
    _saveToPrefs();
  }

  /// Returns an ImageProvider for the current avatar (memory image if set,
  /// otherwise network image using `avatarUrl`).
  ImageProvider get avatarImage {
    if (avatarBytes != null) return MemoryImage(avatarBytes!);
    return NetworkImage(avatarUrl);
  }

  // Persistent storage keys
  static const _kName = 'profile_name';
  static const _kUsername = 'profile_username';
  static const _kPronouns = 'profile_pronouns';
  static const _kBio = 'profile_bio';
  static const _kAvatarUrl = 'profile_avatar_url';
  static const _kAvatarBytes = 'profile_avatar_bytes';
  static const _kGender = 'profile_gender';
  static const _kMusic = 'profile_music';

  // Load saved profile data (call on startup)
  void _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    name = prefs.getString(_kName) ?? name;
    username = prefs.getString(_kUsername) ?? username;
    pronouns = prefs.getString(_kPronouns) ?? pronouns;
    bio = prefs.getString(_kBio) ?? bio;
    avatarUrl = prefs.getString(_kAvatarUrl) ?? avatarUrl;
    gender = prefs.getString(_kGender) ?? gender;
    music = prefs.getString(_kMusic) ?? music;
    final avatarBase64 = prefs.getString(_kAvatarBytes);
    if (avatarBase64 != null && avatarBase64.isNotEmpty) {
      try {
        avatarBytes = base64Decode(avatarBase64);
      } catch (_) {
        avatarBytes = null;
      }
    }
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kName, name);
    await prefs.setString(_kUsername, username);
    await prefs.setString(_kPronouns, pronouns);
    await prefs.setString(_kBio, bio);
    await prefs.setString(_kAvatarUrl, avatarUrl);
    await prefs.setString(_kGender, gender);
    await prefs.setString(_kMusic, music);
    if (avatarBytes != null) {
      try {
        await prefs.setString(_kAvatarBytes, base64Encode(avatarBytes!));
      } catch (_) {
        // ignore
      }
    } else {
      await prefs.remove(_kAvatarBytes);
    }
  }
}
