import 'package:checkprice/login_page.dart';
import 'package:checkprice/options.dart';
//import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  // runApp(DevicePreview(enabled: true, builder: (context) => const MyApp()));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: Locale('ar', 'EN'),
      theme: ThemeData(
        textTheme: GoogleFonts.notoSansArabicTextTheme(),
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => LoginPage(),
        '/options': (context) => Option(),
      },
      home: LoginPage(),
    );
  }
}
