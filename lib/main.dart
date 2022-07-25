import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:frontendforever/functions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'notification.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // notification bar color
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.light,
    ),
  );
  if (!kIsWeb) {
    await Firebase.initializeApp();
    firebaseCloudMessagingListeners();
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    await NotificationService().init();
    await MobileAds.instance.initialize();
    // MobileAds.instance.updateRequestConfiguration(RequestConfiguration(
    //     testDeviceIds: ['35885036-e6bf-437c-b4c0-c33001a3ef4c']));
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Frontend Forever',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      theme: ThemeData(
        primarySwatch: createMaterialColor(const Color(0xFF395B64)),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.sourceSansPro(
            textStyle: Theme.of(context).textTheme.displayLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          displayMedium: GoogleFonts.sourceSansPro(
            textStyle: Theme.of(context).textTheme.displayMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          displaySmall: GoogleFonts.sourceSansPro(
            textStyle: Theme.of(context).textTheme.displaySmall!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          headlineLarge: GoogleFonts.sourceSansPro(
            textStyle: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          headlineMedium: GoogleFonts.sourceSansPro(
            textStyle: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          headlineSmall: GoogleFonts.sourceSansPro(
            textStyle: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          titleLarge: GoogleFonts.sourceSansPro(
            textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          titleMedium: GoogleFonts.sourceSansPro(
            textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          titleSmall: GoogleFonts.sourceSansPro(
            textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          bodyLarge: GoogleFonts.lato(
            textStyle: Theme.of(context).textTheme.bodyLarge,
          ),
          bodyMedium: GoogleFonts.lato(
            textStyle: Theme.of(context).textTheme.bodyMedium,
          ),
          bodySmall: GoogleFonts.lato(
            textStyle: Theme.of(context).textTheme.bodySmall,
          ),
          labelLarge: GoogleFonts.lato(
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          labelMedium: GoogleFonts.lato(
            textStyle: Theme.of(context).textTheme.labelMedium,
          ),
          labelSmall: GoogleFonts.lato(
            textStyle: Theme.of(context).textTheme.labelSmall,
          ),
        ),
        primaryColor: const Color(0xFF395B64),
        fontFamily: GoogleFonts.lato().fontFamily,
      ),
    );
  }
}
