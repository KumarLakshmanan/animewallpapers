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

String webUrl = "https://frontendforever.com/";
String apiUrl = "https://frontendforever.com/api/v3.php";