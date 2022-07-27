import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/controllers/ad_controller.dart';
import 'package:frontendforever/controllers/data_controller.dart';
import 'package:frontendforever/functions.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import 'package:neopop/neopop.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetRewards extends StatefulWidget {
  const GetRewards({Key? key}) : super(key: key);

  @override
  State<GetRewards> createState() => _GetRewardsState();
}

class _GetRewardsState extends State<GetRewards> {
  final dc = Get.put(DataController());
  final ac = Get.put(AdController());
  RewardedAd? rewardedAd;
  bool isLoading = false;
  loadRewardedAd() {
    setState(() {
      isLoading = true;
    });
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
                setState(() {});
              },
              onAdWillDismissFullScreenContent: (ad) {
                ad.dispose();
                rewardedAd = null;
                setState(() {});
              },
            );
            rewardedAd = ad;
            isLoading = false;
            setState(() {});
          },
          onAdFailedToLoad: (err) {
            print('Failed to load a rewarded ad: ${err.message}');
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(int.parse(dc.prelogin!.theme.primary)),
        title: const Text("Get Rewards"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
          },
        ),
        actions: [
          GetBuilder(
            init: DataController(),
            builder: (c) {
              return pointsBuilder(context, c);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 20),
              Center(
                child: CachedNetworkImage(
                  imageUrl: webUrl + dc.prelogindynamic['assets']['ad'],
                  width: 200,
                  height: 200,
                ),
              ),
              const SizedBox(height: 20),
              NeoPopButton(
                color: Color(int.parse(dc.prelogin!.theme.primary)),
                onTapUp: () async {
                  if (rewardedAd == null) {
                    await loadRewardedAd();
                  } else {
                    rewardedAd?.show(onUserEarnedReward: (_, reward) async {
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setInt('gemCount', dc.gemCount + 10);
                      Dialogs.bottomMaterialDialog(
                        context: context,
                        lottieBuilder: LottieBuilder.asset(
                          "assets/json/success.json",
                          height: 100,
                          width: 100,
                          repeat: false,
                        ),
                        title: "Gems Received",
                        msg:
                            "You got 10 gems for watching the ad! You now have ${dc.gemCount + 10} gems.",
                        actions: [
                          IconsOutlineButton(
                            onPressed: () {
                              Get.back();
                            },
                            text: "Close",
                            iconData: Icons.cancel_outlined,
                          ),
                          IconsOutlineButton(
                            onPressed: () {
                              Get.back();
                            },
                            text: "Done",
                            iconData: Icons.check_outlined,
                          ),
                        ],
                      );
                      dc.gemCount = dc.gemCount + 10;
                      dc.update();
                      rewardedAd = null;
                      setState(() {});
                    });
                  }
                },
                onTapDown: () => HapticFeedback.vibrate(),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  child: isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              "Loading",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          ],
                        )
                      : rewardedAd != null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  "Watch Ad",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.movie_outlined,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Load Ad",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                CachedNetworkImage(
                                  imageUrl: webUrl +
                                      dc.prelogindynamic['assets']['load'],
                                  width: 20,
                                  color: Colors.white,
                                  height: 20,
                                ),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "After seeing the advertisement you will get 10 gems",
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 10),
              Text(
                "Usages of Gems:",
                style: Theme.of(context).textTheme.headline6,
              ),
              const SizedBox(height: 10),
              const Text(
                "     1. You can purchase Premium E-Books",
                style: TextStyle(fontSize: 15),
              ),
              const Text(
                "     2. You can get access to our codes",
                style: TextStyle(fontSize: 15),
              ),
              const Text(
                "     3. You can personalize your profile page",
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
