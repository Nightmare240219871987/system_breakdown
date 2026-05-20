import 'package:flutter/material.dart';
import 'package:system_breakdown/src/features/landing_page/presentation/landing_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: LandingPage());
  }
}
