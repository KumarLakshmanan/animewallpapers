import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/controllers/ad_controller.dart';
import 'package:frontendforever/models/single_blog.dart';
import 'package:frontendforever/shimmer/restaurant_shimmer.dart';
import 'package:frontendforever/wallpapers/single_blog.dart';
import 'package:frontendforever/widgets/banner_ad.dart';
import 'package:frontendforever/widgets/on_tap_scale.dart';
import 'package:get/get.dart';
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

  final ac = Get.put(AdController());

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
              child: MasonryGridView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: Get.width > 350 ? 3 : 2,
                ),
                children: [
                  if (codes.isEmpty) ...[
                    const WallpaperShimmer(),
                    const WallpaperShimmer(),
                    const WallpaperShimmer(),
                  ],
                  for (var i = 0; i < codes.length; i++) ...[
                    OnTapScale(
                      onTap: () async {
                        await Get.to(
                          () => SingleBlogScreen(book: codes[i]),
                          transition: Transition.rightToLeft,
                        );
                        getDataFromAPI();
                        if (ac.interstitialAd != null) {
                          ac.interstitialAd?.show();
                        } else {
                          ac.loadInterstitialAd();
                        }
                      },
                      child: Ink(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: appBarColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            CachedNetworkImage(
                              imageUrl: codes[i].thumb,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Center(
                                child: SizedBox(
                                  height: (Get.width *
                                          (Get.width > 350 ? 0.33 : 0.5)) *
                                      1.5,
                                  child: Image.asset(
                                    "assets/icons/logo_nobg.png",
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Center(
                                child: Icon(
                                  Icons.error,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF444857),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(6),
                                  ),
                                ),
                                child:
                                    (codes[i].status != "public" && !ac.isPro)
                                        ? const Icon(
                                            Icons.lock_outline,
                                            color: Colors.white,
                                            size: 16,
                                          )
                                        : Image.asset(
                                            "assets/icons/explore.png",
                                            height: 12,
                                            color: Colors.white,
                                          ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
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
