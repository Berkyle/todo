import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        itemBuilder: _todoRow,
      ),
    );
  }

  Widget _todoRow(context, index) {
    final todo = todos[index];
    // final hasChildrenTodos =
    return Dismissible(
      direction: todo.parentId == null ? DismissDirection.endToStart : DismissDirection.horizontal,
      key: Key(todo.id),
      onDismissed: (direction) => BlocProvider.of<TodosCubit>(context).viewTodo(todo.id),
      // onDismissed: (direction) => direction == DismissDirection.endToStart
      //     ? BlocProvider.of<TodosCubit>(context).deleteTodo(todo) // swipe right to left
      //     : BlocProvider.of<TodosCubit>(context).viewTodo(todo.parentId), // swipe left to right
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xAAAAAAAA), width: 1.0)),
        ),
        child: BlocBuilder<TodosCubit, TodosState>(
          builder: (context, queueState) {
            return ListTile(
              title: Text(todo.title),
              onTap: () => BlocProvider.of<TodosCubit>(context).showTodoFormModal(context, todo),
              leading: Checkbox(
                shape: CircleBorder(),
                value: todo.isComplete,
                onChanged: (newValue) {
                  BlocProvider.of<TodosCubit>(context).updateTodo(todo, isComplete: newValue!);
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            );
          },
        ),
      ),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 20),
        color: Colors.blue,
        child: Icon(Icons.restart_alt, color: Colors.white, size: 32),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20),
        color: Colors.red,
        child: Icon(Icons.delete, color: Colors.white, size: 32),
      ),
    );
  }
}
