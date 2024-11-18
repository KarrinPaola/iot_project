import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Add this import
import 'package:iot_project/main%20app/home/home.dart';
import 'package:iot_project/main%20app/set%20up%20first/connect%20bluetooth/sent_data_to_iot.dart';
import 'authenitation/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure widgets are initialized before Firebase call
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white, // Color of the notch area
      statusBarIconBrightness: Brightness.dark, // Icon color on the status bar
    ));
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('vi', 'VN'), // Vietnamese
        Locale('en', 'US'), // English (fallback)
      ],
      locale: Locale('vi', 'VN'), // Set default locale to Vietnamese
      home: LoginPage(),
    );
  }
}