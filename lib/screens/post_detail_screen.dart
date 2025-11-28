import 'package:flutter/material.dart';
// cached_network_image not needed here anymore
import '../models/posts_repository.dart';
import '../models/profile_repository.dart';
import '../widgets/comments_sheet.dart';
import '../widgets/media_carousel.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late final PostsRepository _postsRepo;

  @override
  void initState() {
    super.initState();
    _postsRepo = PostsRepository.instance;
  }

  String _formatDate(DateTime dt) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title:
            const Text('Posts', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: AnimatedBuilder(
        animation: _postsRepo,
        builder: (context, _) {
          final post = _postsRepo.posts.firstWhere(
            (p) => p.id == widget.post.id,
            orElse: () => widget.post,
          );

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (avatar + username)
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                        'https://picsum.photos/seed/${post.author}/200/200'),
                  ),
                  title: Text(post.author,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(_formatDate(post.createdAt)),
                  trailing: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {},
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),

                // Media carousel (images + short videos)
                AspectRatio(
                  aspectRatio: 4 / 5,
                  child: MediaCarousel(media: post.media),
                ),

                const SizedBox(height: 8),

                // Actions row
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                                post.likedByMe
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: post.likedByMe ? Colors.red : null),
                            onPressed: () => _postsRepo.toggleLike(post.id),
                          ),
                          IconButton(
                            icon: const Icon(Icons.mode_comment_outlined),
                            onPressed: () => showCommentsSheet(context, post),
                          ),
                          IconButton(
                              icon: const Icon(Icons.send_outlined),
                              onPressed: () {}),
                        ],
                      ),
                      IconButton(
                          icon: const Icon(Icons.bookmark_border),
                          onPressed: () {}),
                    ],
                  ),
                ),

                // Likes
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text('${post.likesCount} likes',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 6),

                // Caption
                if (post.caption != null && post.caption!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text.rich(
                      TextSpan(children: [
                        TextSpan(
                            text: '${post.author} ',
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                        TextSpan(text: post.caption!),
                      ]),
                    ),
                  ),

                // Comments preview (first comment)
                if (post.comments.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text.rich(
                      TextSpan(children: [
                        TextSpan(
                            text: '${post.comments.first.user} ',
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                        TextSpan(text: post.comments.first.text),
                      ]),
                    ),
                  ),
                ],

                // Date + See translation
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    children: [
                      Text(_formatDate(post.createdAt),
                          style: TextStyle(color: Colors.grey.shade700)),
                      const SizedBox(width: 8),
                      Text('•  See translation',
                          style: TextStyle(color: Colors.grey.shade700)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
