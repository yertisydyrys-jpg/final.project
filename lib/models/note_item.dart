class NoteItem {
  const NoteItem({
    required this.id,
    required this.title,
    required this.dateText,
    required this.isCompleted,
  });

  final String id;
  final String title;
  final String dateText;
  final bool isCompleted;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'dateText': dateText,
    'isCompleted': isCompleted,
  };

  factory NoteItem.fromJson(Map<String, dynamic> json) {
    return NoteItem(
      id: json['id'] as String,
      title: json['title'] as String,
      dateText: json['dateText'] as String,
      isCompleted: json['isCompleted'] as bool,
    );
  }
}
