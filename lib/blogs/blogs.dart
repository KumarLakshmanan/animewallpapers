import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontendforever/blogs/single_blog.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/controllers/ad_controller.dart';

import 'package:frontendforever/functions.dart';
import 'package:frontendforever/models/single_blog.dart';
import 'package:frontendforever/shimmer/restaurant_shimmer.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class CodesList extends StatefulWidget {
  const CodesList({
    Key? key,
  }) : super(key: key);
  @override
  State<CodesList> createState() => _CodesListState();
}

class _CodesListState extends State<CodesList>
    with AutomaticKeepAliveClientMixin<CodesList> {
  @override
  bool get wantKeepAlive => true;

  bool isOpen = true;
  bool loaded = false;
  List<SingleBlog> codes = [];
  TextEditingController searchText = TextEditingController(text: '');
  int pageNo = 1;
  final ScrollController _scrollController = ScrollController();

  getDataFromAPI() async {
    var response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'mode': 'getcourses',
        'page': pageNo.toString(),
      },
    );
    if (kDebugMode) {
      print(apiUrl + "?mode=getcourses" + "&page=" + pageNo.toString());
    }
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['error']['code'] == '#200') {
        if (pageNo == 1) {
          codes = [];
        }
        for (var i = 0; i < data['data'].length; i++) {
          codes.add(SingleBlog.fromJson(data['data'][i]));
        }
        if (data['data'].length < 10) {
          loaded = true;
        }
        setState(() {});
      } else {
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
      child: RefreshIndicator(
        onRefresh: () async {
          pageNo = 1;
          codes = [];
          setState(() {});
          await getDataFromAPI();
        },
        child: ListView(
          controller: _scrollController,
          children: [
            for (var i = 0; i < codes.length; i++)
              SingleBlogItem(
                code: codes[i],
              ),
            if (!loaded) const RestaurantShimmer(),
          ],
        ),
      ),
    );
  }
}

class SingleBlogItem extends StatefulWidget {
  const SingleBlogItem({Key? key, required this.code}) : super(key: key);
  final SingleBlog code;

  @override
  State<SingleBlogItem> createState() => _SingleBlogItemState();
}

class _SingleBlogItemState extends State<SingleBlogItem> {
  final ac = Get.put(AdController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () async {
          await Get.to(
            SingleBlogScreen(book: widget.code),
            transition: Transition.rightToLeft,
          );
          if (ac.interstitialAd != null) {
            ac.interstitialAd?.show();
          } else {
            ac.loadInterstitialAd();
          }
        },
        child: Ink(
          height: 300,
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
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(
                      child: CachedNetworkImage(
                        imageUrl:
                            '${webUrl}uploads/images/${widget.code.images[0]}',
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
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0xFF444857),
                          borderRadius: BorderRadius.all(
                            Radius.circular(6),
                          ),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              "assets/icons/explore.png",
                              height: 14,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF444857),
                      borderRadius: BorderRadius.all(
                        Radius.circular(6),
                      ),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/icons/eye.png",
                          height: 10,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.code.views.toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF444857),
                      borderRadius: BorderRadius.all(
                        Radius.circular(6),
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd MMMM yyyy').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  widget.code.createdAt)),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
