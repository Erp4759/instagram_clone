import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'create_post_finalize.dart';

class CreatePostEditorScreen extends StatefulWidget {
  final String imageUrl;
  const CreatePostEditorScreen({super.key, required this.imageUrl});

  @override
  State<CreatePostEditorScreen> createState() => _CreatePostEditorScreenState();
}

class _CreatePostEditorScreenState extends State<CreatePostEditorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop()),
        actions: [
          IconButton(
              icon: const Icon(Icons.auto_fix_high_outlined), onPressed: () {}),
          IconButton(
              icon: const Icon(Icons.blur_on_outlined), onPressed: () {}),
          IconButton(
              icon: const Icon(Icons.emoji_emotions_outlined),
              onPressed: () {}),
          IconButton(icon: const Icon(Icons.image_outlined), onPressed: () {}),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                    icon: const Icon(Icons.text_fields), onPressed: () {}),
                Positioned(
                  right: 6,
                  top: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: Colors.pink,
                        borderRadius: BorderRadius.circular(12)),
                    child: const Text('New',
                        style: TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CachedNetworkImage(
                imageUrl: widget.imageUrl,
                fit: BoxFit.contain,
                width: double.infinity,
                placeholder: (c, s) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (c, s, e) =>
                    const Center(child: Icon(Icons.broken_image)),
              ),
            ),

            // Audio carousel area
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tooltip bubble
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 6)
                          ]),
                      child: const Text('Add audio to your post',
                          style: TextStyle(fontSize: 13)),
                    ),
                  ),

                  SizedBox(
                    height: 96,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final thumb =
                            'https://picsum.photos/seed/audio$index/120/120';
                        return Column(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey.shade200),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(thumb, fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                                width: 72,
                                child: Text('Sample track',
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.black87))),
                          ],
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemCount: 8,
                    ),
                  ),
                ],
              ),
            ),

            // Bottom controls: Edit / Next
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Row(
                children: [
                  FloatingActionButton(
                    heroTag: 'edit',
                    onPressed: () {},
                    mini: true,
                    backgroundColor: Colors.grey.shade300,
                    child: const Icon(Icons.edit, color: Colors.black87),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12)),
                    onPressed: () async {
                      final ok = await _showSharingModal();
                      if (!context.mounted) {
                        return; // avoid using context across async gap
                      }
                      if (ok == true) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CreatePostFinalizeScreen(
                              imageUrl: widget.imageUrl,
                            ),
                          ),
                        );
                      }
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Next'),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showSharingModal() {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(4))),
                ),
                const SizedBox(height: 12),
                const Text('Sharing posts',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                ListTile(
                  leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black12)),
                      child: const Icon(Icons.add)),
                  title: const Text(
                      'Your account is public, so anyone can discover your posts and follow you.'),
                ),
                ListTile(
                  leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black12)),
                      child: const Icon(Icons.repeat)),
                  title: const Text(
                      'Anyone can reuse all or part of your post in features like remixes, sequences, templates and stickers, and download your post as part of their reel or post.'),
                ),
                ListTile(
                  leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black12)),
                      child: const Icon(Icons.settings)),
                  title: const Text(
                      'You can turn off reuse for each post or change the default in your settings.'),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('OK', style: TextStyle(fontSize: 16)),
                  ),
                ),
                TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Manage settings')),
                const SizedBox(height: 8),
                Center(
                    child: Text('Learn more in the Help Center.',
                        style: TextStyle(color: Colors.black54))),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }
}
