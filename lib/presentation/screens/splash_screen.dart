import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qscan_app_flutter/presentation/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white54,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/images/qr_scan_logo.png'),
              backgroundColor: Colors.blue[300],
              radius: 50,
            ),
          ),

          Text(
            "Qscan",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 280),

          Text("powered by"),
          Text("Jashvant"),
          Text("version 1.0"),
        ],
      ),
    );
  }
}
