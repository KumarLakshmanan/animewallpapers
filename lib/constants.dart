import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const String kAppTitle = "Frontend Forever";
const String kAppDescription = "Open-Source projects library";

List<BoxShadow> boxShadow = [
  // box-shadow: rgba(149, 157, 165, 0.2) 0px 8px 24px;
  const BoxShadow(
    color: Color.fromRGBO(149, 157, 165, 0.2),
    offset: Offset(0, 8),
    blurRadius: 24,
  ),
];

class FirestoreConstants {
  static const pathUserCollection = "users";
  static const pathMessageCollection = "messages";
  static const displayName = "displayName";
  static const aboutMe = "aboutMe";
  static const photoUrl = "photoUrl";
  static const phoneNumber = "phoneNumber";
  static const id = "id";
  static const chattingWith = "chattingWith";
  static const idFrom = "idFrom";
  static const idTo = "idTo";
  static const timestamp = "timestamp";
  static const content = "content";
  static const type = "type";
  static const email = "email";
}
