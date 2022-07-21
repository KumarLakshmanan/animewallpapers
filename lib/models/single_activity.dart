class SingleActivity {
  SingleActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.type,
    required this.payload,
    required this.createdAt,
  });

  int id;
  String title;
  String description;
  String thumbnail;
  String type;
  String payload;
  int createdAt;

  factory SingleActivity.fromJson(Map<String, dynamic> json) => SingleActivity(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        thumbnail: json["thumbnail"],
        type: json["type"],
        payload: json["payload"],
        createdAt: json["created_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "thumbnail": thumbnail,
        "type": type,
        "payload": payload,
        "created_at": createdAt,
      };
}
