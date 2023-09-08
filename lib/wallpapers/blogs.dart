import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:animewallpapers/controllers/data_controller.dart';
import 'package:animewallpapers/shimmer/restaurant_shimmer.dart';
import 'package:animewallpapers/wallpapers/single_blog_item.dart';
import 'package:get/get.dart';

class CodesList extends StatefulWidget {
  const CodesList({
    Key? key,
  }) : super(key: key);
  @override
  State<CodesList> createState() => _CodesListState();
}

class _CodesListState extends State<CodesList> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  final controller = TextEditingController();
  final searchFocusNode = FocusNode();
  final dc = Get.put(DataController());

  @override
  void initState() {
    super.initState();
    dc.getDataFromAPI();
    _scrollController.addListener(() {
      if ((_scrollController.position.pixels + (Get.width)) >=
          (_scrollController.position.maxScrollExtent)) {
        dc.getDataFromAPI();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        dc.pageNo = 1;
        dc.codes = [];
        dc.loaded = false;
        dc.getDataFromAPI();
        dc.update();
      },
      child: GetBuilder(
        init: DataController(),
        builder: (dc) {
          if (dc.codes.isNotEmpty || !dc.loaded) {
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
                gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: Get.width > 350 ? 3 : 2,
                ),
                children: [
                  for (var i = 0; i < dc.codes.length; i++) ...[
                    SingleBlogItem(
                      code: dc.codes[i],
                    ),
                  ],
                  if (!dc.loaded) ...[
                    for (var i = 0; i < 6; i++) const WallpaperShimmer(),
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
                    height: (Get.width * (Get.width > 350 ? 0.33 : 0.5)) * 2,
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
    );
  }
}
