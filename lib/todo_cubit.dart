import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/models/ModelProvider.dart';
import 'package:todo/order_id.dart';
import 'package:todo/todo_api.dart';

import 'models/Todo.dart';

abstract class TodoState {
  final String? queueId = null;
}

class LoadingTodos extends TodoState {
  final String? queueId;
  LoadingTodos({this.queueId});
}

class ListTodosSuccess extends TodoState {
  final List<Todo> todos;
  final String? queueId;

  Map<String, Todo> todoMap = {};
  List<Todo> orderedTodos = [];

  ListTodosSuccess({required this.todos, this.queueId}) {
    // Populate {todoMap}.
    for (var i = 0; i < todos.length; i += 1) {
      final todo = todos[i];
      todoMap[todo.id] = todo;
    }

    // Populate {orderedTodos}, containing the set of visible todos, in order.
    print(queueId.toString());
    orderedTodos = todos.where((todo) => queueId == null || todo.queueId == queueId).toList();
    orderedTodos.sort((todoA, todoB) => todoA.order.compareTo(todoB.order));
  }
}

class ListTodosFailure extends TodoState {
  final Exception exception;
  ListTodosFailure({required this.exception});
}

class TodoCubit extends Cubit<TodoState> {
  TodoCubit() : super(LoadingTodos(queueId: null));

  void getTodos() async {
    if (state is ListTodosSuccess == false) {
      emit(LoadingTodos(queueId: state.queueId));
    }

    try {
      final todos = await TodoApi.listTodos();
      emit(ListTodosSuccess(todos: todos, queueId: state.queueId));
    } catch (e) {
      if (e is Exception) {
        emit(ListTodosFailure(exception: e));
      }
    }
  }

  void _onNewTodo(Todo newTodo) {
    final state = this.state;
    if (state is ListTodosSuccess && state.todoMap[newTodo.id] == null) {
      emit(ListTodosSuccess(todos: [...state.todos]..add(newTodo), queueId: state.queueId));
    }
  }

  void _onUpdatedTodo(Todo updatedTodo) {
    final state = this.state;
    if (state is ListTodosSuccess) {
      final updatedTodos =
          state.todos.map((todo) => todo.id == updatedTodo.id ? updatedTodo : todo).toList();
      emit(ListTodosSuccess(todos: updatedTodos, queueId: state.queueId));
    }
  }

  void _onDeletedTodo(String deletedTodoId) {
    final state = this.state;
    if (state is ListTodosSuccess && state.todoMap[deletedTodoId] != null) {
      emit(ListTodosSuccess(
        todos: [...state.todos].where((todo) => todo.id != deletedTodoId).toList(),
        queueId: state.queueId,
      ));
    }
  }

  void observeTodos() {
    TodoApi.observeCreateTodo(_onNewTodo);
    TodoApi.observeUpdateTodo(_onUpdatedTodo);
    TodoApi.observeDeleteTodo(_onDeletedTodo);
  }

  void createTodo(String title, String? queueId) async {
    final state = this.state;
    if (state is ListTodosSuccess) {
      final order = state.orderedTodos.length > 0
          ? OrderId.getNext(state.orderedTodos.last.order)
          : OrderId.getInitialId();
      final newTodo = Todo(title: title, isComplete: false, order: order, queueId: queueId);
      emit(ListTodosSuccess(todos: [...state.todos]..add(newTodo), queueId: state.queueId));
      await TodoApi.createTodo(newTodo);
    }
  }

  Future<void> updateTodo(
    Todo todoToUpdate, {
    String? title,
    bool? isComplete,
    String? order,
  }) async {
    final state = this.state;
    if (state is ListTodosSuccess) {
      final updatedTodo = todoToUpdate.copyWith(
        title: title ?? todoToUpdate.title,
        isComplete: isComplete ?? todoToUpdate.isComplete,
        order: order ?? todoToUpdate.order,
      );
      final updatedTodos =
          state.todos.map((todo) => todo.id == todoToUpdate.id ? updatedTodo : todo).toList();
      emit(ListTodosSuccess(todos: updatedTodos, queueId: state.queueId));
      await TodoApi.updateTodo(updatedTodo);
    }
  }

  void moveTodo(int startIndex, int endIndex) async {
    final state = this.state;
    if (state is ListTodosSuccess) {
      final movingTodo = state.orderedTodos[startIndex];
      var updatedOrder = '';
      if (endIndex == 0) {
        updatedOrder = OrderId.getPrevious(state.orderedTodos.first.order);
      } else if (endIndex == state.todos.length) {
        updatedOrder = OrderId.getNext(state.orderedTodos.last.order);
      } else {
        final lowerOrder = state.orderedTodos[endIndex - 1].order;
        final upperOrder = state.orderedTodos[endIndex].order;
        updatedOrder = OrderId.getIdBetween(lowerOrder, upperOrder);
      }
      final updatedTodo = movingTodo.copyWith(order: updatedOrder);
      emit(ListTodosSuccess(
        todos: state.todos.map((todo) {
          if (todo.id == movingTodo.id) return updatedTodo;
          return todo;
        }).toList(),
        queueId: state.queueId,
      ));
      await updateTodo(updatedTodo, order: updatedOrder);
    }
  }

  void deleteTodo(Todo todoToDelete) async {
    final state = this.state;
    if (state is ListTodosSuccess) {
      emit(ListTodosSuccess(
        todos: state.todos.where((todo) => todo.id != todoToDelete.id).toList(),
        queueId: state.queueId,
      ));
      await TodoApi.deleteTodo(todoToDelete);
    }
  }

  void setQueueId(String? queueId) {
    final state = this.state;
    if (state is ListTodosSuccess) {
      emit(ListTodosSuccess(todos: state.todos, queueId: queueId));
    } else if (state is LoadingTodos) {
      emit(LoadingTodos(queueId: queueId));
    }
  }
}
