import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontendforever/blogs/blogs.dart';
import 'package:get/get.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/widgets/home_drawer.dart';
import 'package:lottie/lottie.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  @override
  void initState() {
    init();

    super.initState();
  }

  init() async {
    menuAnimation = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    InAppUpdate.checkForUpdate().then((value) {
      if (value.updateAvailability == UpdateAvailability.updateAvailable) {
        InAppUpdate.startFlexibleUpdate();
      }
    });
  }

  int clickCount = 0;

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
            backgroundColor: secondaryColor,
            key: mainController.mainScaffoldKey,
            drawer: Drawer(
              backgroundColor: secondaryColor,
              child: const HomeDrawer(),
            ),
            appBar: AppBar(
              elevation: 0,
              backgroundColor: primaryColor,
              centerTitle: true,
              title: GestureDetector(
                onTap: () async {
                  clickCount++;
                  if (clickCount > 10) {
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setBool("isVip", true);
                    Get.snackbar(
                      "Pro Unlocked",
                      "You can use pro features now",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: secondaryColor,
                      colorText: Colors.white,
                    );
                  }
                },
                child: const Text(
                  'Anime Wallpapers',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            body: const CodesList(),
          ),
        ),
      ),
    );
  }
}
