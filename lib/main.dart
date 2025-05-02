  // ignore_for_file: duplicate_import

  import 'package:firebase_core/firebase_core.dart';
  import 'package:flutter/material.dart';
  import 'package:food_delivery_app/services/noti_service/noti_service.dart';
  import 'package:provider/provider.dart';
  import 'package:food_delivery_app/firebase_options.dart';
  import 'package:food_delivery_app/intro/splash_screen.dart';
  import 'package:food_delivery_app/models/restauarant.dart';
  import 'package:food_delivery_app/themes/theme_provider.dart';
  import 'package:food_delivery_app/pages/admin/admin_login.dart';

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    } catch (e) {
      debugPrint('Firebase initialization error: $e');
    }
    
    // init notification
    NotiService().initNotification();
    runApp(const AppRoot());
  }
  
  class AppRoot extends StatelessWidget {
    const AppRoot({super.key});

    @override
    Widget build(BuildContext context) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ThemeProvider()),
          ChangeNotifierProvider(create: (context) => Restauarant()),
        ],
        child: const MyApp(),
      );
    }
  }

  class MyApp extends StatelessWidget {
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: Provider.of<ThemeProvider>(context).themeData,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/admin': (context) => const AdminLogin(),
        },
      );
    }
  }
