class SingleBlog {
  SingleBlog({
    required this.id,
    required this.title,
    required this.thumb,
    required this.keywords,
    required this.ytlink,
    required this.username,
    required this.createdAt,
    required this.views,
    required this.gems,
    required this.content,
  });

  int id;
  String title;
  List<String> thumb;
  List<String> keywords;
  List<String> ytlink;
  String username;
  int createdAt;
  int views;
  int gems;
  String content;

  factory SingleBlog.fromJson(Map<String, dynamic> json) => SingleBlog(
        id: int.parse(json["id"].toString()),
        title: json["title"],
        thumb: List<String>.from(json["thumb"].map((x) => x)),
        keywords: List<String>.from(json["keywords"].map((x) => x)),
        ytlink: List<String>.from(json["ytlink"].map((x) => x)),
        username: json["username"],
        createdAt: json["created_at"],
        views: json["views"],
        gems: json["gems"] ?? 10,
        content: json["content"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "thumb": List<dynamic>.from(thumb.map((x) => x)),
        "keywords": List<dynamic>.from(keywords.map((x) => x)),
        "ytlink": List<dynamic>.from(ytlink.map((x) => x)),
        "username": username,
        "created_at": createdAt,
        "views": views,
        "gems": gems,
        "content": content,
      };
}
