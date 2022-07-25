import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/controllers/data_controller.dart';
import 'package:frontendforever/models/single_comment.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class VotingsWidget extends StatefulWidget {
  final String id;
  final String type;
  final int liked;
  final int votes;
  final String username;
  const VotingsWidget({
    Key? key,
    required this.id,
    required this.type,
    required this.liked,
    required this.votes,
    required this.username,
  }) : super(key: key);

  @override
  State<VotingsWidget> createState() => _VotingsWidgetState();
}

class _VotingsWidgetState extends State<VotingsWidget> {
  final dc = Get.find<DataController>();
  int like = 0;
  int votesCount = 0;
  @override
  void initState() {
    super.initState();
    like = widget.liked;
    votesCount = widget.votes;
  }

  voteCommment() async {
    await http.post(
      Uri.parse(apiUrl),
      body: {
        "mode": "vote",
        "type": widget.type,
        "id": widget.id.toString(),
        "vote": like.toString(),
        "email": dc.credentials!.email,
        "username": dc.credentials!.username,
        "token": dc.credentials!.token,
        "forusername": widget.username,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              if (like == 1) {
                like = 0;
                votesCount--;
              } else if (like == -1) {
                like = 1;
                votesCount += 2;
              } else {
                like = 1;
                votesCount++;
              }
            });
            voteCommment();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Icon(
              Icons.keyboard_arrow_up,
              size: 25,
              color: like == 1
                  ? Color(int.parse(dc.prelogin!.theme.primary))
                  : Colors.grey,
            ),
          ),
        ),
        Text(
          votesCount.toString(),
          style: TextStyle(
            fontSize: 16,
            color: Color(int.parse(dc.prelogin!.theme.primary)),
          ),
        ),
        InkWell(
          onTap: () {
            setState(() {
              if (like == -1) {
                like = 0;
                votesCount++;
              } else if (like == 1) {
                like = -1;
                votesCount -= 2;
              } else {
                like = -1;
                votesCount--;
              }
            });
            voteCommment();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Icon(
              Icons.keyboard_arrow_down,
              size: 25,
              color: like == -1
                  ? Color(int.parse(dc.prelogin!.theme.primary))
                  : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}

class AppLause extends StatefulWidget {
  final String id;
  final String type;
  final int liked;
  final int votes;
  final String username;
  const AppLause({
    Key? key,
    required this.id,
    required this.type,
    required this.liked,
    required this.votes,
    required this.username,
  }) : super(key: key);

  @override
  State<AppLause> createState() => _AppLauseState();
}

class _AppLauseState extends State<AppLause> {
  final dc = Get.find<DataController>();
  int like = 0;
  int votesCount = 0;
  @override
  void initState() {
    super.initState();
    like = widget.liked;
    votesCount = widget.votes;
  }

  voteCommment() async {
    await http.post(
      Uri.parse(apiUrl),
      body: {
        "mode": "vote",
        "type": widget.type,
        "id": widget.id.toString(),
        "vote": like.toString(),
        "email": dc.credentials!.email,
        "username": dc.credentials!.username,
        "token": dc.credentials!.token,
        "forusername": widget.username,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              if (like == 1) {
              } else if (like == -1) {
              } else {
                like = 1;
                votesCount++;
                voteCommment();
              }
            });
          },
          child: Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: like == 1
                  ? Color(int.parse(dc.prelogin!.theme.primary))
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Color(int.parse(dc.prelogin!.theme.primary)),
                width: 1,
              ),
            ),
            child: Center(
              child: Image.asset(
                'assets/icons/clap.png',
                height: 30,
                width: 30,
                color: like == 1
                    ? Colors.white
                    : Color(int.parse(dc.prelogin!.theme.primary)),
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        Text(
          votesCount.toString(),
          style: TextStyle(
            fontSize: 20,
            color: Color(int.parse(dc.prelogin!.theme.primary)),
          ),
        ),
      ],
    );
  }
}
