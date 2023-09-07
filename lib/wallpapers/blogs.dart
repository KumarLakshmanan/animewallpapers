import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/functions.dart';
import 'package:frontendforever/models/single_blog.dart';
import 'package:frontendforever/shimmer/restaurant_shimmer.dart';
import 'package:frontendforever/wallpapers/single_blog_item.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class CodesList extends StatefulWidget {
  const CodesList({
    Key? key,
  }) : super(key: key);
  @override
  State<CodesList> createState() => _CodesListState();
}

class _CodesListState extends State<CodesList> with WidgetsBindingObserver {
  bool loaded = false;
  bool loading = false;
  List<ImageType> codes = [];
  TextEditingController searchText = TextEditingController(text: '');
  int pageNo = 1;
  final ScrollController _scrollController = ScrollController();
  String search = "";
  String categories = "";
  final controller = TextEditingController();
  final searchFocusNode = FocusNode();

  getDataFromAPI() async {
    if (loading) {
      return;
    }
    loading = true;
    var response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'mode': 'getAllImages',
        'category': "random",
        'page': pageNo.toString(),
        'search': search,
        'keyword': categories,
      },
    );
    if (kDebugMode) {
      print(
          "$apiUrl?mode=getAllImages&page=$pageNo&search=$search&keyword=$categories");
    }
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['error']['code'] == '#200') {
        if (pageNo == 1) {
          codes = [];
        }
        for (var i = 0; i < data['data'].length; i++) {
          codes.add(ImageType.fromJson(data['data'][i]));
        }
        if (data['data'].length < 10) {
          loaded = true;
        }
        pageNo++;
        loading = false;
        setState(() {});
      } else {
        // ignore: use_build_context_synchronously
        showErrorDialog(context, data['error']['description']);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () async {
      getDataFromAPI();
    });
    _scrollController.addListener(() {
      if ((_scrollController.position.pixels + 0) >=
          (_scrollController.position.maxScrollExtent)) {
        getDataFromAPI();
      }
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        pageNo = 1;
        codes = [];
        loaded = false;
        getDataFromAPI();
        setState(() {});
      },
      child: Builder(builder: (context) {
        if (codes.isNotEmpty || !loaded) {
          return Padding(
            padding: const EdgeInsets.only(
              left: 8.0,
              right: 8.0,
            ),
            child: MasonryGridView(
              controller: _scrollController,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: Get.width > 350 ? 3 : 2,
              ),
              children: [
                for (var i = 0; i < codes.length; i++) ...[
                  SingleBlogItem(
                    code: codes[i],
                  ),
                ],
                if (!loaded) ...[
                  const WallpaperShimmer(),
                  const WallpaperShimmer(),
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
      }),
    );
  }
}
