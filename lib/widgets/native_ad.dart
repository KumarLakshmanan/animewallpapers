import 'package:flutter/material.dart';
import 'package:animewallpapers/constants.dart';
import 'package:animewallpapers/controllers/ad_controller.dart';

import 'package:animewallpapers/screens/pagementpage.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
