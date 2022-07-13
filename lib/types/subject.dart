class SubjectType {
  SubjectType({
    required this.id,
    required this.name,
    required this.questionscount,
    required this.entrollcount,
    required this.color,
    required this.completed,
    required this.createdAt,
  });

  int id;
  String name;
  int questionscount;
  int entrollcount;
  String color;
  int completed;
  int createdAt;

  factory SubjectType.fromJson(Map<String, dynamic> json) => SubjectType(
        id: json["id"],
        name: json["name"],
        questionscount: json["questionscount"],
        entrollcount: json["entrollcount"],
        color: json["color"],
        completed: json["completed"],
        createdAt: json["created_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "questionscount": questionscount,
        "entrollcount": entrollcount,
        "color": color,
        "completed": completed,
        "created_at": createdAt,
      };
}
