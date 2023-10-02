import 'dart:io';
import 'dart:ui';

import 'package:animewallpapers/controllers/data_controller.dart';
import 'package:animewallpapers/controllers/favorites_controller.dart';
import 'package:animewallpapers/widgets/like.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:animewallpapers/controllers/ad_controller.dart';
import 'package:animewallpapers/functions.dart';
import 'package:animewallpapers/widgets/on_tap_scale.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wallpaper/wallpaper.dart';

class SingleBlogScreen extends StatefulWidget {
  final int index;
  final bool type;
  const SingleBlogScreen({Key? key, required this.index, this.type = false})
      : super(key: key);

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
  final dc = Get.put(DataController());
  final fc = Get.put(FavoritesController());
  int index = 0;

  @override
  void initState() {
    super.initState();
    index = widget.index;
  }

  late Stream<String> progressString;
  late String res;
  bool downloading = false;
  var result = "Waiting to set wallpaper";
  int nextImageID = 0;
  bool isDisable = true;

  Future<void> dowloadImage(BuildContext context) async {
    progressString = Wallpaper.imageDownloadProgress(widget.type
        ? fc.favorites[index].image
        : widget.type
            ? fc.favorites[index].image
            : dc.codes[index].image);
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
    return Scaffold(
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
                    "${convertIntToViews(widget.type ? fc.favorites[index].views : dc.codes[index].views)}",
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
              var response = await http.get(Uri.parse(widget.type
                  ? fc.favorites[index].image
                  : widget.type
                      ? fc.favorites[index].image
                      : dc.codes[index].image));
              if (response.statusCode == 200) {
                final result = await ImageGallerySaver.saveImage(
                  Uint8List.fromList(response.bodyBytes),
                  quality: 100,
                  name:
                      "Anime Wallpaper ${widget.type ? fc.favorites[index].id : dc.codes[index].id.toString()}",
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
      body: GetBuilder(
          init: DataController(),
          builder: (dc) {
            return Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: widget.type
                      ? fc.favorites[index].thumb
                      : dc.codes[index].thumb,
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
                  children: [
                    Expanded(
                      child: PageView.builder(
                        itemCount:
                            widget.type ? fc.favorites.length : dc.codes.length,
                        controller: PageController(initialPage: index),
                        onPageChanged: (value) {
                          if (!widget.type) {
                            if (value == dc.codes.length - 1) {
                              dc.getDataFromAPI(
                                scategory:dc.codes[index].category,
                              );
                            }
                          }
                          setState(() {
                            index = value;
                          });
                        },
                        itemBuilder: (context, index) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: kToolbarHeight),
                              Center(
                                child: SizedBox(
                                  height: Get.height -
                                      (kToolbarHeight * 2) -
                                      20 -
                                      MediaQuery.of(context).padding.top,
                                  width: Get.width * 0.9,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: widget.type
                                          ? fc.favorites[index].image
                                          : widget.type
                                              ? fc.favorites[index].image
                                              : dc.codes[index].image,
                                      fit: BoxFit.contain,
                                      placeholder: (context, url) => Stack(
                                        children: [
                                          Center(
                                            child: SizedBox(
                                              height: Get.height * 0.8 -
                                                  kToolbarHeight,
                                              width: Get.width * 0.9,
                                              child: CachedNetworkImage(
                                                imageUrl: widget.type
                                                    ? fc.favorites[index].thumb
                                                    : dc.codes[index].thumb,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                          const Center(
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: kToolbarHeight),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 20 + MediaQuery.of(context).padding.bottom,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LikeButton(
                        color: Colors.white,
                        id: widget.type ? fc.favorites[index] : dc.codes[index],
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
                          final Directory tempDir =
                              await getTemporaryDirectory();
                          String imageExt = widget.type
                              ? fc.favorites[index].image
                              : widget.type
                                  ? fc.favorites[index].image
                                  : dc.codes[index].image.split("/").last;
                          File file = File(
                              "${tempDir.path}/${widget.type ? fc.favorites[index].id : dc.codes[index].id}_$imageExt");
                          if (!file.existsSync()) {
                            showLoadingDialog();
                            var res = await http.get(Uri.parse(widget.type
                                ? fc.favorites[index].image
                                : widget.type
                                    ? fc.favorites[index].image
                                    : dc.codes[index].image));
                            file.writeAsBytesSync(res.bodyBytes);
                            Get.back();
                          }
                          await Share.shareXFiles(
                            [
                              XFile(
                                "${tempDir.path}/${widget.type ? fc.favorites[index].id : dc.codes[index].id}_$imageExt",
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
                )
              ],
            );
          }),
    );
  }
}
