import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/models/Queue.dart';
import 'package:todo/models/Todo.dart';
import 'package:todo/todo_cubit.dart';
import 'package:todo/todo_form_modal.dart';

// class AppState {
//   bool configuringAmplify = false;
//   int selectedIndex = 0;

//   AppState(AppState lastState) {}
// }

class AppCubit extends Cubit<int> {
  AppCubit() : super(0);

  void Function()? _onActionButtonPress;
  Todo? _selectedTodo;
  Queue? _selectedQueue;

  void todosView() {
    emit(0);
  }

  void listsView() {
    emit(1);
  }

  void setNavigationView(int navIndex) {
    emit(navIndex);
  }

  void showTodoFormModal(BuildContext context, Todo? selectedTodo) {
    _selectedTodo = selectedTodo;
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      builder: (ctx) => BlocProvider<TodoCubit>.value(
        value: BlocProvider.of(context),
        child: TodoFormModal(_selectedTodo),
      ),
    );
  }

  // void createTodo(String title) async {
  //   final state = this.state;
  //   if (state is ListTodosSuccess) {
  //     final order = state.orderedTodos.length > 0
  //         ? OrderId.getNext(state.orderedTodos.last.order)
  //         : OrderId.getInitialId();
  //     final newTodo = Todo(title: title, isComplete: false, order: order);
  //     emit(ListTodosSuccess(todos: [...state.todos]..add(newTodo)));
  //     await TodoApi.createTodo(newTodo);
  //   }
  // }

  // void deleteTodo(Todo todoToDelete) async {
  //   final state = this.state;
  //   if (state is ListTodosSuccess) {
  //     emit(ListTodosSuccess(
  //         todos: state.todos.where((todo) => todo.id != todoToDelete.id).toList()));
  //     await TodoApi.deleteTodo(todoToDelete);
  //   }
  // }
}
