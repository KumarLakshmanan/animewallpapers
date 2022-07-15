import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter/material.dart';
import 'package:frontendforever/api.dart';
import 'package:frontendforever/controllers/data_controller.dart';
import 'package:frontendforever/types/single_blog.dart';
import 'package:frontendforever/types/single_book.dart';
import 'package:intl/intl.dart';
import 'package:neopop/neopop.dart';
import 'package:get/get.dart';

class SingleBlogScreen extends StatefulWidget {
  final SingleBlog book;
  const SingleBlogScreen({Key? key, required this.book}) : super(key: key);

  @override
  State<SingleBlogScreen> createState() => _SingleBlogScreenState();
}

class _SingleBlogScreenState extends State<SingleBlogScreen> {
  final d = Get.put(DataController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(int.parse(d.prelogin!.theme.primary)),
        title: Text(widget.book.title),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: <Widget>[
                const SizedBox(height: 16),
                Center(
                  child: Hero(
                    tag: widget.book.thumb,
                    child: CachedNetworkImage(
                      imageUrl: webUrl + 'uploads/images/' + widget.book.thumb,
                      fit: BoxFit.contain,
                      height: MediaQuery.of(context).size.height * 0.4,
                    ),
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
                      widget.book.username,
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
                          widget.book.createdAt,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "Tags",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(int.parse(d.prelogin!.theme.primary)),
                  ),
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
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
                Text(
                  "About this code",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(int.parse(d.prelogin!.theme.primary)),
                  ),
                ),
                Html(
                  data: widget.book.content,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Positioned(
            left: 10,
            bottom: 10,
            right: 10,
            child: Row(
              children: [
                NeoPopButton(
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
                NeoPopButton(
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
                          "Run",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
