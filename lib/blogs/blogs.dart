import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontendforever/blogs/single_blog.dart';
import 'package:frontendforever/constants.dart';

import 'package:frontendforever/functions.dart';
import 'package:frontendforever/models/single_blog.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    final prefs = await SharedPreferences.getInstance();
    var response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'mode': 'getcourses',
        'page': pageNo.toString(),
      },
    );
    print(apiUrl + "?mode=getposts" + "&page=" + pageNo.toString());
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['error']['code'] == '#200') {
        if (pageNo == 1) {
          codes = [];
        }
        for (var i = 0; i < data['data'].length; i++) {
          codes.add(SingleBlog.fromJson(data['data'][i]));
        }
        loaded = true;
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
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: RefreshIndicator(
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
              if (!loaded)
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: codes.isEmpty
                      ? MediaQuery.of(context).size.height * 0.75
                      : 30,
                  child: const Center(
                    child: SizedBox(
                      child: CircularProgressIndicator(),
                      height: 30,
                      width: 30,
                    ),
                  ),
                ),
              if (!loaded)
                const Text(
                  'Loading...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
            ],
          ),
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
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: GestureDetector(
        onTap: () {
          Get.to(
            SingleBlogScreen(book: widget.code),
            transition: Transition.rightToLeft,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 3),
                blurRadius: 12,
              ),
            ],
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                child: Stack(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 150,
                      child: PinchZoom(
                        child: Hero(
                          tag: widget.code.images[0],
                          child: CachedNetworkImage(
                            imageUrl: webUrl +
                                'uploads/images/' +
                                widget.code.images[0],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: SizedBox(
                                child: CircularProgressIndicator(),
                                height: 30,
                                width: 30,
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
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: secondaryColor,
                        ),
                        child: Text(
                          DateFormat('dd MMMM yyyy').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  widget.code.createdAt)),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 5,
                      right: 5,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: secondaryColor,
                        ),
                        child: Row(
                          children: [
                            Text(
                              NumberFormat.compact().format(widget.code.views),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Image.asset(
                                "assets/icons/fire.png",
                                height: 15,
                                width: 15,
                                fit: BoxFit.contain,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.code.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
