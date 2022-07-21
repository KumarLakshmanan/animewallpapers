class SingleComment {
  SingleComment({
    required this.id,
    required this.name,
    required this.username,
    required this.comment,
    required this.votes,
    required this.liked,
    required this.updatedAt,
  });
  int id;
  String name;
  String username;
  String comment;
  int votes;
  int liked;
  int updatedAt;

  factory SingleComment.fromJson(Map<String, dynamic> json) => SingleComment(
        id: int.parse(json["id"].toString()),
        name: json["name"],
        username: json["username"],
        comment: json["comment"],
        votes: json["votes"],
        liked: json["liked"] ?? 0,
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "username": username,
        "comment": comment,
        "votes": votes,
        "liked": liked,
        "updated_at": updatedAt,
      };
}
