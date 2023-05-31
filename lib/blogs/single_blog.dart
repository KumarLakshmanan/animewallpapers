import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
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
  // late AppLifecycleReactor _appLifecycleReactor;

  @override
  void initState() {
    super.initState();
    loadDataFromServer();
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
      if (kDebugMode) {
        print(
            "http://frontendforever.com/api.php?mode=getsinglecourse&courseid=" +
                widget.book.id.toString());
      }
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: secondaryColor,
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: Text(widget.book.title),
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.white,
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
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    if (!isLoading)
                      Html(
                        data: retunHtml(jsonData['content']),
                        style: {
                          "body": Style(
                            fontSize: FontSize(16),
                            color: Colors.grey[300],
                          ),
                        },
                      ),
                    if (!isLoading)
                      const SizedBox(
                        height: 10,
                      ),
                    if (!isLoading)
                      Text(
                        "Steps to Follow",
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                    const SizedBox(
                      height: 10,
                    ),
                    if (!isLoading)
                      for (final item in jsonData['commands'])
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(
                              ClipboardData(text: item),
                            );
                            Get.snackbar(
                              "Copied",
                              "Command copied to clipboard",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: secondaryColor,
                              colorText: Colors.white,
                            );
                            if (ac.interstitialAd != null) {
                              ac.interstitialAd?.show();
                            } else {
                              ac.loadInterstitialAd();
                            }
                          },
                          child: Column(
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
                                    const Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Icon(
                                          Icons.copy,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    if (!isLoading)
                      const SizedBox(
                        height: 10,
                      ),
                  ],
                ),
              ),
              if (isLoading)
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
