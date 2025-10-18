import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qscan_app_flutter/presentation/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    // Start fade-in animation
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _opacity = 1.0;
      });
    });

    // Navigate to HomeScreen after delay
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(seconds: 2),
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundImage: const AssetImage(
                      'assets/images/qr_scan_logo.png',
                    ),
                    backgroundColor: Colors.white,
                    radius: 55,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Qscan",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            const Column(
              children: [
                Text(
                  "powered by",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  "Jashvant",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "version 1.0",
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
                SizedBox(height: 30),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
