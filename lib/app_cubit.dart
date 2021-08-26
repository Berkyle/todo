import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/models/Queue.dart';
import 'package:todo/models/Todo.dart';
import 'package:todo/queue_cubit.dart';
import 'package:todo/todo_cubit.dart';
import 'package:todo/mutation_modal.dart';

// class AppState {
//   bool configuringAmplify = false;
//   int selectedIndex = 0;

//   AppState(AppState lastState) {}
// }

class AppCubit extends Cubit<int> {
  AppCubit() : super(1);

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
    final title = selectedTodo?.title;

    showModalBottomSheet(
      context: context,
      isDismissible: true,
      builder: (ctx) => BlocProvider<TodoCubit>.value(
        value: BlocProvider.of(context),
        child: MutationModal(
          title: title,
          onSave: (newTitle) {
            if (selectedTodo == null) {
              BlocProvider.of<TodoCubit>(context).createTodo(newTitle);
            } else {
              BlocProvider.of<TodoCubit>(context).updateTodo(
                selectedTodo,
                title: newTitle,
              );
            }
          },
        ),
      ),
    );
  }

  void showQueueFormModal(BuildContext context, Queue? selectedQueue) {
    final title = selectedQueue?.title;
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      builder: (ctx) => BlocProvider<QueueCubit>.value(
        value: BlocProvider.of(context),
        child: MutationModal(
          title: title,
          onSave: (newTitle) {
            if (selectedQueue == null) {
              BlocProvider.of<QueueCubit>(context).createQueue(newTitle);
            } else {
              BlocProvider.of<QueueCubit>(context).updateQueue(
                selectedQueue,
                title: newTitle,
              );
            }
          },
        ),
      ),
    );
  }
}
