import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontendforever/blogs/blogs.dart';
import 'package:get/get.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/functions.dart';
import 'package:frontendforever/widgets/home_drawer.dart';
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
  @override
  void initState() {
    menuAnimation = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isOpened) {
          menuAnimation.reverse();
          mainController.mainScaffoldKey.currentState!.closeEndDrawer();
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
            onEndDrawerChanged: (bool open) {
              if (open) {
                menuAnimation.forward();
              } else {
                menuAnimation.reverse();
              }
              setState(() {
                isOpened = open;
              });
            },
            endDrawer: const Drawer(child: HomeDrawer()),
            appBar: AppBar(
              elevation: 0,
              actions: const [
                SizedBox(),
              ],
              automaticallyImplyLeading: false,
              backgroundColor: primaryColor,
              leading: IconButton(
                icon: AnimatedIcon(
                  icon: AnimatedIcons.menu_close,
                  color: Colors.white,
                  progress: menuAnimation,
                ),
                onPressed: () {
                  setState(() {
                    mainController.mainScaffoldKey.currentState!
                        .openEndDrawer();
                  });
                },
              ),
            ),
            body: const CodesList(),
          ),
        ),
      ),
    );
  }
}
