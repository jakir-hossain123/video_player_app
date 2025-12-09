import 'package:flutter/material.dart';
import 'package:video_playre_app/screens/video_list_screen.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

void main (){
  WidgetsFlutterBinding.ensureInitialized();
  WakelockPlus.enable();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: VideoListScreen(),
    );
  }
}
