import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_initicon/flutter_initicon.dart';
import 'package:get/get.dart';
import 'package:frontendforever/controllers/data_controller.dart';
import 'package:frontendforever/functions.dart';
import 'package:neopop/neopop.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final d = Get.find<DataController>();
  PackageInfo? packageInfo;

  @override
  void initState() {
    super.initState();
    initPackageInfo();
  }

  Future<void> initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          const SizedBox(height: 20),
          Center(
            child: d.credentials!.photo == ""
                ? Initicon(
                    text: d.credentials!.name,
                    elevation: 2,
                    backgroundColor:
                        Color(int.parse(d.prelogin!.theme.secondary)),
                    size: 120,
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: CachedNetworkImage(
                      imageUrl: d.credentials!.photo,
                      fit: BoxFit.cover,
                      height: 120,
                      width: 120,
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
          ),
          const SizedBox(height: 5),
          Center(
            child: Text(
              "@" + d.credentials!.username,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(int.parse(d.prelogin!.theme.primary)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: Icon(Icons.person),
            subtitle: Text('Name'),
            title: Text(d.credentials!.name),
            trailing: Icon(Icons.edit),
            onTap: () {
              // Get.to(
              //   EditField(
              //     field: 'name',
              //   ),
              //   transition: Transition.rightToLeft,
              // );
            },
          ),
          ListTile(
            leading: Icon(Icons.email),
            subtitle: Text('Email'),
            title: Text(d.credentials!.email),
            trailing: Icon(Icons.edit),
            onTap: () {
              // Get.to(
              //   EditField(
              //     field: 'name',
              //   ),
              //   transition: Transition.rightToLeft,
              // );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: NeoPopButton(
              color: Color(int.parse(d.prelogin!.theme.primary)),
              onTapUp: () {
                logOutDialog();
              },
              onTapDown: () => HapticFeedback.vibrate(),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "Logout",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          packageInfo != null
              ? Text(
                  'Version: ' +
                      packageInfo!.version +
                      "+" +
                      packageInfo!.buildNumber,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(int.parse(d.prelogin!.theme.primary)),
                  ),
                  textAlign: TextAlign.center,
                )
              : Container(),
        ],
      ),
    );
  }
}

Widget _infoTile(String title, String subtitle) {
  return ListTile(
    title: Text(title),
    subtitle: Text(subtitle.isEmpty ? 'Not set' : subtitle),
  );
}
