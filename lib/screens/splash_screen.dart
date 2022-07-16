import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/controllers/data_controller.dart';
import 'package:frontendforever/pages/main_screen.dart';
import 'package:frontendforever/screens/search.dart';
import 'package:frontendforever/screens/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:frontendforever/types/prelogin.dart';

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
    if (!kIsWeb) {
    }

    Future.delayed(const Duration(seconds: 2), () async {
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
            const MainScreen(),
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
