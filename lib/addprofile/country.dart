import 'dart:convert';

import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
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

class AddCountry extends StatefulWidget {
  const AddCountry({
    Key? key,
  }) : super(key: key);

  @override
  _AddCountryState createState() => _AddCountryState();
}

class _AddCountryState extends State<AddCountry> {
  final d = Get.put(DataController());
  int sended = -1;

  Country _selectedDialogCountry =
      CountryPickerUtils.getCountryByPhoneCode('91');
  @override
  void initState() {
    super.initState();
    if (d.credentials!.country != "") {
      _selectedDialogCountry =
          CountryPickerUtils.getCountryByName(d.credentials!.country);
    }
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
          title: const Text('Your Country'),
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
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => CountryPickerDialog(
                            onValuePicked: (Country country) {
                              setState(() {
                                _selectedDialogCountry = country;
                              });
                            },
                            priorityList: [
                              CountryPickerUtils.getCountryByIsoCode('IN'),
                              CountryPickerUtils.getCountryByIsoCode('US'),
                              CountryPickerUtils.getCountryByIsoCode('GB'),
                            ],
                            itemBuilder: buildDialogItem,
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Color(int.parse(d.prelogin!.theme.primary)),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.all(14.0),
                        child: Row(
                          children: [
                            Container(
                              height: 20.0,
                              width: 20.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: AssetImage(
                                    CountryPickerUtils.getFlagImageAssetPath(
                                        _selectedDialogCountry.isoCode),
                                    package: "country_pickers",
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.black,
                              size: 20,
                            ),
                            Text(
                              _selectedDialogCountry.name,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
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
                    setState(() {
                      sended = 0;
                    });
                    var response = await http.post(
                      Uri.parse(apiUrl),
                      body: {
                        'mode': 'addProfile',
                        'key': 'country',
                        'value': _selectedDialogCountry.name,
                        'token': d.credentials!.token,
                        'username': d.credentials!.username,
                        'email': d.credentials!.email,
                      },
                    );
                    if (response.statusCode == 200) {
                      var data = json.decode(response.body);
                      if (data['error']["code"] == '#200') {
                        sended = 1;
                        d.credentials!.country = _selectedDialogCountry.name;
                        final prefs = await SharedPreferences.getInstance();
                        prefs.setString('credentials',
                            json.encode(d.credentials!.toJson()));
                        d.update();
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

Widget buildDialogItem(Country country) {
  return Row(
    children: <Widget>[
      Image.asset(
        CountryPickerUtils.getFlagImageAssetPath(country.isoCode),
        height: 15.0,
        width: 24.0,
        fit: BoxFit.fill,
        package: "country_pickers",
      ),
      const SizedBox(width: 8.0),
      Expanded(
        child: Text(
          country.name,
          style: const TextStyle(
            fontSize: 14.0,
            color: Colors.black,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}
