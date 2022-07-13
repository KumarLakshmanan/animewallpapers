import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:material_dialogs/material_dialogs.dart';
import 'package:frontendforever/api.dart';
import 'package:frontendforever/controllers/data_controller.dart';
import 'package:frontendforever/screens/onboarding.dart';
import 'package:frontendforever/screens/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontendforever/types/prelogin.dart';
import 'package:frontendforever/types/subject.dart';
import 'package:frontendforever/types/user_credentials.dart';

showCallbackDialog(String message, Function onTap,
    {bool barrierDismissible = true, bool showCancel = true}) {
  Get.dialog(
    AlertDialog(
      content: Text(message),
      actions: <Widget>[
        if (showCancel)
          TextButton(
            child: const Text("Cancel"),
            onPressed: () {
              Get.back();
            },
          ),
        TextButton(
          child: const Text("Ok"),
          onPressed: () {
            onTap();
          },
        )
      ],
    ),
    barrierDismissible: barrierDismissible,
  );
}

showAlertDialog(context, text) {
  Dialogs.materialDialog(
    color: Colors.white,
    msg: text,
    title: 'Warning',
    lottieBuilder: Lottie.asset(
      'assets/json/alert.json',
      fit: BoxFit.contain,
    ),
    context: context,
  );
}

showErrorDialog(context, text) {
  Dialogs.materialDialog(
    color: Colors.white,
    msg: text,
    title: 'Error',
    lottieBuilder: Lottie.asset(
      'assets/json/error.json',
      fit: BoxFit.contain,
    ),
    context: context,
  );
}

showLoadingDialog() {
  return Get.dialog(
    AlertDialog(
      content: Row(
        children: const [
          CircularProgressIndicator(),
          SizedBox(width: 20),
          Text("Loading..."),
        ],
      ),
    ),
  );
}

logOutDialog() {
  return Get.dialog(
    AlertDialog(
      title: const Text("Connfirm"),
      content: const Text("Are you sure you want to logout?"),
      actions: [
        TextButton(
          child: const Text("Yes"),
          onPressed: () {
            Get.offAll(
              const SplashScreen(
                logOut: true,
              ),
            );
          },
        ),
        TextButton(
          child: const Text("No"),
          onPressed: () {
            Get.back();
          },
        )
      ],
    ),
  );
}

convertEpochtoTimeAgo(int epoch) {
// Change the Epoch time to time ago
//   hh:mm AM/PM
//   Yesterday
//   Oct 10
//   Last Year
  var date = DateTime.fromMillisecondsSinceEpoch(epoch);
  var now = DateTime.now();
  var difference = now.difference(date);
  var timeAgo = '';
  if (difference.inSeconds <= 0 ||
      difference.inSeconds > 0 && difference.inMinutes == 0 ||
      difference.inMinutes > 0 && difference.inHours == 0 ||
      difference.inHours > 0 && difference.inDays == 0) {
    // Return HH:MM AM/PM
    timeAgo = DateFormat('hh:mm a').format(date);
  } else if (difference.inDays == 1) {
    timeAgo = 'Yesterday';
  } else if (difference.inDays > 1) {
    if (difference.inDays > 365) {
      timeAgo = (difference.inDays / 365).floor().toString() + ' Years Ago';
    }
    timeAgo = DateFormat('MMM dd').format(date);
  }
  return timeAgo;
}

loadData() async {
  final d = Get.put(DataController());
  final prefs = await SharedPreferences.getInstance();
  final keys = prefs.getKeys();
  for (String key in keys) {
    if (key.startsWith('subject_')) {
      d.subjectQuestion[key.replaceAll('subject_', '')] = json.decode(
        prefs.getString(key)!,
      );
    }
  }
  d.credentials = prefs.getString('userCredentials') != null
      ? UserCredentials.fromJson(
          json.decode(prefs.getString('userCredentials')!))
      : null;
  d.prelogindynamic = prefs.getString('prelogin') != null
      ? json.decode(prefs.getString('prelogin')!)
      : {};
  d.prelogin = d.prelogindynamic.isNotEmpty
      ? PreLogin.fromJson(d.prelogindynamic)
      : null;
  d.update();
}

randomString(int length) {
  String string = "";
  for (var i = 0; i < length; i++) {
    int randomNumber = Random().nextInt(26);
    String randomLetter = String.fromCharCode(97 + randomNumber);
    string += randomLetter;
  }
  return string;
}

logout() async {
  final prefs = await SharedPreferences.getInstance();
  final dController = Get.put(DataController());
  await prefs.clear();
  Get.changeTheme(ThemeData.light());
  await dController.logOut();
}

getLoginData(BuildContext c) async {
  final d = Get.put(DataController());
  try {
    var response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'mode': 'refresh',
        'email': d.credentials!.email,
        'token': d.credentials!.token,
      },
    );
    Get.back();
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['error']["code"] == '#200') {
        final prefs = await SharedPreferences.getInstance();
        data['data']['email'] = d.credentials!.email;
        data['data']['password'] = d.credentials!.password;
        await prefs.setString(
          'userCredentials',
          jsonEncode(data['data']),
        );
        await prefs.setString('subjects', jsonEncode(data['data']['subjects']));
      } else {
        showErrorDialog(c, data['error']['description']);
      }
    } else {
      showErrorDialog(c, 'Something went wrong');
    }
  } catch (e) {
    showErrorDialog(c, e.toString());
  }
}

getLogin(
    String jsonMap, String email, String pass, BuildContext context) async {
  var data = jsonDecode(jsonMap);
  if (data['error']["code"] == '#200') {
    final prefs = await SharedPreferences.getInstance();
    data['data']['email'] = email;
    data['data']['password'] = pass;
    await prefs.setString(
      'userCredentials',
      jsonEncode(data['data']),
    );
    Get.offAll(const OnBoardingPage());
  } else {
    showErrorDialog(context, data['error']['description']);
  }
}
