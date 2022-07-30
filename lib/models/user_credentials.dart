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
    required this.phone,
    required this.fname,
    required this.dob,
    required this.address,
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
  String phone;
  String fname;
  int dob;
  bool pro;
  int createdAt;
  String address;
  factory UserCredentials.fromJson(Map<String, dynamic> json) {
    List<String> skills = [];
    if (json['skills'] != null) {
      skills = json['skills'].cast<String>();
    } else {
      for (var i = 0; i < json['skills'].length; i++) {
        if (json['skills'][i].runtimeType != Null &&
            json['skills'][i].trim() != "") {
          skills.add(json['skills'][i]);
        }
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
      fname: json["fname"] ?? "",
      pro: json["pro"] == 1,
      createdAt: json["created_at"],
      dob: json["dob"] ?? 0,
      phone: json["phone"] ?? "",
      address: json["address"] ?? "",
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
        "pro": pro ? 1 : 0,
        "created_at": createdAt,
        "dob": dob,
        "phone": phone,
        "fname": fname,
        "address": address,
      };
}
