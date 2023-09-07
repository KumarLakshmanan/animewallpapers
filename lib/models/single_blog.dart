// To parse this JSON data, do
//
//     final imageType = imageTypeFromJson(jsonString);

import 'dart:convert';

ImageType imageTypeFromJson(String str) => ImageType.fromJson(json.decode(str));

String imageTypeToJson(ImageType data) => json.encode(data.toJson());

class ImageType {
  int id;
  String title;
  String image;
  String thumb;
  int width;
  int height;
  int views;
  int likes;
  DateTime createdAt;
  DateTime updatedAt;
  String category;
  String subcategory;
  String status;
  String keywords;
  ImageType({
    required this.id,
    required this.title,
    required this.image,
    required this.thumb,
    required this.width,
    required this.height,
    required this.views,
    required this.likes,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    required this.subcategory,
    required this.status,
    required this.keywords,
  });

  factory ImageType.fromJson(Map<String, dynamic> json) => ImageType(
        id: json["id"],
        title: json["title"],
        image: json["image"],
        thumb: json["thumb"],
        width: json["width"],
        height: json["height"],
        views: json["views"],
        likes: json["likes"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        category: json["category"],
        subcategory: json["subcategory"],
        status: json["status"] ?? 'public',
        keywords: json["keywords"] ?? 'Anime',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "image": image,
        "thumb": thumb,
        "width": width,
        "height": height,
        "views": views,
        "likes": likes,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "category": category,
        "subcategory": subcategory,
        "status": status,
        "keywords": keywords,
      };
}
