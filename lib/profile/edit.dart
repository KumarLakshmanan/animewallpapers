import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/controllers/data_controller.dart';
import 'package:frontendforever/functions.dart';
import 'package:frontendforever/widgets/all_widget.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import 'package:neopop/widgets/buttons/neopop_button/neopop_button.dart';

class EditDetails extends StatefulWidget {
  const EditDetails({
    Key? key,
  }) : super(key: key);

  @override
  _EditDetailsState createState() => _EditDetailsState();
}

class _EditDetailsState extends State<EditDetails> {
  final dc = Get.put(DataController());
  final nameControler = TextEditingController();
  final phoneControler = TextEditingController();
  final addressControler = TextEditingController();
  final fatherName = TextEditingController();
  DateTime? dob = DateTime.now();
  int sended = -1;
  @override
  void initState() {
    super.initState();
    nameControler.text = dc.credentials!.name;
    phoneControler.text = dc.credentials!.phone;
    addressControler.text = dc.credentials!.address;
    fatherName.text = dc.credentials!.fname;
    dob = dc.credentials!.dob != 0
        ? DateTime.fromMillisecondsSinceEpoch(dc.credentials!.dob)
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(int.parse(dc.prelogin!.theme.bottombar)),
          title: const Text("Edit Profile"),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Please fill in the details below to update your profile",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(int.parse(dc.prelogin!.theme.primary)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: EntryField(
                      title: "Enter your name",
                      controller: nameControler,
                      color: Color(int.parse(dc.prelogin!.theme.primary)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: EntryField(
                      title: "Enter your phone number",
                      controller: phoneControler,
                      color: Color(int.parse(dc.prelogin!.theme.primary)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: EntryField(
                      title: "Enter your father's name",
                      controller: fatherName,
                      color: Color(int.parse(dc.prelogin!.theme.primary)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  dob != null
                                      ? DateFormat("dd MMMM yyyy").format(dob!)
                                      : "Select your date of birth",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: dob != null
                                        ? Colors.black
                                        : Color(int.parse(
                                                dc.prelogin!.theme.primary))
                                            .withOpacity(0.4),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              GestureDetector(
                                child: const Icon(Icons.calendar_today),
                                onTap: () async {
                                  showDatePicker(
                                    context: context,
                                    initialDate: dob ?? DateTime.now(),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime(2050),
                                  ).then((value) {
                                    if (value != null) {
                                      setState(() {
                                        dob = value;
                                      });
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          thickness: 1.5,
                          color: Color(int.parse(dc.prelogin!.theme.primary)),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: EntryField(
                      title: "Enter your address",
                      controller: addressControler,
                      color: Color(int.parse(dc.prelogin!.theme.primary)),
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: NeoPopButton(
                  color: Color(int.parse(dc.prelogin!.theme.primary)),
                  onTapUp: () async {
                    FocusScope.of(context).unfocus();
                    if (sended == -1) {
                      setState(() {
                        sended = 0;
                      });
                      var response = await http.post(
                        Uri.parse(apiUrl),
                        body: {
                          'mode': 'saveProfile',
                          'name': nameControler.text,
                          'phone': phoneControler.text,
                          'address': addressControler.text,
                          'fname': fatherName.text,
                          'dob': (dob?.millisecondsSinceEpoch ?? 0).toString(),
                          'token': dc.credentials!.token,
                          'username': dc.credentials!.username,
                          'email': dc.credentials!.email,
                        },
                      );
                      print(response.body);
                      if (response.statusCode == 200) {
                        var data = json.decode(response.body);
                        if (data['error']["code"] == '#200') {
                          dc.credentials!.name = nameControler.text;
                          dc.credentials!.phone = phoneControler.text;
                          dc.credentials!.address = addressControler.text;
                          dc.credentials!.fname = fatherName.text;
                          dc.credentials!.dob = dob?.millisecondsSinceEpoch ??
                              0;
                          dc.update();
                          setState(() {
                            sended = 1;
                          });
                          nameControler.clear();
                          phoneControler.clear();
                          addressControler.clear();
                          fatherName.clear();
                          dob = null;
                          setState(() {
                            sended = 1;
                          });
                          Get.back();
                          Dialogs.materialDialog(
                            context: context,
                            titleAlign: TextAlign.center,
                            title: 'Profile saved Successfully',
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
                    setState(() {
                      sended = 0;
                    });
                  },
                  onTapDown: () => HapticFeedback.vibrate(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: (sended == -1)
                        ? const Center(
                            child: Text(
                              "Save Profile",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : (sended == 0)
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    "Saving...",
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
                                    "Saved",
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
              )
            ],
          ),
        ),
      ),
    );
  }
}

Widget _formTextField(
    DataController dc, String label, String initialValue, Function onChanged) {
  return Container(
    padding: const EdgeInsets.all(0),
    margin: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: Colors.grey[100]!,
        width: 1,
      ),
    ),
    child: Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 4.0,
          ),
          child: TextFormField(
            minLines: 1,
            initialValue: initialValue,
            maxLines: 5,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              border: InputBorder.none,
              label: Text(
                label,
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
              hintStyle: const TextStyle(
                color: Colors.black,
              ),
            ),
            style: const TextStyle(color: Colors.black),
            cursorColor: Colors.black,
            onChanged: (value) {
              onChanged(value);
            },
          ),
        ),
      ],
    ),
  );
}
