import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/models/Todo.dart';
import 'package:todo/todo_cubit.dart';

class TodoFormModal extends StatefulWidget {
  final Todo? _selectedTodo;

  TodoFormModal(this._selectedTodo) : super();

  @override
  State<StatefulWidget> createState() => _TodoFormModalState();
}

class _TodoFormModalState extends State<TodoFormModal> {
  final _titleController = TextEditingController();
  Todo? get _selectedTodo => super.widget._selectedTodo;

  @override
  void initState() {
    if (_selectedTodo != null) {
      _titleController.text = _selectedTodo!.title;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Cubit context passed via modal
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Column(children: [
        TextField(
          controller: _titleController,
          autofocus: true,
          maxLines: 3,
          minLines: 1,
          onTap: () {
            _titleController.selection = TextSelection(
              baseOffset: 0,
              extentOffset: _titleController.value.text.length,
            );
          },
          decoration: InputDecoration(hintText: 'Enter todo title'),
        ),
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: null,
                // onPressed: _selectedTodo != null
                //     ? null
                //     : () {
                //         // BlocProvider.of<TodoCubit>(context)
                //         //     .createTodoTemplate(_titleController.text);
                //         _titleController.text = '';
                //         Navigator.of(context).pop();
                //       },
                child: Text('Add to another queue'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_selectedTodo == null) {
                    final todoTitle = _titleController.text;
                    BlocProvider.of<TodoCubit>(context).createTodo(todoTitle);
                  } else {
                    BlocProvider.of<TodoCubit>(context).updateTodo(
                      _selectedTodo!,
                      title: _titleController.text,
                    );
                  }
                  _titleController.text = '';
                  Navigator.of(context).pop();
                },
                child: Text('Save Todo'),
              ),
            ],
          ),
        )
      ]),
    );
  }
}
