import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_initicon/flutter_initicon.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/screens/feeback.dart';
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
          decoration:
              BoxDecoration(color: Color(int.parse(d.prelogin!.theme.primary))),
          currentAccountPicture: Stack(
            children: <Widget>[
              d.credentials!.photo == ""
                  ? Initicon(
                      text: d.credentials!.name,
                      elevation: 2,
                      backgroundColor:
                          Color(int.parse(d.prelogin!.theme.secondary)),
                      size: 60,
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: CachedNetworkImage(
                        imageUrl: d.credentials!.photo,
                        fit: BoxFit.cover,
                        height: 60,
                        width: 60,
                        placeholder: (context, url) => Initicon(
                          text: d.credentials!.name,
                          elevation: 2,
                          backgroundColor:
                              Color(int.parse(d.prelogin!.theme.secondary)),
                          size: 60,
                        ),
                        errorWidget: (context, url, error) => Initicon(
                          text: d.credentials!.name,
                          elevation: 2,
                          backgroundColor:
                              Color(int.parse(d.prelogin!.theme.secondary)),
                          size: 60,
                        ),
                      ),
                    ),
            ],
          ),
          accountName: Text(d.credentials!.name),
          accountEmail: Text(d.credentials!.email),
        ),
        // Get Pro version
        ListTile(
          leading: CachedNetworkImage(
            imageUrl: webUrl + d.prelogindynamic['assets']['royal'],
            width: 22,
            height: 22,
          ),
          title: const Text('Get Pro Version'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
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
            Get.to(
              const FeedbackScreen(),
              transition: Transition.rightToLeft,
            );
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
