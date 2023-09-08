import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:animewallpapers/constants.dart';
import 'package:animewallpapers/functions.dart';
import 'package:animewallpapers/models/single_blog.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class PremiumController extends GetxController {
  List<ImageType> codes = [];
  String category = "random";
  int pageNo = 1;
  bool loaded = false;
  bool loading = false;
  TextEditingController searchText = TextEditingController(text: '');
  String search = "";
  getDataFromAPI({
    String scategory = "",
  }) async {
    if (loading) {
      return;
    }
    if (scategory == "") {
      return;
    }
    if (scategory != "") {
      scategory = category;
    }
    loading = true;
    var response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'mode': 'getAllImages',
        'category': scategory,
        'subcategory': 'premium',
        'page': pageNo.toString(),
        'search': search,
        'limit': "12",
      },
    );
    if (kDebugMode) {
      print(
          "$apiUrl?mode=getAllImages&page=$pageNo&category=$category&search=$search");
    }
    try {
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['error']['code'] == '#200') {
          if (pageNo == 1) {
            codes = [];
          }
          for (var i = 0; i < data['data'].length; i++) {
            codes.add(ImageType.fromJson(data['data'][i]));
          }
          if (data['data'].length < 12) {
            loaded = true;
          }
          pageNo++;
          loading = false;
          update();
        } else {
          snackbar(
            "Sorry",
            data['error']['descripiton'],
          );
        }
      }
    } catch (e) {
      snackbar(
        "Sorry, something went wrong!",
        "Error: $e",
      );
    }
  }
}
