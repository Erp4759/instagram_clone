import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'dart:math';
import 'profile_repository.dart';

class Comment {
  final String id;
  final String user;
  final String text;
  final DateTime createdAt;
  final String? parentId; // null for top-level comments
  int likesCount;
  bool likedByMe;

  Comment({
    required this.id,
    required this.user,
    required this.text,
    this.parentId,
    DateTime? createdAt,
    this.likesCount = 0,
    this.likedByMe = false,
  }) : createdAt = createdAt ?? DateTime.now();
}

enum MediaType { image, video }

class MediaItem {
  final String url;
  final MediaType type;

  MediaItem({required this.url, this.type = MediaType.image});
}

class Post {
  final String id;
  final List<MediaItem> media;
  final String author;
  final String? caption;
  final DateTime createdAt;
  int likesCount;
  bool likedByMe;
  final List<Comment> comments;

  Post({
    required this.id,
    required this.media,
    this.author = '',
    this.caption,
    DateTime? createdAt,
    this.likesCount = 0,
    this.likedByMe = false,
    List<Comment>? comments,
  })  : createdAt = createdAt ?? DateTime.now(),
        comments = comments ?? <Comment>[];
}

class PostsRepository extends ChangeNotifier {
  PostsRepository._() {
    _initSamples();
  }
  static final PostsRepository instance = PostsRepository._();

  void _initSamples() {
    // Multi-image post
    _posts.add(Post(
      id: 'sample-multi-1',
      media: [
        MediaItem(url: 'https://picsum.photos/seed/multi1_a/800/1000'),
        MediaItem(url: 'https://picsum.photos/seed/multi1_b/800/1000'),
        MediaItem(url: 'https://picsum.photos/seed/multi1_c/800/1000'),
      ],
      author: 'sample_user',
      caption: 'A multi-image post — swipe horizontally',
      likesCount: 42,
    ));

    // Video-only post (small sample clip)
    _posts.add(Post(
      id: 'sample-video-1',
      media: [
        MediaItem(
            url:
                'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
            type: MediaType.video),
      ],
      author: 'video_user',
      caption: 'Short video clip',
      likesCount: 128,
    ));

    // notify listeners so UI reflects initial samples
    notifyListeners();
  }

  final List<Post> _posts = [];

  List<Post> get posts => List.unmodifiable(_posts);

  void addPost(Post post) {
    _posts.insert(0, post);
    notifyListeners();
  }

  void toggleLike(String postId) {
    final idx = _posts.indexWhere((p) => p.id == postId);
    if (idx == -1) return;
    final post = _posts[idx];
    if (post.likedByMe) {
      post.likedByMe = false;
      if (post.likesCount > 0) post.likesCount -= 1;
    } else {
      post.likedByMe = true;
      post.likesCount += 1;
    }
    notifyListeners();
  }

  /// Add a comment to [postId]. If [parentId] is provided, this comment is a
  /// reply to another comment (nested). `user` is the author username.
  void addComment(String postId, String user, String text, {String? parentId}) {
    final idx = _posts.indexWhere((p) => p.id == postId);
    if (idx == -1) return;
    final post = _posts[idx];
    post.comments.add(Comment(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      user: user,
      text: text,
      parentId: parentId,
    ));
    notifyListeners();

    // If someone comments on another user's post, have the post owner
    // automatically send a small random reply to that comment (as a
    // reply-to). Do not trigger auto-replies for the owner's own comments.
    if (user != post.author) {
      final newCommentId = post.comments.last.id;
      // pick a random canned reply
      const canned = [
        'Oh yeah',
        'Haha, nice',
        'Thanks!',
        'Appreciate it',
        'Lol',
        '😀',
        'Totally!',
      ];
      final rnd = Random();
      final replyText = canned[rnd.nextInt(canned.length)];
      // random short delay to feel natural
      final delaySeconds = 1 + rnd.nextInt(3);
      Future.delayed(Duration(seconds: delaySeconds), () {
        // Ensure the post still exists (it should, but be defensive)
        final pidx = _posts.indexWhere((p) => p.id == postId);
        if (pidx == -1) return;
        // Add reply as the post author, parented to the original comment
        addComment(postId, post.author, replyText, parentId: newCommentId);
      });
    }
  }

  /// Add a reply to a comment (convenience wrapper).
  void addReply(
      String postId, String parentCommentId, String user, String text) {
    addComment(postId, user, text, parentId: parentCommentId);
  }

  /// Toggle like on a specific comment inside a post.
  void toggleCommentLike(String postId, String commentId) {
    final pIdx = _posts.indexWhere((p) => p.id == postId);
    if (pIdx == -1) return;
    final post = _posts[pIdx];
    final cIdx = post.comments.indexWhere((c) => c.id == commentId);
    if (cIdx == -1) return;
    final comment = post.comments[cIdx];
    if (comment.likedByMe) {
      comment.likedByMe = false;
      if (comment.likesCount > 0) comment.likesCount -= 1;
    } else {
      comment.likedByMe = true;
      comment.likesCount += 1;
    }
    notifyListeners();
  }

  /// Return an existing Post that contains a media item matching [url] or
  /// create one and append it to the repository. This allows sample/feed
  /// media to accept comments.
  Post getOrCreatePostForUrl(String url, {String? author}) {
    final idx = _posts.indexWhere((p) => p.media.any((m) => m.url == url));
    if (idx != -1) return _posts[idx];
    final itemType =
        url.toLowerCase().endsWith('.mp4') ? MediaType.video : MediaType.image;
    final post = Post(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      media: [MediaItem(url: url, type: itemType)],
      author: author ?? ProfileRepository.instance.username,
      caption: '',
      likesCount: 0,
      likedByMe: false,
    );
    _posts.add(post);
    notifyListeners();
    return post;
  }

  void clear() {
    _posts.clear();
    notifyListeners();
  }
}

final rnd = Random();
