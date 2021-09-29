import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/todos_tree.dart';

import 'todos_cubit.dart';
import 'Todo.dart';

class TodoRow extends StatefulWidget {
  final Todo todo;

  TodoRow({required this.todo, required Key key}) : super(key: key);
  State<StatefulWidget> createState() => _TodoRowState();
}

class _TodoRowState extends State<TodoRow> {
  Todo get todo => widget.todo;

  TodosCubit get _cubit => BlocProvider.of<TodosCubit>(context);
  TodosTree get treeState => _cubit.state.tree;

  @override
  Widget build(BuildContext context) {
    final childrenTodos = _cubit.state.tree.getTodosForParent(todo.id);
    final hasChildrenTodos = childrenTodos.length > 0;

    return Dismissible(
      key: Key(todo.id),
      // key: GlobalKey(debugLabel: todo.id),
      direction: todo.parentId == null ? DismissDirection.endToStart : DismissDirection.horizontal,
      onDismissed: (direction) => direction == DismissDirection.endToStart
          ? hasChildrenTodos // swipe right to left
              ? _cubit.viewTodo(todo.id) // Todo has children, let's check em out
              : _cubit.deleteTodo(todo) // Todo has no children and can be deleted
          : _cubit.viewTodo(todo.parentId), // swipe left to right
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xAAAAAAAA), width: 1.0)),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.centerRight,
            colors: [
              Colors.white,
              Colors.white,
              hasChildrenTodos ? Colors.green[100]! : Colors.white
            ],
          ),
        ),
        child: ListTile(
          dense: true,
          title: Text(todo.title),
          onTap: () => _cubit.viewTodo(todo.id),
          leading: Checkbox(
            shape: CircleBorder(),
            value: todo.isComplete,
            onChanged: (newValue) => _cubit.updateTodo(todo, isComplete: newValue!),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          trailing: IconButton(
            // icon: Icon(Icons.add),
            icon: Icon(Icons.edit, size: 18),
            onPressed: () => _cubit.showTodoFormModal(context, todo),
          ),
          subtitle: hasChildrenTodos ? Text('${childrenTodos.length} items') : null,
        ),
      ),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 20),
        color: Colors.blue,
        child: Icon(Icons.arrow_back, color: Colors.white, size: 32),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20),
        color: hasChildrenTodos ? Colors.green[200] : Colors.red[200],
        child: Icon(
          hasChildrenTodos ? Icons.arrow_forward : Icons.delete,
          color: Colors.black,
          size: 32,
        ),
      ),
    );
  }
}
