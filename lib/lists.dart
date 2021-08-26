import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/todo_cubit.dart';
// import 'package:todo/todo_form_modal.dart';

import 'loading_view.dart';
// import 'models/Todo.dart';

class Lists extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ListsState();
}

class _ListsState extends State<Lists> {
  // Todo? _selectedList;

  @override
  Widget build(BuildContext context) {
    return (BlocBuilder<TodoCubit, TodoState>(builder: (context, state) {
      if (state is ListTodosSuccess) {
        return Center(child: Text('lists go right here'));
      } else {
        return LoadingView();
      }
    }));
  }
}
