import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:animewallpapers/constants.dart';
import 'package:animewallpapers/functions.dart';
import 'package:animewallpapers/models/announce_type.dart';
import 'package:animewallpapers/screens/photoslide.dart';
import 'package:animewallpapers/widgets/pdf.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsCard extends StatefulWidget {
  final AnnouncementType item;
  const NewsCard({super.key, required this.item});

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, contrains) {
      return GestureDetector(
        behavior: HitTestBehavior.deferToChild,
        onTap: () {},
        child: Container(
          width: Get.width,
          margin: const EdgeInsets.only(
            top: 8.0,
            bottom: 8.0,
            right: 16.0,
            left: 16.0,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: appBarColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.item.image.isNotEmpty) ...[
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                      child: SizedBox(
                        width: Get.width,
                        child: GestureDetector(
                          onTap: () {
                            Get.to(
                              () => SideSlide(
                                title: widget.item.name,
                                id: widget.item.id,
                                images: widget.item.image,
                                cpage: 0,
                              ),
                              transition: Transition.rightToLeft,
                            );
                          },
                          child: Hero(
                            tag: widget.item.image[0] +
                                widget.item.id.toString(),
                            child: CachedNetworkImage(
                              imageUrl:
                                  "${webUrl}uploads/images/${widget.item.image[0]}",
                              fit: BoxFit.fitWidth,
                              placeholder: (context, url) {
                                return Container(
                                  height: 100,
                                  alignment: Alignment.center,
                                  child: const CircularProgressIndicator(),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Builder(builder: (context) {
                        int count = widget.item.image.length;
                        if (count > 1) {
                          return Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFDD0046),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(4.0),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "+${count - 1} More",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Container();
                        }
                      }),
                    ),
                  ],
                ),
              ],
              if (widget.item.pdf != "") ...[
                Container(
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.only(
                    bottom: 8.0,
                  ),
                  width: Get.width,
                  height: 80,
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.to(
                            () => PdfViewer(
                              // ignore: prefer_interpolation_to_compose_strings
                              path: webUrl + "uploads/pdf/" + widget.item.pdf,
                              title: widget.item.name,
                            ),
                            transition: Transition.rightToLeft,
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Image.asset(
                                "assets/icons/pdf.png",
                                width: 60,
                                height: 60,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: VerticalDivider(
                                width: 1,
                                color: Colors.white,
                              ),
                            ),
                            const Expanded(
                              child: Text(
                                "View Document",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
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
              ],
              if (widget.item.name.trim() != "")
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SelectableText(
                    widget.item.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (widget.item.description.trim() != "")
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      String des = widget.item.description;
                      des = des.replaceAll("\n", " \n ");
                      des = des.replaceAll("'", " ' ");
                      des = des.replaceAll("\"", " \" ");
                      des = des.replaceAll(";", " ; ");
                      RegExp exp = RegExp(
                          r"(https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]+\.[^\s]{2,}|www\.[a-zA-Z0-9]+\.[^\s]{2,})");
                      List<String> descriptionWords = des.split(" ");
                      return SelectableText.rich(
                        TextSpan(
                          children: [
                            for (var i = 0; i < descriptionWords.length; i++)
                              if (exp.hasMatch(descriptionWords[i])) ...[
                                TextSpan(
                                  text: descriptionWords[i].trimLeft(),
                                  style: const TextStyle(
                                    color: Color(0xFFDD0046),
                                    fontSize: 14,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async {
                                      await launchUrl(
                                          Uri.parse(descriptionWords[i]),
                                          mode: LaunchMode.externalApplication);
                                    },
                                )
                              ] else ...[
                                TextSpan(
                                  text: "${descriptionWords[i].trimLeft()} ",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {},
                                )
                              ]
                          ],
                        ),
                      );
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                ),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.withOpacity(0.5),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Spacer(),
                    Text(
                      convertEpochtoTimeAgo(widget.item.createdDate),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
