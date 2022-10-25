class SingleBlog {
  SingleBlog({
    required this.id,
    required this.title,
    required this.images,
    required this.createdAt,
    required this.views,
  });

  int id;
  String title;
  List<String> images;
  int createdAt;
  int views;

  factory SingleBlog.fromJson(Map<String, dynamic> json) => SingleBlog(
        id: int.parse(json["id"].toString()),
        title: json["title"],
        images: List<String>.from(json["images"].map((x) => x)),
        createdAt: json["created_at"],
        views: json["views"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "images": List<dynamic>.from(images.map((x) => x)),
        "created_at": createdAt,
        "views": views,
      };
}
