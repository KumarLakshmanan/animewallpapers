import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter/material.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/controllers/ad_controller.dart';

import 'package:frontendforever/functions.dart';
import 'package:frontendforever/models/single_blog.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SingleBlogScreen extends StatefulWidget {
  final SingleBlog book;
  const SingleBlogScreen({Key? key, required this.book}) : super(key: key);

  @override
  State<SingleBlogScreen> createState() => _SingleBlogScreenState();
}

class _SingleBlogScreenState extends State<SingleBlogScreen> {
  final commentController = TextEditingController();
  int isDownload = -1;
  bool isLoading = true;
  bool isCodeRegistered = false;
  Map<String, dynamic> jsonData = {};
  final ac = Get.put(AdController());

  @override
  void initState() {
    super.initState();
    loadDataFromServer();
    ac.loadInterstitialAd();
  }

  loadDataFromServer() async {
    final prefs = await SharedPreferences.getInstance();
    final registeredCodes = prefs.getString('registeredCode') ?? '[]';
    final registeredCodesList = json.decode(registeredCodes) as List<dynamic>;
    isCodeRegistered =
        registeredCodesList.contains(widget.book.id) ? true : false;
    setState(() {});
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        "mode": "getsinglecourse",
        "courseid": widget.book.id.toString(),
      },
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['error']['code'] == '#200') {
        jsonData = data['data'][0];
        setState(() {
          isLoading = false;
        });
      } else {
        showErrorDialog(context, data['error']['description']);
      }
    }
  }

  @override
  void dispose() {
    ac.interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (ac.interstitialAd != null) {
          ac.interstitialAd?.show();
        }
        return true;
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: primaryColor,
            title: Text(widget.book.title),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (ac.interstitialAd != null) {
                  ac.interstitialAd?.show();
                } else {
                  Get.back();
                }
              },
            ),
          ),
          body: SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                  ),
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: <Widget>[
                      const SizedBox(height: 16),
                      for (final item in widget.book.images)
                        Hero(
                          tag: widget.book.images[0],
                          child: CachedNetworkImage(
                            imageUrl: webUrl + 'uploads/images/' + item,
                            fit: BoxFit.contain,
                          ),
                        ),
                      const SizedBox(height: 16),
                      Text(
                        widget.book.title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 14,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            DateFormat('dd MMMM yyyy').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                widget.book.createdAt,
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      if (!isLoading)
                        Text(
                          "Description",
                          style:
                              Theme.of(context).textTheme.headline6!.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                        ),
                      if (!isLoading)
                        Html(
                          data: jsonData['content'],
                        ),
                      if (!isLoading)
                        const SizedBox(
                          height: 10,
                        ),
                      if (!isLoading)
                        Text(
                          "Steps to Follow",
                          style:
                              Theme.of(context).textTheme.headline6!.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                        ),
                      if (!isLoading)
                        for (final item in jsonData['commands'])
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 5,
                              ),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.only(
                                  bottom: 5,
                                  top: 5,
                                ),
                                decoration: BoxDecoration(
                                  boxShadow: boxShadow,
                                  borderRadius: BorderRadius.circular(2),
                                  color: primaryColor,
                                ),
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Text(
                                          "\$. " + item,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: IconButton(
                                        color: Colors.white,
                                        icon: const Icon(Icons.copy),
                                        onPressed: () {
                                          Clipboard.setData(
                                            ClipboardData(text: item),
                                          );
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Copied to Clipboard",
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                      if (!isLoading)
                        const SizedBox(
                          height: 10,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
