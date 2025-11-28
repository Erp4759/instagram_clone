import 'package:flutter/material.dart';
import '../models/posts_repository.dart';
import '../models/profile_repository.dart';

Future<void> showCommentsSheet(BuildContext context, Post p) async {
  final postsRepo = PostsRepository.instance;
  final TextEditingController controller = TextEditingController();
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.35,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          // Ephemeral state for the comments sheet (kept in outer builder so
          // it survives StatefulBuilder setState calls)
          String? replyToId;
          String? replyToUser;
          bool showTooltip = true;
          // Use StatefulBuilder to manage reply target and tooltip visibility
          return StatefulBuilder(builder: (context, setState) {
            Widget buildCommentTile(Post current, Comment c, int indent) {
              final postsRepo = PostsRepository.instance;
              final replies =
                  current.comments.where((r) => r.parentId == c.id).toList();
              return Padding(
                padding: EdgeInsets.only(left: indent.toDouble()),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                          radius: 16,
                          backgroundImage: NetworkImage(
                              'https://picsum.photos/seed/${c.user}/200/200')),
                      title: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                              color: Colors.black, fontSize: 14),
                          children: [
                            TextSpan(
                                text: '${c.user} ',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            TextSpan(text: c.text),
                          ],
                        ),
                      ),
                      subtitle: Text(c.createdAt.toLocal().toString(),
                          style: const TextStyle(fontSize: 12)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                                c.likedByMe
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: c.likedByMe ? Colors.red : null,
                                size: 18),
                            onPressed: () {
                              postsRepo.toggleCommentLike(p.id, c.id);
                            },
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                replyToId = c.id;
                                replyToUser = c.user;
                                showTooltip = false;
                              });
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text('Reply',
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 13)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // render replies recursively
                    for (final r in replies)
                      buildCommentTile(current, r, indent + 16),
                  ],
                ),
              );
            }

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: SafeArea(
                child: Column(
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
                    const Text('Comments',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Expanded(
                      child: AnimatedBuilder(
                        animation: postsRepo,
                        builder: (context, _) {
                          final current = postsRepo.posts.firstWhere(
                            (pp) => pp.id == p.id,
                            orElse: () => p,
                          );

                          // build top-level comments (parentId == null)
                          final tops = current.comments
                              .where((c) => c.parentId == null)
                              .toList();

                          if (tops.isEmpty) {
                            return ListView(
                              controller: scrollController,
                              children: const [
                                SizedBox(height: 20),
                                Center(child: Text('No comments yet')),
                              ],
                            );
                          }

                          return ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            itemCount: tops.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final c = tops[index];
                              return buildCommentTile(current, c, 0);
                            },
                          );
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    // Balloon tooltip + reply indicator
                    if (showTooltip)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            margin: const EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                                'Tip: Reply to a comment to start a thread',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12)),
                          ),
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 12.0,
                          right: 12.0,
                          top: 6,
                          bottom: MediaQuery.of(context).viewInsets.bottom + 8),
                      child: Column(
                        children: [
                          if (replyToUser != null)
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 6),
                                    decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            child: Text(
                                                'Replying to $replyToUser')),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              replyToId = null;
                                              replyToUser = null;
                                            });
                                          },
                                          child: const Icon(Icons.close,
                                              size: 18, color: Colors.black54),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                          Row(
                            children: [
                              CircleAvatar(
                                  radius: 16,
                                  backgroundImage: NetworkImage(
                                      'https://picsum.photos/seed/${ProfileRepository.instance.username}/200/200')),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: controller,
                                  decoration: InputDecoration(
                                      hintText: replyToUser != null
                                          ? 'Replying to $replyToUser...'
                                          : 'Add a comment...',
                                      border: InputBorder.none),
                                  onSubmitted: (val) {
                                    if (val.trim().isEmpty) return;
                                    postsRepo.addComment(
                                        p.id,
                                        ProfileRepository.instance.username,
                                        val.trim(),
                                        parentId: replyToId);
                                    controller.clear();
                                    setState(() {
                                      replyToId = null;
                                      replyToUser = null;
                                      showTooltip = false;
                                    });
                                  },
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  final val = controller.text.trim();
                                  if (val.isEmpty) return;
                                  postsRepo.addComment(p.id,
                                      ProfileRepository.instance.username, val,
                                      parentId: replyToId);
                                  controller.clear();
                                  setState(() {
                                    replyToId = null;
                                    replyToUser = null;
                                    showTooltip = false;
                                  });
                                },
                                child: const Text('Post'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        },
      );
    },
  );
}
