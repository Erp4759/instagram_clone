import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'create_post_editor.dart';

class GalleryPickerScreen extends StatefulWidget {
  const GalleryPickerScreen({super.key});

  @override
  State<GalleryPickerScreen> createState() => _GalleryPickerScreenState();
}

class _GalleryPickerScreenState extends State<GalleryPickerScreen> {
  List<AssetEntity> _assets = [];
  int _selectedIndex = 0;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final res = await PhotoManager.requestPermissionExtend();
    if (!res.isAuth) {
      setState(() {
        _error = 'Gallery permission denied';
        _loading = false;
      });
      return;
    }

    try {
      final paths = await PhotoManager.getAssetPathList(
        onlyAll: true,
        type: RequestType.image,
      );
      if (paths.isEmpty) {
        setState(() {
          _assets = [];
          _loading = false;
        });
        return;
      }

      final recent = paths.first;
      final assets = await recent.getAssetListPaged(0, 200); // first 200
      setState(() {
        _assets = assets;
        _selectedIndex = assets.isNotEmpty ? 0 : -1;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load gallery';
        _loading = false;
      });
    }
  }

  void _openEditorWithAsset(AssetEntity asset) async {
    final file = await asset.file;
    if (file == null) return;
    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => CreatePostEditorScreen(imageUrl: file.path)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context)),
        title: const Text('Recents',
            style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          TextButton(
            onPressed: () {
              if (_assets.isEmpty) return;
              _openEditorWithAsset(_assets[_selectedIndex]);
            },
            child: const Text('Next'),
          )
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : Column(
                    children: [
                      // Preview area
                      if (_assets.isNotEmpty)
                        FutureBuilder<Uint8List?>(
                          future: _assets[_selectedIndex].thumbnailDataWithSize(
                              const ThumbnailSize(800, 800)),
                          builder: (context, snap) {
                            final data = snap.data;
                            if (data == null)
                              return const SizedBox(
                                  height: 320,
                                  child: Center(
                                      child: CircularProgressIndicator()));
                            return SizedBox(
                                height: 320,
                                width: double.infinity,
                                child: Image.memory(data, fit: BoxFit.cover));
                          },
                        )
                      else
                        const SizedBox(
                            height: 320,
                            child: Center(child: Text('No photos'))),

                      const SizedBox(height: 8),

                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 4,
                                  mainAxisSpacing: 4),
                          itemCount: _assets.length,
                          itemBuilder: (context, index) {
                            final a = _assets[index];
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedIndex = index),
                              onDoubleTap: () => _openEditorWithAsset(a),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  FutureBuilder<Uint8List?>(
                                    future: a.thumbnailDataWithSize(
                                        const ThumbnailSize(200, 200)),
                                    builder: (context, snap) {
                                      final d = snap.data;
                                      if (d == null)
                                        return Container(
                                            color: Colors.grey[300]);
                                      return Image.memory(d, fit: BoxFit.cover);
                                    },
                                  ),
                                  if (_selectedIndex == index)
                                    Positioned(
                                      right: 6,
                                      top: 6,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                            color: Colors.black45,
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        child: const Icon(Icons.check,
                                            color: Colors.white, size: 16),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
      ),
    );
  }
}
