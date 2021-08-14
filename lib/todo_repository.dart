import 'package:amplify_flutter/amplify.dart';
import 'package:todo/models/ModelProvider.dart';
import 'package:amplify_datastore_plugin_interface/amplify_datastore_plugin_interface.dart';
// Uncomment the below line to enable online sync
import 'package:amplify_api/amplify_api.dart';

import 'models/Todo.dart';

class TodoRepository {
  Future<List<Todo>> getTodos() async {
    final todos = await Amplify.DataStore.query(Todo.classType);
    return todos;
  }

  Future<void> createTodo(String title, String order) async {
    final newTodo = Todo(title: title, isComplete: false, order: order);
    await Amplify.DataStore.save(newTodo);
  }

  Future<void> createTodoTemplate(String title) async {
    final newTodoTemplate = Template(title: title);
    await Amplify.DataStore.save(newTodoTemplate);
  }

  Future<void> updateTodo(
    Todo todo, {
    String? title,
    bool? isComplete,
    String? order,
  }) async {
    final updatedTodo = todo.copyWith(
      title: title ?? todo.title,
      isComplete: isComplete ?? todo.isComplete,
      order: order ?? todo.order,
    );
    await Amplify.DataStore.save(updatedTodo);
  }

  Stream<SubscriptionEvent<Todo>> observeTodos() {
    return Amplify.DataStore.observe(Todo.classType);
  }

  Future<void> deleteTodo(Todo todo) async {
    await Amplify.DataStore.delete(todo);
  }
}
