
import 'package:get/get.dart';
import 'package:frontendforever/types/prelogin.dart';
import 'package:frontendforever/types/user_credentials.dart';

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
