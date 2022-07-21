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
import 'package:intl/intl.dart';
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
  int isCodeRegistered = -1;
  final ac = Get.put(AdController());

  @override
  void initState() {
    super.initState();
    loadDataForAds();
    ac.loadInterstitialAd();
    ac.loadRewardedAd();
    print(widget.book.toJson());
  }

  loadDataForAds() async {
    final prefs = await SharedPreferences.getInstance();
    final registeredBooks = prefs.getString('registeredBook') ?? '[]';
    final registeredBooksList = json.decode(registeredBooks) as List<dynamic>;
    isCodeRegistered = registeredBooksList.contains(widget.book.id) ? 1 : -1;
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
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: Color(int.parse(d.prelogin!.theme.primary)),
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
                        children: <Widget>[
                          const SizedBox(height: 16),
                          Center(
                            child: Hero(
                              tag: widget.book.thumbnail,
                              child: CachedNetworkImage(
                                imageUrl: webUrl + widget.book.thumbnail,
                                fit: BoxFit.contain,
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
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
                                    int.parse(d.prelogin!.theme.secondary),
                                  ),
                                ),
                            ],
                          ),
                          Text(
                            widget.book.title,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color:
                                  Color(int.parse(d.prelogin!.theme.primary)),
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
                      height: 60,
                      padding: const EdgeInsets.all(8),
                      child: isCodeRegistered == -1 &&
                              d.credentials!.pro != false
                          ? NeoPopButton(
                              color:
                                  Color(int.parse(d.prelogin!.theme.primary)),
                              onTapUp: () async {
                                if (ac.rewardedAd != null) {
                                  ac.rewardedAd?.show(
                                    onUserEarnedReward: (_, reward) async {
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
                                        isCodeRegistered = 1;
                                      });
                                    },
                                  );
                                } else {
                                  ac.loadRewardedAd();
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  isCodeRegistered == 0
                                      ? const SizedBox(
                                          width: 15,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : CachedNetworkImage(
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
                                  const Text(
                                    "Get Access",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : NeoPopButton(
                              color:
                                  Color(int.parse(d.prelogin!.theme.primary)),
                              onTapUp: () async {
                                if (isDownload == -1) {
                                  setState(() {
                                    isDownload = 0;
                                  });
                                  await downloadBook(widget.book, context);
                                  setState(() {
                                    isDownload = 1;
                                  });
                                } else {
                                  var path =
                                      await getApplicationDocumentsDirectory();
                                  // await OpenFile.open(
                                  //     '${path.path}/${widget.book.title}.pdf');
                                  Get.to(
                                    PdfViewer(
                                      file: File(
                                          '${path.path}/${widget.book.title}.pdf'),
                                      title: widget.book.title,
                                    ),
                                    transition: Transition.rightToLeft,
                                  );
                                }
                              },
                              onTapDown: () => HapticFeedback.vibrate(),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                child: (isDownload == -1)
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Text(
                                            "Download Book",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
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
                                    : (isDownload == 0)
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
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: const [
                                              Text(
                                                "Downloaded",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
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
            ),
          );
        });
  }
}
