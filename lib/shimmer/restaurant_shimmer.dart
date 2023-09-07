import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class WallpaperShimmer extends StatelessWidget {
  const WallpaperShimmer({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: (Get.width * (Get.width > 350 ? 0.33 : 0.5)) * 2,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Shimmer(
              duration: const Duration(seconds: 2),
              enabled: true,
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(6),
                  ),
                  color: Color(0xFF444857),
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Shimmer(
                duration: const Duration(seconds: 2),
                enabled: true,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(6),
                    ),
                    color: Color(0xFF444857),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Shimmer(
                    duration: const Duration(seconds: 2),
                    enabled: true,
                    child: Container(
                      width: (Get.width > 350
                              ? Get.width * 0.33
                              : Get.width * 0.5) -
                          40 -
                          16,
                      height: 10,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(6),
                        ),
                        color: Color(0xFF444857),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Shimmer(
                    duration: const Duration(seconds: 2),
                    enabled: true,
                    child: Container(
                      height: 6,
                      width: (Get.width > 350
                              ? Get.width * 0.33
                              : Get.width * 0.5) -
                          40 -
                          46,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(6),
                        ),
                        color: Color(0xFF444857),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
