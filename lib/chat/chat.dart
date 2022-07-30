import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontendforever/controllers/data_controller.dart';
import 'package:frontendforever/chat/chat_message.dart';
import 'package:frontendforever/widgets/single_msg.dart';
import 'package:get/get.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<ChatMessage> messages = [];
  final commentController = TextEditingController();
  final c = Get.find<DataController>();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              bottom: 40,
            ),
            child: messages.isEmpty
                ? Column(
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
                  )
                : Padding(
                    padding: const EdgeInsets.only(bottom: 18.0),
                    child: ListView.builder(
                      itemCount: messages.length,
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return SingleMessage(
                          time: messages[index].time,
                          name: messages[index].name,
                          msg: messages[index].msg,
                          user: messages[index].user,
                          cUser: c.credentials!.username,
                        );
                      },
                    ),
                  ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 15,
                bottom: 10,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(
                        left: 10,
                        bottom: 5,
                        top: 5,
                        right: 0,
                      ),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                        color: Color(int.parse(c.prelogin!.theme.primary)),
                      ),
                      child: TextFormField(
                        controller: commentController,
                        minLines: 1,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText: "Write message...",
                          hintStyle: TextStyle(
                            color: Colors.grey,
                          ),
                          border: InputBorder.none,
                        ),
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.done,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  FloatingActionButton(
                    backgroundColor: Color(int.parse(c.prelogin!.theme.primary)),
                    onPressed: () {
                      // saveComment();
                    },
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
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
