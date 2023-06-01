class SingleBlog {
  SingleBlog({
    required this.id,
    required this.title,
    required this.images,
    required this.createdAt,
    required this.views,
    required this.likes,
    required this.keywords,
  });

  int id;
  String title;
  List<String> images;
  int createdAt;
  int views;
  int likes;
  List<String> keywords;

  factory SingleBlog.fromJson(Map<String, dynamic> json) => SingleBlog(
        id: int.parse(json["id"].toString()),
        title: json["title"],
        images: List<String>.from(json["images"].map((x) => x)),
        createdAt: json["created_at"],
        views: json["views"] ?? 0,
        likes: json["likes"] ?? 0,
        keywords: List<String>.from(json["keywords"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "images": List<dynamic>.from(images.map((x) => x)),
        "created_at": createdAt,
        "views": views,
        "likes": likes,
        "keywords": List<dynamic>.from(keywords.map((x) => x)),
      };
}
