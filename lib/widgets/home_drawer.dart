import 'package:flutter/material.dart';
import 'package:frontendforever/screens/feedback.dart';
import 'package:frontendforever/screens/payment.dart';
import 'package:get/get.dart';

import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeDrawer extends StatefulWidget {
  const HomeDrawer({Key? key}) : super(key: key);

  @override
  _HomeDrawerState createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        ListTile(
          // donate
          leading: const Icon(
            Icons.favorite,
            color: Colors.black,
          ),
          title: const Text('Donate Us'),
          onTap: () async {
            Get.to(
              const PaymentScreen(),
              transition: Transition.rightToLeft,
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
              "Termux Tools & Commandsn. \nMore than 100+ tools with installation and usage steps are available in this app. \n\nhttps://play.google.com/store/apps/details?id=com.frontendforever.termux",
            );
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.star,
            color: Colors.black,
          ),
          title: const Text('Rate us'),
          onTap: () async {
            await launch(
              'https://play.google.com/store/apps/details?id=com.frontendforever.termux',
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
      ],
    );
  }
}
