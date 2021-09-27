import 'package:todo/Todo.dart';

class TodoNotFoundError extends Error {
  String todoId;
  TodoNotFoundError(this.todoId) : super();
}

class TodoChildrenNotLoadedError extends Error {
  String? parentId;
  TodoChildrenNotLoadedError(this.parentId) : super();
}

/// Utility class to track all todos that have been cached by the local user's app.
///
/// Todos are stored in a tree-like structure, where each root todo (a Todo without a parent)
/// is a root to a separate tree.
class TodosTree {
  /// Set of all rootTodos and their children, sorted into TodoNodes and
  /// indexed by each root `Todo`'s id.
  Set<String> _rootTodos = {};

  /// Set of all `TodoNode`s in the tree, indexed by their `Todo`'s ID.
  Map<String, TodoNode> _todoNodes = {};

  /// Map of all todos, indexed by their id.
  Map<String, Todo> _todos = {};

  /// Callback FN to order a list of Todos.
  static int orderTodos(Todo a, Todo b) => a.order.compareTo(b.order);

  Todo _mapIdsToTodos(String id) {
    final todo = _get(id);
    if (todo == null) throw TodoNotFoundError(id);
    return todo;
  }

  /// Get a Todo in the TodoTree.
  Todo? get(String id) => _get(id);
  Todo? _get(String id) => _todos[id];

  List<Todo> get rootTodos => _rootTodos.map(_mapIdsToTodos).toList()..sort(orderTodos);

  /// Add a Todo to the TodoTree.
  void add(Todo todo) {
    final parentId = todo.parentId;
    final todoNode = TodoNode(id: todo.id, children: {});
    if (parentId == null) {
      _rootTodos.add(todo.id);
    } else {
      final parentNode = _todoNodes[parentId];
      if (parentNode == null) {
        throw new Exception('ffjdslakf');
      } else if (parentNode.children == null) {
        throw new Exception('ffjdslakf ???');
      }
      parentNode.children![todo.id] = todoNode;
    }

    _todoNodes[todo.id] = todoNode;
    _todos[todo.id] = todo;
  }

  /// Returns true if the todo's children have been loaded,
  /// false if they have not been loaded, and null if the todo is not yet loaded.
  bool? isTodoChildrenLoaded(String todoId) =>
      _todoNodes[todoId] == null ? null : _todoNodes[todoId]!.children != null;

  /// Get a `Todo`'s children.
  List<Todo> getTodosForParent(String? parentId) {
    if (parentId == null) {
      // Get root todos
      return _rootTodos.map(_mapIdsToTodos).toList()..sort(orderTodos);
    }

    final parentTodo = _get(parentId);
    final parentNode = _todoNodes[parentId];
    if (parentTodo == null || parentNode == null) throw TodoNotFoundError(parentId);

    final todoIds = parentNode.children?.keys.toList();
    if (todoIds == null) throw TodoChildrenNotLoadedError(parentId);

    return todoIds.map(_mapIdsToTodos).toList()..sort(orderTodos);
  }

  /// Update todo without changing it's parent.
  void update(Todo updatedTodo) {
    _todos.update(updatedTodo.id, (_) => updatedTodo);
  }

  void remove(String id) {
    final Todo? todoToRemove = _get(id);
    if (todoToRemove == null) {
      throw new Exception('That todo ain\'t here broe');
    }

    final String? parentId = todoToRemove.parentId;
    if (parentId == null) {
      _rootTodos.remove(todoToRemove.id);
    } else {
      final parentNode = _todoNodes[parentId];
      if (parentNode == null) {
        throw new Exception('ruh roh');
      } else if (parentNode.children == null) {
        throw new Exception('seriously what the hell');
      }
      parentNode.children!.remove(id);
    }
    _todoNodes.remove(id);
    _todos.remove(id);
  }

  @override
  String toString() {
    var buffer = new StringBuffer();

    buffer.write("TodosTree {\n");
    buffer.write("  _rootTodos=" + "$_rootTodos" + ",\n");
    buffer.write("  _todoNodes=" + "$_todoNodes" + ",\n");
    buffer.write("  _todos=" + "$_todos" + ",\n");
    buffer.write("}\n");

    return buffer.toString();
  }
}

/// A method to associate `Todo`s with their parents and children.
/// A parent Todo
class TodoNode {
  TodoNode({required this.id, required this.children});
  String id;
  Map<String, TodoNode>? children;
}
