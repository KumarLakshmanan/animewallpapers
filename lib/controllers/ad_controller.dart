import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdHelper {
   static String get appOpenAds {
    if (Platform.isAndroid) {
      return 'ca-app-pub-1100799750663761/8828708402';
    } else if (Platform.isIOS) {
      return '<YOUR_IOS_BANNER_AD_UNIT_ID>';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

   static String get blogListAds {
    if (Platform.isAndroid) {
      return 'ca-app-pub-1100799750663761/6394116755';
    } else if (Platform.isIOS) {
      return '<YOUR_IOS_BANNER_AD_UNIT_ID>';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

   static String get bookListAds {
    if (Platform.isAndroid) {
      return 'ca-app-pub-1100799750663761/3767953414';
    } else if (Platform.isIOS) {
      return '<YOUR_IOS_BANNER_AD_UNIT_ID>';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

   static String get openBookAds {
    if (Platform.isAndroid) {
      return 'ca-app-pub-1100799750663761/3183545776';
    } else if (Platform.isIOS) {
      return '<YOUR_IOS_BANNER_AD_UNIT_ID>';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get openCodeAds {
    if (Platform.isAndroid) {
      return 'ca-app-pub-1100799750663761/4151096791';
    } else if (Platform.isIOS) {
      return '<YOUR_IOS_BANNER_AD_UNIT_ID>';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get runDownloadAds {
    if (Platform.isAndroid) {
      return 'ca-app-pub-1100799750663761/3959525102';
    } else if (Platform.isIOS) {
      return '<YOUR_IOS_INTERSTITIAL_AD_UNIT_ID>';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
  static String get interstitialAds {
    if (Platform.isAndroid) {
      return 'ca-app-pub-1100799750663761/5372663214';
    } else if (Platform.isIOS) {
      return '<YOUR_IOS_INTERSTITIAL_AD_UNIT_ID>';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}

// class AdHelper {
//   static String get appOpenAds {
//     if (Platform.isAndroid) {
//       return 'ca-app-pub-3940256099942544/3419835294';
//     } else if (Platform.isIOS) {
//       return '<YOUR_IOS_BANNER_AD_UNIT_ID>';
//     } else {
//       throw UnsupportedError('Unsupported platform');
//     }
//   }

//   static String get blogListAds {
//     if (Platform.isAndroid) {
//       return 'ca-app-pub-3940256099942544/2247696110';
//     } else if (Platform.isIOS) {
//       return '<YOUR_IOS_BANNER_AD_UNIT_ID>';
//     } else {
//       throw UnsupportedError('Unsupported platform');
//     }
//   }

//   static String get bookListAds {
//     if (Platform.isAndroid) {
//       return 'ca-app-pub-3940256099942544/2247696110';
//     } else if (Platform.isIOS) {
//       return '<YOUR_IOS_BANNER_AD_UNIT_ID>';
//     } else {
//       throw UnsupportedError('Unsupported platform');
//     }
//   }

//   static String get openBookAds {
//     if (Platform.isAndroid) {
//       return 'ca-app-pub-3940256099942544/5224354917';
//     } else if (Platform.isIOS) {
//       return '<YOUR_IOS_BANNER_AD_UNIT_ID>';
//     } else {
//       throw UnsupportedError('Unsupported platform');
//     }
//   }

//   static String get openCodeAds {
//     if (Platform.isAndroid) {
//       return 'ca-app-pub-3940256099942544/5224354917';
//     } else if (Platform.isIOS) {
//       return '<YOUR_IOS_BANNER_AD_UNIT_ID>';
//     } else {
//       throw UnsupportedError('Unsupported platform');
//     }
//   }

//   static String get runDownloadAds {
//     if (Platform.isAndroid) {
//       return 'ca-app-pub-3940256099942544/5354046379';
//     } else if (Platform.isIOS) {
//       return '<YOUR_IOS_INTERSTITIAL_AD_UNIT_ID>';
//     } else {
//       throw UnsupportedError('Unsupported platform');
//     }
//   }

//   static String get interstitialAds {
//     if (Platform.isAndroid) {
//       return 'ca-app-pub-3940256099942544/1033173712';
//     } else if (Platform.isIOS) {
//       return '<YOUR_IOS_INTERSTITIAL_AD_UNIT_ID>';
//     } else {
//       throw UnsupportedError('Unsupported platform');
//     }
//   }
// }

class AdController extends GetxController {
  InterstitialAd? interstitialAd;
  RewardedAd? rewardedAd;

  loadInterstitialAd() async {
    if (!kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      int adUnitId = prefs.getInt("showedInterstitialAds") ?? 0;
      print("==================================");
      print("adUnitId: $adUnitId");
      print("==================================");
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
              print('Failed to load an interstitial ad: ${err.message}');
            },
          ),
        );
        prefs.setInt("showedInterstitialAds", 1);
      } else {
        prefs.setInt("showedInterstitialAds", adUnitId - 1);
      }
    } else {
      interstitialAd = null;
    }
  }

  loadRewardedAd() {
    if (!kIsWeb) {
      RewardedAd.load(
        adUnitId: AdHelper.openCodeAds,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                rewardedAd = null;
                loadRewardedAd();
                update();
              },
            );
            rewardedAd = ad;
            update();
          },
          onAdFailedToLoad: (err) {
            print('Failed to load a rewarded ad: ${err.message}');
          },
        ),
      );
    }
  }
}
