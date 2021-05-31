import 'package:farmers_app/splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:provider/provider.dart';
import 'package:farmers_app/Theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
   WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp();
   SharedPreferences.getInstance().then((prefs) {
     var theme = prefs.getString('theme') ;
     runApp(
       ChangeNotifierProvider<ThemeNotifier>(
         create: (_) => ThemeNotifier(theme=="tealTheme" || theme==null ? tealTheme :theme=="blueTheme" ? blueTheme :theme=="purpleTheme" ? purpleTheme : redTheme  ),
         child: MyApp(),
       ),
     );
   });
   // runApp(ChangeNotifierProvider<ThemeNotifier>(
   //     create: (_) => ThemeNotifier(tealTheme), child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Colors.grey[400]);
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      title: 'Rompin',
      theme: themeNotifier.getTheme(),
      home: Splash(),
      debugShowCheckedModeBanner: false,
    );
  }
}
