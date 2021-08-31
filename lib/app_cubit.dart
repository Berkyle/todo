import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/models/Queue.dart';
import 'package:todo/models/Todo.dart';
import 'package:todo/order_id.dart';
import 'package:todo/queue_api.dart';
import 'package:todo/todo_api.dart';
import 'package:todo/mutation_modal.dart';

abstract class TodoState {}

abstract class QueueState {}

class LoadingTodos extends TodoState {}

class LoadingQueues extends QueueState {}

class ListTodosFailure extends TodoState {
  final Exception exception;
  ListTodosFailure({required this.exception});
}

class ListQueuesFailure extends QueueState {
  final Exception exception;
  ListQueuesFailure({required this.exception});
}

class ListTodosSuccess extends TodoState {
  final List<Todo> todos;
  final String? queueId;

  Map<String, Todo> todoMap = {};
  List<Todo> orderedTodos = [];

  ListTodosSuccess({required this.todos, this.queueId}) {
    // Populate {todoMap}.
    for (var i = 0; i < todos.length; i += 1) {
      final todo = todos[i];
      todoMap[todo.id] = todo;
    }

    // Populate {orderedTodos}, containing the set of visible todos, in order.
    orderedTodos = todos.where((todo) => queueId == null || todo.queueId == queueId).toList();
    orderedTodos.sort((todoA, todoB) => todoA.order.compareTo(todoB.order));
  }
}

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

class AppState {
  int navigationIndex = 0;
  final Queue? selectedQueue;
  final TodoState todos;
  final QueueState queues;

  AppState({required int navIndex, required this.queues, required this.todos, this.selectedQueue}) {
    navigationIndex = navIndex;
  }
}

const NoValue = {};

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(AppState(navIndex: 0, todos: LoadingTodos(), queues: LoadingQueues()));

  void _emitNextState(
      {dynamic navIndex = NoValue,
      dynamic todos = NoValue,
      dynamic queues = NoValue,
      dynamic selectedQueue = NoValue}) {
    var nextNavIndex = (navIndex == NoValue) ? state.navigationIndex : navIndex;
    var nextSelectedQueue = (selectedQueue == NoValue) ? state.selectedQueue : selectedQueue;
    final todosState = state.todos;
    var nextTodos = (todos == NoValue)
        ? (todosState is ListTodosSuccess
            ? ListTodosSuccess(todos: todosState.todos, queueId: nextSelectedQueue?.id)
            : state.todos)
        : todos;
    var nextQueues = (queues == NoValue) ? state.queues : queues;

    assert(nextNavIndex is int);
    assert(nextTodos is TodoState);
    assert(nextQueues is QueueState);
    assert(nextSelectedQueue is Queue?);

    emit(AppState(
      navIndex: nextNavIndex,
      todos: nextTodos,
      queues: nextQueues,
      selectedQueue: nextSelectedQueue,
    ));
  }

  // TODOS STATE
  void _onNewTodo(Todo newTodo) {
    final state = this.state.todos;
    if (state is ListTodosSuccess && state.todoMap[newTodo.id] == null) {
      _emitNextState(
        todos: ListTodosSuccess(
          todos: [...state.todos]..add(newTodo),
          queueId: this.state.selectedQueue?.id,
        ),
      );
      if (newTodo.queueId != null) {
        // Needed in order to updated the queueId's {todos} list.
        _getQueues();
      }
    }
  }

  void _onUpdatedTodo(Todo updatedTodo) {
    final state = this.state.todos;
    if (state is ListTodosSuccess) {
      final updatedTodos =
          state.todos.map((todo) => todo.id == updatedTodo.id ? updatedTodo : todo).toList();
      _emitNextState(
          todos: ListTodosSuccess(todos: updatedTodos, queueId: this.state.selectedQueue?.id));
    }
  }

  void _onDeletedTodo(String deletedTodoId) {
    final state = this.state.todos;
    if (state is ListTodosSuccess && state.todoMap[deletedTodoId] != null) {
      _emitNextState(
          todos: ListTodosSuccess(
        todos: [...state.todos].where((todo) => todo.id != deletedTodoId).toList(),
        queueId: this.state.selectedQueue?.id,
      ));
    }
  }

  void _initializeTodos() async {
    if (state.todos is ListTodosSuccess == false) {
      _emitNextState(todos: LoadingTodos());
    }

    try {
      final todos = await TodoApi.listTodos();
      _emitNextState(todos: ListTodosSuccess(todos: todos, queueId: this.state.selectedQueue?.id));
      TodoApi.observeCreateTodo(_onNewTodo);
      TodoApi.observeUpdateTodo(_onUpdatedTodo);
      TodoApi.observeDeleteTodo(_onDeletedTodo);
    } catch (e) {
      if (e is Exception) {
        _emitNextState(todos: ListTodosFailure(exception: e));
      }
    }
  }

  void createTodo(String title, String? queueId) async {
    final todoState = this.state.todos;
    if (todoState is ListTodosSuccess) {
      final order = todoState.orderedTodos.length > 0
          ? OrderId.getNext(todoState.orderedTodos.last.order)
          : OrderId.getInitialId();
      final newTodo = Todo(title: title, isComplete: false, order: order, queueId: queueId);
      _emitNextState(
          todos: ListTodosSuccess(
              todos: [...todoState.todos]..add(newTodo), queueId: this.state.selectedQueue?.id));
      await TodoApi.createTodo(newTodo);
    }
  }

  Future<void> updateTodo(
    Todo todoToUpdate, {
    String? title,
    bool? isComplete,
    String? order,
  }) async {
    final todoState = this.state.todos;
    if (todoState is ListTodosSuccess) {
      final updatedTodo = todoToUpdate.copyWith(
        title: title ?? todoToUpdate.title,
        isComplete: isComplete ?? todoToUpdate.isComplete,
        order: order ?? todoToUpdate.order,
      );
      final updatedTodos =
          todoState.todos.map((todo) => todo.id == todoToUpdate.id ? updatedTodo : todo).toList();
      _emitNextState(
          todos: ListTodosSuccess(todos: updatedTodos, queueId: this.state.selectedQueue?.id));
      await TodoApi.updateTodo(updatedTodo);
    }
  }

  void moveTodo(int startIndex, int endIndex) async {
    final todoState = this.state.todos;
    if (todoState is ListTodosSuccess) {
      final movingTodo = todoState.orderedTodos[startIndex];
      var updatedOrder = '';
      if (endIndex == 0) {
        updatedOrder = OrderId.getPrevious(todoState.orderedTodos.first.order);
      } else if (endIndex == todoState.todos.length) {
        updatedOrder = OrderId.getNext(todoState.orderedTodos.last.order);
      } else {
        final lowerOrder = todoState.orderedTodos[endIndex - 1].order;
        final upperOrder = todoState.orderedTodos[endIndex].order;
        updatedOrder = OrderId.getIdBetween(lowerOrder, upperOrder);
      }
      final updatedTodo = movingTodo.copyWith(order: updatedOrder);
      _emitNextState(
        todos: ListTodosSuccess(
          todos: todoState.todos.map((todo) {
            if (todo.id == movingTodo.id) return updatedTodo;
            return todo;
          }).toList(),
          queueId: this.state.selectedQueue?.id,
        ),
      );
      await updateTodo(updatedTodo, order: updatedOrder);
    }
  }

  void deleteTodo(Todo todoToDelete) async {
    final todoState = this.state.todos;
    if (todoState is ListTodosSuccess) {
      _emitNextState(
          todos: ListTodosSuccess(
        todos: todoState.todos.where((todo) => todo.id != todoToDelete.id).toList(),
        queueId: this.state.selectedQueue?.id,
      ));
      await TodoApi.deleteTodo(todoToDelete);
    }
  }

  // QUEUES STATE
  void _onNewQueue(Queue newTodo) {
    final state = this.state.queues;
    if (state is ListQueuesSuccess && state.queueMap[newTodo.id] == null) {
      _emitNextState(queues: ListQueuesSuccess(queues: [...state.queues]..add(newTodo)));
    }
  }

  void _onUpdatedQueue(Queue updatedTodo) {
    print("&&&&& howdy");
    final state = this.state.queues;
    if (state is ListQueuesSuccess) {
      final updatedTodos =
          state.queues.map((todo) => todo.id == updatedTodo.id ? updatedTodo : todo).toList();
      _emitNextState(queues: ListQueuesSuccess(queues: updatedTodos));
    }
  }

  void _onDeletedQueue(String deletedQueueId) {
    final state = this.state.queues;
    if (state is ListQueuesSuccess && state.queueMap[deletedQueueId] != null) {
      _emitNextState(
        queues: ListQueuesSuccess(
            queues: [...state.queues].where((queue) => queue.id != deletedQueueId).toList()),
      );
    }
  }

  void _getQueues() async {
    bool startObserveTodos = false;
    if (state.queues is ListQueuesSuccess == false) {
      _emitNextState(queues: LoadingQueues());
      startObserveTodos = true;
    }

    try {
      final queues = await QueueApi.listQueues();
      _emitNextState(queues: ListQueuesSuccess(queues: queues));
      if (startObserveTodos) {
        QueueApi.observeCreateQueue(_onNewQueue);
        QueueApi.observeUpdateQueue(_onUpdatedQueue);
        QueueApi.observeDeleteQueue(_onDeletedQueue);
      }
    } catch (e) {
      if (e is Exception) {
        _emitNextState(queues: ListQueuesFailure(exception: e));
      }
    }
  }

  void createQueue(String title) async {
    final queueState = this.state.queues;
    if (queueState is ListQueuesSuccess) {
      final order = queueState.orderedQueues.length > 0
          ? OrderId.getNext(queueState.orderedQueues.last.order)
          : OrderId.getInitialId();
      final newQueue = Queue(
        title: title,
        favorited: false,
        order: order,
        isOrdered: false,
        todos: [],
      );
      _emitNextState(queues: ListQueuesSuccess(queues: [...queueState.queues]..add(newQueue)));
      await QueueApi.createQueue(newQueue);
    }
  }

  Future<void> updateQueue(
    Queue queueToUpdate, {
    String? title,
    bool? isComplete,
    String? order,
    bool? favorited,
    bool? isOrdered,
    List<Todo>? todos,
  }) async {
    final queueState = this.state.queues;
    if (queueState is ListQueuesSuccess) {
      final updatedQueue = queueToUpdate.copyWith(
        title: title ?? queueToUpdate.title,
        favorited: favorited ?? queueToUpdate.favorited,
        order: order ?? queueToUpdate.order,
        isOrdered: isOrdered ?? queueToUpdate.isOrdered,
        todos: todos ?? queueToUpdate.todos,
      );
      final updatedQueues = queueState.queues
          .map((queue) => queue.id == queueToUpdate.id ? updatedQueue : queue)
          .toList();
      _emitNextState(queues: ListQueuesSuccess(queues: updatedQueues));
      await QueueApi.updateQueue(updatedQueue);
    }
  }

  void moveQueue(int startIndex, int endIndex) async {
    final queueState = this.state.queues;
    if (queueState is ListQueuesSuccess) {
      final movingQueue = queueState.orderedQueues[startIndex];
      String updatedOrder = '';
      if (endIndex == 0) {
        updatedOrder = OrderId.getPrevious(queueState.orderedQueues.first.order);
      } else if (endIndex == queueState.queues.length) {
        updatedOrder = OrderId.getNext(queueState.orderedQueues.last.order);
      } else {
        final lowerOrder = queueState.orderedQueues[endIndex - 1].order;
        final upperOrder = queueState.orderedQueues[endIndex].order;
        updatedOrder = OrderId.getIdBetween(lowerOrder, upperOrder);
      }
      final updatedQueue = movingQueue.copyWith(order: updatedOrder);
      _emitNextState(
          queues: ListQueuesSuccess(
              queues: queueState.queues.map((queue) {
        if (queue.id == movingQueue.id) return updatedQueue;
        return queue;
      }).toList()));
      await updateQueue(updatedQueue, order: updatedOrder);
    }
  }

  void deleteQueue(Queue queueToDelete) async {
    final queueState = this.state.queues;
    if (queueState is ListQueuesSuccess) {
      _emitNextState(
          queues: ListQueuesSuccess(
              queues: queueState.queues.where((queue) => queue.id != queueToDelete.id).toList()));
      await QueueApi.deleteQueue(queueToDelete);
    }
  }

  void getInitialData() async {
    _initializeTodos();
    _getQueues();
  }

  void setNavigationView(int navIndex, [Queue? selectedQueue]) {
    final nextSelectedQueue = selectedQueue ?? state.selectedQueue;
    final todosState = state.todos;
    final List<Todo> nextTodos = todosState is ListTodosSuccess ? todosState.todos : [];
    _emitNextState(
      navIndex: navIndex,
      selectedQueue: nextSelectedQueue,
      todos: ListTodosSuccess(todos: nextTodos, queueId: nextSelectedQueue?.id),
    );
  }

  void showTodoFormModal(BuildContext context, Todo? selectedTodo) {
    final title = selectedTodo?.title;

    showModalBottomSheet(
      context: context,
      isDismissible: true,
      builder: (ctx) => BlocProvider<AppCubit>.value(
        value: BlocProvider.of(context),
        child: MutationModal(
          title: title,
          mutationType: Mutation.TODO,
          onSave: (newTitle) {
            if (selectedTodo == null) {
              createTodo(newTitle, state.selectedQueue?.id);
            } else {
              updateTodo(selectedTodo, title: newTitle);
            }
          },
        ),
      ),
    );
  }

  void showQueueFormModal(BuildContext context, Queue? selectedQueue) {
    final title = selectedQueue?.title;
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      builder: (ctx) => BlocProvider<AppCubit>.value(
        value: BlocProvider.of(context),
        child: MutationModal(
          title: title,
          mutationType: Mutation.QUEUE,
          onSave: (newTitle) {
            if (selectedQueue == null) {
              createQueue(newTitle);
            } else {
              updateQueue(selectedQueue, title: newTitle);
            }
          },
        ),
      ),
    );
  }
}
