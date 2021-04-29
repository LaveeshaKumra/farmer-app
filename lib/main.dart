import 'package:farmers_app/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';

Future<void> main() async {
   WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp();
  runApp(
      MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Colors.teal[800]);
    return MaterialApp(
      title: 'Rompin',
      theme: ThemeData(
          primarySwatch: Colors.teal,
      ),
      home: Splash(),
      debugShowCheckedModeBanner: false,
    );
  }
}
