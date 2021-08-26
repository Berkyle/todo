import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/app_cubit.dart';
import 'package:todo/models/Queue.dart';
import 'package:todo/queue_cubit.dart';

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
                // Open this Queue!
                // BlocProvider.of<QueueCubit>(context).createTodoTemplate(todo.title);
              }
              BlocProvider.of<QueueCubit>(context).deleteQueue(queue);
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xAAAAAAAA), width: 1.0)),
              ),
              child: ListTile(
                title: Text(queue.title),
                onTap: () => BlocProvider.of<AppCubit>(context).showQueueFormModal(context, queue),
                // leading: Checkbox(
                //   shape: Icons.favorite,
                //   value: queue.favorited,
                //   onChanged: (newValue) {
                //     BlocProvider.of<QueueCubit>(context).updateQueue(queue, isComplete: newValue!);
                //   },
                //   materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                // ),
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
