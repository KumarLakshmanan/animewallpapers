import 'package:flutter/material.dart';
import 'package:animewallpapers/constants.dart';
import 'package:animewallpapers/screens/pagementpage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
