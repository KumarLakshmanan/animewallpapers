import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontendforever/blogs/premium.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/pages/favorite.dart';
import 'package:frontendforever/screens/feedback.dart';
import 'package:frontendforever/screens/pagementpage.dart';
import 'package:frontendforever/screens/splash_screen.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeDrawer extends StatefulWidget {
  const HomeDrawer({Key? key}) : super(key: key);

  @override
  _HomeDrawerState createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  PackageInfo? packageInfo;
  @override
  void initState() {
    super.initState();
    initPackageInfo();
  }

  bool? alreadyPaid;

  initPackageInfo() async {
    final prefs = await SharedPreferences.getInstance();
    alreadyPaid = prefs.getBool('isVip') ?? false;
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        UserAccountsDrawerHeader(
          currentAccountPicture: CircleAvatar(
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.asset(
                  "assets/icons/applogo.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          accountName: const Text(
            "Termux Tools & Commands",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          accountEmail: const Text(
            "com.frontendforever.termux",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ),
        if (alreadyPaid == null || alreadyPaid == false) ...[
          ListTile(
            leading: Container(
              height: 20,
              width: 20,
              alignment: Alignment.center,
              child: Image.asset(
                'assets/icons/vip.png',
                height: 20,
                width: 20,
                color: Colors.white,
              ),
            ),
            title: const Text(
              'Premium Membership',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            onTap: () async {
              Get.back();
              Get.to(
                const PurchasePage(),
                transition: Transition.rightToLeft,
              );
            },
          ),
        ],
        ListTile(
          leading: const Icon(
            Icons.book_sharp,
            color: Colors.white,
            size: 20,
          ),
          title: Row(
            children: [
              const Text(
                'Premium Tools',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              if (alreadyPaid == null || alreadyPaid == false) ...[
                const SizedBox(
                  width: 5,
                ),
                const Icon(
                  Icons.lock_outline,
                  color: Colors.white,
                  size: 12,
                ),
              ]
            ],
          ),
          onTap: () async {
            if (alreadyPaid == null || alreadyPaid == false) {
              Get.snackbar(
                "Upgrade to Premium",
                "You can only able to access this content after upgrading to premium.",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: secondaryColor,
                colorText: Colors.white,
              );
            } else {
              Get.back();
              Get.to(
                const PremiumList(),
                transition: Transition.rightToLeft,
              );
            }
          },
        ),
        ListTile(
          leading: Container(
            height: 20,
            width: 20,
            alignment: Alignment.center,
            child: const Icon(
              Icons.favorite,
              color: Colors.white,
              size: 20,
            ),
          ),
          title: const Text(
            'Favorites',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          onTap: () async {
            Get.back();
            Get.to(
              const FavoriteList(),
              transition: Transition.rightToLeft,
            );
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.person_add,
            color: Colors.white,
          ),
          title: const Text(
            'Share App',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          onTap: () {
            Get.back();
            Share.share(
              "Termux Tools & Commands. \nMore than 100+ tools with installation and usage steps are available in this app. \n\nhttps://play.google.com/store/apps/details?id=com.frontendforever.termux",
            );
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.add_to_photos_sharp,
            color: Colors.white,
          ),
          onTap: () async {
            await launchUrl(
              Uri.parse(
                "https://play.google.com/store/apps/developer?id=Lakshmanan+R",
              ),
              mode: LaunchMode.externalApplication,
            );
          },
          title: const Text(
            "More Apps",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(
            Icons.star,
            color: Colors.white,
          ),
          title: const Text(
            'Rate us',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          onTap: () async {
            await launchUrl(
              Uri.parse(
                'https://play.google.com/store/apps/details?id=com.frontendforever.termux',
              ),
              mode: LaunchMode.externalApplication,
            );
            Get.back();
          },
        ),
        // Help & Feedback
        ListTile(
          leading: const Icon(
            Icons.help,
            color: Colors.white,
          ),
          title: const Text(
            'Help & Feedback',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          onTap: () {
            Get.back();
            Get.to(
              const FeedbackScreen(),
              transition: Transition.rightToLeft,
            );
          },
        ),
        if (kDebugMode)
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            title: const Text(
              'Logout',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            onTap: () async {
              var prefs = await SharedPreferences.getInstance();
              prefs.clear();
              Get.offAll(
                const SplashScreen(),
              );
            },
          ),
        const SizedBox(
          height: 20,
        ),
        if (packageInfo != null)
          Center(
            child: Text(
              "v${packageInfo!.version} (${packageInfo!.buildNumber})",
              style: const TextStyle(
                fontSize: 12.0,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}
