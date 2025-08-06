import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:redeo_app/config/app_router.dart';
import 'package:redeo_app/providers/auth_provider.dart';
import 'package:redeo_app/providers/payment_provider.dart';
import 'package:redeo_app/providers/notification_provider.dart';
import 'package:redeo_app/providers/profile_provider.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: MaterialApp.router(
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
        title: 'MREDEO',
      ),
    );
  }
}
