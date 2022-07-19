import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:frontendforever/controllers/data_controller.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/controllers/theme_controller.dart';
import 'package:frontendforever/screens/onboarding.dart';
import 'package:frontendforever/screens/splash_screen.dart';
import 'package:frontendforever/widgets/all_widget.dart';
import 'package:neopop/neopop.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontendforever/widgets/buttons.dart';

import '../functions.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({
    Key? key,
  }) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final d = Get.put(DataController());
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullnameController = TextEditingController();
  GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  @override
  initState() {
    super.initState();
    googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      print(account);
    });
  }

  Future<void> handleSignIn(BuildContext context) async {
    try {
      GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email'],
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return;
      } else {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        if (googleAuth.accessToken != '') {
          var accessToken = googleAuth.accessToken;
          var regId = await getAndroidRegId();
          var response = await http.post(
            Uri.parse(apiUrl),
            body: {
              'mode': 'glogin',
              'regid': regId,
              'access_token': accessToken,
              'email': googleUser.email,
              'name': googleUser.displayName,
              'id': googleUser.id,
              'photo': googleUser.photoUrl,
            },
          );
          print(response.body);
          if (response.statusCode == 200) {
            getLogin(
              response.body,
              googleUser.email,
              googleUser.id,
              context,
            );
          } else {
            showErrorDialog(context, 'Something went wrong');
          }
        }
      }
    } catch (error) {
      print(error);
    }
  }

  register() async {
    if (_emailController.text.isEmpty) {
      showAlertDialog(
        context,
        'Email is empty',
        lottie: true,
      );
      return;
    }
    if (_passwordController.text.isEmpty) {
      showAlertDialog(
        context,
        'Password is empty',
        lottie: true,
      );
      return;
    } else {
      if (_emailController.text.length < 4) {
        showAlertDialog(
          context,
          'email must be at least 4 characters',
          lottie: true,
        );
        return;
      } else {
        if (_passwordController.text.length < 4) {
          showAlertDialog(
            context,
            'Password must be at least 4 characters',
            lottie: true,
          );
          return;
        } else {
          if (!_emailController.text
              .contains(RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+'))) {
            showAlertDialog(
              context,
              'email is not valid.',
              lottie: true,
            );
            return;
          } else {
            showLoadingDialog();
            try {
              var regId = await getAndroidRegId();
              var response = await http.post(
                Uri.parse(apiUrl),
                body: {
                  'mode': 'register',
                  'regid': regId,
                  'email': _emailController.text,
                  'password': _passwordController.text,
                  'fullname': _fullnameController.text,
                },
              );
              print(response.body);
              Get.back();
              if (response.statusCode == 200) {
                getLogin(
                  response.body,
                  _emailController.text,
                  _passwordController.text,
                  context,
                );
              } else {
                showAlertDialog(
                  context,
                  'Something went wrong',
                  lottie: true,
                );
              }
            } catch (e) {
              print(e);
            }
          }
        }
      }
    }
  }

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            EntryField(
              title: "Fullname",
              controller: _fullnameController,
            ),
            EntryField(
              title: "Email Id",
              controller: _emailController,
              isEmail: true,
            ),
            EntryField(
              title: "Password",
              controller: _passwordController,
              isPassword: true,
              isSubmit: register,
            ),
            const SizedBox(
              height: 20,
            ),
            NeoPopButton(
              color: Color(int.parse(d.prelogin!.theme.primary)),
              onTapUp: register,
              onTapDown: () => HapticFeedback.vibrate(),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "Register",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            Row(
              children: <Widget>[
                buildDivider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Register With",
                    style: TextStyle(
                      color: Color(int.parse(d.prelogin!.theme.primary)),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                buildDivider(),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            NeoPopButton(
              color: Color(int.parse(d.prelogin!.theme.primary)),
              onTapUp: () {
                handleSignIn(context);
              },
              onTapDown: () => HapticFeedback.vibrate(),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icons/google_color.png',
                      width: 25,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text(
                      "Continue with Google",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
