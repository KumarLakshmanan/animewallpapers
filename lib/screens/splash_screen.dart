import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontendforever/constants.dart';

import 'package:frontendforever/pages/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  final bool logOut;
  const SplashScreen({Key? key, this.logOut = false}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool activeConnection = false;
  @override
  void initState() {
    super.initState();
    _myFunction();
  }

  Future _myFunction() async {
    setState(() {
      activeConnection = true;
    });
    if (widget.logOut) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.clear();
    }
    if (!kIsWeb) {
      checkUserConnection().then((value) {
        if (value) {
          _checkLogin();
        }
      });
    } else {
      _checkLogin();
    }
  }

  Future checkUserConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          activeConnection = true;
        });
        return true;
      }
    } on SocketException catch (_) {
      setState(() {
        activeConnection = false;
      });
      return false;
    }
  }

  Future _checkLogin() async {
    Future.delayed(const Duration(seconds: 2), () async {
      Get.offAll(
        const MainScreen(show: true),
        transition: Transition.rightToLeft,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 90),
            Image.asset(
              'assets/icons/logo.png',
              width: MediaQuery.of(context).size.width * 0.6,
            ),
            const SizedBox(height: 10),
            if (!activeConnection)
              const Text(
                "No Internet Connection",
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF222831),
                ),
              ),
            if (!activeConnection) const SizedBox(height: 20),
            if (!activeConnection)
              const Text(
                "Please check your internet connection and try again",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF28374C),
                ),
              ),
            if (!activeConnection) const SizedBox(height: 20),
            if (!activeConnection)
              MaterialButton(
                onPressed: () {
                  _myFunction();
                },
                child: const Text(
                  "Retry",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF222831),
                  ),
                ),
              ),
            const Spacer(),
            const Text(
              "Powered by",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF28374C),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icons/icon.png',
                  height: 30,
                ),
                const SizedBox(width: 10),
                Text(
                  "Frontend Forever",
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color(0xFF222831),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
