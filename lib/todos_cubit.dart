import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:todo/todo.dart';
import 'package:todo/mutation_modal.dart';
import 'package:todo/order_id.dart';
import 'package:todo/todo_api.dart';
import 'package:todo/todos_tree.dart';

class TodosState {
  final Exception? exception;
  final bool isLoading;
  final TodosTree tree;
  final String? selectedTodo;
  final String? viewedTodo;

  TodosState({
    required this.exception,
    required this.isLoading,
    required this.tree,
    required this.selectedTodo,
    required this.viewedTodo,
  });

  bool get isViewingRoot => viewedTodo == null;
  bool get isViewingTodoChildren => viewedTodo is String;
  bool get isTodoSelected => selectedTodo is String;

  Todo? get getSelectedTodo => selectedTodo is String ? tree.getTodo(selectedTodo!) : null;
  Todo? get getVisibleTodo => isViewingRoot ? null : tree.getTodo(viewedTodo!);

  List<Todo> get todoList => tree.childrenOf(viewedTodo);
}

const NoValue = const {};

class TodosCubit extends Cubit<TodosState> {
  // Initialize {isLoadingTodos} to be {true}
  TodosCubit()
      : super(TodosState(
            exception: null,
            isLoading: true,
            tree: TodosTree(),
            selectedTodo: null,
            viewedTodo: null));

  Exception? get _exception => state.exception;
  bool get _isLoading => state.isLoading;
  TodosTree get _tree => state.tree;
  String? get _selectedTodo => state.selectedTodo;
  String? get _viewedTodo => state.viewedTodo;

  Todo? get visibleTodo => _viewedTodo is String ? _tree.getTodo(_viewedTodo!) : null;

  // @override
  void _emitNextState({
    dynamic exception = NoValue,
    dynamic isLoading = NoValue,
    dynamic tree = NoValue,
    dynamic viewedTodo = NoValue,
    dynamic selectedTodo = NoValue,
  }) {
    // Fuck this shit man I guess default parameter values gotta be compile-time constants in dart.
    assert(exception is Exception || exception == null || exception == NoValue);
    assert(isLoading == true || isLoading == false || isLoading == NoValue);
    assert(tree is TodosTree || tree == NoValue);
    assert(viewedTodo == null || viewedTodo is String || exception == NoValue);
    assert(selectedTodo == null || selectedTodo is String || exception == NoValue);

    final Exception? nextException = (exception == NoValue) ? _exception : exception;
    final bool nextIsLoading = (isLoading == NoValue) ? _isLoading : isLoading;
    final TodosTree nextTree = (tree == NoValue) ? _tree : tree;
    final String? nextViewedTodo = (viewedTodo == NoValue) ? _viewedTodo : viewedTodo;
    final String? nextSelectedTodo = (selectedTodo == NoValue) ? _selectedTodo : selectedTodo;

    emit(TodosState(
      exception: nextException,
      isLoading: nextIsLoading,
      tree: nextTree,
      selectedTodo: nextSelectedTodo,
      viewedTodo: nextViewedTodo,
    ));
  }

  Future<void> initialize() async {
    try {
      await _loadRootTodos();
      _emitNextState(isLoading: false);
      _tree.rootTodos.forEach((rootTodo) {
        _fetchTodoChildren(rootTodo);
      });

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

  Future<void> addTodo(String title, String? parentId) async {
    if (_isLoading) {
      throw Exception(
          '${this.runtimeType}: Attempted to create child todo before todos were loaded.');
    }

    final List<Todo> todoSiblings = _tree.childrenOf(parentId);

    final String order =
        todoSiblings.isEmpty ? OrderId.getInitialId() : OrderId.getNext(todoSiblings.last.order);

    final newTodo = Todo(
      title: title,
      parentId: parentId,
      order: order,
      childrenIds: {},
      isChildrenLoaded: true,
      isComplete: false,
    );

    _tree.add(newTodo);
    _emitNextState();

    await TodoApi.createTodo(newTodo);
  }

  void _onNewTodo(Todo newTodo) {
    // If we already have a copy of this todo, do nothing - we probably made it locally.
    if (_tree.contains(newTodo.id)) return;

    // If a todo's parent has not been loaded, we can just wait to load it when it's needed.
    final parentId = newTodo.parentId;
    if (parentId is String && !_tree.contains(parentId)) return;
////////////
    // The subscription operation will send new todos with isChildrenLoaded == true.
    _tree.add(newTodo);
    _emitNextState();
  }

  void toggleSelectedTodo(String? todoId) {
    if (_selectedTodo == todoId) {
      _emitNextState(selectedTodo: null);
    } else {
      _emitNextState(selectedTodo: todoId);
    }
  }

  /// Update state to view the selected todo. Make sure the latest version of the children are
  /// loaded.
  void viewTodo(String? todoToView) {
    assert(todoToView == null || _tree.contains(todoToView));
    _emitNextState(viewedTodo: todoToView);

    // If the user wants to view a todo whose children have already been loaded, don't re-load
    // them since we keep them up to date.
    if (todoToView == null) return;

    final Todo viewedTodo = _tree.getTodo(todoToView);
    assert(viewedTodo.isChildrenLoaded);

    _tree.childrenOf(todoToView).forEach((todo) {
      // Conditionally fetch todos for a todo whose children we haven't loaded yet.
      if (todo.isChildrenLoaded) return;
      _fetchTodoChildren(todo);
    });

    // // Stay at least one layer of todos ahead of the user's visibility.
    // for (final Todo todo in _tree.childrenOf(todoToView)) {
    //   // _fetchTodoChildren(todo);
    //   _fetchTodoChildren(todo).then((_) {
    //     _tree.childrenOf(todo.id).forEach(_fetchTodoChildren);
    //     // for (final Todo childTodo in _tree.getTodosForParent(todo.id)) {
    //     //   _fetchTodoChildren(childTodo);
    //     // }
    //   });
    // }
  }

  /// Add a list of loaded todos to the TodosTree state.
  void _cacheTodos(List<Todo> todos) {
    _tree.addAll(todos);
    _emitNextState();
  }

  Future<void> _loadRootTodos() async => await TodoApi.loadRootTodos().forEach(_cacheTodos);

  Future<void> _fetchTodoChildren(Todo todo) async {
    await TodoApi.loadTodoChildren(todo).forEach(_cacheTodos);
    todo.setChildrenLoaded();
    _emitNextState();
  }

  Future<void> moveTodo(int startIndex, int endIndex) async {
    assert(_isLoading == false);
    final List<Todo> todoList = state.todoList;

    final Todo movingTodo = todoList[startIndex];
    String updatedOrder = '';
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
      parentId: movingTodo.parentId,
    );
  }

  Future<void> moveTodoToParent(String todoId, String? parentId) async {
    if (!_tree.canMoveTodoTo(todoId, parentId)) return;

    final Todo movingTodo = _tree.getTodo(todoId);
    final nextSiblingList = _tree.childrenOf(parentId);

    final nextOrder = nextSiblingList.isEmpty
        ? OrderId.getInitialId()
        : OrderId.getPrevious(nextSiblingList.first.order);

    _tree.updateParentId(todoId, parentId);

    // Yes we emit two states here but I want to see the todo appear before I close the secondary info appbar.
    _emitNextState(selectedTodo: null);

    await updateTodoWith(
      movingTodo,
      title: movingTodo.title,
      isComplete: movingTodo.isComplete,
      order: nextOrder,
      parentId: parentId,
    );
  }

  // Needed to update parentId because dart can't do fucking runtime parameter default values
  Future<void> updateTodoWith(
    Todo todoToUpdate, {
    required String title,
    required bool isComplete,
    required String order,
    required String? parentId,
  }) async {
    final updatedTodo = todoToUpdate.copyWith(
      title: title,
      isComplete: isComplete,
      order: order,
      parentId: parentId,
      children: todoToUpdate.childrenIds,
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
      children: todoToUpdate.childrenIds,
    );
    _tree.update(updatedTodo);
    _emitNextState();
    await TodoApi.updateTodo(updatedTodo);
  }

  void _onUpdatedTodo(Todo updatedTodo) {
    return;
    // if (!_tree.contains(updatedTodo.id)) {
    //   // We probably just recently deleted it is all.
    //   return;
    // }
    // final Todo currentTodo = _tree.getTodo(updatedTodo.id);

    // final bool didUpdateParent = currentTodo.parentId != updatedTodo.parentId;

    // if (didUpdateParent && currentTodo.parentId is String) {
    //   final currentParentTodo = _tree.getTodo(currentTodo.parentId!);
    //   if (currentParentTodo is Todo) _fetchTodoChildren(currentParentTodo);
    // }

    // if (didUpdateParent && updatedTodo.parentId is String) {
    //   final nextParentTodo = _tree.getTodo(updatedTodo.parentId!);
    //   if (nextParentTodo is Todo) _fetchTodoChildren(nextParentTodo);
    // }

    // // i feel like we need to pull in the existing childs children set and also isLoaded values, idk.
    // _tree.update(updatedTodo);
    // _emitNextState();
  }

  // We kind of assume that if todoToDelete has a parent, then that parent is the viewedTodo
  Future<void> deleteTodo(Todo todoToDelete) async {
    _tree.remove(todoToDelete.id);
    _emitNextState();
    await TodoApi.deleteTodo(todoToDelete);
  }

  void _onDeletedTodo(String deletedTodoId) {
    if (_tree.contains(deletedTodoId)) {
      _tree.remove(deletedTodoId);
      _emitNextState();
    }
  }

  void showTodoFormModal(BuildContext context, Todo? editingTodo) {
    final String? title = editingTodo?.title;

    showModalBottomSheet(
      context: context,
      isDismissible: true,
      builder: (ctx) => BlocProvider<TodosCubit>.value(
        value: BlocProvider.of(context),
        child: MutationModal(
          title: title,
          onSave: (newTitle) {
            if (editingTodo == null) {
              addTodo(newTitle, _viewedTodo);
            } else {
              updateTodo(editingTodo, title: newTitle);
            }
          },
        ),
      ),
    );
  }
}
