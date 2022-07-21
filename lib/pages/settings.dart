import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontendforever/controllers/data_controller.dart';
import 'package:frontendforever/functions.dart';
import 'package:get/get.dart';
import 'package:neopop/widgets/buttons/neopop_button/neopop_button.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
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
    return  Scaffold(
        body: ListView(
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: NeoPopButton(
            color: Color(int.parse(d.prelogin!.theme.primary)),
            onTapUp: () {
              logOutDialog(context);
            },
            onTapDown: () => HapticFeedback.vibrate(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
    ));
  }
}
