import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontendforever/blogs/blogs.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/controllers/ad_controller.dart';
import 'package:frontendforever/models/single_blog.dart';
import 'package:frontendforever/shimmer/restaurant_shimmer.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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
  List<SingleBlog> codes = [];
  TextEditingController searchText = TextEditingController(text: '');
  String sortBy = 'createat';
  bool isAscending = true;
  int pageNo = 1;
  final ScrollController _scrollController = ScrollController();
  BannerAd? bannerAd;

  getDataFromAPI() async {
    final prefs = await SharedPreferences.getInstance();
    var prefsList = prefs.getKeys();
    codes = [];
    for (var i = 0; i < prefsList.length; i++) {
      if (prefsList.elementAt(i).toString().contains('favorites_')) {
        var data = prefs.getString(prefsList.elementAt(i).toString()) ?? '';
        var favoriteList = json.decode(data) as Map<String, dynamic>;
        codes.add(SingleBlog.fromJson(favoriteList));
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getDataFromAPI();
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
          if (kDebugMode) {
            print('Failed to load a banner ad: ${err.message}');
          }
          ad.dispose();
        },
      ),
    ).load();
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
            if (bannerAd != null)
              Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: bannerAd!.size.width.toDouble(),
                  height: bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: bannerAd!),
                ),
              ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(8.0),
                controller: _scrollController,
                children: [
                  if (codes.isEmpty) ...[
                    const RestaurantShimmer(),
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
                      // reloader: () async {
                      //   await getDataFromAPI();
                      // },
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
