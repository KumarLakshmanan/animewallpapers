import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:animewallpapers/pages/favorite.dart';
import 'package:animewallpapers/screens/splash_screen.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeDrawer extends StatefulWidget {
  const HomeDrawer({Key? key}) : super(key: key);

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
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
            "Anime Wallpapers",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          accountEmail: const Text(
            "More than 30k+ Anime Wallpapers in your pocket",
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
            maxLines: 2,
          ),
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
              () => const FavoriteList(),
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
              "Anime Wallpapers. \nMore than 100+ tools with installation and usage steps are available in this app. \n\nhttps://play.google.com/store/apps/details?id=in.codingfrontend.animewallpapers",
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
                'https://play.google.com/store/apps/details?id=in.codingfrontend.animewallpapers',
              ),
              mode: LaunchMode.externalApplication,
            );
            Get.back();
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
