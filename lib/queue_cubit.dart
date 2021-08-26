import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/models/ModelProvider.dart';
import 'package:todo/order_id.dart';
import 'package:todo/queue_api.dart';

abstract class QueueState {}

class LoadingQueues extends QueueState {
  LoadingQueues();
}

var updated = 0;

class ListQueuesSuccess extends QueueState {
  final List<Queue> queues;

  Map<String, Queue> queueMap = {};
  List<Queue> orderedQueues = [];

  ListQueuesSuccess({required this.queues}) {
    // Populate {queueMap}.
    for (var i = 0; i < queues.length; i += 1) {
      final queue = queues[i];
      queueMap[queue.id] = queue;
    }

    // Populate {orderedQueues}
    orderedQueues = [...queues]..sort((queueA, queueB) => queueA.order.compareTo(queueB.order));
  }
}

class ListQueuesFailure extends QueueState {
  final Exception exception;
  ListQueuesFailure({required this.exception});
}

class QueueCubit extends Cubit<QueueState> {
  QueueCubit() : super(LoadingQueues());

  void getQueues() async {
    if (state is ListQueuesSuccess == false) {
      emit(LoadingQueues());
    }

    try {
      print(1);
      final queues = await QueueApi.listQueues();
      print(2);
      emit(ListQueuesSuccess(queues: queues));
    } catch (e) {
      print(e.toString());
      if (e is Exception) {
        emit(ListQueuesFailure(exception: e));
      }
    }
  }

  void _onNewQueue(Queue newTodo) {
    final state = this.state;
    if (state is ListQueuesSuccess && state.queueMap[newTodo.id] == null) {
      emit(ListQueuesSuccess(queues: [...state.queues]..add(newTodo)));
    }
  }

  void _onUpdatedQueue(Queue updatedTodo) {
    final state = this.state;
    if (state is ListQueuesSuccess) {
      final updatedTodos =
          state.queues.map((todo) => todo.id == updatedTodo.id ? updatedTodo : todo).toList();
      emit(ListQueuesSuccess(queues: updatedTodos));
    }
  }

  void _onDeletedQueue(String deletedQueueId) {
    final state = this.state;
    if (state is ListQueuesSuccess && state.queueMap[deletedQueueId] != null) {
      emit(ListQueuesSuccess(
          queues: [...state.queues].where((queue) => queue.id != deletedQueueId).toList()));
    }
  }

  void observeQueues() {
    QueueApi.observeCreateQueue(_onNewQueue);
    QueueApi.observeUpdateQueue(_onUpdatedQueue);
    QueueApi.observeDeleteQueue(_onDeletedQueue);
  }

  void createQueue(String title) async {
    final state = this.state;
    if (state is ListQueuesSuccess) {
      final order = state.orderedQueues.length > 0
          ? OrderId.getNext(state.orderedQueues.last.order)
          : OrderId.getInitialId();
      final newQueue = Queue(title: title, favorited: false, order: order, todos: []);
      emit(ListQueuesSuccess(queues: [...state.queues]..add(newQueue)));
      await QueueApi.createQueue(newQueue);
    }
  }

  Future<void> updateQueue(
    Queue queueToUpdate, {
    String? title,
    bool? isComplete,
    String? order,
    List<Todo>? todos,
  }) async {
    final state = this.state;
    if (state is ListQueuesSuccess) {
      final updatedQueue = queueToUpdate.copyWith(
        title: title ?? queueToUpdate.title,
        favorited: isComplete ?? queueToUpdate.favorited,
        order: order ?? queueToUpdate.order,
        todos: todos ?? queueToUpdate.todos,
      );
      final updatedQueues =
          state.queues.map((queue) => queue.id == queueToUpdate.id ? updatedQueue : queue).toList();
      emit(ListQueuesSuccess(queues: updatedQueues));
      await QueueApi.updateQueue(updatedQueue);
    }
  }

  void moveQueue(int startIndex, int endIndex) async {
    final state = this.state;
    if (state is ListQueuesSuccess) {
      final movingQueue = state.orderedQueues[startIndex];
      var updatedOrder = '';
      if (endIndex == 0) {
        updatedOrder = OrderId.getPrevious(state.orderedQueues.first.order);
      } else if (endIndex == state.queues.length) {
        updatedOrder = OrderId.getNext(state.orderedQueues.last.order);
      } else {
        final lowerOrder = state.orderedQueues[endIndex - 1].order;
        final upperOrder = state.orderedQueues[endIndex].order;
        updatedOrder = OrderId.getIdBetween(lowerOrder, upperOrder);
      }
      final updatedQueue = movingQueue.copyWith(order: updatedOrder);
      emit(ListQueuesSuccess(
          queues: state.queues.map((queue) {
        if (queue.id == movingQueue.id) return updatedQueue;
        return queue;
      }).toList()));
      await updateQueue(updatedQueue, order: updatedOrder);
    }
  }

  void deleteQueue(Queue queueToDelete) async {
    final state = this.state;
    if (state is ListQueuesSuccess) {
      emit(ListQueuesSuccess(
          queues: state.queues.where((queue) => queue.id != queueToDelete.id).toList()));
      await QueueApi.deleteQueue(queueToDelete);
    }
  }
}
