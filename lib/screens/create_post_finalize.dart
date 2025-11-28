import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/posts_repository.dart';
import '../models/profile_repository.dart';

class CreatePostFinalizeScreen extends StatefulWidget {
  final String imageUrl;
  const CreatePostFinalizeScreen({super.key, required this.imageUrl});

  @override
  State<CreatePostFinalizeScreen> createState() =>
      _CreatePostFinalizeScreenState();
}

class _CreatePostFinalizeScreenState extends State<CreatePostFinalizeScreen> {
  final TextEditingController _captionController = TextEditingController();

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

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
        title: const Text('New post',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Center(
            child: SizedBox(
              width: 160,
              height: 160,
              child: CachedNetworkImage(
                  imageUrl: widget.imageUrl, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _captionController,
              maxLines: 3,
              decoration:
                  const InputDecoration.collapsed(hintText: 'Add a caption...'),
            ),
          ),
          const SizedBox(height: 12),

          // Quick action chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.poll),
                    label: const Text('Poll')),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.lightbulb_outline),
                    label: const Text('Prompt')),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                    title: const Text('Tag people'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {}),
                ListTile(
                    title: const Text('Add location'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {}),
                const Divider(),
                ListTile(
                    title: const Text('Audience'),
                    subtitle: const Text('Everyone'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {}),
                ListTile(
                    title: const Text('Also share on...'),
                    subtitle: const Text('Off'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {}),
                ListTile(
                    title: const Text('More options'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {}),
              ],
            ),
          ),

          // Share button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                onPressed: () {
                  // Add post to repository and return to the feed
                  final newPost = Post(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    media: [
                      // Detect if supplied url is video by extension
                      MediaItem(
                          url: widget.imageUrl,
                          type: widget.imageUrl.toLowerCase().endsWith('.mp4')
                              ? MediaType.video
                              : MediaType.image)
                    ],
                    author: ProfileRepository.instance.username,
                    caption: _captionController.text,
                  );
                  PostsRepository.instance.addPost(newPost);
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Share', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
