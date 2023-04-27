import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdHelper {
  static String get appOpenAds {
    if (Platform.isAndroid) {
      return 'ca-app-pub-1100799750663761/9669008513';
    } else if (Platform.isIOS) {
      return '<YOUR_IOS_BANNER_AD_UNIT_ID>';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAds {
    if (Platform.isAndroid) {
      return 'ca-app-pub-1100799750663761/5402460445';
    } else if (Platform.isIOS) {
      return '<YOUR_IOS_INTERSTITIAL_AD_UNIT_ID>';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get bannerAds {
    if (Platform.isAndroid) {
      return 'ca-app-pub-1100799750663761/2776297105';
    } else if (Platform.isIOS) {
      return '<YOUR_IOS_INTERSTITIAL_AD_UNIT_ID>';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}

class AdController extends GetxController {
  InterstitialAd? interstitialAd;

  loadInterstitialAd() async {
    if (!kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      int adUnitId = prefs.getInt("showedInterstitialAds") ?? 0;
      if (adUnitId == 0) {
        InterstitialAd.load(
          adUnitId: AdHelper.interstitialAds,
          request: const AdRequest(),
          adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded: (ad) {
              ad.fullScreenContentCallback = FullScreenContentCallback(
                onAdDismissedFullScreenContent: (ad) {
                  interstitialAd = null;
                  ad.dispose();
                  Get.back();
                  update();
                },
              );
              interstitialAd = ad;
              update();
            },
            onAdFailedToLoad: (err) {
              if (kDebugMode) {
                print('Failed to load an interstitial ad: ${err.message}');
              }
            },
          ),
        );
        prefs.setInt("showedInterstitialAds", 2);
      } else {
        prefs.setInt("showedInterstitialAds", adUnitId - 1);
      }
    } else {
      interstitialAd = null;
    }
  }
}
