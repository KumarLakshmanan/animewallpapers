
import 'package:get/get.dart';
import 'package:frontendforever/models/prelogin.dart';
import 'package:frontendforever/models/user_credentials.dart';

class DataController extends GetxController {
  UserCredentials? credentials;
  Map<String, dynamic> prelogindynamic = {};
  PreLogin? prelogin;
  Map subjectQuestion = {};
  logOut() {
    prelogindynamic = {};
    credentials = null;
    prelogin = null;
    update();
  }
}
