import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_playre_app/screens/video_player_screen.dart';

import '../services/file_service.dart';

class VideoListScreen extends StatefulWidget {
  const VideoListScreen({super.key});

  @override
  State<VideoListScreen> createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  List videos = [];
  bool loading = true;
  bool permissionDenied = false;

  @override
  void initState(){
    super.initState();
    loadVideos();
  }

  Future<void> loadVideos() async {
    var status = await Permission.storage.request();
    var status13  = await Permission.videos.request();

    if(status.isGranted || status13.isGranted){
      final fileService = FileService();
      final list = await fileService.getVideos();
      setState(() {
        videos = list;
        loading =false;
      });
    }else{
      setState(() {
        permissionDenied = true;
        loading = false;
      });

    }
  }
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (permissionDenied) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Please allow storage permission to view videos.",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  openAppSettings();
                },
                child: const Text("Open Settings"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Videos")),
      body: videos.isEmpty
          ? Center(child: Text("No videos found"))
          : ListView.builder(
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final file = videos[index];

          return ListTile(
            leading: Icon(Icons.video_file, size: 40),
            title: Text(file.path.split('/').last),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VideoPlayerScreen(path: file.path),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
