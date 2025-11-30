import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/platform_image.dart';
import 'create_post_editor.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  int _selectedIndex = 0;
  int _selectedTab = 0; // 0: Gallery, 1: Photo, 2: Video

  late final List<String> _items;

  @override
  void initState() {
    super.initState();
    _items = List.generate(
        12, (i) => 'https://picsum.photos/seed/post${i + 1}/800/800');
  }

  @override
  Widget build(BuildContext context) {
    final selectedUrl = _items[_selectedIndex];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop()),
        title: Row(
          children: [
            const Text('Recents',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
        actions: [
          if (_selectedTab == 1)
            IconButton(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library_outlined)),
          TextButton(
              onPressed: () => _onNext(context), child: const Text('Next'))
        ],
      ),
      body: Column(
        children: [
          // Large preview
          AspectRatio(
              aspectRatio: 1,
              child: PlatformImage(selectedUrl, fit: BoxFit.cover)),

          // Thumbnails row
          SizedBox(
            height: 100,
            child: Stack(
              children: [
                ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  itemBuilder: (context, index) {
                    final hasGalleryTile = _selectedTab == 1;
                    final displayIndex = hasGalleryTile ? index - 1 : index;

                    // If PHOTO tab and index == 0, show a gallery access tile
                    if (hasGalleryTile && index == 0) {
                      return GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.photo_library, size: 32),
                              SizedBox(height: 6),
                              Text('Gallery', style: TextStyle(fontSize: 12))
                            ],
                          ),
                        ),
                      );
                    }

                    final url =
                        _items[displayIndex.clamp(0, _items.length - 1)];
                    final selected = displayIndex == _selectedIndex;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedIndex = displayIndex),
                      child: Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color:
                                    selected ? Colors.blue : Colors.transparent,
                                width: 2)),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            PlatformImage(url, fit: BoxFit.cover),
                            if (selected)
                              Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  margin: const EdgeInsets.all(6),
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                      color: Colors.black45,
                                      borderRadius: BorderRadius.circular(12)),
                                  child: const Icon(Icons.check,
                                      color: Colors.white, size: 16),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(width: 4),
                  itemCount: _items.length + (_selectedTab == 1 ? 1 : 0),
                ),

                // Select multiple button at top-right
                Positioned(
                  right: 12,
                  top: 12,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black54,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20))),
                    onPressed: () {},
                    child: Row(
                      children: const [
                        Icon(Icons.crop_square, size: 14),
                        SizedBox(width: 6),
                        Text('SELECT MULTIPLE', style: TextStyle(fontSize: 12))
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Tabs (Gallery / Photo / Video)
          Row(
            children: [
              Expanded(child: _buildTab('GALLERY', 0)),
              Expanded(child: _buildTab('PHOTO', 1)),
              Expanded(child: _buildTab('VIDEO', 2)),
            ],
          ),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // When on the Gallery tab show a centered Gallery button to open picker
          if (_selectedTab == 0)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Open Gallery'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int idx) {
    final active = _selectedTab == idx;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = idx),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(color: active ? Colors.black : Colors.black54)),
          const SizedBox(height: 8),
          if (active)
            Container(height: 4, width: 48, color: Colors.black)
          else
            Container(height: 4, width: 48, color: Colors.transparent),
        ],
      ),
    );
  }

  void _onNext(BuildContext context) {
    // Push editor screen with the selected image
    final selected = _items[_selectedIndex];
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => CreatePostEditorScreen(imageUrl: selected)));
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final xfile = await picker.pickImage(source: ImageSource.gallery);
      if (xfile == null) return;
      final path = xfile.path;
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => CreatePostEditorScreen(imageUrl: path)));
    } catch (e) {
      // ignore errors for now
    }
  }
}
