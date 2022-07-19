import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/notification.dart';
import 'package:frontendforever/screens/pdf.dart';
import 'package:frontendforever/types/single_blog.dart';
import 'package:frontendforever/types/single_book.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:material_dialogs/material_dialogs.dart';
import 'package:frontendforever/controllers/data_controller.dart';
import 'package:frontendforever/screens/onboarding.dart';
import 'package:frontendforever/screens/splash_screen.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontendforever/types/prelogin.dart';
import 'package:frontendforever/types/user_credentials.dart';
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

showErrorDialog(context, text, {lottie = true}) {
  Dialogs.materialDialog(
    color: Colors.white,
    msg: text,
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

logOutDialog() {
  return Get.dialog(
    AlertDialog(
      title: const Text("Confirm"),
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

getLoginData(BuildContext c, {isBack = true}) async {
  final d = Get.put(DataController());
  try {
    var regId = await getAndroidRegId();
    var response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'mode': 'refresh',
        'regid': regId,
        'email': d.credentials!.email,
        'token': d.credentials!.token,
      },
    );
    print(webUrl + '?token=' + d.credentials!.token);
    print(response.body);
    if (isBack) {
      Get.back();
    }
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
        d.credentials = UserCredentials.fromJson(data['data']);
        d.update();
      } else if (data['error']["code"] == '#600') {
        showLogoutDialog(c, data['error']["description"]);
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

showLogoutDialog(BuildContext c, String text) {
  Dialogs.materialDialog(
    barrierDismissible: false,
    context: c,
    lottieBuilder: Lottie.asset(
      'assets/json/error.json',
      repeat: false,
      fit: BoxFit.contain,
    ),
    title: 'Logout',
    msg: text,
    actions: [
      IconsOutlineButton(
        onPressed: () {
          Get.offAll(
            SplashScreen(
              logOut: true,
            ),
            transition: Transition.rightToLeft,
          );
        },
        text: 'Login Again',
        iconData: Icons.login_outlined,
        textStyle: TextStyle(color: Colors.grey),
        iconColor: Colors.grey,
      ),
    ],
  );
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
    Dialogs.materialDialog(
      context: context,
      title: 'Login Successful',
      lottieBuilder: Lottie.asset(
        'assets/json/success.json',
        repeat: false,
        fit: BoxFit.contain,
      ),
      actions: [
        IconsOutlineButton(
          onPressed: () {
            Get.offAll(const OnBoardingPage());
          },
          text: 'Continue',
          iconData: Icons.arrow_forward_outlined,
        ),
      ],
    );
  } else {
    showErrorDialog(context, data['error']['description']);
  }
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

Future downloadBook(SingleBook book, BuildContext context) async {
  try {
    var response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'mode': 'downloadbook',
        'id': book.id.toString(),
        'pdf': book.pdf,
      },
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['error']["code"] == '#200') {
        var dir = await getApplicationDocumentsDirectory();
        var path = dir.path;
        var file = File('$path/${book.title}.pdf');
        // file already there
        if (file.existsSync()) {
          Get.to(
            PdfViewer(
              file: File('${file.path}/${book.title}.pdf'),
              title: book.title,
            ),
            transition: Transition.rightToLeft,
          );
        } else {
          var response = await http.get(Uri.parse(data['data']['url']));

          await NotificationService().showNotify(
            body: {
              'title': book.title,
              'message': 'Your book has been downloaded.',
              'module': 'pdf',
            },
          );
          await file.writeAsBytes(response.bodyBytes);
          Get.to(
            PdfViewer(
              file: File('${file.path}/${book.title}.pdf'),
              title: book.title,
            ),
            transition: Transition.rightToLeft,
          );
        }
      } else {
        await NotificationService().showNotify(
          body: {
            'title': "Error while Downloading Book",
            'message': data['error']['description'],
            'module': 'pdf',
          },
        );
      }
    }
  } catch (e) {
    showErrorDialog(context, e.toString());
  }
}

Future downloadCode(SingleBlog blog, BuildContext context) async {
  try {
    var response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'mode': 'downloadcode',
        'id': blog.id.toString(),
        'title': blog.title,
      },
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['error']["code"] == '#200') {
        await NotificationService().showNotify(
          body: {
            'title': "Code Downloaded",
            'message': "You will be redirected to the code download page.",
            'module': 'code',
          },
        );
        await launch(data['data']['url']);
      } else {
        await NotificationService().showNotify(
          body: {
            'title': "Error while Downloading Book",
            'message': data['error']['description'],
            'module': 'pdf',
          },
        );
      }
    } else {
      await NotificationService().showNotify(
        body: {
          'title': "Error while Downloading Code",
          'message': response.bodyBytes,
          'module': 'pdf',
        },
      );
    }
  } catch (e) {
    showErrorDialog(context, e.toString());
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
