import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:animewallpapers/controllers/premium_controller.dart';
import 'package:animewallpapers/shimmer/restaurant_shimmer.dart';
import 'package:animewallpapers/constants.dart';
import 'package:animewallpapers/wallpapers/premium_categories.dart';
import 'package:animewallpapers/wallpapers/single_blog_item.dart';
import 'package:get/get.dart';

class PremiumList extends StatefulWidget {
  const PremiumList({Key? key}) : super(key: key);

  @override
  State<PremiumList> createState() => _PremiumListState();
}

class _PremiumListState extends State<PremiumList>
    with SingleTickerProviderStateMixin {
  late AnimationController menuAnimation;
  bool isOpened = false;
  final ScrollController _scrollController = ScrollController();
  final controller = TextEditingController();
  final searchFocusNode = FocusNode();
  final pc = Get.put(PremiumController());

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if ((_scrollController.position.pixels + (Get.width)) >=
          (_scrollController.position.maxScrollExtent)) {
        pc.getDataFromAPI();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        centerTitle: true,
        title: const Text(
          'Premium Wallpapers',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          const PremiumCategoriesListView(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                pc.pageNo = 1;
                pc.codes = [];
                pc.loaded = false;
                pc.getDataFromAPI();
                pc.update();
              },
              child: GetBuilder(
                init: PremiumController(),
                builder: (dc) {
                  if (pc.codes.isNotEmpty || !pc.loaded) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        left: 8.0,
                        right: 8.0,
                      ),
                      child: MasonryGridView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        gridDelegate:
                            SliverSimpleGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: Get.width > 350 ? 3 : 2,
                        ),
                        children: [
                          for (var i = 0; i < pc.codes.length; i++) ...[
                            SingleBlogItem(
                              code: pc.codes[i],
                            ),
                          ],
                          if (!pc.loaded) ...[
                            for (var i = 0; i < 6; i++)
                              const WallpaperShimmer(),
                          ],
                        ],
                      ),
                    );
                  } else {
                    return ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height:
                                (Get.width * (Get.width > 350 ? 0.33 : 0.5)) *
                                    2,
                            width: (Get.width),
                            child: const Row(
                              children: [
                                Expanded(child: WallpaperShimmer()),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(child: WallpaperShimmer()),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(child: WallpaperShimmer()),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "No Wallpapers Found",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        )
                      ],
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
