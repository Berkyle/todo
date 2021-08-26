import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_cubit.dart';
import 'lists.dart';
import 'todos.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _floatingActionButton(),
      body: BlocConsumer<AppCubit, int>(
        listener: (context, state) {}, // I guess I need this
        builder: (context, state) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: state == 0 ? Todos() : Lists(),
        ),
      ),
      bottomNavigationBar: _navBar(),
    );
  }

  AppBar _appbar() {
    return AppBar(title: Text('Todos'));
  }

  Widget _navBar() {
    return BlocConsumer<AppCubit, int>(
      listener: (context, state) {}, // I guess I need this
      builder: (context, state) => BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: state,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Todos'),
          BottomNavigationBarItem(icon: Icon(Icons.yard), label: 'Lists'),
        ],
        onTap: (itemNumber) {
          BlocProvider.of<AppCubit>(context).setNavigationView(itemNumber);
        },
      ),
    );
  }

  Widget _floatingActionButton() {
    return BlocConsumer<AppCubit, int>(
      listener: (context, state) {},
      builder: (context, state) => FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          if (state == 0) {
            BlocProvider.of<AppCubit>(context).showTodoFormModal(context, null);
          } else if (state == 1) {
            print("I don't have this done yet hehehehe");
          }
          // _showTodoFormModal(null);
        },
      ),
    );
  }
}
