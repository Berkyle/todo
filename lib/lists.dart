import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/app_cubit.dart';
import 'package:todo/models/Queue.dart';
import 'package:todo/queue_cubit.dart';
import 'package:todo/todo_cubit.dart';

import 'loading_view.dart';

class Lists extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ListsState();
}

class _ListsState extends State<Lists> {
  @override
  Widget build(BuildContext context) {
    return (BlocBuilder<QueueCubit, QueueState>(builder: (context, state) {
      if (state is ListQueuesSuccess) {
        if (state.queues.isEmpty) {
          return _emptyListsView();
        } else {
          return _listsView(state.orderedQueues);
        }
      } else if (state is ListQueuesFailure) {
        return _exceptionView(state.exception);
      } else {
        return LoadingView();
      }
    }));
  }

  Widget _exceptionView(Exception exception) {
    return Center(child: Text(exception.toString()));
  }

  Widget _emptyListsView() {
    return Center(child: Text('No Lists yet!'));
  }

  void _openQueue(Queue queue) {
    BlocProvider.of<TodoCubit>(context).setQueueId(queue.id);
    BlocProvider.of<AppCubit>(context).setNavigationView(1, queue);
  }

  Widget _listsView(List<Queue> queues) {
    return Scrollbar(
      child: ReorderableListView.builder(
        itemCount: queues.length,
        onReorder: (indexA, indexB) async {
          BlocProvider.of<QueueCubit>(context).moveQueue(indexA, indexB);
        },
        itemBuilder: (context, index) {
          final queue = queues[index];
          return Dismissible(
            key: Key(queue.id),
            onDismissed: (direction) {
              if (direction == DismissDirection.startToEnd) {
                _openQueue(queue);
              } else {
                BlocProvider.of<QueueCubit>(context).deleteQueue(queue);
              }
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xAAAAAAAA), width: 1.0)),
              ),
              child: ListTile(
                title: Text("${queue.title} (${queue.todos.length})"),
                onTap: () => _openQueue(queue),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    BlocProvider.of<AppCubit>(context).showQueueFormModal(context, queue);
                  },
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
