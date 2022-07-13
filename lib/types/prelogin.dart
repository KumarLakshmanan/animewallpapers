import 'package:flutter/cupertino.dart';

class PreLogin {
  PreLogin({
    required this.website,
    required this.theme,
    required this.feedback,
  });

  String website;
  Theme theme;
  List<String> feedback;
  factory PreLogin.fromJson(Map<String, dynamic> json) => PreLogin(
        website: json["website"],
        theme: Theme.fromJson(json["theme"]),
        feedback: List<String>.from(json["feedback"]),
      );

  Map<String, dynamic> toJson() => {
        "website": website,
        "theme": theme.toJson(),
        "feedback": feedback,
      };
}

class Theme {
  Theme({
    required this.primay,
    required this.secondary,
    required this.accents,
    required this.textPrimary,
    required this.textSecondary,
    required this.background,
    required this.canvas,
  });

  String primay;
  String secondary;
  String accents;
  String textPrimary;
  String textSecondary;
  String background;
  String canvas;

  factory Theme.fromJson(Map<String, dynamic> json) => Theme(
        primay: json["primay"],
        secondary: json["secondary"],
        accents: json["accents"],
        textPrimary: json["textPrimary"],
        textSecondary: json["textSecondary"],
        background: json["background"],
        canvas: json["canvas"],
      );

  Map<String, dynamic> toJson() => {
        "primay": primay,
        "secondary": secondary,
        "accents": accents,
        "textPrimary": textPrimary,
        "textSecondary": textSecondary,
        "background": background,
        "canvas": canvas,
      };
}
