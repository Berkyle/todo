import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'todos_cubit.dart';
import 'todo.dart';

class TodoRow extends StatelessWidget {
  final Todo todo;

  TodoRow({required this.todo, required Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TodosCubit cubit = BlocProvider.of<TodosCubit>(context);

    return Dismissible(
      key: Key(todo.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => !todo.isChildrenLoaded || todo.childrenIds.isNotEmpty
          ? cubit.viewTodo(todo.id) // Todo has children, let's check em out
          : cubit.deleteTodo(todo), // Todo has no children and can be deleted
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
              todo.childrenIds.isNotEmpty ? Colors.green.shade100 : Colors.white,
            ],
          ),
        ),
        child: ListTile(
          selected: cubit.state.selectedTodo == todo.id,
          enabled: todo.isChildrenLoaded,
          dense: true,
          onTap: () => cubit.viewTodo(todo.id),
          title: Text(todo.title),
          leading: Checkbox(
            shape: CircleBorder(),
            value: todo.isComplete,
            onChanged: (newValue) => cubit.updateTodo(todo, isComplete: newValue!),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          trailing: PopupMenuButton<EditOptions>(
            onSelected: (EditOptions result) {
              switch (result) {
                case EditOptions.Rename:
                  return cubit.showTodoFormModal(context, todo);
                case EditOptions.Move:
                  return cubit.toggleSelectedTodo(todo.id);
              }
            },
            itemBuilder: (BuildContext context) => EditOptions.values
                .map(
                  (editOption) => PopupMenuItem<EditOptions>(
                    value: editOption,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [optionIcon[editOption]!, Text(optionText[editOption]!)],
                    ),
                  ),
                )
                .toList(),
          ),
          subtitle: todo.childrenIds.isNotEmpty ? Text('${todo.childrenIds.length} items') : null,
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
        color: todo.childrenIds.isNotEmpty ? Colors.green.shade200 : Colors.red[200],
        child: Icon(
          todo.childrenIds.isNotEmpty ? Icons.arrow_forward : Icons.delete,
          color: Colors.black,
          size: 32,
        ),
      ),
    );
  }
}

enum EditOptions { Rename, Move }
// enum EditOptions { Rename, Move, Deselect }
Set<EditOptions> selectedEditOptions = {...EditOptions.values};
// Set<EditOptions> selectedEditOptions = { EditOptions.Rename, EditOptions.Deselect };
final Map<EditOptions, String> optionText = {
  EditOptions.Rename: 'Rename',
  EditOptions.Move: 'Move',
};
final Map<EditOptions, Widget> optionIcon = {
  EditOptions.Rename: Icon(Icons.edit),
  EditOptions.Move: Icon(Icons.miscellaneous_services_sharp),
};
