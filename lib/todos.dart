import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/todo_row.dart';

import 'todos_cubit.dart';
import 'todo.dart';

class Todos extends StatelessWidget {
  final List<Todo> todos;

  Todos({required this.todos});

  @override
  Widget build(BuildContext context) {
    final TodosCubit cubit = BlocProvider.of<TodosCubit>(context);
    final state = cubit.state;
    final selectedTodo = state.getSelectedTodo;

    return Scaffold(
      appBar: _appbar(context),
      body: Column(
        children: [
          SizedBox(child: _selectedInfoBar(context), height: selectedTodo == null ? 0 : 50),
          Expanded(
            child: Builder(builder: (context) {
              if (todos.isEmpty) {
                return _emptyTodosView();
              } else {
                return Scrollbar(
                  child: ReorderableListView.builder(
                    itemCount: todos.length,
                    onReorder: BlocProvider.of<TodosCubit>(context).moveTodo,
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      return TodoRow(key: Key(todo.id), todo: todo);
                    },
                  ),
                );
              }
            }),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _floatingActionButton(),
      bottomNavigationBar: _navBar(),
      // bottomSheet: _bottomSheet(),
    );
  }

  Widget _emptyTodosView() => Center(child: Text('No todos here yet.'));

  Widget _selectedInfoBar(BuildContext context) {
    // final ThemeData theme = Theme.of(context);
    final TodosCubit cubit = BlocProvider.of<TodosCubit>(context);
    final state = cubit.state;
    final selectedTodo = state.getSelectedTodo;
    final viewedTodo = state.getVisibleTodo;

    if (selectedTodo == null) return Container();

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xAAAAAAAA), width: 1.0)),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Colors.white, Colors.blue[100]!],
          ),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(12.0, 0, 8.0, 0),
              child: CloseButton(
                color: Colors.black,
                onPressed: () => cubit.toggleSelectedTodo(null),
              ),
            ),
            Expanded(
              flex: 5,
              child: Text(
                selectedTodo.title,
                style: TextStyle(color: Colors.black),
              ),
            ),
            Container(
              padding: EdgeInsetsDirectional.fromSTEB(0, 0, 8.0, 0),
              child: Center(
                child: Builder(builder: (context) {
                  final canMoveTodo = state.tree.canMoveTodoTo(selectedTodo.id, viewedTodo?.id);

                  if (!canMoveTodo) {
                    return Text('Invalid target', style: TextStyle(color: Colors.black54));
                  }

                  return ElevatedButton(
                    // onPressed: () => print('hm!!'),
                    onPressed: () => cubit.moveTodoToParent(selectedTodo.id, viewedTodo?.id),
                    child: Text('Move here', style: TextStyle(fontSize: 12)),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _appbar(BuildContext context) {
    final TodosCubit cubit = BlocProvider.of<TodosCubit>(context);
    final state = cubit.state;

    String appBarText = state.isViewingRoot ? 'Todos' : state.getVisibleTodo!.title;
    appBarText += ' (${state.todoList.length})';

    return AppBar(
      toolbarOpacity: 1.0,
      leading: _backButton(),
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        child: Text(appBarText),
      ),
    );
  }

  Widget? _backButton() {
    return BlocConsumer<TodosCubit, TodosState>(
        listener: (context, state) {}, // I guess I need this
        builder: (context, state) {
          final String? visibleTodoId = state.viewedTodo;
          if (visibleTodoId == null) return Container();

          final Todo visibleTodo = state.tree.getTodo(visibleTodoId);

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
