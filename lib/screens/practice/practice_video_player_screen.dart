import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../models/practice_model.dart';
import '../../core/config/theme_config.dart';

class PracticeVideoPlayerScreen extends StatefulWidget {
  final PracticeModel practice;

  const PracticeVideoPlayerScreen({
    super.key,
    required this.practice,
  });

  @override
  State<PracticeVideoPlayerScreen> createState() => _PracticeVideoPlayerScreenState();
}

class _PracticeVideoPlayerScreenState extends State<PracticeVideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      // For demo purposes, using a sample video URL
      // In production, you would use widget.practice.videoUrl
      _controller = VideoPlayerController.networkUrl(
        Uri.parse('https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4'),
      );
      
      await _controller!.initialize();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.practice.title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: _isInitialized && _controller != null
            ? AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: Stack(
                  children: [
                    VideoPlayer(_controller!),
                    if (_showControls)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black26,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    _controller!.value.isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 64,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _controller!.value.isPlaying
                                          ? _controller!.pause()
                                          : _controller!.play();
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              )
            : const CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
