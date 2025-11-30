import 'package:flutter/material.dart';

import '../models/profile_repository.dart';
import 'user_profile_screen.dart';
import 'home_screen.dart';

class ProfileFollowersTabs extends StatelessWidget {
  final int initialIndex;
  final String username;

  const ProfileFollowersTabs(
      {super.key, this.initialIndex = 0, required this.username});

  @override
  Widget build(BuildContext context) {
    final repo = ProfileRepository.instance;
    // Use repo accessors that handle other users' follower/following lists.
    return DefaultTabController(
      length: 4,
      initialIndex: initialIndex,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop()),
          title: Text(username,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(46),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                labelColor: Colors.black,
                unselectedLabelColor: Colors.black54,
                indicatorColor: Colors.black,
                indicatorSize: TabBarIndicatorSize.label,
                isScrollable: true,
                tabs: [
                  Tab(
                      child: Text(
                          '${repo.getFollowersFor(username).length} followers',
                          style: const TextStyle(fontSize: 14))),
                  Tab(
                      child: Text(
                          '${repo.getFollowingFor(username).length} following',
                          style: const TextStyle(fontSize: 14))),
                  Tab(
                      child: Text('${repo.subscriptions.length} subscriptions',
                          style: const TextStyle(fontSize: 14))),
                  const Tab(
                      child: Text('Flagged', style: TextStyle(fontSize: 14))),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildUserList(context, repo.getFollowersFor(username),
                allowOpen: false),
            _buildUserList(context, repo.getFollowingFor(username),
                allowOpen: true),
            _buildUserList(context, repo.subscriptions),
            _buildFlaggedPlaceholder(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList(BuildContext context, List<String> users,
      {bool allowOpen = true}) {
    if (users.isEmpty) {
      return const Center(child: Text('No users'));
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: users.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final u = users[index];
        final content = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              _StoryAvatar(seed: u, size: 52),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(u,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('Display name',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 36,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFF0EBFB),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                  ),
                  child: const Text('Message',
                      style: TextStyle(color: Colors.black)),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert, color: Colors.black54),
              ),
            ],
          ),
        );

        if (!allowOpen) return content;

        return InkWell(
          onTap: () async {
            // Capture the navigator to avoid using `context` after an await.
            final nav = Navigator.of(context);
            // If the HomePage exists underneath this route, pop this
            // followers/following screen so the inline profile becomes
            // visible, then request the inline view. If inline fails,
            // fall back to pushing a full-screen profile.
            if (HomePage.homeKey.currentState != null) {
              if (nav.canPop()) nav.pop();
              // Wait a tick for the pop to complete and HomePage to be visible.
              await Future<void>.delayed(Duration.zero);
              final shownInline = HomePage.showInlineProfile(u);
              if (!shownInline) {
                nav.push(MaterialPageRoute(
                    builder: (_) => UserProfileScreen(username: u)));
              }
            } else {
              nav.push(MaterialPageRoute(
                  builder: (_) => UserProfileScreen(username: u)));
            }
          },
          child: content,
        );
      },
    );
  }

  Widget _buildFlaggedPlaceholder() {
    return const Center(child: Text('No flagged users'));
  }
}

class _StoryAvatar extends StatelessWidget {
  final String seed;
  final double size;
  const _StoryAvatar({required this.seed, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final image = NetworkImage('https://picsum.photos/seed/$seed/200/200');
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
            colors: [Color(0xFFDE0046), Color(0xFFF7A34B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
      ),
      child: Container(
        decoration:
            const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
        padding: const EdgeInsets.all(2),
        child: CircleAvatar(radius: (48 - 10) / 2, backgroundImage: image),
      ),
    );
  }
}
