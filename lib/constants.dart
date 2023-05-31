import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const String kAppTitle = "Termux Tools & Commands";
const String kAppDescription = "Open-Source projects library";

List<BoxShadow> boxShadow = [
  // box-shadow: rgba(149, 157, 165, 0.2) 0px 8px 24px;
  const BoxShadow(
    color: Color.fromRGBO(149, 157, 165, 0.2),
    offset: Offset(0, 8),
    blurRadius: 24,
  ),
];
// Color primaryColor = const Color(0xFF000000);
// Color secondaryColor = const Color(0xFFDD0046);
Color primaryColor = const Color(0xFF131417);
Color secondaryColor = const Color(0xFF2C303A);
Color appBarColor = const Color(0xFF1E1F25);

Color backgroundColor = const Color(0xFFFFFFFF);
String webUrl = "https://termux.frontendforever.com/";
String apiUrl = "https://termux.frontendforever.com/api/v1.php";
