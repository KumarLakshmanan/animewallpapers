import 'package:flutter/material.dart';
import 'package:flutter_initicon/flutter_initicon.dart';
import 'package:get/get.dart';
import 'package:frontendforever/controllers/data_controller.dart';
import 'package:frontendforever/controllers/theme_controller.dart';
import 'package:frontendforever/functions.dart';

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
          decoration: BoxDecoration(
            color: Color(int.parse(d.prelogin!.theme.secondary))
          ),
          currentAccountPicture: Stack(
            children: <Widget>[
              Initicon(
                text: d.credentials!.name,
                elevation: 2,
                backgroundColor:  Color(int.parse(d.prelogin!.theme.primary)),
                size: 60,
              ),
              // Positioned(
              //   bottom: 10,
              //   right: 10,
              //   child: Container(
              //     decoration: BoxDecoration(
              //       color: Colors.yellow,
              //       shape: BoxShape.circle,
              //       border: Border.all(
              //         color: Colors.yellow[900]!,
              //         width: 2,
              //       ),
              //     ),
              //     padding: const EdgeInsets.all(1),
              //     child: Icon(
              //       Icons.star,
              //       size: 14,
              //       color: Colors.yellow[900],
              //     ),
              //   ),
              // ),
            ],
          ),
          accountName: Text(d.credentials!.name),
          accountEmail: Text(d.credentials!.email),
        ),
        // Get Pro version
        ListTile(
          leading: Image.asset(
            'assets/icons/royal.png',
            width: 22,
            height: 22,
          ),
          title: const Text('Get Pro Version'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        // Leaderboard
        // ListTile(
        //   leading: const Icon(
        //     Icons.contact,
        //     color: Colors.black,
        //   ),
        //   title: const Text('Leaderboard'),
        //   onTap: () {
        //     Navigator.pop(context);
        //   },
        // ),
        // ListTile(
        //   leading: const Icon(
        //     Icons.bookmark,
        //     color: Colors.black,
        //   ),
        //   title: const Text('Bookmarks'),
        //   onTap: () {
        //     Navigator.pop(context);
        //   },
        // ),
        // Divider
        // Invite Friends
        ListTile(
          leading: const Icon(
            Icons.person_add,
            color: Colors.black,
          ),
          title: const Text('Invite Friends'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        // Donate us
        ListTile(
          leading: const Icon(
            Icons.attach_money,
            color: Colors.black,
          ),
          title: const Text('Donate us'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        // Rate us
        ListTile(
          leading: const Icon(
            Icons.star,
            color: Colors.black,
          ),
          title: const Text('Rate us'),
          onTap: () {
            Navigator.pop(context);
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
            Navigator.pop(context);
          },
        ),
        // // settinngs
        // ListTile(
        //   leading: const Icon(
        //     Icons.settings,
        //     color: Colors.black,
        //   ),
        //   title: const Text('Settings'),
        //   onTap: () {
        //     Navigator.pop(context);
        //   },
        // ),
        // Logout
        ListTile(
          leading: const Icon(
            Icons.exit_to_app,
            color: Colors.black,
          ),
          title: const Text('Logout'),
          onTap: () {
            logOutDialog();
          },
        ),
      ],
    );
  }
}
