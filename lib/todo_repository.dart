import 'package:amplify_flutter/amplify.dart';
import 'package:todo/models/ModelProvider.dart';
import 'package:amplify_datastore_plugin_interface/amplify_datastore_plugin_interface.dart';
// Uncomment the below line to enable online sync
import 'package:amplify_api/amplify_api.dart';

import 'models/Todo.dart';

class TodoRepository {
  Future<List<Todo>> getTodos() async {
    final todos = await Amplify.DataStore.query(Todo.classType);
    return todos;
  }

  Future<void> createTodo(Todo newTodo) async {
    await Amplify.DataStore.save(newTodo);
  }

  Future<void> updateTodo(Todo updatedTodo) async {
    await Amplify.DataStore.save(updatedTodo);
  }

  Stream<SubscriptionEvent<Todo>> observeTodos() {
    return Amplify.DataStore.observe(Todo.classType);
  }

  Future<void> deleteTodo(Todo todo) async {
    await Amplify.DataStore.delete(todo);
  }
}


// // ignore: camel_case_types
// class TodoCubit_OLD extends Cubit<TodoState> {
//   final _todoRepo = TodoRepository();

//   TodoCubit_OLD() : super(LoadingTodos());

//   void getTodos() async {
//     if (state is ListTodosSuccess == false) {
//       emit(LoadingTodos(todos: state.todos));
//     }

//     try {
//       final todos = await _todoRepo.getTodos();
//       emit(ListTodosSuccess(todos: todos));
//     } catch (e) {
//       if (e is Exception) {
//         emit(ListTodosFailure(exception: e, todos: state.todos));
//       }
//     }
//   }

//   void observeTodos() async {
//     // TodoApi
//     // final todosStream = _todoRepo.observeTodos();
//     // todosStream.listen((_) => getTodos());
//   }

//   void createTodo(String title) async {
//     final state = this.state;
//     if (state is ListTodosSuccess) {
//       final order = state.orderedTodos.length > 0
//           ? OrderId.getNext(state.orderedTodos.last.order)
//           : OrderId.getInitialId();
//       final newTodo = Todo(title: title, isComplete: false, order: order);
//       emit(ListTodosSuccess(todos: [...state.todos]..add(newTodo)));
//       await _todoRepo.createTodo(newTodo);
//     }
//   }

//   Future<void> updateTodo(
//     Todo todoToUpdate, {
//     String? title,
//     bool? isComplete,
//     String? order,
//   }) async {
//     final state = this.state;
//     if (state is ListTodosSuccess) {
//       final updatedTodo = todoToUpdate.copyWith(
//         title: title ?? todoToUpdate.title,
//         isComplete: isComplete ?? todoToUpdate.isComplete,
//         order: order ?? todoToUpdate.order,
//       );
//       final updatedTodos =
//           state.todos.map((todo) => todo.id == todoToUpdate.id ? updatedTodo : todo).toList();
//       emit(ListTodosSuccess(todos: updatedTodos));
//       await _todoRepo.updateTodo(updatedTodo);
//     }
//   }

//   void moveTodo(int startIndex, int endIndex) async {
//     final state = this.state;
//     if (state is ListTodosSuccess) {
//       final movingTodo = state.orderedTodos[startIndex];
//       var updatedOrder = '';
//       if (endIndex == 0) {
//         updatedOrder = OrderId.getPrevious(state.orderedTodos[0].order);
//       } else if (endIndex == state.todos.length) {
//         updatedOrder = OrderId.getNext(state.orderedTodos.last.order);
//       } else {
//         final lowerOrder = state.orderedTodos[endIndex - 1].order;
//         final upperOrder = state.orderedTodos[endIndex].order;
//         updatedOrder = OrderId.getIdBetween(lowerOrder, upperOrder);
//       }
//       emit(ListTodosSuccess(
//           todos: state.todos.map((todo) {
//         if (todo.id == movingTodo.id) return movingTodo.copyWith(order: updatedOrder);
//         return todo;
//       }).toList()));
//       await updateTodo(movingTodo, order: updatedOrder);
//     }
//   }

//   void deleteTodo(Todo todoToDelete) async {
//     final state = this.state;
//     if (state is ListTodosSuccess) {
//       emit(ListTodosSuccess(
//           todos: state.todos.where((todo) => todo.id != todoToDelete.id).toList()));
//       await _todoRepo.deleteTodo(todoToDelete);
//     }
//   }
// }