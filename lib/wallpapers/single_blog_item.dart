import 'package:animewallpapers/controllers/data_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:animewallpapers/wallpapers/single_blog.dart';
import 'package:animewallpapers/constants.dart';
import 'package:animewallpapers/controllers/ad_controller.dart';
import 'package:animewallpapers/widgets/on_tap_scale.dart';
import 'package:get/get.dart';

class SingleBlogItem extends StatefulWidget {
  final int index;
  const SingleBlogItem({Key? key, required this.index}) : super(key: key);

  @override
  State<SingleBlogItem> createState() => _SingleBlogItemState();
}

class _SingleBlogItemState extends State<SingleBlogItem> {
  final ac = Get.put(AdController());
  final dc = Get.put(DataController());
  @override
  Widget build(BuildContext context) {
    return OnTapScale(
      onTap: () async {
        dc.codes = [];
        dc.loaded = false;
        dc.update();
        await Get.to(
          () => SingleBlogScreen(
            index: widget.index,
            type: false,
          ),
          transition: Transition.rightToLeft,
        );
        if (ac.interstitialAd != null) {
          ac.interstitialAd?.show();
        } else {
          ac.loadInterstitialAd();
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Container(
          decoration: BoxDecoration(
            color: appBarColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: dc.codes[widget.index].thumb,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: SizedBox(
                    height: ((Get.width * 0.5) *
                            (dc.codes[widget.index].height /
                                dc.codes[widget.index].width)) -
                        24,
                    child: Image.asset(
                      "assets/icons/logo_nobg.png",
                      fit: BoxFit.contain,
                      width: 100,
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => SizedBox(
                  height: ((Get.width * 0.5) *
                          (dc.codes[widget.index].height /
                              dc.codes[widget.index].width)) -
                      24,
                  child: const Center(
                    child: Icon(
                      Icons.error,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFF444857),
                    borderRadius: BorderRadius.all(
                      Radius.circular(6),
                    ),
                  ),
                  child:
                      (dc.codes[widget.index].status != "public" && !ac.isPro)
                          ? const Icon(
                              Icons.lock_outline,
                              color: Colors.white,
                              size: 16,
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
      ),
    );
  }
}
