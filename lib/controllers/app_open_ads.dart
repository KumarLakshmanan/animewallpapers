// import 'package:google_mobile_ads/google_mobile_ads.dart';
// class AppLifecycleReactor {
//   final AppOpenAdManager appOpenAdManager;

//   AppLifecycleReactor({required this.appOpenAdManager});

//   void listenToAppStateChanges() {
//     AppStateEventNotifier.startListening();
//     AppStateEventNotifier.appStateStream
//         .forEach((state) => _onAppStateChanged(state));
//   }

//   void _onAppStateChanged(AppState appState) {
//     // Try to show an app open ad if the app is being resumed and
//     // we're not already showing an app open ad.
//     if (appState == AppState.foreground) {
//       appOpenAdManager.showAdIfAvailable();
//     }
//   }
// }
// /// Utility class that manages loading and showing app open ads.
// class AppOpenAdManager {
//   final Duration maxCacheDuration = Duration(hours: 4);

//   /// Keep track of load time so we don't show an expired ad.
//   DateTime? _appOpenLoadTime;
//   /// Load an AppOpenAd.
//   void loadAd() {
//     AppOpenAd.load(
//       adUnitId: "ca-app-pub-1100799750663761/9669008513",
//       orientation: AppOpenAd.orientationPortrait,
//       adRequest: AdRequest(),
//       adLoadCallback: AppOpenAdLoadCallback(
//         onAdLoaded: (ad) {
//           print('$ad loaded');
//           _appOpenLoadTime = DateTime.now();
//           _appOpenAd = ad;
//         },
//         onAdFailedToLoad: (error) {
//           print('AppOpenAd failed to load: $error');
//         },
//       ),
//     );
//   }

//   /// Shows the ad, if one exists and is not already being shown.
//   ///
//   /// If the previously cached ad has expired, this just loads and caches a
//   /// new ad.
//   void showAdIfAvailable() {
//     if (!isAdAvailable) {
//       print('Tried to show ad before available.');
//       loadAd();
//       return;
//     }
//     if (_isShowingAd) {
//       print('Tried to show ad while already showing an ad.');
//       return;
//     }
//     if (DateTime.now().subtract(maxCacheDuration).isAfter(_appOpenLoadTime!)) {
//       print('Maximum cache duration exceeded. Loading another ad.');
//       _appOpenAd!.dispose();
//       _appOpenAd = null;
//       loadAd();
//       return;
//     }
//     // Set the fullScreenContentCallback and show the ad.
//     _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(...);
//     _appOpenAd!.show();
//   }
// }