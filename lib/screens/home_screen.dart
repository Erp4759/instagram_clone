import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math';
import 'messages_screen.dart';
import 'profile_screen.dart';
import '../models/profile_repository.dart';
import 'user_profile_screen.dart';
import 'create_post_screen.dart';
import '../models/posts_repository.dart';
import '../widgets/comments_sheet.dart';
import '../widgets/media_carousel.dart';

class HomePage extends StatefulWidget {
  // Global key used to control inline profile viewing from other screens.
  // Use a public State type to avoid exposing a private type in the public API.
  static final GlobalKey<HomePageState> homeKey = GlobalKey<HomePageState>();

  const HomePage({super.key});

  /// Request the `HomePage` to show a user's profile inline (keeps bottom
  /// navigation visible). Safe to call from other screens.
  // Returns true if the inline profile was shown, false otherwise.
  // This lets callers fall back to pushing a full-screen profile when
  // the `HomePage` isn't in a state to render inline content (for
  // example when another route is on top of it).
  static bool showInlineProfile(String username) {
    final s = homeKey.currentState;
    if (s != null) {
      s._showInlineProfile(username);
      return true;
    }
    return false;
  }

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String? _viewingUsername;

  void _showCreateMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Create',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.video_call_outlined),
                title: const Text('Reel'),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.grid_on),
                title: const Text('Post'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const CreatePostScreen()));
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.grid_on_outlined),
                title: const Text('Share only to profile'),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showInlineProfile(String username) {
    // Ensure the Home tab is selected so the inline profile is visible.
    setState(() {
      _selectedIndex = 0;
      _viewingUsername = username;
    });
  }

  // Generate a deterministic, realistic-ish username for a given index.
  // Uses the index as seed so the same index always yields the same name.
  String _usernameForIndex(int index) {
    final rnd = Random(index);
    const adjectives = [
      'blue',
      'tiny',
      'brave',
      'quiet',
      'golden',
      'wild',
      'lucky',
      'curious',
      'happy',
      'bold'
    ];
    const nouns = [
      'fox',
      'pixel',
      'river',
      'sketch',
      'ember',
      'orbit',
      'poppy',
      'harbor',
      'meadow',
      'comet'
    ];
    final adj = adjectives[rnd.nextInt(adjectives.length)];
    final noun = nouns[rnd.nextInt(nouns.length)];
    final num = 100 + rnd.nextInt(900);
    // Use braces to keep identifiers separate; the analyzer may flag this
    // as unnecessary, but without braces `$adj_$noun` is parsed as `adj_`.
    // ignore: unnecessary_brace_in_string_interps
    return '${adj}_${noun}$num';
  }
  // (removed unused _sampleGrid helper)

  // Build a single post widget; we'll generate several of these for the feed
  Widget _buildPost(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Post header (username + avatar)
          ListTile(
            onTap: () {
              // If the tapped user is the current user, switch to the
              // Profile tab (same behavior as tapping the profile icon).
              final tapped = _usernameForIndex(index);
              if (tapped == ProfileRepository.instance.username) {
                setState(() {
                  _selectedIndex = 4;
                  _viewingUsername = null;
                });
                return;
              }
              // Otherwise show the tapped user's profile inline.
              setState(() {
                _selectedIndex = 0;
                _viewingUsername = tapped;
              });
            },
            leading: CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(
                  'https://picsum.photos/seed/profile$index/200/200'),
            ),
            title: Text(_usernameForIndex(index),
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Location · Now'),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {},
            ),
          ),

          // Big media area (supports images & small videos, swipe horizontally for multiple media)
          AspectRatio(
            aspectRatio: 4 / 5,
            child: MediaCarousel(
              media: index % 3 == 1
                  ? [
                      // small sample video for demo purposes
                      MediaItem(
                          url:
                              'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
                          type: MediaType.video),
                    ]
                  : [
                      MediaItem(
                          url:
                              'https://picsum.photos/seed/post${index + 1}/800/1000',
                          type: MediaType.image),
                    ],
            ),
          ),

          // Action row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Use PostsRepository so generated posts support likes/comments
                    Builder(builder: (context) {
                      final postsRepo = PostsRepository.instance;
                      final mediaUrl =
                          'https://picsum.photos/seed/post${index + 1}/800/1000';
                      final post = postsRepo.getOrCreatePostForUrl(mediaUrl,
                          author: _usernameForIndex(index));
                      return IconButton(
                        icon: Icon(
                            post.likedByMe
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: post.likedByMe ? Colors.red : null),
                        onPressed: () => postsRepo.toggleLike(post.id),
                      );
                    }),
                    IconButton(
                      icon: const Icon(Icons.mode_comment_outlined),
                      onPressed: () {
                        final postsRepo = PostsRepository.instance;
                        final mediaUrl =
                            'https://picsum.photos/seed/post${index + 1}/800/1000';
                        final post = postsRepo.getOrCreatePostForUrl(mediaUrl,
                            author: _usernameForIndex(index));
                        showCommentsSheet(context, post);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.send_outlined),
                      onPressed: () {},
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_border),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Likes and caption
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Reflect actual like count for generated posts when available
                Builder(builder: (context) {
                  final postsRepo = PostsRepository.instance;
                  final mediaUrl =
                      'https://picsum.photos/seed/post${index + 1}/800/1000';
                  final post = postsRepo.getOrCreatePostForUrl(mediaUrl,
                      author: _usernameForIndex(index));
                  return Text('${post.likesCount} likes',
                      style: const TextStyle(fontWeight: FontWeight.w600));
                }),
                const SizedBox(height: 6),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                          text: '${_usernameForIndex(index)} ',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      const TextSpan(text: 'A quick caption for the post.'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostFromModel(Post p) {
    final postsRepo = PostsRepository.instance;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            onTap: () {
              // If this post is authored by the current user, navigate to the
              // Profile tab so the view matches tapping the profile icon.
              if (p.author == ProfileRepository.instance.username) {
                setState(() {
                  _selectedIndex = 4;
                  _viewingUsername = null;
                });
                return;
              }
              // Otherwise show the tapped user's profile inline.
              setState(() {
                _selectedIndex = 0;
                _viewingUsername = p.author;
              });
            },
            leading: CircleAvatar(
              radius: 20,
              backgroundImage: p.author == ProfileRepository.instance.username
                  ? ProfileRepository.instance.avatarImage
                  : NetworkImage(
                      'https://picsum.photos/seed/profile_${p.author}/200/200'),
            ),
            title: Text(p.author,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('${p.createdAt.toLocal()}'),
            trailing:
                IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
          ),
          AspectRatio(
            aspectRatio: 4 / 5,
            child: MediaCarousel(media: p.media),
          ),
          // Action row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                          p.likedByMe ? Icons.favorite : Icons.favorite_border,
                          color: p.likedByMe ? Colors.red : null),
                      onPressed: () => postsRepo.toggleLike(p.id),
                    ),
                    IconButton(
                      icon: const Icon(Icons.mode_comment_outlined),
                      onPressed: () => showCommentsSheet(context, p),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send_outlined),
                      onPressed: () {},
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_border),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          // Likes, caption, comments hint
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${p.likesCount} likes',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                if (p.caption != null && p.caption!.isNotEmpty)
                  Text.rich(
                    TextSpan(
                      children: const [
                        TextSpan(
                            text: 'you ',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                if (p.caption != null && p.caption!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(p.caption!),
                  ),
                if (p.comments.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => showCommentsSheet(context, p),
                    child: Text('View all ${p.comments.length} comments',
                        style: const TextStyle(color: Colors.black54)),
                  ),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If we're viewing another user's profile inline, render it inside the
    // same scaffold so the bottom navigation remains visible.
    if (_viewingUsername != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => setState(() => _viewingUsername = null)),
          title: Text(_viewingUsername!,
              style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
        body: UserProfileContent(username: _viewingUsername!),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) {
            if (i == 2) {
              // Middle add button -> open create menu instead of switching tab
              _showCreateMenu(context);
              return;
            }
            setState(() {
              _selectedIndex = i;
              _viewingUsername = null;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black54,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(
                icon: Icon(
                    _selectedIndex == 0 ? Icons.home : Icons.home_outlined),
                label: 'Home'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.search), label: 'Search'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.add_box_outlined), label: 'Add'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.ondemand_video_outlined), label: 'Reels'),
            BottomNavigationBarItem(
                icon: CircleAvatar(
                    radius: 12,
                    backgroundImage: ProfileRepository.instance.avatarImage),
                label: 'Profile'),
          ],
        ),
      );
    }
    final postsRepo = PostsRepository.instance;

    return Scaffold(
      appBar: _selectedIndex == 4
          ? AppBar(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
              leading: IconButton(
                  icon: const Icon(Icons.lock_outline), onPressed: () {}),
              title: AnimatedBuilder(
                animation: ProfileRepository.instance,
                builder: (context, _) {
                  final profile = ProfileRepository.instance;
                  return Row(
                    children: [
                      Text(profile.username,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  );
                },
              ),
              actions: [
                IconButton(
                    icon: const Icon(Icons.circle_outlined), onPressed: () {}),
                IconButton(
                    icon: const Icon(Icons.add_box_outlined),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (context) {
                          return SafeArea(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 8),
                                Container(
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.black12,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text('Create',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 12),
                                const Divider(height: 1),
                                ListTile(
                                  leading:
                                      const Icon(Icons.video_call_outlined),
                                  title: const Text('Reel'),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                const Divider(height: 1),
                                ListTile(
                                  leading: const Icon(Icons.grid_on),
                                  title: const Text('Post'),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const CreatePostScreen()));
                                  },
                                ),
                                const Divider(height: 1),
                                ListTile(
                                  leading: const Icon(Icons.grid_on_outlined),
                                  title: const Text('Share only to profile'),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          );
                        },
                      );
                    }),
                IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
              ],
            )
          : AppBar(
              title: const Text(
                'Instagram',
                style: TextStyle(
                  fontFamily: 'Billabong',
                  fontSize: 36,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              centerTitle: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.send_outlined),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const MessagesPage()));
                  },
                ),
              ],
            ),
      body: _selectedIndex == 4
          ? const ProfileContent()
          : AnimatedBuilder(
              animation: postsRepo,
              builder: (context, _) {
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemBuilder: (context, index) {
                    // index 0 -> stories row
                    if (index == 0) {
                      return SizedBox(
                        height: 110,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          scrollDirection: Axis.horizontal,
                          itemCount: 8,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, sIndex) {
                            return SizedBox(
                              height: 88,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 68,
                                    height: 68,
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [Colors.purple, Colors.orange],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            'https://picsum.photos/seed/story$sIndex/200/200',
                                        fit: BoxFit.cover,
                                        width: 64,
                                        height: 64,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  SizedBox(
                                    width: 70,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        _usernameForIndex(sIndex),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    }

                    // For index >= 1, compute which feed item this should be
                    final logical = index - 1; // position in feed after stories

                    // Helper to build suggested reels widget
                    Widget suggestedReels() {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: SizedBox(
                          height: 140,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            scrollDirection: Axis.horizontal,
                            itemCount: 6,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, rIndex) {
                              final thumb =
                                  'https://picsum.photos/seed/reel$rIndex/320/180';
                              return GestureDetector(
                                onTap: () {},
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Stack(
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl: thumb,
                                        width: 240,
                                        height: 140,
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned(
                                        left: 8,
                                        top: 8,
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                              color: Colors.black45,
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: const Icon(
                                            Icons.play_arrow,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }

                    // Walk the feed sequence to determine what to render at `logical`.
                    // We include user posts first, then infinite generated posts
                    // and insert the suggestedReels after the 3rd post.
                    int seenPosts = 0;
                    int cursor = 0;
                    bool reelsInserted = false;

                    while (true) {
                      // Insert reels after 3 posts
                      if (!reelsInserted && seenPosts == 3) {
                        if (cursor == logical) {
                          return suggestedReels();
                        }
                        cursor++;
                        reelsInserted = true;
                        continue;
                      }

                      if (seenPosts < postsRepo.posts.length) {
                        if (cursor == logical) {
                          return _buildPostFromModel(
                              postsRepo.posts[seenPosts]);
                        }
                        seenPosts++;
                        cursor++;
                        continue;
                      }

                      // generated posts (infinite)
                      final genIndex = seenPosts - postsRepo.posts.length;
                      if (cursor == logical) {
                        return _buildPost(genIndex);
                      }
                      seenPosts++;
                      cursor++;
                    }
                  },
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) {
          if (i == 2) {
            _showCreateMenu(context);
            return;
          }
          setState(() => _selectedIndex = i);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
              icon:
                  Icon(_selectedIndex == 0 ? Icons.home : Icons.home_outlined),
              label: 'Home'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.search), label: 'Search'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined), label: 'Add'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.ondemand_video_outlined), label: 'Reels'),
          BottomNavigationBarItem(
              icon: CircleAvatar(
                  radius: 12,
                  backgroundImage: ProfileRepository.instance.avatarImage),
              label: 'Profile'),
        ],
      ),
    );
  }
}
