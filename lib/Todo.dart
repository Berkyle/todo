import 'package:uuid/uuid.dart';

class Todo {
  late final String id;
  String title;
  String? parentId;
  String order;
  final Set<String> childrenIds;
  bool isChildrenLoaded;
  bool isComplete;

  Todo({
    String? id,
    required this.title,
    required this.parentId,
    required this.order,
    required this.childrenIds,
    required this.isChildrenLoaded,
    required this.isComplete,
  }) {
    this.id = id ?? Uuid().v4();
  }

  /// Make changes to a todo's title, isComplete, or order property.
  Todo copyWith({
    String? title,
    required String? parentId, // parentId is required since null is a valid value
    String? order,
    Set<String>? children,
    bool? isChildrenLoaded,
    bool? isComplete,
  }) {
    return Todo(
      id: this.id,
      title: title ?? this.title,
      parentId: parentId,
      order: order ?? this.order,
      childrenIds: children ?? this.childrenIds,
      isChildrenLoaded: isChildrenLoaded ?? this.isChildrenLoaded,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  bool addChild(String childId) {
    if (isChildrenLoaded == false) this.isChildrenLoaded = true;
    return childrenIds.add(childId);
  }

  bool removeChild(String childId) => childrenIds.remove(childId);

  bool setChildrenLoaded() {
    if (isChildrenLoaded) return false;
    this.isChildrenLoaded = true;
    return true;
  }

  @override
  String toString() => '''Todo {
    id=$id,
    title=$title,
    parentId=$parentId,
    order=$order,
    children=$childrenIds,
    isChildrenLoaded=$isChildrenLoaded,
    isComplete=$isComplete,
  }''';

  static const String todoFieldQuery = '''{
  id
  title
  isComplete
  order
  parentId
}''';
}
