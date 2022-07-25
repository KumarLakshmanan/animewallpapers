class UserCredentials {
  UserCredentials({
    required this.token,
    required this.id,
    required this.username,
    required this.photo,
    required this.password,
    required this.name,
    required this.email,
    required this.about,
    required this.country,
    required this.skills,
    required this.website,
    required this.role,
    required this.pro,
    required this.createdAt,
  });

  String token;
  int id;
  String username;
  String photo;
  String password;
  String name;
  String email;
  String about;
  String country;
  List<String> skills;
  String website;
  String role;
  bool pro;
  int createdAt;

  factory UserCredentials.fromJson(Map<String, dynamic> json) {
    List<String> skills = [];
    for (var i = 0; i < json['skills'].length; i++) {
      if (json['skills'][i] != null && json['skills'][i].trim() != "") {
        skills.add(json['skills'][i]);
      }
    }

    return UserCredentials(
      token: json["token"],
      id: int.parse(json["id"].toString()),
      username: json["username"],
      photo: json["photo"],
      password: json["password"],
      name: json["name"],
      email: json["email"],
      about: json["about"] ?? "",
      country: json["country"] ?? "",
      skills: skills,
      website: json["website"] ?? "",
      role: json["role"],
      pro: json["pro"] == 1,
      createdAt: json["created_at"],
    );
  }

  Map<String, dynamic> toJson() => {
        "token": token,
        "id": id,
        "username": username,
        "photo": photo,
        "password": password,
        "name": name,
        "email": email,
        "about": about,
        "country": country,
        "skills": skills.join(","),
        "website": website,
        "role": role,
        "pro": pro,
        "created_at": createdAt,
      };
}
