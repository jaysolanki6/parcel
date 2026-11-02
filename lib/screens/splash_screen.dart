import 'package:flutter/material.dart';

import '../services/local_storage.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController controller;
  late Animation<double> scaleAnimation;
  late Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    scaleAnimation = CurvedAnimation(
      parent: controller,
      curve: Curves.elasticOut,
    );

    fadeAnimation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeIn,
    );

    controller.forward();

    checkLogin();
  }

  Future<void> checkLogin() async {
    await Future.delayed(const Duration(seconds: 3));

    final phone = await LocalStorage.getPhone();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) {
          if (phone != null && phone.isNotEmpty) {
            return HomeScreen(phone: phone);
          }

          return const LoginScreen();
        },
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF10131B),
              Color(0xFF252044),
              Color(0xFF10131B),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: scaleAnimation,
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: const Color(0xFF7568FF),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.local_shipping_rounded,
                  size: 65,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 25),

            FadeTransition(
              opacity: fadeAnimation,
              child: const Text(
                'PARCEL TRACKER',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Track Your Delivery & Earnings',
              style: TextStyle(color: Colors.white60),
            ),

            const SizedBox(height: 70),

            const CircularProgressIndicator(
              color: Color(0xFF7568FF),
            ),

            const SizedBox(height: 25),

            const Text(
              'Developed By Jay Solanki',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}