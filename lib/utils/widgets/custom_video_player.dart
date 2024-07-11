import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:zipbuzz/utils/constants/colors.dart';

class CustomVideoPlayer extends StatefulWidget {
  final String videoUrl;
  const CustomVideoPlayer({super.key, required this.videoUrl});

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  late VideoPlayerController videoPlayerController;
  ChewieController? chewieController;

  void _initialiseVideoPlayer() async {
    videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    )..initialize().then(
        (value) {
          setState(
            () {
              chewieController = ChewieController(
                videoPlayerController: videoPlayerController,
                autoPlay: false,
                looping: false,
                aspectRatio: videoPlayerController.value.aspectRatio,
                draggableProgressBar: true,
                allowFullScreen: true,
                materialProgressColors: ChewieProgressColors(
                  playedColor: AppColors.primaryColor,
                  handleColor: AppColors.primaryColor,
                  // bufferedColor: disableColor2,
                  // backgroundColor: disableColor2,
                ),
                cupertinoProgressColors: ChewieProgressColors(
                  playedColor: AppColors.primaryColor,
                  handleColor: AppColors.primaryColor,
                  // bufferedColor: disableColor2,
                  // backgroundColor: disableColor2,
                ),
              );
            },
          );
        },
      );
  }

  @override
  void initState() {
    _initialiseVideoPlayer();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    videoPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return videoPlayerController.value.isInitialized
        ? ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: videoPlayerController.value.aspectRatio,
              child: Chewie(controller: chewieController!),
            ),
          )
        : Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.bgGrey,
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            ),
          );
  }

  void playOrPause() {
    if (!videoPlayerController.value.isPlaying) {
      setState(() {
        videoPlayerController.play();
      });
    } else {
      setState(() {
        videoPlayerController.pause();
      });
    }
  }

  Widget buildBackwardButton() {
    return IconButton(
      onPressed: () {
        setState(() {
          videoPlayerController
              .seekTo(videoPlayerController.value.position - const Duration(seconds: 10));
        });
      },
      icon: const Icon(
        Icons.replay_10,
        size: 30,
        color: Colors.white,
      ),
    );
  }

  Widget buildForwardButton() {
    return IconButton(
      onPressed: () {
        setState(() {
          videoPlayerController
              .seekTo(videoPlayerController.value.position + const Duration(seconds: 10));
        });
      },
      icon: const Icon(
        Icons.forward_10,
        size: 30,
        color: Colors.white,
      ),
    );
  }

  Widget buildPlayPauseButton() {
    return IconButton(
      onPressed: playOrPause,
      icon: videoPlayerController.value.isPlaying
          ? const Icon(
              Icons.pause,
              size: 30,
              color: Colors.white,
            )
          : const Icon(
              Icons.play_arrow,
              size: 30,
              color: Colors.white,
            ),
    );
  }
}
