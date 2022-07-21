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
    required this.primary,
    required this.secondary,
    required this.bottombar,
    required this.bottombaractive,
    required this.background,
  });

  String primary;
  String secondary;
  String bottombar;
  String bottombaractive;
  String background;

  factory Theme.fromJson(Map<String, dynamic> json) => Theme(
        primary: json["primary"],
        secondary: json["secondary"],
        bottombar: json["bottombar"],
        bottombaractive: json["bottombaractive"],
        background: json["background"],
      );

  Map<String, dynamic> toJson() => {
        "primary": primary,
        "secondary": secondary,
        "bottombar": bottombar,
        "bottombaractive": bottombaractive,
        "background": background,
      };
}
