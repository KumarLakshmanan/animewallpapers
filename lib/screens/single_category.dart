import 'package:animewallpapers/controllers/data_controller.dart';
import 'package:animewallpapers/shimmer/restaurant_shimmer.dart';
import 'package:animewallpapers/wallpapers/single_blog_item.dart';
import 'package:flutter/material.dart';
import 'package:animewallpapers/constants.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

class SingleCategory extends StatefulWidget {
  final String category;
  const SingleCategory({Key? key, required this.category}) : super(key: key);

  @override
  State<SingleCategory> createState() => _SingleCategoryState();
}

class _SingleCategoryState extends State<SingleCategory> {
  int clickCount = 0;

  final ScrollController _scrollController = ScrollController();
  final controller = TextEditingController();
  final searchFocusNode = FocusNode();
  final dc = Get.put(DataController());

  @override
  void initState() {
    dc.codes = [];
    dc.loaded = false;
    super.initState();
    dc.getDataFromAPI(
      scategory: widget.category,
    );
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          (_scrollController.position.maxScrollExtent)) {
        dc.getDataFromAPI(
          scategory: widget.category,
        );
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
    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        centerTitle: true,
        title: Text(
          widget.category,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          dc.codes = [];
          dc.loaded = false;
          dc.getDataFromAPI();
          dc.update();
        },
        child: GetBuilder(
          init: DataController(),
          builder: (dc) {
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
                    const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                children: [
                  const SizedBox(height: 2),
                  const SizedBox(height: 2),
                  for (var i = 0; i < dc.codes.length; i++) ...[
                    SingleBlogItem(
                      index: i,
                    ),
                  ],
                  if (!dc.loaded) ...[
                    for (var i = 0; i < 2; i++) const WallpaperShimmer(),
                  ],
                  if (dc.codes.isEmpty) ...[
                    for (var i = 0; i < 2; i++) const WallpaperShimmer(),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
