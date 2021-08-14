import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/models/ModelProvider.dart';
import 'package:todo/todo_repository.dart';
import 'package:amplify_datastore_plugin_interface/amplify_datastore_plugin_interface.dart';

import 'models/Todo.dart';

abstract class TodoState {
  final List<Todo>? todos = null;
}

class LoadingTodos extends TodoState {
  final List<Todo>? todos;
  LoadingTodos({this.todos});
}

var updated = 0;

class ListTodosSuccess extends TodoState {
  final List<Todo> todos;

  Map<String, Todo> todoMap = {};
  List<Todo> orderedTodos = [];

  ListTodosSuccess({required this.todos}) {
    // Populate {todoMap}.
    for (var i = 0; i < todos.length; i += 1) {
      final todo = todos[i];
      todoMap[todo.id] = todo;
    }

    // Populate {orderedTodos}
    orderedTodos = [...todos]..sort((todoA, todoB) => todoA.order.compareTo(todoB.order));
  }
}

class ListTodosFailure extends TodoState {
  final Exception exception;
  final List<Todo>? todos;
  ListTodosFailure({required this.exception, this.todos});
}

class TodoCubit extends Cubit<TodoState> {
  final _todoRepo = TodoRepository();

  TodoCubit() : super(LoadingTodos());

  void getTodos() async {
    if (state is ListTodosSuccess == false) {
      emit(LoadingTodos(todos: state.todos));
    }

    try {
      final todos = await _todoRepo.getTodos();
      emit(ListTodosSuccess(todos: todos));
    } catch (e) {
      if (e is Exception) {
        emit(ListTodosFailure(exception: e, todos: state.todos));
      }
    }
  }

  void observeTodos() async {
    final todosStream = _todoRepo.observeTodos();
    todosStream.listen((_) => getTodos());
    // todosStream.listen((event) {
    //   if (event.eventType == EventType.create) {
    //     final newTodo = event.item;
    //     final currentTodosState = state.todos == null ? null : [...state.todos!];
    //     if (currentTodosState != null) {
    //       currentTodosState.add(newTodo);
    //       emit(ListTodosSuccess(todos: currentTodosState));
    //     }
    //   } else if (event.eventType == EventType.update) {
    //   } else if (event.eventType == EventType.delete) {
    //   }
    // });
  }

  void createTodo(String title) async {
    final state = this.state;
    if (state is ListTodosSuccess) {
      if (state.orderedTodos.length > 0) {
        final order = OrderId.getNext(state.orderedTodos.last.order);
        await _todoRepo.createTodo(title, order);
      } else {
        await _todoRepo.createTodo(title, OrderId.getInitialId());
      }
    }
  }

  void createTodoTemplate(String title) async {
    await _todoRepo.createTodoTemplate(title);
  }

  Future<void> updateTodo(
    Todo todo, {
    String? title,
    bool? isComplete,
    String? order,
  }) async {
    await _todoRepo.updateTodo(
      todo,
      title: title ?? todo.title,
      isComplete: isComplete ?? todo.isComplete,
      order: order ?? todo.order,
    );
  }

  void moveTodo(int startIndex, int endIndex) async {
    final state = this.state;
    if (state is ListTodosSuccess) {
      final movingTodo = state.orderedTodos[startIndex];
      var updatedOrder = '';
      if (endIndex == 0) {
        updatedOrder = OrderId.getPrevious(state.orderedTodos[0].order);
      } else if (endIndex == state.todos.length) {
        updatedOrder = OrderId.getNext(state.orderedTodos.last.order);
      } else {
        final lowerOrder = state.orderedTodos[endIndex - 1].order;
        final upperOrder = state.orderedTodos[endIndex].order;
        updatedOrder = OrderId.getIdBetween(lowerOrder, upperOrder);
      }
      emit(ListTodosSuccess(
          todos: state.todos.map((todo) {
        if (todo.id == movingTodo.id) return movingTodo.copyWith(order: updatedOrder);
        return todo;
      }).toList()));
      await _todoRepo.updateTodo(movingTodo, order: updatedOrder);
    }
  }

  void deleteTodo(Todo todoToDelete) async {
    final state = this.state;
    if (state is ListTodosSuccess) {
      emit(ListTodosSuccess(
          todos: state.todos.where((todo) => todo.id != todoToDelete.id).toList()));
      await _todoRepo.deleteTodo(todoToDelete);
    }
  }
}

class OrderId {
  static String getInitialId() => 'mmm'; // 3 fucking "m"s :')

  static String getNext(String id) {
    if (id.endsWith('z')) {
      // 'mmz' -> 'mmzm'
      return id + 'm';
    } else {
      // 'mma' -> 'mmb'
      return id.substring(0, id.length - 1) + fromCharCode(orderIdRank(id[id.length - 1]) + 1);
    }
  }

  static String getPrevious(String id) {
    assert(id != 'a');

    if (id.endsWith('a')) {
      // 'gmaa' => 'glzzm'
      var fromRight = 0;
      while (id[id.length - 1 - fromRight] == 'a' && fromRight < id.length) {
        fromRight += 1;
      }
      if (fromRight == id.length) {
        throw Exception("Failed to get previous value for id $id"); // probably like 'aaaaa' lol
      }
      final charToDecrement = id[id.length - 1 - fromRight];
      final rolledBackValue = fromCharCode(orderIdRank(charToDecrement) - 1);
      final endValue = List.filled(fromRight, 'z').join() + 'm';
      return id.substring(0, id.length - 1 - fromRight) + rolledBackValue + endValue;
    } else {
      // 'mmb' -> 'mma'
      return id.substring(0, id.length - 1) + fromCharCode(orderIdRank(id[id.length - 1]) - 1);
    }
  }

  static String getIdBetween(String smallerId, String largerId) {
    assert(smallerId.compareTo(largerId) == -1);

    if (getNext(smallerId).compareTo(largerId) == -1) {
      return getNext(smallerId);
    }
    if (smallerId.compareTo(getPrevious(largerId)) == -1) {
      return getPrevious(largerId);
    }
    return smallerId + 'm';
  }

  static int orderIdRank(String orderId) => orderId[0].codeUnits[0];

  static String fromCharCode(int charCode) => String.fromCharCode(charCode);
}
