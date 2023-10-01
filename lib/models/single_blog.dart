// To parse this JSON data, do
//
//     final imageType = imageTypeFromJson(jsonString);

import 'dart:convert';

ImageType imageTypeFromJson(String str) => ImageType.fromJson(json.decode(str));

String imageTypeToJson(ImageType data) => json.encode(data.toJson());

class ImageType {
  int id;
  String image;
  String thumb;
  int views;
  String category;
  String status;
  double height;
  double width;
  ImageType({
    required this.id,
    required this.image,
    required this.thumb,
    required this.views,
    required this.category,
    required this.status,
    required this.height,
    required this.width,
  });

  factory ImageType.fromJson(Map<String, dynamic> json) => ImageType(
        id: json["id"],
        image: json["image"],
        thumb: json["thumb"],
        views: json["views"],
        category: json["category"],
        status: json["status"] ?? 'public',
        height: json["height"].toDouble(),
        width: json["width"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "image": image,
        "thumb": thumb,
        "views": views,
        "category": category,
        "status": status,
        "height": height,
        "width": width,
      };
}
