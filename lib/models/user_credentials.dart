class UserCredentials {
  UserCredentials({
    required this.token,
    required this.id,
    required this.username,
    required this.photo,
    required this.password,
    required this.name,
    required this.email,
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
  String role;
  bool pro;
  int createdAt;

  factory UserCredentials.fromJson(Map<String, dynamic> json) =>
      UserCredentials(
        token: json["token"],
        id: int.parse(json["id"].toString()),
        username: json["username"],
        photo: json["photo"],
        password: json["password"],
        name: json["name"],
        email: json["email"],
        role: json["role"],
        pro: json["pro"] == 1,
        createdAt: json["created_at"],
      );

  Map<String, dynamic> toJson() => {
        "token": token,
        "id": id,
        "username": username,
        "photo": photo,
        "password": password,
        "name": name,
        "email": email,
        "role": role,
        "pro": pro,
        "created_at": createdAt,
      };
}
