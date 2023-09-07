import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontendforever/constants.dart';
import 'package:frontendforever/models/announce_type.dart';
import 'package:frontendforever/shimmer/restaurant_shimmer.dart';
import 'package:frontendforever/widgets/inline_ad.dart';
import 'package:frontendforever/widgets/news_card.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Announcements extends StatefulWidget {
  final String type;
  const Announcements({
    super.key,
    this.type = 'announcement',
  });

  @override
  State<Announcements> createState() => _AnnouncementsState();
}

class _AnnouncementsState extends State<Announcements> {
  List<AnnouncementType> announceData = [];
  final ScrollController _scrollController = ScrollController();
  bool loaded = false;
  int pageNo = 1;
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 1), () async {
      getAnnounceData();
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        pageNo++;
        getAnnounceData();
      }
    });
    super.initState();
  }

  getAnnounceData() async {
    final prefs = await SharedPreferences.getInstance();
    final links = jsonDecode(prefs.getString(announcementsKey) ?? "[]");
    if (links != null) {
      for (var i = 0; i < links.length; i++) {
        announceData.add(AnnouncementType.fromJson((links)[i]));
      }
      announceData.sort((a, b) => b.id.compareTo(a.id));
      if (mounted) {
        setState(() {});
      }
    }
    var res =
        await http.get(Uri.parse('$apiUrl?mode=getannouncements&page=$pageNo'));
    if (kDebugMode) {
      print('$apiUrl?mode=getannouncements&page=$pageNo');
    }
    if (res.statusCode == 200) {
      try {
        var jsonData = jsonDecode(res.body);
        if (jsonData['error']['code'] == '#200') {
          if (pageNo == 1) {
            announceData = [];
          }
          for (var i = 0; i < jsonData['data'].length; i++) {
            announceData.add(AnnouncementType.fromJson(jsonData['data'][i]));
          }
          announceData.sort((a, b) => b.id.compareTo(a.id));
          prefs.setString(announcementsKey, jsonEncode(jsonData['data']));
          if (jsonData['data'].length < 10) {
            loaded = true;
          }
          if (mounted) {
            setState(() {});
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        title: const Text("News & Announcements"),
        backgroundColor: primaryColor,
      ),
      body: ListView(
        controller: _scrollController,
        shrinkWrap: true,
        children: [
          if (announceData.isNotEmpty)
            for (int i = 0; i < announceData.length; i++) ...[
              NewsCard(item: announceData[i]),
              if (i % 3 == 0 && i != 0) ...[
                const Padding(
                  padding: EdgeInsets.only(left: 8, right: 8),
                  child: InlineAdWidget(),
                ),
              ]
            ],
          if (!loaded) ...[
            const WallpaperShimmer(),
            if (announceData.isEmpty) ...[
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    "No Data Found...",
                  ),
                ),
              ),
            ]
          ],
        ],
      ),
    );
  }
}
