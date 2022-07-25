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
import 'package:shared_preferences/shared_preferences.dart';

class AddWebsite extends StatefulWidget {
  const AddWebsite({
    Key? key,
  }) : super(key: key);

  @override
  _AddWebsiteState createState() => _AddWebsiteState();
}

class _AddWebsiteState extends State<AddWebsite> {
  final TextEditingController websiteController = TextEditingController();
  final d = Get.put(DataController());
  int sended = -1;

  @override
  void initState() {
    super.initState();
    websiteController.text = d.credentials!.website;
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
          title: const Text('Your Website'),
          backgroundColor: Color(int.parse(d.prelogin!.theme.bottombar)),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    TextField(
                      controller: websiteController,
                      maxLines: 1,
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
                        labelText: 'Enter your website link',
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
                    if (websiteController.text.isEmpty) {
                      showAlertDialog(
                          context, 'Please enter your website link');
                      return;
                    }
                    if (!RegExp(
                            r'^(?:http(s)?:\/\/)?[\w.-]+(?:\.[\w.-]+)+[\w\-._~:/?#[\]@!$&\\(\)\*\+,;%=.]+$')
                        .hasMatch(websiteController.text)) {
                      showAlertDialog(
                          context, 'Please enter a valid website link');
                      return;
                    }
                    setState(() {
                      sended = 0;
                    });
                    var response = await http.post(
                      Uri.parse(apiUrl),
                      body: {
                        'mode': 'addProfile',
                        'key': 'website',
                        'token': d.credentials!.token,
                        'username': d.credentials!.username,
                        'email': d.credentials!.email,
                        'value': websiteController.text,
                      },
                    );
                    if (response.statusCode == 200) {
                      var data = json.decode(response.body);
                      if (data['error']["code"] == '#200') {
                        sended = 1;
                        d.credentials!.website = websiteController.text;
                        final prefs = await SharedPreferences.getInstance();
                        prefs.setString('credentials',
                            json.encode(d.credentials!.toJson()));
                        d.update();
                        websiteController.clear();
                        setState(() {});
                        Dialogs.materialDialog(
                          context: context,
                          titleAlign: TextAlign.center,
                          title: 'Website added',
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
                  } else {}
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
                              "Update",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Icon(
                              Icons.arrow_forward_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        )
                      : (sended == 0)
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  "Processing...",
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
                                  "Done.",
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
                                  size: 20,
                                ),
                              ],
                            ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
