import 'dart:convert';
import 'dart:ui';
import 'package:animewallpapers/controllers/ad_controller.dart';
import 'package:animewallpapers/screens/pagementpage.dart';
import 'package:animewallpapers/screens/single_category.dart';
import 'package:animewallpapers/widgets/on_tap_scale.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:animewallpapers/functions.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:animewallpapers/constants.dart';
import 'package:animewallpapers/widgets/home_drawer.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  final bool show;
  const MainScreen({Key? key, this.show = false}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  bool isOpened = false;
  final ac = Get.put(AdController());
  List categories = [];
  bool loading = true;
  CarouselController pageController = CarouselController();
  int currentPage = 0;

  @override
  initState() {
    super.initState();
    if (!kDebugMode) {
      InAppUpdate.checkForUpdate().then((value) {
        if (value.updateAvailability == UpdateAvailability.updateAvailable) {
          InAppUpdate.startFlexibleUpdate();
        }
      });
    }
    getAndroidRegId();
    getCategoriesFromAPI();
  }

  getCategoriesFromAPI() async {
    final prefs = await SharedPreferences.getInstance();
    String allCategories = prefs.getString('allCategoriesV2') ?? '';
    if (allCategories.isNotEmpty) {
      categories = jsonDecode(allCategories);
      loading = false;
      setState(() {});
    }
    var response = await http.post(
      Uri.parse(apiUrl),
      body: {'mode': 'getAllCategories'},
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['error']['code'] == '#200') {
        categories = data['data'];
        prefs.setString('allCategoriesV2', json.encode(categories));
        loading = false;
        setState(() {});
      }
    }
  }

  int clickCount = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      drawer: Drawer(
        backgroundColor: secondaryColor,
        child: const HomeDrawer(),
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        titleSpacing: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        title: GestureDetector(
          onTap: () async {
            clickCount++;
            if (clickCount > 10) {
              final prefs = await SharedPreferences.getInstance();
              ac.isPro = true;
              ac.update();
              prefs.setBool("isVip", true);
              Get.closeAllSnackbars();
              Get.snackbar(
                "Pro Unlocked",
                "You can use pro features now",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: secondaryColor,
                colorText: Colors.white,
              );
            }
          },
          child: const Text(
            'Anime Wallpapers',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          GetBuilder(
            init: AdController(),
            builder: (ac) {
              if (ac.isPro) {
                return const SizedBox();
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  OnTapScale(
                    onTap: () {
                      Get.to(
                        () => const PurchasePage(),
                        transition: Transition.rightToLeft,
                      );
                    },
                    child: Container(
                      height: 30,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        color: cherryColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.yellow,
                            size: 18,
                          ),
                          SizedBox(width: 5),
                          Text(
                            "Get PRO",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: categories.isEmpty
          ? const SizedBox()
          : Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: categories[currentPage]['thumb'],
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: -100,
                  left: -100,
                  right: -100,
                  bottom: -100,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 1.2,
                      width: MediaQuery.of(context).size.width * 1.2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.2),
                            Colors.black.withOpacity(0.2),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height:
                          kToolbarHeight + MediaQuery.of(context).padding.top,
                    ),
                    Divider(
                      color: Colors.white.withOpacity(0.5),
                      height: 1.5,
                    ),
                    Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      height: 50,
                      child: Stack(
                        children: [
                          for (var i = 0; i < categories.length; i++) ...[
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 500),
                              left: 0,
                              right: 0,
                              bottom: currentPage == i ? 0 : -50,
                              child: Text(
                                categories[i]['category']
                                    .toString()
                                    .toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Expanded(
                      child: CarouselSlider(
                        options: CarouselOptions(
                          onPageChanged: (index, reason) {
                            currentPage = index;
                            setState(() {});
                          },
                          height: MediaQuery.of(context).size.height -
                              160 -
                              kToolbarHeight,
                          enlargeCenterPage: true,
                          enlargeFactor: 0.2,
                          viewportFraction: 0.8,
                          enableInfiniteScroll: false,
                        ),
                        carouselController: pageController,
                        items: [
                          for (var i = 0; i < categories.length; i++) ...[
                            GestureDetector(
                              onTap: () async {
                                await Get.to(
                                  SingleCategory(
                                    category: categories[i]['category'],
                                  ),
                                  transition: Transition.rightToLeft,
                                );
                                if (ac.interstitialAd != null) {
                                  ac.interstitialAd?.show();
                                } else {
                                  ac.loadInterstitialAd();
                                }
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color.fromRGBO(100, 100, 111, 0.2),
                                      blurRadius: 29,
                                      offset: Offset(0, 7),
                                    ),
                                  ],
                                  image: DecorationImage(
                                    image: CachedNetworkImageProvider(
                                      categories[i]['thumb'],
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    const Spacer(),
                                    if (categories[i]['image'].runtimeType ==
                                            String &&
                                        categories[i]['image']
                                            .toString()
                                            .isNotEmpty) ...[
                                      CachedNetworkImage(
                                        imageUrl: categories[i]['image'],
                                        width: 100,
                                        height: 100,
                                      ),
                                    ],
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(30),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "${categories[i]['count']} WALLPAPERS",
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
