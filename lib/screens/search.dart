import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/controllers/data_controller.dart';
import 'package:frontendforever/controllers/main_screen_controller.dart';
import 'package:frontendforever/controllers/theme_controller.dart';
import 'package:frontendforever/types/subject.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  final ThemeController themeController = Get.put(ThemeController());
  final DataController d = Get.put(DataController());
  final MainScreenController mainController = Get.put(MainScreenController());

  @override
  Widget build(BuildContext context) {
    SubTheme subTheme = Get.isDarkMode
        ? themeController.currentTheme.dark
        : themeController.currentTheme.light;
    return Scaffold(
      backgroundColor: subTheme.canvas,
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: subTheme.primary,
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white60,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.black12,
                width: 1,
              ),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: "Search Questions",
                      border: InputBorder.none,
                    ),
                    onEditingComplete: () {},
                  ),
                ),
                const Icon(Icons.search),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
