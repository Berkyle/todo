import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/Todo.dart';

import 'loading_view.dart';
import 'todos_cubit.dart';
import 'todos.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TodosCubit, TodosState>(
      listener: (context, state) {}, // I guess I need this
      builder: (context, state) {
        return Scaffold(
          appBar: _appbar(),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: _floatingActionButton(),
          bottomNavigationBar: _navBar(),
          body: _body(state),
        );
      },
    );
  }

  Widget _body(TodosState state) {
    if (state.exception is Exception) {
      return _exceptionView(state.exception!);
    } else if (state.isLoading) {
      return LoadingView();
    } else {
      final orderedTodos = state.tree.getTodosForParent(state.viewedTodo);
      return Todos(todos: orderedTodos);
    }
  }

  Widget _exceptionView(Exception exception) {
    return Center(child: Text(exception.toString()));
  }

  AppBar _appbar() {
    return AppBar(
      toolbarOpacity: 1.0,
      leading: _backButton(),
      title: BlocConsumer<TodosCubit, TodosState>(
          listener: (context, state) {}, // I guess I need this
          builder: (context, state) {
            final appBarText =
                state.viewedTodo == null ? 'Todos' : state.tree.get(state.viewedTodo!).title;
            return AnimatedSwitcher(
              // I should keep these both rendered !!!!
              duration: const Duration(milliseconds: 150),
              child: Text(appBarText),
            );
          }),
    );
  }

  Widget? _backButton() {
    return BlocConsumer<TodosCubit, TodosState>(
        listener: (context, state) {}, // I guess I need this
        builder: (context, state) {
          final String? visibleTodoId = state.viewedTodo;
          if (visibleTodoId == null) return Container();

          final Todo visibleTodo = state.tree.get(visibleTodoId);

          return IconButton(
            onPressed: () {
              BlocProvider.of<TodosCubit>(context).viewTodo(visibleTodo.parentId);
            },
            icon: Icon(Icons.arrow_back_ios_sharp),
          );
        });
  }

  Widget _navBar() {
    return BlocConsumer<TodosCubit, TodosState>(
      listener: (context, state) {}, // I guess I need this
      builder: (context, state) => BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: 0,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              state.isViewingTodoChildren ? Icons.arrow_back : Icons.list,
            ),
            label: 'Todos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.check), label: 'Schedule'),
        ],
        onTap: (itemNumber) {
          if (itemNumber == 0 && state.isViewingTodoChildren) {
            BlocProvider.of<TodosCubit>(context).viewTodo(state.getVisibleTodo!.parentId);
          }
        },
      ),
    );
  }

  Widget _floatingActionButton() {
    return BlocConsumer<TodosCubit, TodosState>(
      listener: (context, state) {},
      builder: (context, state) => FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          BlocProvider.of<TodosCubit>(context).showTodoFormModal(context, null);
        },
      ),
    );
  }
}
