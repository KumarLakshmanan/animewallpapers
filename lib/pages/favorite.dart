import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/models/single_blog.dart';
import 'package:frontendforever/shimmer/restaurant_shimmer.dart';
import 'package:frontendforever/wallpapers/single_blog_item.dart';
import 'package:frontendforever/widgets/banner_ad.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteList extends StatefulWidget {
  const FavoriteList({
    Key? key,
  }) : super(key: key);
  @override
  State<FavoriteList> createState() => _FavoriteListState();
}

class _FavoriteListState extends State<FavoriteList> {
  bool isOpen = true;
  bool loaded = false;
  List<ImageType> codes = [];
  TextEditingController searchText = TextEditingController(text: '');
  String sortBy = 'createat';
  bool isAscending = true;
  int pageNo = 1;
  final ScrollController _scrollController = ScrollController();

  getDataFromAPI() async {
    final prefs = await SharedPreferences.getInstance();
    var prefsList = prefs.getKeys();
    codes = [];
    for (var i = 0; i < prefsList.length; i++) {
      if (prefsList.elementAt(i).toString().contains('favorites_')) {
        var data = prefs.getString(prefsList.elementAt(i).toString()) ?? '';
        var favoriteList = json.decode(data) as Map<String, dynamic>;
        codes.add(ImageType.fromJson(favoriteList));
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getDataFromAPI();
  }

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: secondaryColor,
        appBar: AppBar(
          backgroundColor: appBarColor,
          title: const Text(
            "Favorite",
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            const BannerAdWidget(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(8.0),
                controller: _scrollController,
                children: [
                  if (codes.isEmpty) ...[
                    const WallpaperShimmer(),
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        "No Favorite Found",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                  for (var i = 0; i < codes.length; i++) ...[
                    SingleBlogItem(
                      code: codes[i],
                    ),
                    const SizedBox(height: 10),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
