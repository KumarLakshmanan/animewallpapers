class SingleBlog {
  SingleBlog({
    required this.id,
    required this.title,
    required this.thumb,
    required this.keywords,
    required this.username,
    required this.createdAt,
    required this.views,
    required this.content,
  });

  int id;
  String title;
  String thumb;
  List<String> keywords;
  String username;
  int createdAt;
  int views;
  String content;

  factory SingleBlog.fromJson(Map<String, dynamic> json) => SingleBlog(
        id: json["id"],
        title: json["title"],
        thumb: json["thumb"],
        keywords: List<String>.from(json["keywords"].map((x) => x)),
        username: json["username"],
        createdAt: json["created_at"],
        views: json["views"],
        content: json["content"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "thumb": thumb,
        "keywords": List<dynamic>.from(keywords.map((x) => x)),
        "username": username,
        "created_at": createdAt,
        "views": views,
        "content": content,
      };
}
