import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/todo_cubit.dart';

import 'app_cubit.dart';
import 'lists.dart';
import 'todos.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<TodoCubit>(context).getTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _floatingActionButton(),
      body: BlocConsumer<AppCubit, AppState>(
        listener: (context, state) {}, // I guess I need this
        builder: (context, state) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: state.navigationIndex == 0 ? Lists() : Todos(),
        ),
      ),
      bottomNavigationBar: _navBar(),
    );
  }

  AppBar _appbar() {
    return AppBar(
        title: BlocConsumer<AppCubit, AppState>(
            listener: (context, state) {}, // I guess I need this
            builder: (context, state) {
              final appBarText = state.navigationIndex == 0
                  ? 'Lists'
                  : (state.selectedQueue?.title ?? 'All Todos');
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: Text(appBarText),
              );
            }));
  }

  Widget _navBar() {
    return BlocConsumer<AppCubit, AppState>(
      listener: (context, state) {}, // I guess I need this
      builder: (context, state) => BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: state.navigationIndex,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Lists'),
          BottomNavigationBarItem(icon: Icon(Icons.check), label: 'Todos'),
        ],
        onTap: (itemNumber) {
          BlocProvider.of<AppCubit>(context).setNavigationView(itemNumber);
        },
      ),
    );
  }

  Widget _floatingActionButton() {
    return BlocConsumer<AppCubit, AppState>(
      listener: (context, state) {},
      builder: (context, state) => FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          if (state.navigationIndex == 0) {
            BlocProvider.of<AppCubit>(context).showQueueFormModal(context, null);
          } else if (state.navigationIndex == 1) {
            BlocProvider.of<AppCubit>(context).showTodoFormModal(context, null);
          }
        },
      ),
    );
  }
}
