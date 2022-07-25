class SingleActivity {
  SingleActivity({
    required this.title,
    required this.description,
    required this.thumb,
    required this.type,
    required this.payload,
    required this.createdAt,
  });

  String title;
  String description;
  String thumb;
  String type;
  Map? payload;
  int createdAt;

  factory SingleActivity.fromJson(Map<String, dynamic> json) => SingleActivity(
        title: json["title"] ?? "",
        description: json["description"] ?? "",
        thumb: json["thumb"] ?? "",
        type: json["type"] ?? "",
        payload: json["payload"].runtimeType != Map ? null : json['payload'],
        createdAt: json["created_at"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "description": description,
        "thumb": thumb,
        "type": type,
        "payload": payload,
        "created_at": createdAt,
      };
}
