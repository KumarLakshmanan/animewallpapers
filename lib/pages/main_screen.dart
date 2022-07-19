import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:frontendforever/controllers/data_controller.dart';
import 'package:frontendforever/pages/books.dart';
import 'package:frontendforever/pages/codes.dart';
import 'package:frontendforever/pages/profile.dart';
import 'package:get/get.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/controllers/theme_controller.dart';
import 'package:frontendforever/functions.dart';
import 'package:frontendforever/widgets/home_drawer.dart';
import '../controllers/main_screen_controller.dart';
import '../widgets/bottom_bar.dart';

import 'package:http/http.dart' as http;

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  final MainScreenController mainController = Get.put(MainScreenController());
  final DataController dc = Get.put(DataController());
  late AnimationController menuAnimation;
  bool isOpened = false;
  List people = [];
  @override
  void initState() {
    loadData();
    menuAnimation = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      onSecondaryLongPress: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: mainController.mainScaffoldKey,
        backgroundColor: Color(int.parse(dc.prelogin!.theme.background)),
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
          actions: [
            Container(
              width: 40,
            ),
          ],
          automaticallyImplyLeading: false,
          backgroundColor: Color(int.parse(dc.prelogin!.theme.bottombar)),
          leading: IconButton(
            icon: AnimatedIcon(
              icon: AnimatedIcons.menu_close,
              color: Colors.white,
              progress: menuAnimation,
            ),
            onPressed: () {
              setState(() {
                mainController.mainScaffoldKey.currentState!.openEndDrawer();
              });
            },
          ),
        ),
        body: PageView(
          onPageChanged: (index) {
            FocusScope.of(context).unfocus();
            mainController.changeTabIndex(index);
          },
          controller: mainController.pageViewController,
          children: const [
            CodesList(),
            BooksList(),
            ProfilePage(),
          ],
        ),
        bottomNavigationBar: GetBuilder<MainScreenController>(
          init: MainScreenController(),
          builder: (controller) {
            return CustomBottomBar(
              selectedIndex: controller.tabIndex,
              onItemSelected: (index) {
                controller.changeTabIndex(index);
                controller.changePage(index);
              },
              items: <BottomNavyBarItem>[
                for (var i = 0; i < dc.prelogindynamic['bottombar'].length; i++)
                  BottomNavyBarItem(
                    title: dc.prelogindynamic['bottombar'][i]['title'],
                    icon: CachedNetworkImage(
                      imageUrl:
                          webUrl + dc.prelogindynamic['bottombar'][i]['icon'],
                      width: 25,
                      height: 25,
                      color: controller.tabIndex == i
                          ? Colors.white
                          : Colors.white38,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
