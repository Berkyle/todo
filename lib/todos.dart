import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/app_cubit.dart';
import 'package:todo/todo_cubit.dart';

import 'loading_view.dart';
import 'models/Todo.dart';

class Todos extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TodosState();
}

class _TodosState extends State<Todos> {
  @override
  Widget build(BuildContext context) {
    return (BlocBuilder<TodoCubit, TodoState>(builder: (context, state) {
      if (state is ListTodosSuccess) {
        if (state.orderedTodos.isEmpty)
          return _emptyTodosView();
        else
          return _todosListView(state.orderedTodos);
      } else if (state is ListTodosFailure) {
        return _exceptionView(state.exception);
      } else {
        return LoadingView();
      }
    }));
  }

  Widget _exceptionView(Exception exception) {
    return Center(child: Text(exception.toString()));
  }

  Widget _emptyTodosView() {
    return Center(
      child: Text('No todos yet.'),
    );
  }

  Widget _todosListView(List<Todo> todos) {
    return Scrollbar(
      child: ReorderableListView.builder(
        itemCount: todos.length,
        onReorder: (indexA, indexB) async {
          BlocProvider.of<TodoCubit>(context).moveTodo(indexA, indexB);
        },
        itemBuilder: (context, index) {
          final todo = todos[index];
          return Dismissible(
            key: Key(todo.id),
            onDismissed: (direction) {
              if (direction == DismissDirection.startToEnd) {
                // Send to another Queue instead!
                // BlocProvider.of<TodoCubit>(context).createTodoTemplate(todo.title);
              }
              BlocProvider.of<TodoCubit>(context).deleteTodo(todo);
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xAAAAAAAA), width: 1.0)),
              ),
              child: ListTile(
                title: Text(todo.title),
                onTap: () => BlocProvider.of<AppCubit>(context).showTodoFormModal(context, todo),
                leading: Checkbox(
                  shape: CircleBorder(),
                  value: todo.isComplete,
                  onChanged: (newValue) {
                    BlocProvider.of<TodoCubit>(context).updateTodo(todo, isComplete: newValue!);
                  },
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
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
        },
      ),
    );
  }
}
