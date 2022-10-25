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
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Termux Tools & Commands',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      theme: ThemeData(
        primarySwatch: createMaterialColor(const Color(0xFF395B64)),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.openSans(
            textStyle: Theme.of(context).textTheme.displayLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          displayMedium: GoogleFonts.openSans(
            textStyle: Theme.of(context).textTheme.displayMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          displaySmall: GoogleFonts.openSans(
            textStyle: Theme.of(context).textTheme.displaySmall!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          headlineLarge: GoogleFonts.openSans(
            textStyle: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          headlineMedium: GoogleFonts.openSans(
            textStyle: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          headlineSmall: GoogleFonts.openSans(
            textStyle: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          titleLarge: GoogleFonts.openSans(
            textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          titleMedium: GoogleFonts.openSans(
            textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          titleSmall: GoogleFonts.openSans(
            textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          bodyLarge: GoogleFonts.ubuntuCondensed(
            textStyle: Theme.of(context).textTheme.bodyLarge,
          ),
          bodyMedium: GoogleFonts.ubuntuCondensed(
            textStyle: Theme.of(context).textTheme.bodyMedium,
          ),
          bodySmall: GoogleFonts.ubuntuCondensed(
            textStyle: Theme.of(context).textTheme.bodySmall,
          ),
          labelLarge: GoogleFonts.ubuntuCondensed(
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          labelMedium: GoogleFonts.ubuntuCondensed(
            textStyle: Theme.of(context).textTheme.labelMedium,
          ),
          labelSmall: GoogleFonts.ubuntuCondensed(
            textStyle: Theme.of(context).textTheme.labelSmall,
          ),
        ),
        primaryColor: const Color(0xFF395B64),
        fontFamily: GoogleFonts.ubuntuCondensed().fontFamily,
      ),
    );
  }
}
