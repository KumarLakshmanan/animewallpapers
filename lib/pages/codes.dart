import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontendforever/api.dart';
import 'package:frontendforever/controllers/data_controller.dart';
import 'package:frontendforever/functions.dart';
import 'package:frontendforever/types/single_blog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class CodesList extends StatefulWidget {
  const CodesList({
    Key? key,
    required this.title,
  }) : super(key: key);
  final String title;
  @override
  State<CodesList> createState() => _CodesListState();
}

class _CodesListState extends State<CodesList>
    with AutomaticKeepAliveClientMixin<CodesList> {
  @override
  bool get wantKeepAlive => true;

  final DataController c = Get.put(DataController());
  bool isOpen = true;
  List<SingleBlog> codes = [];
  String searchText = '';
  String sortBy = '';
  bool isAscending = true;
  int pageNo = 1;
  final ScrollController _scrollController = ScrollController();

  getDataFromAPI() async {
    final prefs = await SharedPreferences.getInstance();
    var codesData = prefs.getString('codesData') ?? '[]';
    var codesList = json.decode(codesData) as List<dynamic>;
    setState(() {
      codes = codesList.map((e) => SingleBlog.fromJson(e)).toList();
    });
    var response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'mode': 'getposts',
        'email': c.credentials!.email,
        'token': c.credentials!.token,
        'page': pageNo.toString(),
      },
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['error']['code'] == '#200') {
        if (data['data'].length == 0) {
          _scrollController.removeListener(() {
            if (_scrollController.position.pixels ==
                _scrollController.position.maxScrollExtent) {
              pageNo++;
              getDataFromAPI();
            }
          });
        }
        for (var i = 0; i < data['data'].length; i++) {
          if (!codes.any((e) => e.id == data['data'][i]['id'])) {
            codes.add(SingleBlog.fromJson(data['data'][i]));
          }
        }
        prefs.setString('codesData', json.encode(codes));
        codes = await searchIdCard(searchText);
        setState(() {});
      } else {
        showErrorDialog(context, data['error']['description']);
      }
    }
  }

  searchIdCard(String value) async {
    List<SingleBlog> myList = [];
    final prefs = await SharedPreferences.getInstance();
    var codesData = prefs.getString('codesData') ?? '[]';
    var codesList = json.decode(codesData) as List<dynamic>;
    for (var i = 0; i < codesList.length; i++) {
      myList.add(SingleBlog.fromJson(codesList[i]));
    }
    List<SingleBlog> tempList = [];
    for (var i = 0; i < myList.length; i++) {
      if (myList[i].title.toLowerCase().contains(value.toLowerCase())) {
        tempList.add(myList[i]);
      }
      if (myList[i].content.toLowerCase().contains(value.toLowerCase())) {
        if (tempList.where((e) => e.id == myList[i].id).isEmpty) {
          tempList.add(myList[i]);
        }
      }
    }
    if (sortBy == "title") {
      tempList.sort((a, b) => a.title.compareTo(b.title));
    } else if (sortBy == "createat") {
      tempList.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else if (sortBy == "views") {
      tempList.sort((a, b) => a.views.compareTo(b.views));
    }
    if (!isAscending) {
      return tempList.reversed.toList();
    }
    return tempList;
  }

  filterListBox(String key, String text) {
    return ListTile(
      minLeadingWidth: 0,
      contentPadding: EdgeInsets.zero,
      leading: sortBy == key
          ? isAscending
              ? CachedNetworkImage(
                  imageUrl: webUrl + c.prelogindynamic['assets']['sort_asc'],
                  width: 20,
                  height: 20,
                  color: Color(
                    int.parse(c.prelogin!.theme.primary),
                  ),
                )
              : CachedNetworkImage(
                  imageUrl: webUrl + c.prelogindynamic['assets']['sort_desc'],
                  width: 20,
                  height: 20,
                  color: Color(
                    int.parse(c.prelogin!.theme.primary),
                  ),
                )
          : const SizedBox(
              width: 10,
            ),
      title: Text(text),
      onTap: () async {
        isAscending = !isAscending;
        sortBy = key;
        codes = await searchIdCard(searchText);
        Get.back();
        setState(() {});
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getDataFromAPI();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        pageNo++;
        getDataFromAPI();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: Color(
          int.parse(c.prelogin!.theme.background),
        ),
        body: Container(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 10, right: 10),
                margin: const EdgeInsets.only(
                  bottom: 10,
                  left: 10,
                  right: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (value) async {
                          searchText = value.toLowerCase();
                          codes = await searchIdCard(searchText);
                          setState(() {});
                        },
                        decoration: const InputDecoration(
                          filled: false,
                          hintText: "Search",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      child: Icon(
                        Icons.search,
                        color: Color(
                          int.parse(c.prelogin!.theme.primary),
                        ),
                      ),
                    ),
                    GestureDetector(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CachedNetworkImage(
                          imageUrl:
                              webUrl + c.prelogindynamic['assets']['filter'],
                          height: 25,
                          color: Color(
                            int.parse(c.prelogin!.theme.primary),
                          ),
                          width: 25,
                          fit: BoxFit.contain,
                        ),
                      ),
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        Get.dialog(
                          AlertDialog(
                            title: const Text("Sort by"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                filterListBox("author", "Author Name"),
                                filterListBox("views", "Views Count"),
                                filterListBox("createat", "Created Date"),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: codes.length,
                  controller: _scrollController,
                  itemBuilder: (context, index) {
                    return SingleBlogItem(code: codes[index]);
                  },
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
  final c = Get.find<DataController>();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: GestureDetector(
        onTap: () {},
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
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                child: Stack(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: CachedNetworkImage(
                        imageUrl:
                            webUrl + 'uploads/images/' + widget.code.thumb,
                        fit: BoxFit.cover,
                      ),
                      height: 200,
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Color(
                            int.parse(c.prelogin!.theme.secondary),
                          ),
                        ),
                        child: Text(
                          DateFormat('dd MMMM yyyy').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  widget.code.createdAt)),
                          style: TextStyle(
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
                          color: Color(
                            int.parse(c.prelogin!.theme.bottombaractive),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              NumberFormat.compact().format(widget.code.views),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: CachedNetworkImage(
                                imageUrl: webUrl +
                                    c.prelogindynamic['assets']['fire'],
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
                        fontFamily: GoogleFonts.nunito().fontFamily,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      widget.code.content,
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.person,
                          size: 14,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          widget.code.username,
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Wrap(
                      spacing: 2,
                      runSpacing: 2,
                      children: widget.code.keywords
                          .map((keyword) => Chip(
                                backgroundColor: Color(
                                  int.parse(c.prelogin!.theme.secondary),
                                ),
                                label: Text(
                                  keyword,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ))
                          .toList(),
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
