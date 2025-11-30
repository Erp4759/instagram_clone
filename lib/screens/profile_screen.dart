import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/platform_image.dart';
import 'create_post_screen.dart';
import 'edit_profile_screen.dart';
import 'profile_followers_tabs.dart';
import 'post_detail_screen.dart';
import '../models/profile_repository.dart';
import '../models/posts_repository.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = ProfileRepository.instance;
    return AnimatedBuilder(
      animation: profile,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            leading: IconButton(
                icon: const Icon(Icons.lock_outline), onPressed: () {}),
            title: Row(
              children: [
                Text(profile.username,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
            actions: [
              IconButton(
                  icon: const Icon(Icons.circle_outlined), onPressed: () {}),
              IconButton(
                  icon: const Icon(Icons.add_box_outlined),
                  onPressed: () => _showCreateMenu(context)),
              IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
            ],
          ),
          body: const ProfileContent(),
        );
      },
    );
  }
}

class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    final postsRepo = PostsRepository.instance;
    final profile = ProfileRepository.instance;
    final fallbackPosts = List.generate(
        9, (i) => 'https://picsum.photos/seed/profile_post${i + 1}/400/400');

    return AnimatedBuilder(
      animation: profile,
      builder: (context, _) {
        return ListView(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 44,
                            backgroundImage: profile.avatarImage,
                          ),
                          Positioned(
                            right: -2,
                            bottom: -2,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black12, blurRadius: 4)
                                ],
                              ),
                              child: const CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.black,
                                child: Icon(Icons.add,
                                    color: Colors.white, size: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Posts (not clickable for now)
                                const _StatColumn(count: '18', label: 'posts'),
                                // Followers - clickable
                                InkWell(
                                  onTap: () {
                                    final repo = ProfileRepository.instance;
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                ProfileFollowersTabs(
                                                    initialIndex: 0,
                                                    username: repo.username)));
                                  },
                                  child: _StatColumn(
                                      count:
                                          '${ProfileRepository.instance.followers.length}',
                                      label: 'followers'),
                                ),
                                // Following - clickable
                                InkWell(
                                  onTap: () {
                                    final repo = ProfileRepository.instance;
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                ProfileFollowersTabs(
                                                    initialIndex: 1,
                                                    username: repo.username)));
                                  },
                                  child: _StatColumn(
                                      count:
                                          '${ProfileRepository.instance.following.length}',
                                      label: 'following'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(profile.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            Text(profile.bio,
                                style: const TextStyle(height: 1.3)),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => const EditProfileScreen()));
                          },
                          child: const Text('Edit profile'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                          onPressed: () {}, child: const Text('Share profile')),
                      const SizedBox(width: 8),
                      OutlinedButton(
                          onPressed: () {},
                          child: const Icon(Icons.person_add_alt_1)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 96,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      itemCount: 5,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Column(
                            children: const [
                              SizedBox(
                                width: 64,
                                height: 64,
                                child: CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  child: Icon(Icons.add,
                                      size: 28, color: Colors.black),
                                ),
                              ),
                              SizedBox(height: 6),
                              Text('New', style: TextStyle(fontSize: 12)),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black26),
                              ),
                              child: ClipOval(
                                child: Image.network(
                                  'https://picsum.photos/seed/highlight$index/120/120',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text('Story', style: TextStyle(fontSize: 12)),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                          icon: const Icon(Icons.grid_on), onPressed: () {}),
                      IconButton(
                          icon: const Icon(Icons.play_circle_outline),
                          onPressed: () {}),
                      IconButton(
                          icon: const Icon(Icons.replay), onPressed: () {}),
                      IconButton(
                          icon: const Icon(Icons.person_pin_outlined),
                          onPressed: () {}),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 8),
              child: AnimatedBuilder(
                animation: postsRepo,
                builder: (context, _) {
                  // Only show posts authored by the current profile on the
                  // profile page. Fall back to `fallbackPosts` when none.
                  final allPosts = postsRepo.posts;
                  final rp = allPosts
                      .where((p) => p.author == profile.username)
                      .toList();
                  return GridView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 2,
                      childAspectRatio: 1,
                    ),
                    itemCount: rp.isNotEmpty ? rp.length : fallbackPosts.length,
                    itemBuilder: (context, index) {
                      if (rp.isNotEmpty && index < rp.length) {
                        final post = rp[index];
                        return InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PostDetailScreen(post: post),
                              ),
                            );
                          },
                          child: post.media.first.type == MediaType.image
                              ? PlatformImage(post.media.first.url,
                                  fit: BoxFit.cover)
                              : Container(
                                  color: Colors.black12,
                                  child: const Center(
                                    child: Icon(Icons.play_circle_fill,
                                        size: 48, color: Colors.black54),
                                  ),
                                ),
                        );
                      }
                      final url = fallbackPosts[index];
                      return InkWell(
                        onTap: () {
                          final p = postsRepo.getOrCreatePostForUrl(url,
                              author: ProfileRepository.instance.username);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PostDetailScreen(post: p),
                            ),
                          );
                        },
                        child: CachedNetworkImage(
                            imageUrl: url, fit: BoxFit.cover),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

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
                // TODO: open reel creation flow
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
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12)),
                child: const Text('New',
                    style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: share only to profile flow
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}

class _StatColumn extends StatelessWidget {
  final String count;
  final String label;
  const _StatColumn({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(count,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.black54)),
      ],
    );
  }
}
