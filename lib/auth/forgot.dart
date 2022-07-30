import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/controllers/data_controller.dart';
import 'package:frontendforever/functions.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:frontendforever/widgets/all_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import 'package:neopop/widgets/buttons/neopop_button/neopop_button.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final dc = Get.put(DataController());
  final forgotPasswordController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  login() async {
    if (forgotPasswordController.text.isEmpty) {
      showAlertDialog(
        context,
        'Email or Username is empty',
        lottie: true,
      );
    } else {
      showLoadingDialog();
      try {
        var response = await http.post(
          Uri.parse(apiUrl),
          body: {
            'mode': "forgotpass",
            'username': forgotPasswordController.text,
          },
        );
        Get.back();
        if (response.statusCode == 200) {
          var jsonResponse = json.decode(response.body);
          if (jsonResponse['error']['code'] == '#200') {
            Dialogs.materialDialog(
              context: context,
              title: 'Email Sent',
              msg:
                  "Please check your email for reset password. The link will expire in 1 hour.",
              lottieBuilder: Lottie.asset(
                'assets/json/success.json',
                repeat: false,
                fit: BoxFit.contain,
              ),
              actions: [
                IconsOutlineButton(
                  onPressed: () {
                    Get.back();
                    Get.back();
                  },
                  text: 'Go Back to Login',
                  iconData: Icons.arrow_back,
                ),
              ],
            );
          } else {
            showAlertDialog(
              context,
              jsonResponse['message'],
              lottie: true,
            );
          }
        } else {
          showErrorDialog(context, 'Something went wrong', lottie: false);
        }
      } catch (e) {
        showErrorDialog(context, e.toString(), lottie: false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.all(14.0),
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * .025),
              Text(
                "Change Password",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF30475E),
                  fontFamily: GoogleFonts.poppins().fontFamily,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "We will send password changing link to your email. You can change your password after clicking the link. The link will expire in 1 hour.",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              EntryField(
                title: "Enter Your Email of Username",
                controller: forgotPasswordController,
                isSubmit: login,
                color: Color(int.parse(dc.prelogin!.theme.primary)),
              ),
              const SizedBox(
                height: 10,
              ),
              NeoPopButton(
                color: Color(int.parse(dc.prelogin!.theme.primary)),
                onTapUp: login,
                onTapDown: () => HapticFeedback.vibrate(),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "Get Reset Link",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      ),
                    ],
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
