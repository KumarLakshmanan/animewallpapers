import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontendforever/profile/profile.dart';
import 'package:frontendforever/screens/comments.dart';
import 'package:frontendforever/screens/feeback.dart';
import 'package:get/get.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/controllers/data_controller.dart';
import 'package:frontendforever/pages/main_screen.dart';
import 'package:frontendforever/screens/search.dart';
import 'package:frontendforever/screens/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:frontendforever/models/prelogin.dart';

import '../functions.dart';

class SplashScreen extends StatefulWidget {
  final bool logOut;
  const SplashScreen({Key? key, this.logOut = false}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final d = Get.put(DataController());
  @override
  void initState() {
    super.initState();
    _myFunction();
  }

  Future _myFunction() async {
    if (widget.logOut) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.clear();
    }
    if (widget.logOut) {
      await logout();
    }
    _checkLogin();
  }

  Future _checkLogin() async {
    if (!kIsWeb) {}
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getString('userCredentials') ?? "";
    if (isLoggedIn.isNotEmpty) {
      var httpsRes = await http
          .get(Uri.parse(webUrl + 'prelogin.json?r=' + randomString(5)));
      print("=============================================");
      print(webUrl + 'prelogin.json');
      print("=============================================");
      if (httpsRes.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(httpsRes.body);
        print(jsonData);
        prefs.setString("prelogin", json.encode(jsonData));
        d.prelogin = PreLogin.fromJson(jsonData);
        d.prelogindynamic = jsonData;
        await loadData();
        Get.offAll(
          const ProfilePage(),
          // const MainScreen(),
          // const FeedbackScreen(),
          transition: Transition.rightToLeft,
        );
      } else {
        Get.offAll(
          const SplashScreen(
            logOut: true,
          ),
        );
      }
    } else {
      var httpsRes = await http
          .get(Uri.parse(webUrl + 'prelogin.json?r=' + randomString(5)));
      print("=============================================");
      print(webUrl + 'prelogin.json');
      print("=============================================");
      if (httpsRes.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(httpsRes.body);
        prefs.setString("prelogin", json.encode(jsonData));
        d.prelogin = PreLogin.fromJson(jsonData);
        d.prelogindynamic = jsonData;
        Get.offAll(
          const WelcomeScreen(),
          transition: Transition.rightToLeft,
        );
      } else {
        Get.offAll(
          const SplashScreen(
            logOut: true,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/logo.png',
              width: MediaQuery.of(context).size.width * 0.6,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              color: Color(0xFF222831),
            ),
          ],
        ),
      ),
    );
  }
}
