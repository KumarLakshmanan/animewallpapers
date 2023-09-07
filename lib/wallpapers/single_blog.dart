import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/controllers/ad_controller.dart';
import 'package:frontendforever/models/single_blog.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SingleBlogScreen extends StatefulWidget {
  final ImageType book;
  const SingleBlogScreen({Key? key, required this.book}) : super(key: key);

  @override
  State<SingleBlogScreen> createState() => _SingleBlogScreenState();
}

class _SingleBlogScreenState extends State<SingleBlogScreen> {
  final commentController = TextEditingController();
  bool isLoading = true;
  bool isAdWatched = false;
  bool isAdLoading = false;
  Map<String, dynamic> jsonData = {};
  final ac = Get.put(AdController());

  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    loadDataFromServer();
  }

  loadDataFromServer() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> prefsKeys = prefs.getKeys().toList();
    if (prefsKeys.contains("favorites_${widget.book.id}")) {
      setState(() {
        isFavorite = true;
      });
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
        appBar: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            Center(
              child: Ink(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFf3004a),
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
                    const SizedBox(width: 5),
                    Text(
                      "${widget.book.views}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
        backgroundColor: Colors.white,
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: widget.book.thumb,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.cover,
            ),
            Positioned(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.2),
                        Colors.black.withOpacity(0.2),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: kToolbarHeight),
                Center(
                  child: SizedBox(
                    height: (Get.height * 0.8) - kToolbarHeight,
                    width: Get.width * 0.9,
                    child: CachedNetworkImage(
                      imageUrl: widget.book.image,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Center(
                        child: Container(
                          height: Get.height * 0.8 - kToolbarHeight,
                          width: Get.width * 0.9,
                          color: Colors.black.withOpacity(0.2),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(6),
                      ),
                      onTap: () async {
                        final prefs = await SharedPreferences.getInstance();
                        if (isFavorite) {
                          prefs.remove("favorites_${widget.book.id}");
                        } else {
                          prefs.setString(
                            "favorites_${widget.book.id}",
                            jsonEncode(widget.book.toJson()),
                          );
                          bool voted =
                              prefs.getBool("voted_${widget.book.id}") ?? false;
                          if (!voted) {
                            http.post(
                              Uri.parse(apiUrl),
                              body: {
                                "mode": "vote",
                                "id": widget.book.id.toString(),
                              },
                            );
                            prefs.setBool(
                              "voted_${widget.book.id}",
                              true,
                            );
                          }

                          if (kDebugMode) {
                            print(
                              "$apiUrl?mode=vote&id=${widget.book.id.toString()}",
                            );
                          }
                        }
                        setState(() {
                          isFavorite = !isFavorite;
                        });
                      },
                      child: Center(
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 24,
                          color: isFavorite ? Colors.red : Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    InkWell(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(6),
                      ),
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: const BoxDecoration(
                          color: Color(0xFFf3004a),
                          borderRadius: BorderRadius.all(
                            Radius.circular(100),
                          ),
                        ),
                        child: const Icon(
                          Icons.download,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Icon(
                      Icons.share,
                      size: 24,
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
