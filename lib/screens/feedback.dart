import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/controllers/data_controller.dart';
import 'package:frontendforever/functions.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import 'package:neopop/neopop.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({
    Key? key,
  }) : super(key: key);

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController feedbackController = TextEditingController();
  final d = Get.put(DataController());
  int sended = -1;
  String? feedbackCategory;
  @override
  initState() {
    super.initState();
  }

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      onSecondaryLongPress: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Submit Feedback'),
          backgroundColor: Color(int.parse(d.prelogin!.theme.bottombar)),
        ),
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          border: Border.all(
                            color: Color(int.parse(d.prelogin!.theme.primary)),
                            width: 1,
                          ),
                        ),
                        child: DropdownButton(
                          hint: const Text('Select Category'),
                          underline: const SizedBox(),
                          isExpanded: true,
                          items: d.prelogin!.feedback.map((String category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              feedbackCategory = newValue;
                            });
                          },
                          value: feedbackCategory,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: feedbackController,
                        maxLines: 5,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(int.parse(d.prelogin!.theme.primary)),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(int.parse(d.prelogin!.theme.primary)),
                              width: 2,
                            ),
                          ),
                          labelText: 'Enter the Feedback',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 10,
                bottom: 10,
                right: 10,
                child: NeoPopButton(
                  color: Color(int.parse(d.prelogin!.theme.primary)),
                  onTapUp: () async {
                    if (sended == -1) {
                      if (feedbackCategory == null) {
                        showAlertDialog(context, 'Please select a category');
                      } else if (feedbackController.text.isEmpty) {
                        showAlertDialog(context, 'Please enter a feedback');
                      }
                      setState(() {
                        sended = 0;
                      });
                      var response = await http.post(
                        Uri.parse(apiUrl),
                        body: {
                          'mode': 'contactMessage',
                          'name': d.credentials!.name +
                              ' @' +
                              d.credentials!.username,
                          'email': d.credentials!.email,
                          'message':
                              (feedbackCategory ?? "-----------") + "\n\n" + feedbackController.text,
                        },
                      );
                      if (response.statusCode == 200) {
                        var data = json.decode(response.body);
                        if (data['error']["code"] == '#200') {
                          feedbackController.clear();
                          feedbackCategory = null;
                          setState(() {
                            sended = 1;
                          });
                          Dialogs.materialDialog(
                            context: context,
                            titleAlign: TextAlign.center,
                            title: 'Feedback Sent Successfully',
                            lottieBuilder: Lottie.asset(
                              'assets/json/success.json',
                              repeat: false,
                              fit: BoxFit.contain,
                            ),
                            actions: [
                              IconsOutlineButton(
                                onPressed: () {
                                  Get.back();
                                },
                                text: 'Continue',
                                iconData: Icons.arrow_forward_outlined,
                              ),
                            ],
                          );
                        } else {
                          showErrorDialog(context, data['error']['description']);
                        }
                      } else {
                        showErrorDialog(context, 'Something went wrong');
                      }
                    }
                    setState(() {
                      sended = 0;
                    });
                  },
                  onTapDown: () => HapticFeedback.vibrate(),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: (sended == -1)
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                "Send feedback",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Icon(
                                Icons.send,
                                color: Colors.white,
                              ),
                            ],
                          )
                        : (sended == 0)
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    "Sending...",
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
                                    child: CircularProgressIndicator(
                                      backgroundColor: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    "Sended",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Icon(
                                    Icons.check,
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
    );
  }
}
