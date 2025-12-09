import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String path;
  const VideoPlayerScreen({super.key,required this.path});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController controller;
  bool controls =true;

  void _seekRelative(Duration offset) {
    final newPosition = controller.value.position + offset;
    final duration = controller.value.duration;
    final seekTo = newPosition < Duration.zero
        ? Duration.zero
        : newPosition > duration
        ? duration
        : newPosition;
    controller.seekTo(seekTo);
  }

  @override
  void initState(){
    super.initState();
    controller = VideoPlayerController.file(File(widget.path))
    ..initialize().then((_) {
      setState(() {

      });
      controller.play();
      WakelockPlus.enable();
    });
    controller.addListener(_videoListener);
  }
  void _videoListener(){
    if (controller.value.isPlaying){
      WakelockPlus.enable();
    }
    else{
      WakelockPlus.disable();
    }
  }
  @override
  void dispose(){
    controller.removeListener(_videoListener);
    WakelockPlus.disable();
    super.dispose();
    controller.dispose();
    }

  void toggleControls(){
    setState(() {
      controls = !controls;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
   backgroundColor: Colors.black,
      body:
      controller.value.isInitialized ? Stack(
        children: [
          // 1. মূল ভিডিও প্লেয়ার উইজেট (এটিকে সবার নিচে রাখতে হবে)
          Center(
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),
          ),

          // 2. বাম দিকের ডাবল ট্যাপ এরিয়া (Backward Skip - 10s)
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onDoubleTap: () {
                _seekRelative(const Duration(seconds: -10));
              },
              onTap: toggleControls,
              child: Container(
                width: screenSize.width / 2,
                height: double.infinity,
                color: Colors.transparent,
              ),
            ),
          ),

          // 3. Forward Skip + 10s
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onDoubleTap: () {
                _seekRelative(const Duration(seconds: 10));
              },
              onTap: toggleControls,
              child: Container(
                width: screenSize.width / 2,
                height: double.infinity,
                color: Colors.transparent,
              ),
            ),
          ),

          // 4.  Back Button
          if(controls)
            Positioned(
              top: 30,
              left: 10, child: IconButton(
                onPressed: ()=> Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white)
            ),
            ),

          // 5.  Progress Indicator ও Play/Pause Button
          if(controls)
            Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child:Column(
                  children: [
                    VideoProgressIndicator
                      (controller,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: Colors.white,
                        backgroundColor: Colors.white24,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                            onPressed: (){
                              setState(() {
                                controller.value.isPlaying ? controller.pause() : controller.play();
                              });
                            },
                            icon: Icon(controller.value.isPlaying ? Icons.pause : Icons.play_arrow,color: Colors.white,size: 35,)
                        )
                      ],
                    )
                  ],
                )
            )
        ],


      ): Center(
        child: CircularProgressIndicator(color: Colors.white12,),
      ),

    );
  }
}
