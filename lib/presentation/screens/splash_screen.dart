import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qscan_app_flutter/presentation/screens/home_screen.dart';
import '../../core/utils/responsive_utils.dart';

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

    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        _opacity = 1.0;
      });
    });

    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveUtil(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          // Background gradient
          gradient: LinearGradient(
            colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)], // Blue shades
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: responsive.hp(15)),

            AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(
                seconds: 2,
              ), // Reduced duration for faster animation
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundImage: const AssetImage(
                      'assets/images/qr_scan_logo.png',
                    ),
                    backgroundColor: Colors.white,
                    radius: responsive.wp(15), // Responsive radius
                  ),
                  SizedBox(height: responsive.hp(2)),
                  Text(
                    "Qscan",
                    style: TextStyle(
                      fontSize: responsive.sp(7), // Responsive font size
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1.5,
                      shadows: const [
                        Shadow(
                          blurRadius: 5.0,
                          color: Colors.black26,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            Padding(
              padding: EdgeInsets.only(
                bottom: responsive.hp(4),
              ), // Consistent bottom padding
              child: Column(
                children: [
                  Text(
                    "powered by",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: responsive.sp(4),
                    ),
                  ),
                  Text(
                    "Jashvant",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: responsive.sp(6),
                    ),
                  ),
                  SizedBox(height: responsive.hp(1)),
                  Text(
                    "version 1.0",
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: responsive.sp(5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
