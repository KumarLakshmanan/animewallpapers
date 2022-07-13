class Question {
  Question({
    required this.id,
    required this.questionname,
    required this.answerid,
    required this.subject,
    required this.likes,
    required this.creatorid,
    required this.creatorname,
    required this.createdAt,
    required this.status,
    required this.questionid,
    required this.choices,
    required this.answers,
  });

  int id;
  String questionname;
  int answerid;
  String subject;
  int likes;
  String creatorid;
  String creatorname;
  DateTime createdAt;
  String status;
  String questionid;
  List<Choices> choices;
  AnswerType? answers;
  factory Question.fromJson(Map<String, dynamic> json) => Question(
        id: json["id"],
        questionname: json["questionname"],
        answerid: json["answerid"],
        subject: json["subject"],
        likes: json["likes"],
        creatorid: json["creatorid"],
        creatorname: json["creatorname"],
        createdAt: DateTime.parse(json["created_at"]),
        status: json["status"],
        questionid: json["questionid"],
        choices:
            List<Choices>.from(json["choices"].map((x) => Choices.fromJson(x))),
        answers: json["answers"] == null
            ? null
            : AnswerType.fromJson(json["answers"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "questionname": questionname,
        "answerid": answerid,
        "subject": subject,
        "likes": likes,
        "creatorid": creatorid,
        "creatorname": creatorname,
        "created_at": createdAt.toIso8601String(),
        "status": status,
        "questionid": questionid,
        "choices": List<dynamic>.from(choices.map((x) => x.toJson())),
        "answers": answers == null ? null : answers!.toJson(),
      };
}

class Choices {
  Choices({
    required this.id,
    required this.choice,
    required this.createdAt,
  });

  int id;
  String choice;
  int createdAt;

  factory Choices.fromJson(Map<String, dynamic> json) => Choices(
        id: json["id"],
        choice: json["choice"],
        createdAt: json["created_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "choice": choice,
        "created_at": createdAt,
      };
}

class AnswerType {
  AnswerType({
    required this.id,
    required this.timeTaken,
    required this.isCrt,
    required this.answerid,
  });

  int id;
  int timeTaken;
  String isCrt;
  int answerid;
  factory AnswerType.fromJson(Map<String, dynamic> json) => AnswerType(
        id: json["id"],
        timeTaken: json["timeTaken"],
        isCrt: json["isCrt"],
        answerid: json["answerid"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "timeTaken": timeTaken,
        "isCrt": isCrt,
        "answerid": answerid,
      };
}
