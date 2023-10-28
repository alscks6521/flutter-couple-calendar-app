class Event {
  String title;
  String content;

  Event(this.title, this.content);

  // toJson 메서드를 추가하여 Event 객체를 JSON으로 직렬화합니다.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
    };
  }

  // fromJson 메서드를 추가하여 JSON을 Event 객체로 역직렬화합니다.
  factory Event.fromJson(Map<dynamic, dynamic> json) {
    return Event(
      json['title'],
      json['content'],
    );
  }
}
