import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontendforever/blogs/blogs.dart';
import 'package:frontendforever/controllers/ad_controller.dart';
import 'package:get/get.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/widgets/home_drawer.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import '../controllers/main_screen_controller.dart';

class MainScreen extends StatefulWidget {
  final bool show;
  const MainScreen({Key? key, this.show = false}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  final MainScreenController mainController = Get.put(MainScreenController());
  late AnimationController menuAnimation;
  bool isOpened = false;
  List people = [];

  BannerAd? bannerAd;
  @override
  void initState() {
    menuAnimation = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    InAppUpdate.checkForUpdate().then((value) {
      if (value.updateAvailability == UpdateAvailability.updateAvailable) {
        InAppUpdate.startFlexibleUpdate();
      }
    });
    super.initState();
    BannerAd(
      adUnitId: AdHelper.bannerAds,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    ).load();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (Scaffold.of(context).isDrawerOpen) {
          Scaffold.of(context).closeDrawer();
          isOpened = false;
          return false;
        } else if (mainController.tabIndex != 0) {
          mainController.changePage(0);
          return false;
        } else {
          Dialogs.bottomMaterialDialog(
            color: Colors.white,
            msg: 'Are you sure you want to exit?',
            title: 'Exit',
            lottieBuilder: Lottie.asset(
              'assets/json/exit.json',
              repeat: false,
              fit: BoxFit.contain,
            ),
            context: context,
            actions: [
              IconsOutlineButton(
                onPressed: () {
                  Get.back();
                },
                text: 'Close',
                iconData: Icons.cancel_outlined,
                textStyle: const TextStyle(color: Colors.grey),
                iconColor: Colors.grey,
              ),
              IconsOutlineButton(
                onPressed: () {
                  // exit the app
                  Get.back();
                  SystemNavigator.pop();
                },
                text: 'Exit',
                iconData: Icons.exit_to_app,
                textStyle: const TextStyle(color: Colors.grey),
                iconColor: Colors.grey,
              ),
            ],
          );
          return false;
        }
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        onSecondaryLongPress: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: Scaffold(
            key: mainController.mainScaffoldKey,
            backgroundColor: backgroundColor,
            drawer: const Drawer(child: HomeDrawer()),
            appBar: AppBar(
              elevation: 0,
              backgroundColor: primaryColor,
            ),
            body: Column(
              children: [
                if (bannerAd != null)
                  Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: bannerAd!.size.width.toDouble(),
                      height: bannerAd!.size.height.toDouble(),
                      child: AdWidget(ad: bannerAd!),
                    ),
                  ),
                const Expanded(child: CodesList()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
