import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/controllers/data_controller.dart';
import 'package:frontendforever/functions.dart';
import 'package:frontendforever/screens/single_book.dart';
import 'package:frontendforever/types/single_blog.dart';
import 'package:frontendforever/types/single_book.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class BooksList extends StatefulWidget {
  const BooksList({
    Key? key,
  }) : super(key: key);
  @override
  State<BooksList> createState() => _BooksListState();
}

class _BooksListState extends State<BooksList>
    with AutomaticKeepAliveClientMixin<BooksList> {
  @override
  bool get wantKeepAlive => true;

  final DataController c = Get.put(DataController());
  bool isOpen = true;
  List<SingleBook> codes = [];
  TextEditingController searchText = TextEditingController(text: '');
  String sortBy = '';
  bool isAscending = true;
  int pageNo = 1;
  final ScrollController _scrollController = ScrollController();

  getDataFromAPI() async {
    final prefs = await SharedPreferences.getInstance();
    var booksData = prefs.getString('booksData') ?? '[]';
    var codesList = json.decode(booksData) as List<dynamic>;
    setState(() {
      codes = codesList.map((e) => SingleBook.fromJson(e)).toList();
    });
    var response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'mode': 'getbooks',
        'email': c.credentials!.email,
        'token': c.credentials!.token,
        'page': pageNo.toString(),
      },
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['error']['code'] == '#200') {
        for (var i = 0; i < data['data'].length; i++) {
          if (!codes.any((e) => e.id == data['data'][i]['id'])) {
            codes.add(SingleBook.fromJson(data['data'][i]));
          }
        }
        prefs.setString('booksData', json.encode(codes));
        await searchIdCard(searchText.text);
        setState(() {});
      } else if (data['error']["code"] == '#600') {
        showLogoutDialog(context, data['error']["message"]);
      } else {
        showErrorDialog(context, data['error']['description']);
      }
    }
  }

  searchIdCard(String value) async {
    List<SingleBook> myList = [];
    final prefs = await SharedPreferences.getInstance();
    var booksData = prefs.getString('booksData') ?? '[]';
    var codesList = json.decode(booksData) as List<dynamic>;
    for (var i = 0; i < codesList.length; i++) {
      myList.add(SingleBook.fromJson(codesList[i]));
    }
    List<SingleBook> tempList = [];
    for (var i = 0; i < myList.length; i++) {
      if (myList[i].title.toLowerCase().contains(value.toLowerCase())) {
        tempList.add(myList[i]);
      }
      if (myList[i].category.toLowerCase() == value.toLowerCase()) {
        if (tempList.where((e) => e.id == myList[i].id).isEmpty) {
          tempList.add(myList[i]);
        }
      }
    }
    if (sortBy == "title") {
      tempList.sort((a, b) => a.title.compareTo(b.title));
    } else if (sortBy == "createat") {
      tempList.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else if (sortBy == "downloads") {
      tempList.sort((a, b) => a.downloads.compareTo(b.downloads));
    }
    if (!isAscending) {
      tempList.reversed.toList();
    }
    codes = await tempList;
    setState(() {});
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
        await searchIdCard(searchText.text);
        Get.back();
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
    searchText.addListener(() {
      searchIdCard(searchText.text);
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
                                filterListBox("title", "Book Name"),
                                filterListBox("downloads", "Download Count"),
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
                    return SingleBookItem(
                      code: codes[index],
                      searchFunction: searchIdCard,
                    );
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

class SingleBookItem extends StatefulWidget {
  const SingleBookItem(
      {Key? key, required this.code, required this.searchFunction})
      : super(key: key);
  final SingleBook code;
  final Function searchFunction;

  @override
  State<SingleBookItem> createState() => _SingleBookItemState();
}

class _SingleBookItemState extends State<SingleBookItem> {
  final c = Get.find<DataController>();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: GestureDetector(
        onTap: () {
          Get.to(
            SingleBookScreen(book: widget.code),
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
          child: Stack(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                    child: SizedBox(
                      width: 100,
                      child: Hero(
                        tag: widget.code.thumbnail,
                        child: CachedNetworkImage(
                          imageUrl: webUrl +
                              'uploads/images/' +
                              widget.code.thumbnail,
                          fit: BoxFit.cover,
                        ),
                      ),
                      height: 150,
                    ),
                  ),
                  Expanded(
                    child: Padding(
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
                                widget.code.author,
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 14,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                DateFormat('dd MMMM yyyy').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                    widget.code.createdAt,
                                  ),
                                ),
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
                        NumberFormat.compact().format(widget.code.downloads),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Icon(
                          Icons.file_download,
                          color: Colors.white,
                          size: 15,
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
