import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:animewallpapers/constants.dart';
import 'package:animewallpapers/functions.dart';
import 'package:animewallpapers/models/single_blog.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class DataController extends GetxController {
  List<ImageType> codes = [];
  bool loaded = false;
  bool loading = false;

  getDataFromAPI({
    String scategory = "",
  }) async {
    if (loading) {
      return;
    }
    loading = true;
    var response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'mode': 'getAllImages',
        'category': scategory,
      },
    );
    if (kDebugMode) {
      print("$apiUrl?mode=getAllImages&category=$scategory");
    }
    try {
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['error']['code'] == '#200') {
          for (var i = 0; i < data['data'].length; i++) {
            codes.add(ImageType.fromJson(data['data'][i]));
          }
          if (data['data'].length < 10) {
            loaded = true;
          }
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
