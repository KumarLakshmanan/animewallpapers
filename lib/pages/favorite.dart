import 'package:animewallpapers/controllers/favorites_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:animewallpapers/constants.dart';
import 'package:animewallpapers/controllers/ad_controller.dart';
import 'package:animewallpapers/wallpapers/single_blog.dart';
import 'package:animewallpapers/widgets/banner_ad.dart';
import 'package:animewallpapers/widgets/on_tap_scale.dart';
import 'package:get/get.dart';

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
  TextEditingController searchText = TextEditingController(text: '');
  String sortBy = 'createat';
  bool isAscending = true;
  int pageNo = 1;
  final ScrollController _scrollController = ScrollController();

  final ac = Get.put(AdController());
  final fc = Get.put(FavoritesController());

  @override
  void initState() {
    fc.init();
    super.initState();
  }

  @override
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
              child: GetBuilder(
                init: FavoritesController(),
                builder: (fc) {
                  if (fc.favorites.isEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: Get.width),
                        Icon(
                          Icons.favorite_border,
                          color: Colors.white.withOpacity(0.5),
                          size: 100,
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "You did not add any images into your favorite list",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    );
                  }
                  return MasonryGridView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    gridDelegate:
                        const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    children: [
                      for (var i = 0; i < fc.favorites.length; i++) ...[
                        OnTapScale(
                          onTap: () async {
                            await Get.to(
                              () => SingleBlogScreen(
                                type: true,
                                index: i,
                              ),
                              transition: Transition.rightToLeft,
                            );
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
                                  imageUrl: fc.favorites[i].thumb,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Center(
                                    child: SizedBox(
                                      height: (Get.width * 0.5) * 1.5,
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
                                        (fc.favorites[i].status != "public" &&
                                                !ac.isPro)
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
