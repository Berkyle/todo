import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/models/Queue.dart';
import 'package:todo/models/Todo.dart';
import 'package:todo/queue_cubit.dart';
import 'package:todo/todo_cubit.dart';
import 'package:todo/mutation_modal.dart';

// abstract class AppState {}

// class AppState extends AppState {
class AppState {
  int navigationIndex = 0;
  final Queue? selectedQueue;

  AppState({required int navIndex, this.selectedQueue}) {
    navigationIndex = navIndex;
  }
}

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(AppState(navIndex: 0));

  void setNavigationView(int navIndex, [Queue? selectedQueue]) {
    emit(AppState(navIndex: navIndex, selectedQueue: selectedQueue ?? state.selectedQueue));
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
          mutationType: Mutation.TODO,
          onSave: (newTitle) {
            if (selectedTodo == null) {
              BlocProvider.of<TodoCubit>(context).createTodo(newTitle, state.selectedQueue?.id);
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
          mutationType: Mutation.QUEUE,
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
