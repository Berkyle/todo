import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'loading_view.dart';
import 'todos_cubit.dart';
import 'todos.dart';
import 'todos_theme.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => TodosCubit()..initialize(),
      // create: (BuildContext context) => TodosCubit(),
      child: MaterialApp(
        theme: lightTheme,
        debugShowCheckedModeBanner: false,
        home: BlocConsumer<TodosCubit, TodosState>(
          listener: (context, state) {}, // I guess I need this
          builder: (context, state) {
            final TodosState state = BlocProvider.of<TodosCubit>(context).state;
            if (state.exception is Exception) {
              return _exceptionView(state.exception!);
            } else if (state.isLoading) {
              return LoadingView();
            } else {
              final orderedTodos = state.tree.childrenOf(state.viewedTodo);
              return Todos(todos: orderedTodos);
            }
          },
        ),
      ),
    );
  }

  Widget _exceptionView(Exception exception) {
    return Scaffold(body: Center(child: Text(exception.toString())));
  }
}
