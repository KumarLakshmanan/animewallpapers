class SingleBook {
  SingleBook({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.username,
    required this.author,
    required this.category,
    required this.pdf,
    required this.downloads,
    required this.content,
    required this.createdAt,
  });

  int id;
  String title;
  String thumbnail;
  String username;
  String author;
  List<String> category;
  String pdf;
  int downloads;
  String content;
  int createdAt;

  factory SingleBook.fromJson(Map<String, dynamic> json) => SingleBook(
        id: int.parse(json["id"].toString()),
        title: json["title"],
        thumbnail: json["thumbnail"],
        username: json["username"],
        author: json["author"],
        category: List<String>.from(json["category"].map((x) => x)),
        pdf: json["pdf"],
        downloads: json["downloads"],
        content: json["content"],
        createdAt: json["created_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "thumbnail": thumbnail,
        "username": username,
        "author": author,
        "category": category,
        "pdf": pdf,
        "downloads": downloads,
        "content": content,
        "created_at": createdAt,
      };
}
