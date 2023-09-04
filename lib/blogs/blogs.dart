import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontendforever/blogs/single_blog.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/controllers/ad_controller.dart';

import 'package:frontendforever/functions.dart';
import 'package:frontendforever/models/single_blog.dart';
import 'package:frontendforever/screens/pagementpage.dart';
import 'package:frontendforever/shimmer/restaurant_shimmer.dart';
import 'package:frontendforever/widgets/filter_by.dart';
import 'package:frontendforever/widgets/search.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CodesList extends StatefulWidget {
  const CodesList({
    Key? key,
  }) : super(key: key);
  @override
  State<CodesList> createState() => _CodesListState();
}

class _CodesListState extends State<CodesList> with WidgetsBindingObserver {
  bool isOpen = true;
  bool loaded = false;
  bool inAppAds = false;
  bool paused = false;
  List<SingleBlog> codes = [];
  TextEditingController searchText = TextEditingController(text: '');
  int pageNo = 1;
  final ScrollController _scrollController = ScrollController();
  String search = "";
  String categories = "";
  final controller = TextEditingController();
  final searchFocusNode = FocusNode();

  getDataFromAPI() async {
    var response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'mode': 'getcourses',
        'page': pageNo.toString(),
        'search': search,
        'keyword': categories,
      },
    );
    if (kDebugMode) {
      print(
          "$apiUrl?mode=getcourses&page=$pageNo&search=$search&keyword=$categories");
    }
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['error']['code'] == '#200') {
        if (pageNo == 1) {
          codes = [];
        }
        for (var i = 0; i < data['data'].length; i++) {
          codes.add(SingleBlog.fromJson(data['data'][i]));
        }
        if (data['data'].length < 10) {
          loaded = true;
        }
        setState(() {});
      } else {
        // ignore: use_build_context_synchronously
        showErrorDialog(context, data['error']['description']);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () async {
      getDataFromAPI();
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        pageNo++;
        getDataFromAPI();
      }
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (kDebugMode) {
      print("---------------------------------------------");
      print(state);
      print("---------------------------------------------");
    }
    if (state == AppLifecycleState.paused) {
      paused = true;
    }

    if (state == AppLifecycleState.resumed && !inAppAds && paused) {
      AppOpenAd.load(
        adUnitId: AdHelper.appOpenAds,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            ad.show();
            inAppAds = true;
          },
          onAdFailedToLoad: (error) {},
        ),
        orientation: AppOpenAd.orientationPortrait,
      );
    }
  }

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Column(
        children: [
          Container(
            color: primaryColor,
            child: SearchBox(
              controller: controller,
              searchFocusNode: searchFocusNode,
              onChanged: (_) {
                search = _;
                pageNo = 1;
                codes = [];
                loaded = false;
                getDataFromAPI();
                setState(() {});
              },
            ),
          ),
          Container(
            color: primaryColor,
            child: Column(
              children: [
                FilterBy(
                  onChanged: (_) {
                    categories = _;
                    pageNo = 1;
                    codes = [];
                    loaded = false;
                    getDataFromAPI();
                    setState(() {});
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                pageNo = 1;
                codes = [];
                loaded = false;
                getDataFromAPI();
                setState(() {});
              },
              child: ListView(
                controller: _scrollController,
                children: [
                  for (var i = 0; i < codes.length; i++) ...[
                    SingleBlogItem(
                      code: codes[i],
                    ),
                    if (i % 5 == 0) ...[
                      const InlineAdWidget(),
                    ]
                  ],
                  if (!loaded) ...[
                    if (codes.isEmpty) const RestaurantShimmer(),
                    const RestaurantShimmer(),
                  ]
                ],
              ),
            ),
          ),
          // const BannerAdWidget(),
        ],
      ),
    );
  }
}

class SingleBlogItem extends StatefulWidget {
  const SingleBlogItem({Key? key, required this.code}) : super(key: key);
  final SingleBlog code;

  @override
  State<SingleBlogItem> createState() => _SingleBlogItemState();
}

class _SingleBlogItemState extends State<SingleBlogItem> {
  final ac = Get.put(AdController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
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
          height: 250,
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
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
          child: GetBuilder(
            init: AdController(),
            builder: (ac) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                                height: 150,
                                width: 150,
                                child: Image.asset(
                                  "assets/icons/logo_nobg.png",
                                  fit: BoxFit.contain,
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
                            child: (widget.code.status != "public" && !ac.isPro)
                                ? const Icon(
                                    Icons.lock_outline,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : Image.asset(
                                    "assets/icons/explore.png",
                                    height: 14,
                                    color: Colors.white,
                                  ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (widget.code.status != "public" && !ac.isPro) ...[
                        const Icon(
                          Icons.lock_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 5),
                      ],
                      Expanded(
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
                  const SizedBox(height: 10),
                  Wrap(
                    runAlignment: WrapAlignment.start,
                    alignment: WrapAlignment.start,
                    direction: Axis.horizontal,
                    spacing: 5,
                    children: [
                      for (var i = 0; i < widget.code.keywords.length; i++)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDD0046).withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.code.keywords[i],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF444857),
                          borderRadius: BorderRadius.all(
                            Radius.circular(6),
                          ),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              "assets/icons/eye.png",
                              height: 10,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              NumberFormat.compact().format(widget.code.views),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF444857),
                          borderRadius: BorderRadius.all(
                            Radius.circular(6),
                          ),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              "assets/icons/like.png",
                              height: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              NumberFormat.compact().format(widget.code.likes),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF444857),
                          borderRadius: BorderRadius.all(
                            Radius.circular(6),
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('dd MMMM yyyy').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      widget.code.createdAt)),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class NativeAdWidget extends StatefulWidget {
  const NativeAdWidget({super.key});

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget>
    with AutomaticKeepAliveClientMixin<NativeAdWidget> {
  @override
  bool get wantKeepAlive => true;

  NativeAd? _ad;
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    final prefs = await SharedPreferences.getInstance();
    bool isPro = prefs.getBool("isVip") ?? false;
    if (isPro) {
      return;
    }
    NativeAd(
      adUnitId: AdHelper.nativeAdUnitId,
      factoryId: 'listTile',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _ad = ad as NativeAd;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint(
            'Ad load failed (code=${error.code} message=${error.message})',
          );
        },
      ),
    ).load();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _ad == null
        ? const SizedBox()
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  height: 62,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
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
                  child: AdWidget(ad: _ad!),
                ),
                const SizedBox(height: 5),
                GestureDetector(
                  onTap: () {
                    Get.to(
                      () => const PurchasePage(),
                      transition: Transition.rightToLeft,
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Premium Ad Free Version",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(
                        Icons.double_arrow_rounded,
                        color: Colors.white,
                        size: 12,
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
  }
}

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? bannerAd;
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    final prefs = await SharedPreferences.getInstance();
    bool isPro = prefs.getBool("isVip") ?? false;
    if (!isPro) {
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
  }

  @override
  Widget build(BuildContext context) {
    return bannerAd == null
        ? const SizedBox()
        : Container(
            color: primaryColor,
            child: SizedBox(
              height: 50,
              child: AdWidget(ad: bannerAd!),
            ),
          );
  }
}

class InlineAdWidget extends StatefulWidget {
  const InlineAdWidget({super.key});

  @override
  State<InlineAdWidget> createState() => _InlineAdWidgetState();
}

class _InlineAdWidgetState extends State<InlineAdWidget> {
  bool isPro = true;
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    final prefs = await SharedPreferences.getInstance();
    isPro = prefs.getBool("isVip") ?? false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return isPro
        ? const SizedBox()
        : GestureDetector(
            onTap: () {
              Get.to(
                () => const PurchasePage(),
                transition: Transition.rightToLeft,
              );
            },
            child: Column(
              children: [
                Container(
                  height: 75,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
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
                  child: Row(
                    children: [
                      SizedBox(
                        width: 60,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Image.asset(
                                'assets/icons/logo_nobg.png',
                                height: 50,
                                width: 50,
                                color: Colors.white,
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              left: 0,
                              child: Image.asset(
                                "assets/icons/vip.png",
                                fit: BoxFit.contain,
                                height: 25,
                                width: 25,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Anime Wallpapers",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Expanded(
                              child: Text(
                                "You get the ad free version & more amazing features in the premium version",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Get Premium Version",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(
                      Icons.double_arrow_rounded,
                      color: Colors.white,
                      size: 12,
                    ),
                  ],
                )
              ],
            ),
          );
  }
}
