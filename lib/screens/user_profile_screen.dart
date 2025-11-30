import 'package:flutter/material.dart';
import '../models/profile_repository.dart';
import '../models/posts_repository.dart';
import 'post_detail_screen.dart';
import 'profile_followers_tabs.dart';

class _StatBlock extends StatelessWidget {
  final String count;
  final String label;
  const _StatBlock({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(count,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
      ],
    );
  }
}

class UserProfileScreen extends StatefulWidget {
  final String username;

  const UserProfileScreen({super.key, required this.username});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop()),
        title: Row(
          children: [
            Text(widget.username,
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(width: 6),
            const Icon(Icons.verified, color: Colors.blue, size: 18),
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {}, icon: const Icon(Icons.notifications_none)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: UserProfileContent(username: widget.username),
    );
  }
}

/// Embeddable profile content used by `UserProfileScreen` and by the
/// `HomePage` when rendering a profile inline (keeps the bottom navigation).
class UserProfileContent extends StatefulWidget {
  final String username;
  const UserProfileContent({super.key, required this.username});

  @override
  State<UserProfileContent> createState() => _UserProfileContentState();
}

class _UserProfileContentState extends State<UserProfileContent> {
  late final ProfileRepository _repo;
  late bool _isFollowing;
  bool _showSuggestions = false;

  String _displayName() {
    final base = widget.username.replaceAll(RegExp(r"\d+"), '');
    final withSpaces = base.replaceAll('_', ' ').trim();
    if (withSpaces.isEmpty) return widget.username;
    return withSpaces
        .split(' ')
        .map((w) => w.isEmpty
            ? w
            : (w[0].toUpperCase() + (w.length > 1 ? w.substring(1) : '')))
        .join(' ');
  }

  @override
  void initState() {
    super.initState();
    _repo = ProfileRepository.instance;
    _isFollowing = _repo.isFollowing(widget.username);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 92,
              height: 92,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                    colors: [Color(0xFFDE0046), Color(0xFFF7A34B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
              ),
              child: Container(
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.white),
                padding: const EdgeInsets.all(2),
                child: CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(
                        'https://picsum.photos/seed/${widget.username}/200/200')),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text(_displayName(),
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                  const SizedBox(height: 6),
                  Text(widget.username,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StatBlock(count: '117', label: 'posts'),
                      // Followers count (not tappable per request)
                      _StatBlock(
                          count:
                              '${_repo.getFollowersFor(widget.username).length}',
                          label: 'followers'),
                      // Following count (tappable: opens following list for this user)
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => ProfileFollowersTabs(
                                  initialIndex: 1, username: widget.username)));
                        },
                        child: _StatBlock(
                            count:
                                '${_repo.getFollowingFor(widget.username).length}',
                            label: 'following'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _isFollowing
                          ? SizedBox(
                              height: 36,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _isFollowing = false;
                                    _showSuggestions = false;
                                  });
                                  _repo.unfollowUser(widget.username);
                                },
                                icon: const Icon(Icons.arrow_drop_down),
                                label: const Text('Following'),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF0EBFB),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            )
                          : SizedBox(
                              height: 36,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _isFollowing = true;
                                    _showSuggestions = true;
                                  });
                                  _repo.followUser(widget.username);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 12.0),
                                  child: Text('Follow',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 36,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFF0EBFB),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text('Message',
                                style: TextStyle(color: Colors.black)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 36,
                        width: 36,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8)),
                        child: IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.more_horiz)),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                          radius: 12,
                          backgroundImage: NetworkImage(
                              'https://picsum.photos/seed/imwinter/80/80')),
                      const SizedBox(width: 6),
                      CircleAvatar(
                          radius: 12,
                          backgroundImage: NetworkImage(
                              'https://picsum.photos/seed/katarinabluu/80/80')),
                      const SizedBox(width: 6),
                      CircleAvatar(
                          radius: 12,
                          backgroundImage: NetworkImage(
                              'https://picsum.photos/seed/aespa_official/80/80')),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(
                              'Followed by imwinter, katarinabluu and aespa_official',
                              style: TextStyle(color: Colors.grey.shade700))),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
        if (_showSuggestions) ...[
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          const Text('Suggested for you',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _suggestedUsers.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final u = _suggestedUsers[index];
                final already = _repo.isFollowing(u);
                return _SuggestionCard(
                  username: u,
                  alreadyFollowing: already,
                  onFollow: () {
                    setState(() {});
                    _repo.followUser(u);
                  },
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 8),
        // Tabs row (grid, reels, tagged)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            Icon(Icons.grid_on, size: 22),
            Icon(Icons.play_circle_outline, size: 22),
            Icon(Icons.repeat, size: 22),
            Icon(Icons.perm_camera_mic, size: 22),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              childAspectRatio: 1),
          itemCount: 9,
          itemBuilder: (context, index) {
            final url =
                'https://picsum.photos/seed/${widget.username}_p$index/400/400';
            return InkWell(
              onTap: () {
                final p = PostsRepository.instance
                    .getOrCreatePostForUrl(url, author: widget.username);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PostDetailScreen(post: p),
                  ),
                );
              },
              child: Image.network(url, fit: BoxFit.cover),
            );
          },
        )
      ],
    );
  }
}

const List<String> _suggestedUsers = [
  'aespa_official',
  'katarinabluu',
  'karin_miyamoto',
  'ayaka_watanabe',
];

class _SuggestionCard extends StatelessWidget {
  final String username;
  final bool alreadyFollowing;
  final VoidCallback onFollow;

  const _SuggestionCard({
    required this.username,
    required this.alreadyFollowing,
    required this.onFollow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
              radius: 28,
              backgroundImage:
                  NetworkImage('https://picsum.photos/seed/$username/200/200')),
          const SizedBox(height: 8),
          Text(username,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SizedBox(
            height: 32,
            child: alreadyFollowing
                ? OutlinedButton(
                    onPressed: null,
                    child: const Text('Following'),
                  )
                : ElevatedButton(
                    onPressed: onFollow,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    child: const Text('Follow'),
                  ),
          )
        ],
      ),
    );
  }
}
