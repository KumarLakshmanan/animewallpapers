import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:animewallpapers/constants.dart';
import 'package:animewallpapers/notification.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';

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
        textStyle: const TextStyle(color: Colors.grey),
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
        textStyle: const TextStyle(color: Colors.grey),
        iconColor: Colors.grey,
      ),
    ],
  );
}

showLoadingDialog() {
  return Get.dialog(
    const AlertDialog(
      contentPadding: EdgeInsets.all(12),
      content: Row(
        children: [
          SizedBox(
            height: 30,
            width: 30,
            child: CircularProgressIndicator(),
          ),
          SizedBox(width: 20),
          Text(
            "Please Wait...",
          )
        ],
      ),
    ),
    barrierDismissible: false,
  );
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print("Handling a background message from firebase");
    print(message.data);
  }
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
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    String? androidRegId = await firebaseMessaging.getToken();
    await http.get(
      Uri.parse('$apiUrl?mode=saveregid&regid=$androidRegId&version=2'),
    );
    if (kDebugMode) {
      print('Android Reg Id: $androidRegId');
    }
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
      timeAgo = '${difference.inDays} days ago';
    } else if (difference.inDays > 30 && difference.inDays <= 365) {
      timeAgo = '${(difference.inDays / 30).floor()} months ago';
    } else {
      timeAgo = '${(difference.inDays / 365).floor()} years ago';
    }
  }
  return timeAgo;
}

retunHtml(String html) {
  // remove all the styles and attributes from the html string
  html = html.replaceAll(
      RegExp(r'(<p style=")([a-zA-Z0-9:;\.\s\(\)\-\,]*)(")'), '<p>');
  html = html.replaceAll(
      RegExp(r'(<span style=")([a-zA-Z0-9:;\.\s\(\)\-\,]*)(")'), '<span>');
  html = html.replaceAll(
      RegExp(r'(<strong style=")([a-zA-Z0-9:;\.\s\(\)\-\,]*)(")'), '<strong>');
  html = html.replaceAll(
      RegExp(r'(<b style=")([a-zA-Z0-9:;\.\s\(\)\-\,]*)(")'), '<b>');
  html = html.replaceAll(
      RegExp(r'(<i style=")([a-zA-Z0-9:;\.\s\(\)\-\,]*)(")'), '<i>');
  html = html.replaceAll(
      RegExp(r'(<em style=")([a-zA-Z0-9:;\.\s\(\)\-\,]*)(")'), '<em>');
  html = html.replaceAll(
      RegExp(r'(<u style=")([a-zA-Z0-9:;\.\s\(\)\-\,]*)(")'), '<u>');
  html = html.replaceAll(
      RegExp(r'(<strike style=")([a-zA-Z0-9:;\.\s\(\)\-\,]*)(")'), '<strike>');
  html = html.replaceAll(
      RegExp(r'(<a style=")([a-zA-Z0-9:;\.\s\(\)\-\,]*)(")'), '<a>');
  html = html.replaceAll(
      RegExp(r'(<h1 style=")([a-zA-Z0-9:;\.\s\(\)\-\,]*)(")'), '<h1>');
  html = html.replaceAll(
      RegExp(r'(<h2 style=")([a-zA-Z0-9:;\.\s\(\)\-\,]*)(")'), '<h2>');
  html = html.replaceAll(
      RegExp(r'(<h3 style=")([a-zA-Z0-9:;\.\s\(\)\-\,]*)(")'), '<h3>');
  html = html.replaceAll(
      RegExp(r'(<h4 style=")([a-zA-Z0-9:;\.\s\(\)\-\,]*)(")'), '<h4>');
  html = html.replaceAll(
      RegExp(r'(<h5 style=")([a-zA-Z0-9:;\.\s\(\)\-\,]*)(")'), '<h5>');
  html = html.replaceAll(
      RegExp(r'(<h6 style=")([a-zA-Z0-9:;\.\s\(\)\-\,]*)(")'), '<h6>');
  // html = html.replaceAll(
  //     RegExp(r'(<table ([a-z][a-z0-9]*)[^>]*?(/?)>)'), '<table>');
  // html = html.replaceAll(
  //     RegExp(r'(<td style=")([a-zA-Z0-9:;\.\s\(\)\-\,]*)(")'), '<td ');
  // html = html.replaceAll(
  //     RegExp(r'(<tr style=")([a-zA-Z0-9:;\.\s\(\)\-\,]*)(")'), '<tr ');
  // html = html.replaceAll(
  //     RegExp(r'(width=")([a-zA-Z0-9:;\.\s\(\)\-\,]*)(")'), '');
  // html = html.replaceAll(
  //     RegExp(r"(width=')([a-zA-Z0-9:;\.\s\(\)\-\,]*)(')"), '');
  html = html.replaceAll(")(", ") (");
  return html;
}

snackbar(String title, String message) {
  Get.closeCurrentSnackbar();
  Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.BOTTOM,
    animationDuration: const Duration(milliseconds: 300),
    backgroundColor: secondaryColor,
    colorText: Colors.white,
    margin: const EdgeInsets.all(2),
  );
}

convertIntToViews(views) {
  if (views >= 1000000000) {
    return (views / 1000000000).toFixed(1) +
        'B'; // Convert to billions (1 decimal place)
  } else if (views >= 1000000) {
    return (views / 1000000).toFixed(1) +
        'M'; // Convert to millions (1 decimal place)
  } else if (views >= 1000) {
    return (views / 1000).toFixed(1) +
        'K'; // Convert to thousands (1 decimal place)
  } else {
    return views.toString(); // Less than a thousand, no conversion needed
  }
}