import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:comment_box/comment/comment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/controllers/data_controller.dart';
import 'package:frontendforever/functions.dart';
import 'package:frontendforever/models/single_comment.dart';
import 'package:frontendforever/widgets/votings.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';

class Comments extends StatefulWidget {
  final String id;
  final String type;
  const Comments({Key? key, required this.id, required this.type})
      : super(key: key);

  @override
  State<Comments> createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  final dc = Get.put(DataController());
  final commentController = TextEditingController();
  final scrollController = ScrollController();
  List<SingleComment> comments = [];
  String comment = '';
  int pageNo = 1;
  bool loaded = false;
  loadComments() async {
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        "mode": "loadComments",
        "type": widget.type,
        "id": widget.id,
        "page": pageNo.toString(),
        "username": dc.credentials!.username,
      },
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['error']['code'] == '#200') {
        for (var i = 0; i < data['data'].length; i++) {
          if (!comments.any((e) => e.id == data['data'][i]['id'])) {
            comments.add(SingleComment.fromJson(data['data'][i]));
          } else {
            comments.removeWhere((e) => e.id == data['data'][i]['id']);
            comments.add(SingleComment.fromJson(data['data'][i]));
          }
        }
        if (data['data'].length != 10) {
          loaded = true;
        }
        pageNo++;
        for (var i = 0; i < comments.length; i++) {
          print(comments[i].toJson());
        }
        setState(() {});
      } else if (data['error']["code"] == '#600') {
        showLogoutDialog(context, data['error']["description"]);
      } else {
        showErrorDialog(context, data['error']['description']);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadComments();
    commentController.addListener(() {
      setState(() {
        comment = commentController.text;
      });
    });
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        loadComments();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(int.parse(dc.prelogin!.theme.primary)),
          title: const Text("Comments"),
        ),
        body: CommentBox(
          userImage: dc.credentials!.photo != ""
              ? dc.credentials!.photo
              : webUrl + "api/avatar.php?username=" + dc.credentials!.username,
          child: commentChild(),
          labelText: 'Write a comment...',
          withBorder: false,
          errorText: 'Comment cannot be blank',
          sendButtonMethod: () async {
            if (comment != '') {
              final response = await http.post(
                Uri.parse(apiUrl),
                body: {
                  "mode": "saveComment",
                  "type": widget.type,
                  "id": widget.id,
                  "comment": comment,
                  "email": dc.credentials!.email,
                  "token": dc.credentials!.token,
                  "name": dc.credentials!.name,
                  "username": dc.credentials!.username,
                },
              );
              if (response.statusCode == 200) {
                var data = json.decode(response.body);
                if (data['error']['code'] == '#200') {
                  comments.add(SingleComment.fromJson(data['data']));
                  commentController.clear();
                  comment = '';
                  FocusScope.of(context).unfocus();
                  setState(() {});
                } else if (data['error']["code"] == '#600') {
                  showLogoutDialog(context, data['error']["description"]);
                } else {
                  showErrorDialog(context, data['error']['description']);
                }
              }
            }
          },
          commentController: commentController,
          backgroundColor: Colors.grey[200],
          textColor: Colors.black,
          header: Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey[500]!,
          ),
          sendWidget: Icon(
            Icons.send_sharp,
            size: 30,
            color: comment.isEmpty
                ? Colors.grey
                : Color(int.parse(dc.prelogin!.theme.primary)),
          ),
        ),
      ),
    );
  }

  Widget commentChild() {
    return ListView(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      children: [
        if (comments.isEmpty && loaded)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              const Icon(
                Icons.info_outline,
                size: 100,
              ),
              const SizedBox(height: 10),
              Text(
                "No comments yet",
                style: Theme.of(context).textTheme.headline5,
              ),
              const SizedBox(height: 5),
              const Text("Be the first to comment"),
            ],
          ),
        for (var i = 0; i < comments.length; i++)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: CachedNetworkImage(
                        imageUrl: webUrl +
                            "api/avatar.php?username=" +
                            comments[i].username,
                        fit: BoxFit.cover,
                        height: 50,
                        width: 50,
                      ),
                    ),
                    if (dc.credentials!.pro)
                      Positioned(
                        bottom: -2,
                        right: -2,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.yellow,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.yellow[900]!,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: CachedNetworkImage(
                              imageUrl:
                                  webUrl + dc.prelogindynamic['assets']['royal'],
                              fit: BoxFit.contain,
                              height: 12,
                              width: 12,
                              color: Colors.yellow[900],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  comments[i].name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  comments[i].comment,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: "report",
                                child: Text('Report'),
                              ),
                              if (comments[i].username ==
                                  dc.credentials!.username)
                                const PopupMenuItem(
                                  value: "delete",
                                  child: Text('Delete'),
                                ),
                            ],
                            onSelected: (value) {
                              if (value == "report") {
                                Dialogs.bottomMaterialDialog(
                                  context: context,
                                  lottieBuilder: LottieBuilder.asset(
                                    "assets/json/report.json",
                                    height: 100,
                                    width: 100,
                                    repeat: false,
                                  ),
                                  title: "Report comment",
                                  msg:
                                      "If you find this comment offensive, please report it to the moderators. This will help us to keep the site clean and safe.",
                                  actions: [
                                    IconsOutlineButton(
                                      onPressed: () {
                                        Get.back();
                                      },
                                      text: "Cancel",
                                      iconData: Icons.cancel_outlined,
                                    ),
                                    IconsOutlineButton(
                                      onPressed: () {
                                        // reportComment(comments[i].id,
                                        //     comments[i].username);
                                        Get.back();
                                      },
                                      text: "Report",
                                      iconData: Icons.report_outlined,
                                    ),
                                  ],
                                );
                              } else if (value == "delete") {
                                Dialogs.bottomMaterialDialog(
                                  lottieBuilder: LottieBuilder.asset(
                                    "assets/json/delete.json",
                                    height: 100,
                                    width: 100,
                                    repeat: false,
                                  ),
                                  context: context,
                                  title: "Delete comment",
                                  msg:
                                      "If you delete this comment, it will be permanently deleted and cannot be recovered. Are you sure you want to delete this comment?",
                                  actions: [
                                    IconsOutlineButton(
                                      onPressed: () {
                                        Get.back();
                                      },
                                      iconData: Icons.cancel_outlined,
                                      text: "Cancel",
                                    ),
                                    IconsOutlineButton(
                                      onPressed: () {
                                        Get.back();
                                      },
                                      text: "Delete",
                                      iconData: Icons.delete_outlined,
                                    ),
                                  ],
                                );
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('The Option is not yet available'),
                                ),
                              );
                            },
                            tooltip: "More options",
                            elevation: 12,
                            iconSize: 20,
                            icon: const Icon(Icons.more_vert),
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: VotingsWidget(
                              liked: comments[i].liked,
                              votes: comments[i].votes,
                              type: widget.type,
                              id: comments[i].id.toString(),
                              username: comments[i].username,
                            ),
                          ),
                          Text(
                            convertEpochtoTimeAgo(comments[i].updatedAt),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        if (!loaded)
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: comments.isEmpty
                ? MediaQuery.of(context).size.height * 0.75
                : 30,
            child: const Center(
              child: SizedBox(
                child: CircularProgressIndicator(),
                height: 30,
                width: 30,
              ),
            ),
          ),
      ],
    );
  }
}
