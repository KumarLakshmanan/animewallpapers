import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/functions.dart';
import 'package:frontendforever/models/single_blog.dart';
import 'package:frontendforever/shimmer/restaurant_shimmer.dart';
import 'package:frontendforever/wallpapers/single_blog_item.dart';
import 'package:frontendforever/widgets/inline_ad.dart';
import 'package:http/http.dart' as http;

class PremiumList extends StatefulWidget {
  const PremiumList({
    Key? key,
  }) : super(key: key);
  @override
  State<PremiumList> createState() => _PremiumListState();
}

class _PremiumListState extends State<PremiumList>
    with AutomaticKeepAliveClientMixin<PremiumList> {
  @override
  bool get wantKeepAlive => true;

  bool isOpen = true;
  bool loaded = false;
  List<ImageType> codes = [];
  TextEditingController searchText = TextEditingController(text: '');
  int pageNo = 1;
  final ScrollController _scrollController = ScrollController();
  final controller = TextEditingController();
  final searchFocusNode = FocusNode();

  getDataFromAPI() async {
    var response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'mode': 'getpremiumcourses',
        'page': pageNo.toString(),
      },
    );
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
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        pageNo++;
        getDataFromAPI();
      }
    });
  }

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: secondaryColor,
        appBar: AppBar(
          title: const Text(
            'Premium Courses',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            pageNo = 1;
            codes = [];
            loaded = false;
            getDataFromAPI();
            setState(() {});
          },
          child: ListView(
            controller: _scrollController,
            children: [
              for (var i = 0; i < codes.length; i++) ...[
                SingleBlogItem(
                  code: codes[i],
                ),
                if (i % 5 == 0) ...[
                  const InlineAdWidget(),
                ]
              ],
              if (!loaded) ...[
                if (codes.isEmpty) const WallpaperShimmer(),
                const WallpaperShimmer(),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
