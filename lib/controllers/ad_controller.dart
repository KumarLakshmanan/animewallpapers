import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdHelper {
  static String get appOpenAds {
    if (Platform.isAndroid) {
      return 'ca-app-pub-1100799750663761/5320199386';
    } else if (Platform.isIOS) {
      return '<YOUR_IOS_BANNER_AD_UNIT_ID>';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAds {
    if (Platform.isAndroid) {
      return 'ca-app-pub-1100799750663761/1064463448';
    } else if (Platform.isIOS) {
      return '<YOUR_IOS_INTERSTITIAL_AD_UNIT_ID>';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get rewaredAds {
    if (Platform.isAndroid) {
      return 'ca-app-pub-1100799750663761/8863062414';
    } else if (Platform.isIOS) {
      return '<YOUR_IOS_INTERSTITIAL_AD_UNIT_ID>';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get bannerAds {
    if (Platform.isAndroid) {
      return 'ca-app-pub-1100799750663761/3610735737';
    } else if (Platform.isIOS) {
      return '<YOUR_IOS_INTERSTITIAL_AD_UNIT_ID>';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get nativeAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-1100799750663761/3133019741';
    } else if (Platform.isIOS) {
      return '<YOUR_IOS_NATIVE_AD_UNIT_ID>';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}

class AdController extends GetxController {
  InterstitialAd? interstitialAd;
  bool isPro = false;
  @override
  void onInit() {
    super.onInit();
    loadPro();
  }

  loadPro() async {
    final prefs = await SharedPreferences.getInstance();
    isPro = prefs.getBool("isVip") ?? false;
    update();
  }

  loadInterstitialAd() async {
    if (!kIsWeb) {
      if (interstitialAd.runtimeType == Null) {
        final prefs = await SharedPreferences.getInstance();
        int adUnitId = prefs.getInt("showInterstitialAds") ?? 0;
        if (kDebugMode) {
          print("You are Pro: $isPro");
        }
        if (interstitialAd == null && adUnitId == 0) {
          if (!isPro) {
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
                  if (adUnitId <= 0) {
                    prefs.setInt("showInterstitialAds", 3);
                  } else {
                    prefs.setInt("showInterstitialAds", adUnitId - 1);
                  }
                  update();
                },
                onAdFailedToLoad: (err) {
                  if (kDebugMode) {
                    print('Failed to load an interstitial ad: ${err.message}');
                  }
                },
              ),
            );
          }
        } else {
          if (adUnitId != 0) {
            prefs.setInt("showInterstitialAds", adUnitId - 1);
          }
        }
      }
    } else {
      interstitialAd = null;
    }
  }
}
