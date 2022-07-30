import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_initicon/flutter_initicon.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/pages/settings.dart';
import 'package:frontendforever/screens/feedback.dart';
import 'package:frontendforever/screens/getpro.dart';
import 'package:frontendforever/screens/rewards.dart';
import 'package:get/get.dart';
import 'package:frontendforever/controllers/data_controller.dart';
import 'package:frontendforever/controllers/theme_controller.dart';
import 'package:frontendforever/functions.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeDrawer extends StatefulWidget {
  const HomeDrawer({Key? key}) : super(key: key);

  @override
  _HomeDrawerState createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  final d = Get.find<DataController>();
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        UserAccountsDrawerHeader(
          decoration:
              BoxDecoration(color: Color(int.parse(d.prelogin!.theme.primary))),
          currentAccountPicture: Stack(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: CachedNetworkImage(
                  imageUrl: webUrl +
                      "api/avatar.php?username=" +
                      d.credentials!.username,
                  fit: BoxFit.cover,
                  height: 60,
                  width: 60,
                ),
              ),
              if (d.credentials!.pro)
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      color: Colors.yellow,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.yellow[900]!,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: CachedNetworkImage(
                        imageUrl: webUrl + d.prelogindynamic['assets']['royal'],
                        fit: BoxFit.contain,
                        height: 14,
                        width: 14,
                        color: Colors.yellow[900],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          accountName: Text(d.credentials!.name),
          accountEmail: Text(d.credentials!.email),
        ),
        // Get Pro version
        if (!d.credentials!.pro)
          ListTile(
            leading: CachedNetworkImage(
              imageUrl: webUrl + d.prelogindynamic['assets']['royal'],
              width: 22,
              height: 22,
            ),
            title: const Text('Upgrade to VIP'),
            onTap: () async {
              Get.off(
                const GetPro(),
                transition: Transition.rightToLeft,
              );
            },
          ),
        ListTile(
          leading: Image.asset(
            'assets/icons/gem_bw.png',
            width: 22,
            height: 22,
          ),
          title: const Text('Earn Gems'),
          onTap: () {
            Get.back();
            Get.to(
              const GetRewards(),
              transition: Transition.rightToLeft,
            );
          },
        ),
        // Donate us
        ListTile(
          leading: Image.asset(
            'assets/icons/buymecoffee.png',
            width: 25,
            height: 25,
            color: Colors.black,
          ),
          title: const Text('Buy Me a Coffe'),
          onTap: () async {
            Get.back();
            await launch(
              'https://www.buymeacoffee.com/CodingFrontend',
            );
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.person_add,
            color: Colors.black,
          ),
          title: const Text('Invite Friends'),
          onTap: () {
            Get.back();
            Share.share(
              d.prelogindynamic['share_link'],
            );
          },
        ),
        // Rate us
        ListTile(
          leading: const Icon(
            Icons.star,
            color: Colors.black,
          ),
          title: const Text('Rate us'),
          onTap: () async {
            await launch(
              'https://play.google.com/store/apps/details?id=com.frontendforever',
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
          title: const Text('Help & Feedback'),
          onTap: () {
            Get.back();
            Get.to(
              const FeedbackScreen(),
              transition: Transition.rightToLeft,
            );
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.settings,
            color: Colors.black,
          ),
          title: const Text('Settings'),
          onTap: () {
            Get.back();
            Get.to(
              const Settings(),
              transition: Transition.rightToLeft,
            );
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.exit_to_app,
            color: Colors.black,
          ),
          title: const Text('Logout'),
          onTap: () {
            Get.back();
            logOutDialog(context);
          },
        ),
      ],
    );
  }
}
