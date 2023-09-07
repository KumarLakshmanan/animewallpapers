import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontendforever/wallpapers/single_blog.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/controllers/ad_controller.dart';
import 'package:frontendforever/models/single_blog.dart';
import 'package:get/get.dart';

class SingleBlogItem extends StatefulWidget {
  const SingleBlogItem({Key? key, required this.code}) : super(key: key);
  final ImageType code;

  @override
  State<SingleBlogItem> createState() => _SingleBlogItemState();
}

class _SingleBlogItemState extends State<SingleBlogItem> {
  final ac = Get.put(AdController());

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await Get.to(
          () => SingleBlogScreen(book: widget.code),
          transition: Transition.rightToLeft,
        );
        if (ac.interstitialAd != null) {
          ac.interstitialAd?.show();
        } else {
          ac.loadInterstitialAd();
        }
      },
      child: Ink(
        height: (Get.width * (Get.width > 350 ? 0.33 : 0.5)) * 2,
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
                          imageUrl: widget.code.thumb,
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
                          padding: const EdgeInsets.all(6),
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
                                  size: 13,
                                )
                              : Image.asset(
                                  "assets/icons/explore.png",
                                  height: 12,
                                  color: Colors.white,
                                ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 5),
              ],
            );
          },
        ),
      ),
    );
  }
}
