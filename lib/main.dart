import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:mredeo_app/config/app_router.dart';
import 'package:mredeo_app/providers/auth_provider.dart';
import 'package:mredeo_app/providers/payment_provider.dart';
import 'package:mredeo_app/providers/notification_provider.dart';
import 'package:mredeo_app/providers/profile_provider.dart';
import 'package:mredeo_app/providers/admin_provider.dart';
import 'package:mredeo_app/data/repositories/admin_repository.dart';
import 'package:mredeo_app/data/services/api_client.dart';
import 'package:mredeo_app/config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}

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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  AuthProvider? _authProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed && _authProvider != null) {
      // App came to foreground - update session activity
      _authProvider!.updateSessionActivity();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            _authProvider = AuthProvider();
            return _authProvider!;
          },
        ),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(
          create: (_) {
            final apiClient = ApiClient(baseUrl: AppConfig.baseUrl);
            final adminRepository = AdminRepository(apiClient: apiClient);
            return AdminProvider(repository: adminRepository);
          },
        ),
      ],
      child: MaterialApp.router(
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
        title: 'MREDEO',
      ),
    );
  }
}
