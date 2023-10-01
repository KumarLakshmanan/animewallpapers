import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class WallpaperShimmer extends StatelessWidget {
  const WallpaperShimmer({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: (Get.width * 0.5) * 2,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
      ),
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
    );
  }
}
