import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/notification.dart';
import 'package:frontendforever/models/single_blog.dart';
import 'package:frontendforever/models/single_book.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:material_dialogs/material_dialogs.dart';
import 'package:frontendforever/screens/splash_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontendforever/models/prelogin.dart';
import 'package:frontendforever/models/user_credentials.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import 'package:url_launcher/url_launcher.dart';

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

showAlertDialog(context, text, {lottie = true}) {
  Dialogs.materialDialog(
    color: Colors.white,
    msg: text,
    title: 'Warning',
    lottieBuilder: lottie
        ? Lottie.asset(
            'assets/json/alert.json',
            repeat: false,
            fit: BoxFit.contain,
          )
        : null,
    context: context,
    titleAlign: TextAlign.center,
    msgAlign: TextAlign.center,
    actions: [
      IconsOutlineButton(
        onPressed: () {
          Get.back();
        },
        text: 'Close',
        iconData: Icons.cancel_outlined,
        textStyle: TextStyle(color: Colors.grey),
        iconColor: Colors.grey,
      ),
    ],
  );
}

showConfirmationDialog(context, text, onTap) {
  Dialogs.bottomMaterialDialog(
    color: Colors.white,
    msg: text,
    title: 'Confirmation Required',
    lottieBuilder: Lottie.asset(
      'assets/json/alert.json',
      repeat: false,
      fit: BoxFit.contain,
    ),
    context: context,
    actions: [
      IconsOutlineButton(
        onPressed: () {
          Get.back();
        },
        text: 'Close',
        iconData: Icons.cancel_outlined,
        textStyle: const TextStyle(color: Colors.grey),
        iconColor: Colors.grey,
      ),
      IconsOutlineButton(
        onPressed: () {
          Get.back();
          onTap();
        },
        text: 'Ok',
        iconData: Icons.check_outlined,
        textStyle: const TextStyle(color: Colors.grey),
        iconColor: Colors.grey,
      ),
    ],
  );
}

showErrorDialog(context, text, {lottie = true}) {
  Dialogs.materialDialog(
    color: Colors.white,
    msg: text,
    titleAlign: TextAlign.center,
    msgAlign: TextAlign.center,
    title: 'Error',
    lottieBuilder: lottie
        ? Lottie.asset(
            'assets/json/error.json',
            repeat: false,
            fit: BoxFit.contain,
          )
        : null,
    context: context,
    actions: [
      IconsOutlineButton(
        onPressed: () {
          Get.back();
        },
        text: 'Close',
        iconData: Icons.cancel_outlined,
        textStyle: TextStyle(color: Colors.grey),
        iconColor: Colors.grey,
      ),
    ],
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

logOutDialog(context) {
  Dialogs.bottomMaterialDialog(
    context: context,
    title: 'Logout',
    msg: 'Are you sure you want to logout?',
    lottieBuilder: Lottie.asset(
      'assets/json/exit.json',
      repeat: false,
      fit: BoxFit.contain,
    ),
    actions: [
      IconsOutlineButton(
        iconData: Icons.cancel_outlined,
        onPressed: () {
          Get.back();
        },
        text: 'Cancel',
      ),
      IconsOutlineButton(
        iconData: Icons.exit_to_app_outlined,
        onPressed: () {
          Get.offAll(
            const SplashScreen(
              logOut: true,
            ),
            transition: Transition.rightToLeft,
          );
        },
        text: 'Logout',
      ),
    ],
  );
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message from firebase");
  print(message.data);
  _messageHandler(message);
}

firebaseCloudMessagingListeners() {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onBackgroundMessage((RemoteMessage message) async {
    _messageHandler(message);
  });
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    _messageHandler(message);
  });
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    _messageHandler(message);
  });
}

Future<void> _messageHandler(RemoteMessage message) async {
  Map<String, dynamic> data = message.data;
  if (kDebugMode) {
    print(data);
  }
  await NotificationService().showNotify(
    body: data,
  );
}

Future<String> getAndroidRegId() async {
  if (!kIsWeb) {
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    String? androidRegId = await _firebaseMessaging.getToken();
    return androidRegId!;
  } else {
    return "";
  }
}

MaterialColor createMaterialColor(Color color) {
  final strengths = <double>[.05];
  final swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (final strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}

int getMilliSecondsTime(dynamic timeInEpoch) {
  if (timeInEpoch is String) {
    timeInEpoch = int.parse(timeInEpoch);
  }
  if (timeInEpoch.toString().length <= 11) {
    return timeInEpoch * 1000;
  } else {
    return timeInEpoch;
  }
}

convertEpochtoTimeAgo(int epoch) {
  epoch = getMilliSecondsTime(epoch);
  var date = DateTime.fromMillisecondsSinceEpoch(epoch);
  var now = DateTime.now();
  var difference = now.difference(date);
  var timeAgo = '';
  if (difference.inSeconds <= 0 ||
      difference.inSeconds > 0 && difference.inMinutes == 0 ||
      difference.inMinutes > 0 && difference.inHours == 0 ||
      difference.inHours > 0 && difference.inDays == 0) {
    timeAgo = DateFormat('hh:mm a').format(date);
  } else if (difference.inDays == 1) {
    timeAgo = 'Yesterday';
  } else {
    if (difference.inDays <= 30) {
      timeAgo = difference.inDays.toString() + ' days ago';
    } else if (difference.inDays > 30 && difference.inDays <= 365) {
      timeAgo = (difference.inDays / 30).floor().toString() + ' months ago';
    } else {
      timeAgo = (difference.inDays / 365).floor().toString() + ' years ago';
    }
  }
  return timeAgo;
}
