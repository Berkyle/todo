// import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/todo_cubit.dart';
import 'package:todo/todo_form_modal.dart';
// import 'package:todo/todos_api.dart';

import 'loading_view.dart';
import 'models/Todo.dart';

class TodosView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TodosViewState();
}

class _TodosViewState extends State<TodosView> {
  Todo? _selectedTodo;
  int _currentNavigationIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _navbar(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentNavigationIndex,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Todos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restart_alt),
            label: 'Recurring Todos',
          ),
        ],
        onTap: (itemNumber) {
          setState(() {
            // if (itemNumber == 1) {
            //   listTodos();
            // } else {
            //   final newTodo =
            //       Todo(title: 'a subscription for this todo', isComplete: false, order: 'mmff');
            //   createTodo(newTodo);
            // }
            _currentNavigationIndex = itemNumber;
          });
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _floatingActionButton(),
      body: BlocBuilder<TodoCubit, TodoState>(builder: (context, state) {
        if (state is ListTodosSuccess) {
          if (state.todos.isEmpty)
            return _emptyTodosView();
          else
            return _todosListView(state.orderedTodos);
        } else if (state is ListTodosFailure) {
          return _exceptionView(state.exception);
        } else {
          return LoadingView();
        }
      }),
    );
  }

  Widget _exceptionView(Exception exception) {
    return Center(child: Text(exception.toString()));
  }

  AppBar _navbar() {
    return AppBar(title: Text('Todos'), actions: <Widget>[
      IconButton(
        icon: const Icon(Icons.favorite),
        tooltip: 'Favorite this Queue',
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Queue saved')));
        },
      ),
    ]);
  }

  void _showTodoFormModal(Todo? selectedTodo) {
    setState(() {
      _selectedTodo = selectedTodo;
    });
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      builder: (ctx) => BlocProvider<TodoCubit>.value(
        value: BlocProvider.of(context),
        child: TodoFormModal(_selectedTodo),
      ),
    );
  }

  Widget _floatingActionButton() {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {
        _showTodoFormModal(null);
      },
    );
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
                onTap: () => _showTodoFormModal(todo),
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
