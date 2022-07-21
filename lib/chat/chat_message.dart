class ChatMessage {
  ChatMessage({
    required this.id,
    required this.time,
    required this.name,
    required this.msg,
    required this.user,
  });
  int id;
  int time;
  String name;
  String msg;
  String user;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: int.parse(json["id"].toString()),
        name: json["name"],
        msg: json["msg"],
        user: json["user"],
        time: json["time"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "msg": msg,
        "user": user,
        "time": time,
      };
}
