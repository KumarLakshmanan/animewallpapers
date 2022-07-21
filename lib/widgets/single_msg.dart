import 'package:flutter/material.dart';
import 'package:frontendforever/controllers/data_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SingleMessage extends StatefulWidget {
  final String user;
  final int time;
  final String name;
  final String msg;
  final String cUser;
  const SingleMessage({
    Key? key,
    required this.user,
    required this.time,
    required this.name,
    required this.msg,
    required this.cUser,
  }) : super(key: key);

  @override
  _SingleMessageState createState() => _SingleMessageState();
}

class _SingleMessageState extends State<SingleMessage> {
  bool isClicked = false;
  final c = Get.find<DataController>();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    isClicked = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isClicked = !isClicked;
        });
        Future.delayed(const Duration(milliseconds: 3000), () {
          setState(() {
            isClicked = false;
          });
        });
      },
      child: Container(
        padding: const EdgeInsets.all(5),
        child: Align(
          alignment: (widget.user != widget.cUser
              ? Alignment.topLeft
              : Alignment.topRight),
          child: Column(
            crossAxisAlignment: (widget.user != widget.cUser
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end),
            children: [
              if (widget.user != widget.cUser)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    widget.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: widget.user == widget.cUser
                          ? Color(int.parse(c.prelogin!.theme.primary))
                          : Color(int.parse(c.prelogin!.theme.secondary)),
                    ),
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: widget.user == widget.cUser
                        ? const Radius.circular(0)
                        : const Radius.circular(10),
                    topLeft: widget.user == widget.cUser
                        ? const Radius.circular(10)
                        : const Radius.circular(0),
                    bottomLeft: const Radius.circular(10),
                    bottomRight: const Radius.circular(10),
                  ),
                  color: widget.user != widget.cUser
                      ? Color(int.parse(c.prelogin!.theme.secondary))
                          .withOpacity(0.15)
                      : Color(int.parse(c.prelogin!.theme.primary))
                          .withOpacity(0.15),
                ),
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 8,
                  bottom: 8,
                ),
                margin: const EdgeInsets.only(
                  left: 5,
                  right: 5,
                ),
                child: Text(
                  widget.msg,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
              isClicked
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      child: Text(
                        DateFormat('dd MMM, hh:mm a').format(
                            DateTime.fromMillisecondsSinceEpoch(widget.time)),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
