import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/pages/main_screen.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    Key? key,
  }) : super(key: key);
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future _checkLogin() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    Get.offAll(
      () => const MainScreen(),
      transition: Transition.rightToLeft,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(3000),
                child: Image.asset(
                  'assets/icons/logo_nobg.png',
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width * 0.4,
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              const Text(
                "Termux Tools & Commands",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Termux is a free and open-source terminal emulator for Android which allows for running a Linux environment on an Android device.",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
