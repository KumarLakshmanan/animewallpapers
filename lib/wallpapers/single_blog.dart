import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/controllers/ad_controller.dart';
import 'package:frontendforever/functions.dart';
import 'package:frontendforever/models/single_blog.dart';
import 'package:frontendforever/widgets/on_tap_scale.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallpaper/wallpaper.dart';

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

  late Stream<String> progressString;
  late String res;
  bool downloading = false;
  var result = "Waiting to set wallpaper";
  int nextImageID = 0;
  bool isDisable = true;

  Future<void> dowloadImage(BuildContext context) async {
    // final Directory tempDir = await getTemporaryDirectory();
    // String imageExt = widget.book.image.split(".").last;
    // File file = File("${tempDir.path}/${widget.book.id}_$imageExt");
    // if (file.existsSync()) {
    //   showSetWallpaperDialog(imageExt: imageExt);
    //   return;
    // }
    progressString = Wallpaper.imageDownloadProgress(widget.book.image);
    showLoadingDialog();
    progressString.listen((data) {
      setState(() {
        downloading = true;
      });
    }, onDone: () async {
      setState(() {
        downloading = false;
        isDisable = false;
      });
      Get.back();
      showSetWallpaperDialog();
    }, onError: (error) {
      setState(() {
        downloading = false;
        isDisable = true;
      });
      Get.back();
      showSetWallpaperDialog();
    });
  }

  showSetWallpaperDialog() {
    Get.dialog(
      AlertDialog(
        contentPadding: const EdgeInsets.all(6),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            const Text(
              "Set Wallpaper for",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            InkWell(
              child: Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                child: const Text("Home Screen"),
              ),
              onTap: () async {
                Get.back();
                showLoadingDialog();
                await Wallpaper.homeScreen();
                Get.back();
                snackbar(
                  "Success",
                  "Wallpaper set successfully",
                );
              },
            ),
            InkWell(
              child: Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                child: const Text("Lock Screen"),
              ),
              onTap: () async {
                Get.back();
                showLoadingDialog();
                await Wallpaper.lockScreen();
                Get.back();
                snackbar(
                  "Success",
                  "Wallpaper set successfully",
                );
              },
            ),
            InkWell(
              child: Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                child: const Text("Both Screen"),
              ),
              onTap: () async {
                Get.back();
                showLoadingDialog();
                await Wallpaper.bothScreen();
                Get.back();
                snackbar(
                  "Success",
                  "Wallpaper set successfully",
                );
              },
            ),
          ],
        ),
      ),
    );
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
                  horizontal: 8,
                  vertical: 8,
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
                      "${convertIntToViews(widget.book.views)}",
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
            IconButton(
              onPressed: () async {
                showLoadingDialog();
                var response = await http.get(Uri.parse(widget.book.image));
                if (response.statusCode == 200) {
                  final result = await ImageGallerySaver.saveImage(
                    Uint8List.fromList(response.bodyBytes),
                    quality: 100,
                    name: "Anime Wallpaper ${widget.book.id.toString()}",
                  );
                  Get.back();
                  if (result["isSuccess"] == true) {
                    snackbar(
                      "Success",
                      "Wallpaper downloaded successfully",
                    );
                  } else {
                    snackbar(
                      "Error",
                      "Something went wrong",
                    );
                  }
                } else {
                  snackbar(
                    "Error",
                    "Server Connection Error",
                  );
                }
              },
              icon: const Icon(Icons.download),
            ),
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
                        child: Center(
                          child: Container(
                            height: Get.height * 0.8 - kToolbarHeight,
                            width: Get.width * 0.9,
                            color: Colors.black.withOpacity(0.2),
                            child: Image.asset(
                              "assets/icons/logo_nobg.png",
                              fit: BoxFit.contain,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OnTapScale(
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 24,
                          color: isFavorite ? Colors.red : Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    OnTapScale(
                      onTap: () async {
                        return await dowloadImage(context);
                      },
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
                          Icons.now_wallpaper,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    OnTapScale(
                      onTap: () async {
                        final Directory tempDir = await getTemporaryDirectory();
                        String imageExt = widget.book.image.split("/").last;
                        File file =
                            File("${tempDir.path}/${widget.book.id}_$imageExt");
                        if (!file.existsSync()) {
                          showLoadingDialog();
                          var res =
                              await http.get(Uri.parse(widget.book.image));
                          file.writeAsBytesSync(res.bodyBytes);
                          Get.back();
                        }
                        await Share.shareXFiles(
                          [
                            XFile(
                              "${tempDir.path}/${widget.book.id}_$imageExt",
                            ),
                          ],
                          text:
                              "Check out this cool wallpaper. Get more amazing 30k+ wallpapers from  at: \n\n https://play.google.com/store/apps/details?id=in.codingfrontend.animewallpapers",
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        child: Icon(
                          Icons.share,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
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
