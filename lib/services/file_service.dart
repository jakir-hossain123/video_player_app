import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileService {
  Future<List<FileSystemEntity>> getVideos() async {
    List<Directory>? externalDirs = await getExternalStorageDirectories();
    if (externalDirs == null || externalDirs.isEmpty) {
      return [];
    }


    String baseDir = externalDirs.first.path.split('/Android')[0];

    Directory downloadDir = Directory('$baseDir/Download');

    List<FileSystemEntity> files = [];


    if (await downloadDir.exists()) {
      await for (var entity in downloadDir.list(recursive: true, followLinks: false)) {
        files.add(entity);
      }
    } else {

      print("Download directory not found at: ${downloadDir.path}");
      return [];
    }


    return files.where((file) {
      final path = file.path.toLowerCase();
      return path.endsWith(".mp4") || path.endsWith(".mkv") || path.endsWith(".mov");
    }).toList();
  }
}