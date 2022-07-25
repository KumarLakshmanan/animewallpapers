
import 'package:get/get.dart';
import 'package:frontendforever/models/prelogin.dart';
import 'package:frontendforever/models/user_credentials.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataController extends GetxController {
  UserCredentials? credentials;
  int gemCount = 0;
  Map<String, dynamic> prelogindynamic = {};
  PreLogin? prelogin;
  Map subjectQuestion = {};
  logOut() {
    prelogindynamic = {};
    gemCount = 0;
    credentials = null;
    prelogin = null;
    update();
  }
  decreaseGems(int count) async {
    final prefs = await SharedPreferences.getInstance();
    gemCount -= count;
    prefs.setInt("gemCount", gemCount);
    update();
  }
}
