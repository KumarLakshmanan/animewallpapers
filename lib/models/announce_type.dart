class AnnouncementType {
  AnnouncementType({
    required this.id,
    required this.name,
    required this.url,
    required this.description,
    required this.pdf,
    required this.image,
    required this.createdDate,
  });

  int id;
  String name;
  String url;
  String description;
  String pdf;
  List<String> image;
  int createdDate;

  factory AnnouncementType.fromJson(Map<String, dynamic> json) =>
      AnnouncementType(
        id: json["id"],
        name: json["name"] ?? "",
        url: json["url"] ?? json["link"] ?? "",
        description: json["description"] ?? "",
        pdf: json["pdf"] ?? "",
        image: json["image"] == null || json["image"] == ""
            ? []
            : List<String>.from(json["image"].map((x) => x)),
        createdDate: json["created_date"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "url": url,
        "description": description,
        "pdf": pdf,
        "image": List<dynamic>.from(image.map((x) => x)),
        "created_date": createdDate,
      };
}
