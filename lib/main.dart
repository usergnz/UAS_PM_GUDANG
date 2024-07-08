import 'package:flutter/material.dart';
import 'package:cafeubernet_app/views/splash_screen.dart';

void main() {
  runApp(CafeUbernetAppp());
}

class CafeUbernetAppp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cafe Ubernet',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}
