import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainScreenController extends GetxController {
  int tabIndex = 0;

  dynamic credentials = {};
  final PageController pageViewController = PageController();
  final GlobalKey<ScaffoldState> mainScaffoldKey = GlobalKey<ScaffoldState>();
  void changeTabIndex(int index) {
    tabIndex = index;
    update();
  }

  void changePage(int index) {
    pageViewController.jumpToPage(
      index,
    );
  }
}
