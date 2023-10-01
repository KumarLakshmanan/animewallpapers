import 'dart:convert';

import 'package:animewallpapers/models/single_blog.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesController extends GetxController {
  List<ImageType> favorites = [];

  @override
  void onInit() {
    super.onInit();
    init();
  }

  init() async {
    final prefs = await SharedPreferences.getInstance();
    final fav = prefs.getString("favoriteKeyImageType");
    if (fav != null) {
      var favs = jsonDecode(fav);
      favorites = [];
      for (var i in favs) {
        favorites.add(ImageType.fromJson(i));
      }
      favorites = favorites.toSet().toList();
    }
    update();
  }

  save() async {
    final prefs = await SharedPreferences.getInstance();
    favorites = favorites.toSet().toList();
    prefs.setString("favoriteKeyImageType", jsonEncode(favorites));
    update();
  }
}
