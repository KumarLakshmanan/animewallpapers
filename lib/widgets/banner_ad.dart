import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/controllers/ad_controller.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
