import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/controllers/data_controller.dart';
import 'package:frontendforever/functions.dart';
import 'package:frontendforever/models/single_activity.dart';
import 'package:frontendforever/profile/edit_card.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityProfile extends StatefulWidget {
  const ActivityProfile({Key? key}) : super(key: key);

  @override
  State<ActivityProfile> createState() => _ActivityProfileState();
}

class _ActivityProfileState extends State<ActivityProfile>
    with AutomaticKeepAliveClientMixin<ActivityProfile> {
  @override
  bool get wantKeepAlive => true;
  final dc = Get.put(DataController());
  List<SingleActivity> activities = [];
  bool loaded = false;
  int pageNo = 1;
  final ScrollController _scrollController = ScrollController();

  getDataFromAPI() async {
    var response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'mode': 'getactivites',
        'email': dc.credentials!.email,
        'token': dc.credentials!.token,
        'username': dc.credentials!.username,
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
          if (!activities
              .any((e) => e.createdAt == data['data'][i]['createdAt'])) {
            activities.add(SingleActivity.fromJson(data['data'][i]));
          } else {
            activities.removeWhere(
                (e) => e.createdAt == data['data'][i]['createdAt']);
            activities.add(SingleActivity.fromJson(data['data'][i]));
          }
        }
        if (data['data'].length != 10) {
          loaded = true;
        }
        setState(() {});
      } else if (data['error']["code"] == '#600') {
        showLogoutDialog(context, data['error']["description"]);
      } else {
        showErrorDialog(context, data['error']['description']);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getDataFromAPI();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (!loaded) {
          pageNo++;
          getDataFromAPI();
        }
      }
    });
  }

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return GetBuilder(
      init: DataController(),
      builder: (c) {
        return ListView(
          controller: _scrollController,
          children: [
            for (var i = 0; i < activities.length; i++)
              myListTile(
                leading: activities[i].thumb,
                title: activities[i].title,
                subtitle: activities[i].description,
                time: activities[i].createdAt,
              ),
            if (loaded && activities.isEmpty)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  const Icon(
                    Icons.info_outline,
                    size: 100,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "You dont have any recent activites",
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            if (!loaded)
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: activities.isEmpty
                    ? MediaQuery.of(context).size.height * 0.5
                    : 30,
                child: const Center(
                  child: SizedBox(
                    child: CircularProgressIndicator(),
                    height: 30,
                    width: 30,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  myListTile({
    required String leading,
    required String title,
    required String subtitle,
    required int time,
  }) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          CachedNetworkImage(
            imageUrl: leading,
            height: 50,
            width: 50,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headline6,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('dd MMMM yyyy hh:mm a')
                      .format(DateTime.fromMillisecondsSinceEpoch(time)),
                  style: Theme.of(context).textTheme.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
