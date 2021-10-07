import 'package:todo/todo.dart';

class TodoNotFoundError extends Error {
  String todoId;
  TodoNotFoundError(this.todoId) : super();
}

class ChildrenNotLoadedError extends Error {}

/// Utility class to track all todos that have been cached by the local user's app.
///
/// Todos are stored in a tree-like structure, where each root todo (a Todo without a parent)
/// is a root to a separate tree.
class TodosTree {
  /// Internal: Set of all rootTodo ids, as strings.
  ///
  /// Every item in the _todos map either
  /// a) has a parentId property populated with the id of another todo in the _todos map, XOR
  /// b) is represented in the _rootTodos set by the todo's id.
  Set<String> _rootTodos = {};

  /// Internal: Map of all todos, indexed by their id.
  ///
  /// Todos have a `children` property which is either [null] meaning the todo's children
  /// have not been loaded, or a Map of Todos which will always be a subset of this value.
  ///
  /// This value serves as the single source of truth for all todos in the application.
  Map<String, Todo> _todos = {};

  /// Internal: get a todo from the _todos Map property - it is generally assumed that if an id is
  /// sent in, the user only knows about it because they got it from this structure.
  ///
  /// For a method that returns a non-optional Todo, see `Todo? get(String id)`.
  Todo? _get(String id) => _todos[id];

  /// Map an iterable structure of todo IDs to a list of Todo objects, sorted by their order value.
  List<Todo> _mapIdsToTodosSorted(Iterable<String> todoIds) => todoIds.map(getTodo).toList()
    ..sort((Todo todoA, Todo todoB) => todoA.order.compareTo(todoB.order));

  /// Whether the TodosTree contains a Todo with the given [id].
  bool contains(String id) => _todos.containsKey(id);

  /// Get a loaded Todo from the TodoTree.
  Todo getTodo(String id) {
    final Todo? todo = _get(id);
    assert(todo is Todo);
    return todo!;
  }

  /// Get the list of root `Todo`s. Conceptually, these todos are the "base" of the TodosTree.
  List<Todo> get rootTodos => _mapIdsToTodosSorted(_rootTodos);

  /// Get a `Todo`'s children, sorted by their order.
  List<Todo> childrenOf(String? parentId) {
    if (parentId == null) return rootTodos;
    final Todo parentTodo = getTodo(parentId);
    if (!parentTodo.isChildrenLoaded) throw ChildrenNotLoadedError();
    return _mapIdsToTodosSorted(parentTodo.childrenIds);
  }

  /// Add a Todo to the TodosTree.
  void add(Todo todo) {
    final parentId = todo.parentId;
    if (parentId == null) {
      _rootTodos.add(todo.id);
    } else {
      final Todo parentTodo = getTodo(parentId);
      parentTodo.addChild(todo.id);
    }
    _todos[todo.id] = todo;
  }

  /// Add all Todos in a list to the TodosTree.
  void addAll(List<Todo> todos) => todos.forEach(add);

  /// Update todo without changing it's parent. To change a todo's parent, use updateParentId.
  Todo update(Todo updatedTodo) => _todos.update(updatedTodo.id, (_) => updatedTodo);

  /// Update todo's parentId, as well as the todo's next and previous parent todos by removing
  /// the todo from the old parent's children into the children of the next parent.
  void updateParentId(String todoId, String? parentId) {
    // remove and add will manage the todo's previous and next parents' children.
    final Todo? todo = remove(todoId);
    if (todo == null) throw TodoNotFoundError(todoId);
    final Todo updatedTodo = todo.copyWith(parentId: parentId, children: todo.childrenIds);
    add(updatedTodo);
  }

  /// Remove a todo from the TodosTree.
  Todo? remove(String id) {
    final Todo? todo = _todos.remove(id);
    if (todo == null) return null;

    final String? parentId = todo.parentId;
    if (parentId == null) {
      _rootTodos.remove(id);
    } else {
      final Todo parentTodo = getTodo(parentId);
      parentTodo.removeChild(id);
    }

    return todo;
  }

  bool canMoveTodoTo(String selectedTodoId, String? targetTodoId) =>
      targetTodoId == null ||
      (selectedTodoId != targetTodoId && !todoHasAncestor(targetTodoId, selectedTodoId));

  bool todoHasAncestor(String todoId, String? ancestorId) {
    if (ancestorId == null) return true;

    Todo? todo = _get(todoId);

    while (todo is Todo) {
      if (todo.parentId == null) return false;
      if (todo.parentId == ancestorId) return true;
      todo = _get(todo.parentId!);
    }

    return false;
  }
}
