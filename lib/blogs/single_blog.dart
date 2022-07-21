import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter/material.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/controllers/ad_controller.dart';
import 'package:frontendforever/controllers/data_controller.dart';
import 'package:frontendforever/functions.dart';
import 'package:frontendforever/screens/comments.dart';
import 'package:frontendforever/screens/tryit.dart';
import 'package:frontendforever/models/single_blog.dart';
import 'package:frontendforever/widgets/votings.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:neopop/neopop.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class SingleBlogScreen extends StatefulWidget {
  final SingleBlog book;
  const SingleBlogScreen({Key? key, required this.book}) : super(key: key);

  @override
  State<SingleBlogScreen> createState() => _SingleBlogScreenState();
}

class _SingleBlogScreenState extends State<SingleBlogScreen> {
  final d = Get.put(DataController());
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
    ac.loadRewardedAd();
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
        "mode": "getsinglepost",
        "id": widget.book.id.toString(),
        "token": d.credentials!.token,
        "email": d.credentials!.email,
        "username": d.credentials!.username,
      },
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['error']['code'] == '#200') {
        jsonData = data['data'];
        setState(() {
          isLoading = false;
        });
      } else if (data['error']["code"] == '#600') {
        showLogoutDialog(context, data['error']["message"]);
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
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
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
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                      ),
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        children: <Widget>[
                          const SizedBox(height: 16),
                          for (final item in widget.book.thumb)
                            Hero(
                              tag: widget.book.thumb,
                              child: CachedNetworkImage(
                                imageUrl: webUrl + 'uploads/images/' + item,
                                fit: BoxFit.contain,
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                              ),
                            ),
                          const SizedBox(height: 16),
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
                                widget.book.username,
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
                            height: 10,
                          ),
                          if (isLoading != true)
                            VotingsWidget(
                              id: widget.book.id.toString(),
                              type: 'postvote',
                              liked: jsonData['liked'],
                              votes: jsonData['votes'],
                              username: widget.book.username,
                            ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Tags",
                            style:
                                Theme.of(context).textTheme.headline6!.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Color(
                                          int.parse(d.prelogin!.theme.primary)),
                                    ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Wrap(
                            spacing: 2,
                            runSpacing: 2,
                            children: widget.book.keywords
                                .map((keyword) => GestureDetector(
                                      onTap: () async {},
                                      child: Chip(
                                        backgroundColor: Color(
                                          int.parse(
                                              d.prelogin!.theme.secondary),
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
                          const SizedBox(
                            height: 10,
                          ),
                          if (widget.book.ytlink.isNotEmpty)
                            Text(
                              "Youtube Video",
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Color(
                                        int.parse(d.prelogin!.theme.primary)),
                                  ),
                            ),
                          if (widget.book.ytlink.isNotEmpty)
                            const SizedBox(
                              height: 5,
                            ),
                          for (final item in widget.book.ytlink)
                            GestureDetector(
                              onTap: () {
                                Get.dialog(
                                  BuildYoutubePlayer(
                                    controller: d,
                                    link: item.trim(),
                                    title: widget.book.title,
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                ),
                                child: Container(
                                  margin: const EdgeInsets.only(
                                    bottom: 8.0,
                                  ),
                                  height: 200,
                                  width: MediaQuery.of(context).size.width,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl: "https://i.ytimg.com/vi/" +
                                            item.trim() +
                                            "/hqdefault.jpg",
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned.fill(
                                        child: Center(
                                          child: Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.black.withOpacity(0.5),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                Radius.circular(30),
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.play_arrow_rounded,
                                              size: 28,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          //   BuildYoutubePlayer(link: item.trim()),
                          if (!isLoading)
                            if (jsonData['content'] != null)
                              Text(
                                "Description",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Color(
                                          int.parse(d.prelogin!.theme.primary)),
                                    ),
                              ),
                          if (!isLoading)
                            if (jsonData['content'] != null)
                              Html(
                                data: jsonData['content'],
                              ),
                          if (!isLoading)
                            if (jsonData['content'] != null)
                              const SizedBox(
                                height: 10,
                              ),
                          const SizedBox(
                            height: 60,
                          ),
                        ],
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
                          child: isCodeRegistered || d.credentials!.pro
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: NeoPopButton(
                                        color: Color(int.parse(
                                            d.prelogin!.theme.primary)),
                                        onTapUp: () async {
                                          setState(() {
                                            isDownload = 0;
                                          });
                                          await downloadCode(
                                              widget.book, context);
                                          setState(() {
                                            isDownload = 1;
                                          });
                                        },
                                        onTapDown: () =>
                                            HapticFeedback.vibrate(),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 10),
                                          child: (isDownload == -1)
                                              ? Row(
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
                                              : (isDownload == 0)
                                                  ? Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: const [
                                                        Text(
                                                          "Downloading...",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w600,
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
                                                            backgroundColor:
                                                                Colors.white,
                                                            strokeWidth: 2,
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  : Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
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
                                                    ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: NeoPopButton(
                                        color: Color(int.parse(
                                            d.prelogin!.theme.primary)),
                                        onTapUp: () {
                                          Get.to(
                                            TryIt(
                                              css: jsonData['css'],
                                              html: jsonData['html'],
                                              js: jsonData['js'],
                                            ),
                                            transition: Transition.rightToLeft,
                                          );
                                        },
                                        onTapDown: () =>
                                            HapticFeedback.vibrate(),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: const [
                                              Text(
                                                "Run",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Icon(
                                                Icons.play_arrow,
                                                color: Colors.white,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : NeoPopButton(
                                  color: Color(
                                      int.parse(d.prelogin!.theme.primary)),
                                  onTapUp: () async {
                                    if (ac.rewardedAd != null) {
                                      ac.rewardedAd?.show(
                                        onUserEarnedReward: (_, reward) async {
                                          final prefs = await SharedPreferences
                                              .getInstance();
                                          final registeredCodes =
                                              prefs.getString(
                                                      'registeredCode') ??
                                                  '[]';
                                          final registeredCodesList =
                                              json.decode(registeredCodes)
                                                  as List<dynamic>;
                                          registeredCodesList
                                              .add(widget.book.id);
                                          prefs.setString('registeredCode',
                                              json.encode(registeredCodesList));
                                          setState(() {
                                            isCodeRegistered = true;
                                          });
                                        },
                                      );
                                    } else {
                                      await ac.loadRewardedAd();
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
                                )),
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
                          type: 'postcomment',
                        ),
                      );
                    },
                    child: const Icon(Icons.comment),
                  ),
                ),
              ),
            ),
          );
        });
  }
}

class BuildYoutubePlayer extends StatelessWidget {
  final String link;
  final String title;
  final DataController controller;
  const BuildYoutubePlayer(
      {Key? key,
      required this.link,
      required this.title,
      required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    YoutubePlayerController _controller = YoutubePlayerController(
      initialVideoId: link,
      params: const YoutubePlayerParams(
        showControls: true,
      ),
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(int.parse(controller.prelogin!.theme.primary)),
        title: Text(title.toUpperCase()),
      ),
      body: Center(
        child: YoutubePlayerIFrame(
          controller: _controller,
        ),
      ),
    );
  }
}
