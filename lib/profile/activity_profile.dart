import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/controllers/data_controller.dart';
import 'package:frontendforever/functions.dart';
import 'package:frontendforever/models/single_activity.dart';
import 'package:frontendforever/profile/edit_card.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ActivityProfile extends StatefulWidget {
  const ActivityProfile({Key? key}) : super(key: key);

  @override
  State<ActivityProfile> createState() => _ActivityProfileState();
}

class _ActivityProfileState extends State<ActivityProfile> {
  final dc = Get.put(DataController());
  List<SingleActivity> activities = [];
  bool loaded = false;
  int pageNo = 1;
  final ScrollController _scrollController = ScrollController();

  getDataFromAPI() async {
    final prefs = await SharedPreferences.getInstance();
    var response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'mode': 'getActivities',
        'email': dc.credentials!.email,
        'token': dc.credentials!.token,
        'page': pageNo.toString(),
      },
    );
    if (pageNo == 1) {
      activities = [];
    }
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['error']['code'] == '#200') {
        if (pageNo == 1) {
          activities = [];
        }
        for (var i = 0; i < data['data'].length; i++) {
          if (!activities.any((e) => e.id == data['data'][i]['id'])) {
            activities.add(SingleActivity.fromJson(data['data'][i]));
          } else {
            activities.removeWhere((e) => e.id == data['data'][i]['id']);
            activities.add(SingleActivity.fromJson(data['data'][i]));
          }
        }
        if (data['data'].length != 10) {
          loaded = true;
        }
      } else if (data['error']["code"] == '#600') {
        showLogoutDialog(context, data['error']["description"]);
      } else {
        showErrorDialog(context, data['error']['description']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [],
    );
  }
}
