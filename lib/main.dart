import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(const VideoPlayerApp());

class VideoPlayerApp extends StatelessWidget {
  const VideoPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 원래는 const였지만 themedata가 const가 될 수 없나봄 ㅇㅇ
      title: 'Video Player Demo',
      theme: ThemeData(primarySwatch: Colors.red),
      home: VideoPlayerScreen(),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoController;
  final TextEditingController _textController = TextEditingController();
  late Future<void> _initializeVideoPlayerFuture;
  String src =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';
  List<String> logs = [];
  @override
  void initState() {
    super.initState();

    // Create and store the VideoPlayerController. The VideoPlayerController
    // offers several different constructors to play videos from assets, files,
    // or the internet.
    _videoController = VideoPlayerController.network(
      src,
    );
    // Initialize the controller and store the Future for later use.
    _initializeVideoPlayerFuture = _videoController.initialize();

    // Use the controller to loop the video.
    _videoController.setLooping(true);
  }

  void updateState() {
    _videoController.dispose();
    _videoController = VideoPlayerController.network(
      src,
    );
    _initializeVideoPlayerFuture = _videoController.initialize();
    _videoController.setLooping(true);
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _videoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Demo'),
      ),
      // Use a FutureBuilder to display a loading spinner while waiting for the
      // VideoPlayerController to finish initializing.
      body: Column(
        children: [
          FutureBuilder(
            future: _initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // If the VideoPlayerController has finished initialization, use
                // the data it provides to limit the aspect ratio of the video.
                return AspectRatio(
                  aspectRatio: _videoController.value.aspectRatio,
                  // Use the VideoPlayer widget to display the video.
                  child: VideoPlayer(_videoController),
                );
              } else {
                // If the VideoPlayerController is still initializing, show a
                // loading spinner.
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
          Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Column(
                children: [
                  TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: '주소를 입력하세요',
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            src = _textController.text;
                          });
                          _textController.text = "";
                          updateState();
                        },
                        icon: Icon(Icons.check),
                      ),
                    ),
                  ),
                  ValueListenableBuilder(
                    valueListenable: _videoController,
                    builder: (context, VideoPlayerValue value, child) {
                      String isPlaying = value.isPlaying.toString();
                      String duration = value.duration.toString();
                      String currentPos = value.position.toString();
                      String isBuffering = value.isBuffering.toString();
                      return Text(
                          '재생 중: $isPlaying, 버퍼링중: $isBuffering, 총 재생시간: $duration,현재 재생 시간: $currentPos');
                    },
                  )
                ],
              ))
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Wrap the play or pause in a call to `setState`. This ensures the
          // correct icon is shown.
          setState(() {
            // If the video is playing, pause it.
            if (_videoController.value.isPlaying) {
              _videoController.pause();
            } else {
              // If the video is paused, play it.
              _videoController.play();
            }
          });
        },
        // Display the correct icon depending on the state of the player.
        child: Icon(
          _videoController.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
