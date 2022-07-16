import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter/material.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/controllers/data_controller.dart';
import 'package:frontendforever/functions.dart';
import 'package:frontendforever/screens/tryit.dart';
import 'package:frontendforever/types/single_blog.dart';
import 'package:frontendforever/types/single_book.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:neopop/neopop.dart';
import 'package:get/get.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class SingleBlogScreen extends StatefulWidget {
  final SingleBlog book;
  const SingleBlogScreen({Key? key, required this.book}) : super(key: key);

  @override
  State<SingleBlogScreen> createState() => _SingleBlogScreenState();
}

class _SingleBlogScreenState extends State<SingleBlogScreen> {
  final d = Get.put(DataController());
  bool isLoading = true;
  Map<String, dynamic> jsonData = {};
  @override
  void initState() {
    super.initState();
    loadDataFromServer();
  }

  loadDataFromServer() async {
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        "mode": "getsinglepost",
        "id": widget.book.id.toString(),
        "token": d.credentials!.token,
        "email": d.credentials!.email,
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(int.parse(d.prelogin!.theme.primary)),
        title: Text(widget.book.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 60),
            child: ListView(
              children: <Widget>[
                const SizedBox(height: 16),
                for (final item in widget.book.thumb)
                  Hero(
                    tag: widget.book.thumb,
                    child: CachedNetworkImage(
                      imageUrl: webUrl + 'uploads/images/' + item,
                      fit: BoxFit.contain,
                      height: MediaQuery.of(context).size.height * 0.4,
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  widget.book.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(int.parse(d.prelogin!.theme.primary)),
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
                Text(
                  "Tags",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(int.parse(d.prelogin!.theme.primary)),
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
                                int.parse(d.prelogin!.theme.secondary),
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
                if (!isLoading)
                  if (jsonData['content'] != null)
                    Html(
                      data: jsonData['content'],
                    ),
                if (widget.book.ytlink.isNotEmpty)
                  Text(
                    "Youtube Video",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(int.parse(d.prelogin!.theme.primary)),
                    ),
                  ),
                if (widget.book.ytlink.isNotEmpty)
                  const SizedBox(
                    height: 5,
                  ),
                for (final item in widget.book.ytlink)
                  BuildYoutubePlayer(link: item),
                const SizedBox(height: 40),
              ],
            ),
          ),
          Positioned(
            left: 10,
            bottom: 10,
            right: 10,
            child: Container(
              color: Colors.white,
              height: 50,
              child: Row(
                children: [
                  Expanded(
                    child: NeoPopButton(
                      color: Color(int.parse(d.prelogin!.theme.primary)),
                      onTapUp: () {},
                      onTapDown: () => HapticFeedback.vibrate(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              "Download",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Icon(
                              Icons.file_download,
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
                      color: Color(int.parse(d.prelogin!.theme.primary)),
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
                      onTapDown: () => HapticFeedback.vibrate(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BuildYoutubePlayer extends StatelessWidget {
  final String link;
  const BuildYoutubePlayer({Key? key, required this.link}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    YoutubePlayerController _controller = YoutubePlayerController(
      initialVideoId: link,
      params: const YoutubePlayerParams(
        showControls: true,
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: YoutubePlayerIFrame(
        controller: _controller,
      ),
    );
  }
}
