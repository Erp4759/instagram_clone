import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/posts_repository.dart';
import 'platform_image.dart';

class MediaCarousel extends StatefulWidget {
  final List<MediaItem> media;
  const MediaCarousel({super.key, required this.media});

  @override
  State<MediaCarousel> createState() => _MediaCarouselState();
}

class _MediaCarouselState extends State<MediaCarousel> {
  late final List<VideoPlayerController?> _videoControllers;
  late final List<String?> _videoInitErrors;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _videoControllers =
        List<VideoPlayerController?>.filled(widget.media.length, null);
    _videoInitErrors = List<String?>.filled(widget.media.length, null);
    for (var i = 0; i < widget.media.length; i++) {
      final m = widget.media[i];
      if (m.type == MediaType.video) {
        final c = VideoPlayerController.networkUrl(Uri.parse(m.url));
        _videoControllers[i] = c;
        c.initialize().then((_) {
          // initialization succeeded
          if (mounted) setState(() {});
        }).catchError((e, st) {
          // record initialization error for this index
          _videoInitErrors[i] = e?.toString() ?? 'Unknown video init error';
          if (mounted) setState(() {});
        });
        c.setLooping(true);
      }
    }
    // Auto-play first if it's a video
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playIfVideo(0);
    });
  }

  void _playIfVideo(int index) {
    for (var i = 0; i < _videoControllers.length; i++) {
      final c = _videoControllers[i];
      if (c != null) {
        if (i == index) {
          if (c.value.isInitialized) c.play();
        } else {
          if (c.value.isPlaying) c.pause();
        }
      }
    }
  }

  @override
  void dispose() {
    for (final c in _videoControllers) {
      c?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.media.isEmpty) return const SizedBox.shrink();

    return Stack(
      children: [
        PageView.builder(
          itemCount: widget.media.length,
          onPageChanged: (i) {
            setState(() => _current = i);
            _playIfVideo(i);
          },
          itemBuilder: (context, index) {
            final item = widget.media[index];
            if (item.type == MediaType.image) {
              return PlatformImage(item.url,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity);
            } else {
              final controller = _videoControllers[index];
              final initError = _videoInitErrors[index];
              if (initError != null) {
                // Initialization failed — do NOT try to decode the video URL as
                // an image (that causes a decoder error). Show a safe fallback
                // UI instead with a generic video placeholder and the error.
                return Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        color: Colors.black87,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.movie, color: Colors.white24, size: 64),
                            SizedBox(height: 8),
                            Text('Video unavailable',
                                style: TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ),
                    ),
                    const Center(
                        child: Icon(Icons.error_outline,
                            color: Colors.white70, size: 48)),
                    Positioned(
                      left: 12,
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(initError,
                            style: const TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                );
              }
              if (controller == null || !controller.value.isInitialized) {
                return const Center(child: CircularProgressIndicator());
              }
              return GestureDetector(
                onTap: () {
                  setState(() {
                    controller.value.isPlaying
                        ? controller.pause()
                        : controller.play();
                  });
                },
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        clipBehavior: Clip.hardEdge,
                        child: SizedBox(
                          width: controller.value.size.width,
                          height: controller.value.size.height,
                          child: VideoPlayer(controller),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      bottom: 12,
                      child: Icon(
                        controller.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
        if (widget.media.length > 1)
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.media.length, (i) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _current == i ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}
