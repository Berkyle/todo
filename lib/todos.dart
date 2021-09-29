import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/todo_row.dart';

import 'todos_cubit.dart';
import 'Todo.dart';

class Todos extends StatelessWidget {
  final List<Todo> todos;

  Todos({required this.todos});

  @override
  Widget build(BuildContext context) {
    if (todos.isEmpty) {
      return _emptyTodosView();
    } else {
      return _todosListView(todos, context);
    }
  }

  Widget _emptyTodosView() {
    return Center(
      child: Text('No todos here yet.'),
    );
  }

  Widget _todosListView(List<Todo> todos, BuildContext context) {
    return Scrollbar(
      child: ReorderableListView.builder(
        itemCount: todos.length,
        onReorder: BlocProvider.of<TodosCubit>(context).moveTodo,
        itemBuilder: (context, index) {
          final todo = todos[index];
          return TodoRow(key: Key(todo.id), todo: todo);
        },
      ),
    );
  }
}
