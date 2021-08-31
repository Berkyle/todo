import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/app_cubit.dart';

import 'loading_view.dart';
import 'models/Todo.dart';

class Todos extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TodosState();
}

class _TodosState extends State<Todos> {
  @override
  Widget build(BuildContext context) {
    return (BlocBuilder<AppCubit, AppState>(builder: (context, state) {
      final todosState = state.todos;
      if (todosState is ListTodosSuccess) {
        if (todosState.orderedTodos.isEmpty)
          return _emptyTodosView();
        else
          return _todosListView(todosState.orderedTodos);
      } else if (todosState is ListTodosFailure) {
        return _exceptionView(todosState.exception);
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
          BlocProvider.of<AppCubit>(context).moveTodo(indexA, indexB);
        },
        itemBuilder: (context, index) {
          final todo = todos[index];
          return Dismissible(
            direction: DismissDirection.endToStart,
            key: Key(todo.id),
            onDismissed: (direction) => BlocProvider.of<AppCubit>(context).deleteTodo(todo),
            child: Container(
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xAAAAAAAA), width: 1.0)),
              ),
              child: BlocBuilder<AppCubit, AppState>(
                builder: (context, queueState) {
                  // if (queueState is ListQueuesSuccess && todo.queueId != null) {
                  //   if (queueState.queueMap[todo.queueId] != null) {
                  //     queueState.queueMap[todo.queueId].isOrdered;
                  //   } else {
                  //     throw Exception("That Todo's Queue doesn't exist! ${todo.toString()}");
                  //   }
                  // }
                  return ListTile(
                    title: Text(todo.title),
                    onTap: () =>
                        BlocProvider.of<AppCubit>(context).showTodoFormModal(context, todo),
                    // (BlocProvider.of<QueueCubit>(context).state as ListQueuesSuccess).queueMap
                    // leading: queueState.,
                    leading: todo.queueId != null &&
                            (queueState is ListQueuesSuccess) &&
                            (BlocProvider.of<AppCubit>(context).state as ListQueuesSuccess)
                                    .queueMap[todo.queueId]
                                    ?.isOrdered ==
                                true
                        ? Container(
                            padding: EdgeInsetsDirectional.only(start: 10.0),
                            child: Text(
                              "${index + 1}.",
                              style:
                                  TextStyle(fontSize: 22, fontWeight: FontWeight.w300, height: 1.3),
                            ),
                          )
                        : Checkbox(
                            shape: CircleBorder(),
                            value: todo.isComplete,
                            onChanged: (newValue) {
                              BlocProvider.of<AppCubit>(context)
                                  .updateTodo(todo, isComplete: newValue!);
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
        },
      ),
    );
  }
}
