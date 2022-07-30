import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontendforever/blogs/single_blog.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/controllers/data_controller.dart';
import 'package:frontendforever/functions.dart';
import 'package:frontendforever/models/single_blog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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

  final DataController c = Get.put(DataController());
  bool isOpen = true;
  bool loaded = false;
  List<SingleBlog> codes = [];
  TextEditingController searchText = TextEditingController(text: '');
  String sortBy = 'createat';
  bool isAscending = true;
  int pageNo = 1;
  final ScrollController _scrollController = ScrollController();

  getDataFromAPI() async {
    final prefs = await SharedPreferences.getInstance();
    var response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'mode': 'getposts',
        'email': c.credentials!.email,
        'token': c.credentials!.token,
        'page': pageNo.toString(),
      },
    );
    print(response.body);
    print(apiUrl +
        "?mode=getposts&email=" +
        c.credentials!.email +
        "&token=" +
        c.credentials!.token +
        "&page=" +
        pageNo.toString());
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['error']['code'] == '#200') {
        if (pageNo == 1) {
          codes = [];
        }
        for (var i = 0; i < data['data'].length; i++) {
          if (!codes.any((e) => e.id == data['data'][i]['id'])) {
            codes.add(SingleBlog.fromJson(data['data'][i]));
          } else {
            codes.removeWhere((e) => e.id == data['data'][i]['id']);
            codes.add(SingleBlog.fromJson(data['data'][i]));
          }
        }
        codes.sort((b, a) => a.createdAt.compareTo(b.createdAt));
        prefs.setString('codesData', json.encode(codes));
        if (data['data'].length != 10) {
          loaded = true;
        }
        await searchIdCard(searchText.text);
      } else if (data['error']["code"] == '#600') {
        showLogoutDialog(context, data['error']["description"]);
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
      for (var j = 0; j < myList[i].keywords.length; j++) {
        if (myList[i].keywords[j].toLowerCase() == value.toLowerCase()) {
          if (tempList.where((e) => e.id == myList[i].id).isEmpty) {
            tempList.add(myList[i]);
          }
        }
      }
    }
    if (sortBy == "createat") {
      if (isAscending) {
        tempList.sort((b, a) => a.createdAt.compareTo(b.createdAt));
      } else {
        tempList.sort((b, a) => b.createdAt.compareTo(a.createdAt));
      }
    } else if (sortBy == "views") {
      if (isAscending) {
        tempList.sort((b, a) => a.views.compareTo(b.views));
      } else {
        tempList.sort((b, a) => b.views.compareTo(a.views));
      }
    }
    codes = tempList;
    setState(() {});
  }

  filterListBox(String key, String text) {
    return ListTile(
      minLeadingWidth: 0,
      contentPadding: EdgeInsets.zero,
      leading: sortBy == key
          ? !isAscending
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
        print(sortBy);
        print(isAscending);
        setState(() {});
        await searchIdCard(searchText.text);
        Get.back();
      },
    );
  }

  @override
  void initState() {
    super.initState();
    loadDataFromPrefs();
    Future.delayed(const Duration(seconds: 1), () async {
      await getLoginData(context, isBack: false);
      getDataFromAPI();
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        pageNo++;
        getDataFromAPI();
      }
    });
    searchText.addListener(() {
      searchIdCard(searchText.text);
    });
  }

  loadDataFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    var codesData = prefs.getString('codesData') ?? '[]';
    var codesList = json.decode(codesData) as List<dynamic>;
    codes = codesList.map((e) => SingleBlog.fromJson(e)).toList();
    codes.sort((b, a) => a.createdAt.compareTo(b.createdAt));
    setState(() {});
  }

  @override
  // ignore: must_call_super
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
          padding: const EdgeInsets.only(top: 10),
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
                        controller: searchText,
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
                          searchFunction: searchIdCard,
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
                    ],
                  ),
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
  const SingleBlogItem(
      {Key? key, required this.code, required this.searchFunction})
      : super(key: key);
  final SingleBlog code;
  final Function searchFunction;

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
                      child: Hero(
                        tag: widget.code.thumb,
                        child: CachedNetworkImage(
                          imageUrl:
                              webUrl + 'uploads/images/' + widget.code.thumb[0],
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
                          color: Color(
                            int.parse(c.prelogin!.theme.bottombaractive),
                          ),
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
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      widget.code.content,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CachedNetworkImage(
                            imageUrl: webUrl +
                                "api/avatar.php?username=" +
                                widget.code.username,
                            fit: BoxFit.cover,
                            height: 20,
                            width: 20,
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          widget.code.username,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Wrap(
                      spacing: 2,
                      runSpacing: 2,
                      children: widget.code.keywords
                          .map((keyword) => GestureDetector(
                                onTap: () async {},
                                child: Chip(
                                  backgroundColor: Color(
                                    int.parse(c.prelogin!.theme.secondary),
                                  ),
                                  label: Text(
                                    keyword,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
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
