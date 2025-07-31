import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:redeo_app/config/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Make status bar visible with desired style
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Allows content behind status bar
      statusBarIconBrightness: Brightness.dark, // Light icons if bg is dark
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      title: 'RedeoPay',
    );
  }
}
