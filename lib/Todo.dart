import 'package:uuid/uuid.dart';

class Todo {
  late final String id;
  final String title;
  final bool isComplete;
  final String? parentId;
  final String order;

  Todo({
    String? id,
    required this.title,
    required this.isComplete,
    required this.parentId,
    required this.order,
  }) {
    this.id = id == null ? Uuid().v4() : id;
  }

  @override
  int get hashCode => toString().hashCode;

  bool equals(Object other) {
    return this == other;
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Todo &&
        id == other.id &&
        title == other.title &&
        isComplete == other.isComplete &&
        parentId == other.parentId &&
        order == other.order;
  }

  @override
  String toString() {
    var buffer = new StringBuffer();

    buffer.write("Todo {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("title=" + "$title" + ", ");
    buffer.write("isComplete=" + "$isComplete" + ", ");
    buffer.write("parentId=" + "$parentId" + ", ");
    buffer.write("order=" + "$order");
    buffer.write("}");

    return buffer.toString();
  }

  /// Make changes to a todo's title, isComplete, or order property.
  Todo copyWith({
    required String title,
    required bool isComplete,
    required String order,
    required String? parentId,
  }) {
    return Todo(
      id: this.id,
      title: title,
      isComplete: isComplete,
      order: order,
      parentId: parentId,
    );
  }

  Todo.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        isComplete = json['isComplete'],
        parentId = json['parentId'],
        order = json['order'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isComplete': isComplete,
        'parentId': parentId,
        'order': order,
      };
}
