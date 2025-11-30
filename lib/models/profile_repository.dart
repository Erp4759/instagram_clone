import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'dart:math';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileRepository extends ChangeNotifier {
  ProfileRepository._();
  static final ProfileRepository instance = ProfileRepository._()
    .._loadFromPrefs();

  String name = 'John Doe';
  String username = 'john_doe';
  String pronouns = '';
  String bio = 'potato - is me';
  String avatarUrl = 'https://picsum.photos/seed/me/200/200';
  Uint8List? avatarBytes;
  String gender = 'Prefer not to say';
  String music = '';
  // Simple follower/following lists for UI demo (reduced for testing)
  final List<String> followers = ['junehxuk', 'cch991112'];
  final List<String> following = ['haetbaaan', 'cau_ai_', 'imwinter'];
  // Per-other-user follower/following maps so we can simulate other accounts
  // (username -> list of followers / following). Populated with demo data
  // for groups like aespa.
  final Map<String, List<String>> otherFollowers = {};
  final Map<String, List<String>> otherFollowing = {};
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

  // Get followers for arbitrary username (current user uses `followers`)
  List<String> getFollowersFor(String username) {
    if (username == this.username) return List.unmodifiable(followers);
    _ensureSeededForUser(username);
    return List.unmodifiable(otherFollowers[username] ?? []);
  }

  // Get following for arbitrary username (current user uses `following`)
  List<String> getFollowingFor(String username) {
    if (username == this.username) return List.unmodifiable(following);
    _ensureSeededForUser(username);
    return List.unmodifiable(otherFollowing[username] ?? []);
  }

  // Ensure we have synthetic follower/following lists for the given user.
  // This populates `otherFollowers` and `otherFollowing` deterministically
  // on first access so most accounts appear to follow / be followed by some
  // demo users.
  void _ensureSeededForUser(String username) {
    if (otherFollowers.containsKey(username) &&
        otherFollowing.containsKey(username)) return;

    // Small pool of demo accounts to choose from; include seeded aespa members
    // and some generated names so lists look varied.
    final demoPool = <String>{
      'aespa_official',
      'katarinabluu',
      'imwinter',
      'imnotningning',
      'aerichandesu',
      'blue_fox123',
      'tiny_pixel456',
      'curious_comet789',
      'lucky_poppy101'
    };

    // Avoid self-references
    demoPool.remove(username);

    final rnd =
        Random(username.hashCode ^ DateTime.now().millisecondsSinceEpoch);
    final wantFollowing = 3 + rnd.nextInt(4); // 3..6
    final wantFollowers = 2 + rnd.nextInt(4); // 2..5

    final followingList = <String>[];
    final poolList = demoPool.toList();
    while (followingList.length < wantFollowing && poolList.isNotEmpty) {
      final pick = poolList[rnd.nextInt(poolList.length)];
      if (pick == username || followingList.contains(pick)) continue;
      followingList.add(pick);
    }

    final followersList = <String>[];
    while (followersList.length < wantFollowers && poolList.isNotEmpty) {
      final pick = poolList[rnd.nextInt(poolList.length)];
      if (pick == username ||
          followersList.contains(pick) ||
          followingList.contains(pick)) continue;
      followersList.add(pick);
    }

    otherFollowing[username] = followingList;
    otherFollowers[username] = followersList;

    // Make reciprocal relationships for any demo accounts we referenced
    for (final target in followingList) {
      final tFollowers = otherFollowers[target] ?? <String>[];
      if (!tFollowers.contains(username)) {
        tFollowers.add(username);
        otherFollowers[target] = tFollowers;
      }
    }
    for (final target in followersList) {
      final tFollowing = otherFollowing[target] ?? <String>[];
      if (!tFollowing.contains(username)) {
        tFollowing.add(username);
        otherFollowing[target] = tFollowing;
      }
    }

    notifyListeners();
  }

  // Set up demo group relationships for a set of members and an official account.
  void seedGroupFollowers(List<String> members, String official) {
    // Ensure current user follows all members
    for (final m in members) {
      if (!following.contains(m)) following.add(m);
    }

    // Each member follows each other and the official account
    for (final a in members) {
      final followersList = <String>[];
      for (final b in members) {
        if (b != a && !followersList.contains(b)) followersList.add(b);
      }
      // members also follow the official
      if (!followersList.contains(official)) followersList.add(official);
      otherFollowers[a] = followersList;

      // Their following list includes other members and the official
      final followingList = <String>[];
      for (final b in members) {
        if (b != a && !followingList.contains(b)) followingList.add(b);
      }
      if (!followingList.contains(official)) followingList.add(official);
      otherFollowing[a] = followingList;
    }

    // Official account follows the members (optional)
    otherFollowing[official] = List.from(members);
    otherFollowers[official] = List.from(members);
    notifyListeners();
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
    // Seed demo group (aespa) relationships if not already present.
    if (otherFollowers.isEmpty && otherFollowing.isEmpty) {
      seedGroupFollowers(
          ['aerichandesu', 'imnotningning', 'katarinabluu', 'imwinter'],
          'aespa_official');
    }
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
