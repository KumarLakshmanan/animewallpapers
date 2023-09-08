import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animewallpapers/wallpapers/blogs.dart';
import 'package:animewallpapers/wallpapers/categories.dart';
import 'package:animewallpapers/constants.dart';
import 'package:in_app_update/in_app_update.dart';

class SingleCategory extends StatefulWidget {
  final String category;
  const SingleCategory({Key? key, required this.category}) : super(key: key);

  @override
  State<SingleCategory> createState() => _SingleCategoryState();
}

class _SingleCategoryState extends State<SingleCategory> {
  @override
  void initState() {
    init();

    super.initState();
  }

  init() async {
    if (!kDebugMode) {
      InAppUpdate.checkForUpdate().then((value) {
        if (value.updateAvailability == UpdateAvailability.updateAvailable) {
          InAppUpdate.startFlexibleUpdate();
        }
      });
    }
  }

  int clickCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        centerTitle: true,
        title: const Text(
          'Anime Wallpapers',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: const Column(
        children: [
          CategoriesListView(),
          Expanded(
            child: CodesList(),
          ),
        ],
      ),
    );
  }
}
