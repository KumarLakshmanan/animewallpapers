// {
//     "id": 14,
//     "title": "Install FreePhishing",
//     "images": [
//         "8_635531e936ad69.67756900.png"
//     ],
//     "views": 1,
//     "created_at": 1666527732000
// }
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
