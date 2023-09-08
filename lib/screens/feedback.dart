import 'dart:convert';

import 'package:frontendforever/constants.dart';

import 'package:frontendforever/functions.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({
    Key? key,
  }) : super(key: key);

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController feedbackController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
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
        backgroundColor: secondaryColor,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () {
              Get.back();
            },
          ),
          title: const Text('Submit Feedback'),
          backgroundColor: primaryColor,
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
                      TextField(
                        controller: nameController,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          labelStyle: TextStyle(
                            color: Colors.white,
                          ),
                          labelText: 'Name',
                        ),
                        cursorColor: Colors.white,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 1,
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          labelStyle: const TextStyle(
                            color: Colors.white,
                          ),
                          labelText: 'Email',
                        ),
                        cursorColor: Colors.white,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 1,
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          labelStyle: const TextStyle(
                            color: Colors.white,
                          ),
                          labelText: 'Phone',
                        ),
                        cursorColor: Colors.white,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: feedbackController,
                        maxLines: 5,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          labelStyle: TextStyle(
                            color: Colors.white,
                          ),
                          labelText: 'Enter the Feedback',
                        ),
                        cursorColor: Colors.white,
                        style: const TextStyle(
                          color: Colors.white,
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
                child: MaterialButton(
                  color: primaryColor,
                  onPressed: () async {
                    if (sended == -1) {
                      if (feedbackController.text.isEmpty) {
                        showAlertDialog(context, 'Please enter a feedback');
                        return;
                      }
                      setState(() {
                        sended = 0;
                      });
                      var response = await http.post(
                        Uri.parse(apiUrl),
                        body: {
                          'mode': 'contactMessage',
                          'name': nameController.text,
                          'email': emailController.text,
                          'phone': phoneController.text,
                          'message': feedbackController.text,
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
                          showErrorDialog(
                              context, data['error']['description']);
                        }
                      } else {
                        showErrorDialog(context, 'Something went wrong');
                      }
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: (sended == -1)
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
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
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
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
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
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
