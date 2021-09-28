import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:todo/Todo.dart';
import 'package:todo/mutation_modal.dart';
import 'package:todo/order_id.dart';
import 'package:todo/todo_api.dart';
import 'package:todo/todos_tree.dart';

class TodosState {
  final bool isLoading;
  final Exception? exception;
  final String? viewedTodo;
  final TodosTree tree;

  TodosState({
    required this.exception,
    required this.isLoading,
    required this.tree,
    required this.viewedTodo,
  });

  bool get isViewingRoot => viewedTodo == null;
  bool get isViewingTodoChildren => viewedTodo is String;

  Todo? get getVisibleTodo => viewedTodo == null ? null : tree.get(viewedTodo!);
}

const NoValue = const {};

// const intialState = const TodosState(exception: null, isLoading: true, tree: const TodosTree(), viewedTodo: null)

class TodosCubit extends Cubit<TodosState> {
  // Initialize {isLoadingTodos} to be {true}
  TodosCubit()
      : super(TodosState(exception: null, isLoading: true, tree: TodosTree(), viewedTodo: null));

  Exception? get _exception => state.exception;
  bool get _isLoading => state.isLoading;
  TodosTree get _tree => state.tree;
  String? get _viewedTodo => state.viewedTodo;

  // @override
  void _emitNextState({
    dynamic exception = NoValue,
    dynamic isLoading = NoValue,
    dynamic tree = NoValue,
    dynamic viewedTodo = NoValue,
  }) {
    // Fuck this shit man I guess default parameter values gotta be compile-time constants in dart.
    assert(exception is Exception || exception == null || exception == NoValue);
    assert(isLoading == true || isLoading == false || isLoading == NoValue);
    assert(tree is TodosTree || tree == NoValue);
    assert(viewedTodo == null || viewedTodo is String || exception == NoValue);

    final Exception? nextException = (exception == NoValue) ? _exception : exception;
    final bool nextIsLoading = (isLoading == NoValue) ? _isLoading : isLoading;
    final TodosTree nextTree = (tree == NoValue) ? _tree : tree;
    final String? nextViewedTodo = (viewedTodo == NoValue) ? _viewedTodo : viewedTodo;

    super.emit(TodosState(
      exception: nextException,
      isLoading: nextIsLoading,
      tree: nextTree,
      viewedTodo: nextViewedTodo,
    ));
  }

  Todo? get visibleTodo => _viewedTodo is String ? _tree.get(_viewedTodo!) : null;

  List<Todo> _getVisibleOrderedTodoList() => _tree.getTodosForParent(_viewedTodo);

  List<Todo> getSortedTodos(List<Todo> todos) => todos..sort(TodosTree.orderTodos);

  Future<void> initialize() async {
    try {
      final List<Todo> rootTodos = await TodoApi.listRootTodos();
      for (final todo in rootTodos) {
        _tree.add(todo);
        loadTodoChildren(todo);
      }

      _emitNextState(isLoading: false);

      TodoApi.observeCreateTodo(_onNewTodo);
      TodoApi.observeUpdateTodo(_onUpdatedTodo);
      TodoApi.observeDeleteTodo(_onDeletedTodo);
    } catch (e) {
      if (e is Exception) {
        print('Failed to initialize todos cubit.');
        _emitNextState(exception: e, isLoading: false);
      }
    }
  }

  Future<void> addRootTodo(String title) async {
    if (_isLoading) {
      throw Exception(
          '${this.runtimeType} Attempted to create root todo before todos were loaded.');
    }

    final List<Todo> sortedRootTodos = getSortedTodos(_tree.rootTodos);
    final String order = sortedRootTodos.length > 0
        ? OrderId.getNext(sortedRootTodos.last.order)
        : OrderId.getInitialId();

    final newTodo = Todo(
      title: title,
      isComplete: false,
      order: order,
      parentId: null,
    );

    _tree.add(newTodo);
    _emitNextState();

    await TodoApi.createTodo(newTodo);
  }

  Future<void> addSubTodo(String title, String parentId) async {
    if (_isLoading) {
      throw Exception(
          '${this.runtimeType}: Attempted to create child todo before todos were loaded.');
    }

    final parentTodo = _tree.get(parentId);
    final bool isParentCached = parentTodo is Todo;

    if (!isParentCached) {
      throw Exception(
          '${this.runtimeType}: Tried to create a todo with a parent that is not yet cached.');
    }

    // final List<Todo>? parentChildren = parentTodo.children;
    final List<Todo>? parentChildren = _tree.getTodosForParent(parentId);
    final bool isTodoChildrenLoaded = parentChildren is List<Todo>;

    if (!isTodoChildrenLoaded) {
      throw Exception(
          '${this.runtimeType}: Cannot determine `order` because this todo\'s siblings are not loaded yet.');
    }

    final List<Todo> sortedTodos = getSortedTodos(parentChildren);
    final String order =
        sortedTodos.length > 0 ? OrderId.getNext(sortedTodos.last.order) : OrderId.getInitialId();

    final newTodo = Todo(
      title: title,
      isComplete: false,
      order: order,
      parentId: parentId,
    );

    _tree.add(newTodo);
    _emitNextState();

    await TodoApi.createTodo(newTodo);
  }

  void _onNewTodo(Todo newTodo) {
    final parentId = newTodo.parentId;

    // If a todo's parent has not been loaded, we can just wait to load it when it's needed.
    if (parentId is String && _tree.get(parentId) == null) return;

    _tree.add(newTodo);
    _emitNextState();
  }

  /// Update state to view the selected todo. Make sure the latest version of the children are
  /// loaded.
  Future<void> viewTodo(String? todoId) async {
    if (todoId == null) {
      _emitNextState(viewedTodo: null);
    } else {
      final nextViewTodo = _tree.get(todoId);
      if (nextViewTodo is Todo) {
        final isLoaded = _tree.isTodoChildrenLoaded(todoId);
        _emitNextState(viewedTodo: nextViewTodo.id);

        // Try to stay one layer of todos ahead of the user's visibility.
        final List<Todo> children = isLoaded == true
            ? _tree.getTodosForParent(todoId)
            : await loadTodoChildren(nextViewTodo);
        for (final Todo todo in children) {
          loadTodoChildren(todo);
        }
      } else {
        final e = new Exception('hehehe that viewed todo aint ready');
        _emitNextState(exception: e, viewedTodo: todoId);
        throw e;
      }
    }
  }

  Future<List<Todo>> loadTodoChildren(Todo todo) async {
    final List<Todo> todoChildren = await TodoApi.listTodoChildren(todo);
    for (final loadedTodo in todoChildren) {
      _tree.add(loadedTodo);
    }
    _emitNextState();
    return todoChildren;
  }

  Future<void> moveTodo(int startIndex, int endIndex) async {
    assert(_isLoading == false);
    final todoList = _getVisibleOrderedTodoList();

    final movingTodo = todoList[startIndex];
    var updatedOrder = '';
    if (endIndex == 0) {
      updatedOrder = OrderId.getPrevious(todoList.first.order);
    } else if (endIndex == todoList.length) {
      updatedOrder = OrderId.getNext(todoList.last.order);
    } else {
      final lowerOrder = todoList[endIndex - 1].order;
      final upperOrder = todoList[endIndex].order;
      updatedOrder = OrderId.getIdBetween(lowerOrder, upperOrder);
    }

    // Next state is emitted in our update function.
    await updateTodoWith(
      movingTodo,
      order: updatedOrder,
      title: movingTodo.title,
      isComplete: movingTodo.isComplete,
      // parentId: movingTodo.parentId,
    );
  }

  // Needed to update parentId because dart can't do fucking runtime parameter default values
  Future<void> updateTodoWith(
    Todo todoToUpdate, {
    required String title,
    required bool isComplete,
    required String order,
    // required String? parentId,
  }) async {
    final updatedTodo = todoToUpdate.copyWith(
      title: title,
      isComplete: isComplete,
      order: order,
      parentId: todoToUpdate.parentId,
    );
    _tree.update(updatedTodo);
    _emitNextState();
    await TodoApi.updateTodo(updatedTodo);
  }

  Future<void> updateTodo(
    Todo todoToUpdate, {
    String? title,
    bool? isComplete,
    String? order,
  }) async {
    final updatedTodo = todoToUpdate.copyWith(
      title: title ?? todoToUpdate.title,
      isComplete: isComplete ?? todoToUpdate.isComplete,
      order: order ?? todoToUpdate.order,
      parentId: todoToUpdate.parentId,
    );
    _tree.update(updatedTodo);
    _emitNextState();
    await TodoApi.updateTodo(updatedTodo);
  }

  void _onUpdatedTodo(Todo updatedTodo) {
    final Todo? currentTodo = _tree.get(updatedTodo.id);

    // We probably just recently deleted it is all.
    if (currentTodo == null) return;

    final bool didUpdateParent = currentTodo.parentId != updatedTodo.parentId;

    if (didUpdateParent && currentTodo.parentId is String) {
      final currentParentTodo = _tree.get(currentTodo.parentId!);
      if (currentParentTodo is Todo) loadTodoChildren(currentParentTodo);
    }

    if (didUpdateParent && updatedTodo.parentId is String) {
      final nextParentTodo = _tree.get(updatedTodo.parentId!);
      if (nextParentTodo is Todo) loadTodoChildren(nextParentTodo);
    }

    _tree.update(updatedTodo);
    _emitNextState();
  }

  // We kind of assume that if todoToDelete has a parent, then that parent is the viewedTodo
  Future<void> deleteTodo(Todo todoToDelete) async {
    _tree.remove(todoToDelete.id);
    _emitNextState();
    await TodoApi.deleteTodo(todoToDelete);
  }

  void _onDeletedTodo(String deletedTodoId) {
    if (_tree.isTodoPresent(deletedTodoId)) {
      _tree.remove(deletedTodoId);
      _emitNextState();
    }
  }

  void showTodoFormModal(BuildContext context, Todo? selectedTodo) {
    final title = selectedTodo?.title;

    // Check parent ID now, when the modal is opened.
    final String? parentId = _viewedTodo;

    showModalBottomSheet(
      context: context,
      isDismissible: true,
      builder: (ctx) => BlocProvider<TodosCubit>.value(
        value: BlocProvider.of(context),
        child: MutationModal(
          title: title,
          onSave: (newTitle) {
            if (selectedTodo == null) {
              if (parentId is String) {
                addSubTodo(newTitle, parentId);
              } else {
                addRootTodo(newTitle);
              }
            } else {
              updateTodo(selectedTodo, title: newTitle);
            }
          },
        ),
      ),
    );
  }
}
