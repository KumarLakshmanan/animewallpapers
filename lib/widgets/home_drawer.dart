import 'package:flutter/material.dart';
import 'package:frontendforever/screens/feedback.dart';
import 'package:frontendforever/screens/pagementpage.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:share_plus/share_plus.dart';
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

  initPackageInfo() async {
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
        ListTile(
          leading: Container(
            height: 20,
            width: 20,
            alignment: Alignment.center,
            child: Image.asset(
              'assets/icons/heart.png',
              height: 20,
              width: 20,
              color: Colors.black,
            ),
          ),
          title: const Text(
            'Donate Us',
            style: TextStyle(
              fontSize: 14,
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
        ListTile(
          leading: const Icon(
            Icons.person_add,
            color: Colors.black,
          ),
          title: const Text(
            'Invite Friends',
            style: TextStyle(
              fontSize: 14,
            ),
          ),
          onTap: () {
            Get.back();
            Share.share(
              "Termux Tools & Commandsn. \nMore than 100+ tools with installation and usage steps are available in this app. \n\nhttps://play.google.com/store/apps/details?id=com.frontendforever.termux",
            );
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.star,
            color: Colors.black,
          ),
          title: const Text(
            'Rate us',
            style: TextStyle(
              fontSize: 14,
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
            color: Colors.black,
          ),
          title: const Text(
            'Help & Feedback',
            style: TextStyle(
              fontSize: 14,
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
        const SizedBox(
          height: 20,
        ),
        if (packageInfo != null)
          Center(
            child: Text(
              "v${packageInfo!.version} (${packageInfo!.buildNumber})",
              style: const TextStyle(
                fontSize: 12.0,
              ),
            ),
          )
      ],
    );
  }
}
