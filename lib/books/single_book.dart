import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter/material.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/controllers/ad_controller.dart';
import 'package:frontendforever/controllers/data_controller.dart';
import 'package:frontendforever/functions.dart';
import 'package:frontendforever/screens/comments.dart';
import 'package:frontendforever/screens/pdf.dart';
import 'package:frontendforever/models/single_book.dart';
import 'package:frontendforever/screens/rewards.dart';
import 'package:intl/intl.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import 'package:neopop/neopop.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SingleBookScreen extends StatefulWidget {
  final SingleBook book;
  const SingleBookScreen({Key? key, required this.book}) : super(key: key);

  @override
  State<SingleBookScreen> createState() => _SingleBookScreenState();
}

class _SingleBookScreenState extends State<SingleBookScreen> {
  final d = Get.put(DataController());
  int isDownload = -1;
  bool isCodeRegistered = false;
  final ac = Get.put(AdController());

  @override
  void initState() {
    super.initState();
    loadDataForAds();
    ac.loadInterstitialAd();
  }

  loadDataForAds() async {
    final prefs = await SharedPreferences.getInstance();
    final registeredBooks = prefs.getString('registeredBook') ?? '[]';
    final registeredBooksList = json.decode(registeredBooks) as List<dynamic>;
    isCodeRegistered =
        registeredBooksList.contains(widget.book.id) ? true : false;
    var dir = await getApplicationDocumentsDirectory();
    var path = dir.path;
    var file = File('$path/${widget.book.title}.pdf');
    // file already there
    if (file.existsSync()) {
      setState(() {
        isDownload = 1;
      });
    } else {
      setState(() {
        isDownload = -1;
      });
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: AdController(),
        builder: (adController) {
          return WillPopScope(
            onWillPop: () async {
              if (d.credentials!.pro) {
                return true;
              }
              if (ac.interstitialAd != null) {
                ac.interstitialAd?.show();
              }
              return true;
            },
            child: GetBuilder(
                init: DataController(),
                builder: (c) {
                  return Scaffold(
                    appBar: AppBar(
                      actions: [
                        pointsBuilder(context, d),
                      ],
                      backgroundColor:
                          Color(int.parse(d.prelogin!.theme.primary)),
                      title: Text(widget.book.title),
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          if (d.credentials!.pro) {
                            Get.back();
                          } else {
                            if (ac.interstitialAd != null) {
                              ac.interstitialAd?.show();
                            } else {
                              Get.back();
                            }
                          }
                        },
                      ),
                    ),
                    body: Stack(
                      children: [
                        SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const SizedBox(height: 16),
                                Center(
                                  child: Hero(
                                    tag: widget.book.thumbnail,
                                    child: CachedNetworkImage(
                                      imageUrl: webUrl + widget.book.thumbnail,
                                      fit: BoxFit.contain,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.4,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  children: [
                                    for (final item in widget.book.category)
                                      Chip(
                                        label: Text(
                                          item,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        backgroundColor: Color(
                                          int.parse(
                                              d.prelogin!.theme.secondary),
                                        ),
                                      ),
                                  ],
                                ),
                                Text(
                                  widget.book.title,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(
                                        int.parse(d.prelogin!.theme.primary)),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      size: 14,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      widget.book.author,
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
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
                                  height: 5,
                                ),
                                Html(
                                  data: widget.book.content,
                                ),
                                const SizedBox(
                                  height: 60,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          bottom: 0,
                          right: 0,
                          child: Container(
                            color: Colors.white,
                            padding: const EdgeInsets.all(8),
                            height: 60,
                            child: NeoPopButton(
                              color:
                                  Color(int.parse(d.prelogin!.theme.primary)),
                              onTapUp: () async {
                                if (isCodeRegistered || d.credentials!.pro) {
                                  if (isDownload == -1) {
                                    setState(() {
                                      isDownload = 0;
                                    });
                                    await downloadBook(widget.book, context);
                                    setState(() {
                                      isDownload = 1;
                                    });
                                  } else if (isDownload == 1) {
                                    var path =
                                        await getApplicationDocumentsDirectory();
                                    Get.to(
                                      PdfViewer(
                                        file: File(
                                            '${path.path}/${widget.book.title}.pdf'),
                                        title: widget.book.title,
                                      ),
                                      transition: Transition.rightToLeft,
                                    );
                                  }
                                } else {
                                  if (d.gemCount >= widget.book.gems) {
                                    showConfirmationDialog(
                                        context,
                                        "Are you sure you want to download this book for : " +
                                            widget.book.gems.toString() +
                                            " Gems ?", () async {
                                      d.decreaseGems(widget.book.gems);
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      final registeredBooks =
                                          prefs.getString('registeredBook') ??
                                              '[]';
                                      final registeredBooksList =
                                          json.decode(registeredBooks)
                                              as List<dynamic>;
                                      registeredBooksList.add(widget.book.id);
                                      prefs.setString('registeredBook',
                                          json.encode(registeredBooksList));
                                      setState(() {
                                        isCodeRegistered = true;
                                      });
                                    });
                                  } else {
                                    Dialogs.materialDialog(
                                      color: Colors.white,
                                      msg: "Not enough gems",
                                      title: 'Warning',
                                      lottieBuilder: Lottie.asset(
                                        'assets/json/alert.json',
                                        repeat: false,
                                        fit: BoxFit.contain,
                                      ),
                                      context: context,
                                      titleAlign: TextAlign.center,
                                      msgAlign: TextAlign.center,
                                      actions: [
                                        IconsOutlineButton(
                                          onPressed: () {
                                            Get.back();
                                          },
                                          text: 'Close',
                                          iconData: Icons.cancel_outlined,
                                          textStyle: const TextStyle(
                                              color: Colors.grey),
                                          iconColor: Colors.grey,
                                        ),
                                        IconsOutlineButton(
                                          onPressed: () {
                                            Get.back();
                                            Get.dialog(
                                              const GetRewards(),
                                            );
                                          },
                                          text: 'Get Gems',
                                          iconData: Icons.attach_money_outlined,
                                          textStyle: const TextStyle(
                                              color: Colors.grey),
                                          iconColor: Colors.grey,
                                        ),
                                      ],
                                    );
                                  }
                                }
                              },
                              onTapDown: () => HapticFeedback.vibrate(),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                child: isCodeRegistered || d.credentials!.pro
                                    ? isDownload == 0
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: const [
                                              Text(
                                                "Downloading...",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              SizedBox(
                                                width: 10,
                                                height: 10,
                                                child:
                                                    CircularProgressIndicator(
                                                  backgroundColor: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              ),
                                            ],
                                          )
                                        : (isDownload == 1)
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: const [
                                                  Text(
                                                    "Downloaded",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Icon(
                                                    Icons.download_done,
                                                    color: Colors.white,
                                                  ),
                                                ],
                                              )
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: const [
                                                  Text(
                                                    "Download",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Icon(
                                                    Icons.file_download,
                                                    color: Colors.white,
                                                  ),
                                                ],
                                              )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CachedNetworkImage(
                                            imageUrl: webUrl +
                                                d.prelogindynamic['assets']
                                                    ['royal'],
                                            width: 16,
                                            height: 16,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            "Purchase (" +
                                                widget.book.gems.toString() +
                                                "gems)",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    floatingActionButton: Padding(
                      padding: const EdgeInsets.only(bottom: 50.0),
                      child: FloatingActionButton(
                        onPressed: () {
                          Get.dialog(
                            Comments(
                              id: widget.book.id.toString(),
                              type: 'bookcomment',
                            ),
                          );
                        },
                        child: const Icon(Icons.comment),
                      ),
                    ),
                  );
                }),
          );
        });
  }
}
