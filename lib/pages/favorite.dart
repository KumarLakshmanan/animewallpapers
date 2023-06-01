import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontendforever/blogs/single_blog.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/controllers/ad_controller.dart';
import 'package:frontendforever/models/single_blog.dart';
import 'package:frontendforever/shimmer/restaurant_shimmer.dart';
import 'package:get/get.dart';
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
                    FavoriteItem(
                      code: codes[i],
                      reloader: () async {
                        await getDataFromAPI();
                      },
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

class FavoriteItem extends StatefulWidget {
  const FavoriteItem({
    Key? key,
    required this.code,
    required this.reloader,
  }) : super(key: key);
  final SingleBlog code;
  final Function reloader;

  @override
  State<FavoriteItem> createState() => _FavoriteItemState();
}

class _FavoriteItemState extends State<FavoriteItem> {
  final ac = Get.find<AdController>();
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await Get.to(
          SingleBlogScreen(book: widget.code),
          transition: Transition.rightToLeft,
        );
        if (ac.interstitialAd != null) {
          ac.interstitialAd?.show();
        } else {
          ac.loadInterstitialAd();
        }
      },
      child: Ink(
        height: 200,
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: appBarColor,
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: CachedNetworkImage(
                      imageUrl:
                          '${webUrl}uploads/images/${widget.code.images[0]}',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                        child: SizedBox(
                          height: 100,
                          width: 100,
                          child: Image.asset(
                            "assets/logo_nobg.png",
                            fit: BoxFit.contain,
                            color: Colors.black.withOpacity(0.4),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(
                          Icons.error,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFF444857),
                        borderRadius: BorderRadius.all(
                          Radius.circular(6),
                        ),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/icons/explore.png",
                            height: 14,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.code.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
