import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontendforever/api.dart';
import 'package:frontendforever/controllers/theme_controller.dart';
import 'package:frontendforever/widgets/all_widget.dart';
import 'package:neopop/neopop.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontendforever/widgets/buttons.dart';

import '../functions.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    Key? key,
  }) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
  login() async {
    if (_emailController.text.isEmpty) {
      showAlertDialog(context, 'Email is empty');
      return;
    }
    if (_passwordController.text.isEmpty) {
      showAlertDialog(context, 'Password is empty');
      return;
    } else {
      if (_passwordController.text.length < 4) {
        showAlertDialog(context, 'Password must be at least 4 characters');
        return;
      } else {
        if (!_emailController.text.contains(
            RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$'))) {
          showAlertDialog(context, 'Email is not valid');
          return;
        } else {
          showLoadingDialog();
          try {
            var response = await http.post(
              Uri.parse(apiUrl),
              body: {
                'mode': "login",
                'email': _emailController.text,
                'password': _passwordController.text,
              },
            );
            Get.back();
            if (response.statusCode == 200) {
              getLogin(
                response.body,
                _emailController.text,
                _passwordController.text,
                context,
              );
            } else {
              showErrorDialog(context, 'Something went wrong');
            }
          } catch (e) {
            showErrorDialog(context, e.toString());
          }
        }
      }
    }
  }

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 40,
          left: 20,
          right: 20,
          bottom: 20,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            EntryField(
              title: "Email Id",
              controller: _emailController,
              isEmail: true,
            ),
            EntryField(
              title: "Password",
              controller: _passwordController,
              isPassword: true,
              isSubmit: login,
            ),
            const SizedBox(height: 10),
            NeoPopButton(
              color: Color(0xFF30475E),
              onTapUp: () {
                login();
              },
              onTapDown: () => HapticFeedback.vibrate(),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "Login",
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
                    "Login With",
                    style: TextStyle(
                      color: Color(0xFF30475E),
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
              color: Color(0xFF30475E),
              onTapUp: (){
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
