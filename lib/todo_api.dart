import 'dart:convert';

import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:todo/Todo.dart';

String parentIdInputString(String? id) => id is String ? '"$id"' : 'null';

class TodoApi {
  static Future<void> createTodo(Todo newTodo) async {
    String graphQLDocument = '''mutation CreateTodo {
      createTodo(
        input: {
          id: "${newTodo.id}",
          isComplete: false,
          title: "${newTodo.title}",
          order: "${newTodo.order}",
          parentId: ${parentIdInputString(newTodo.parentId)},
        }
      ) {
        id
        title
        isComplete
        order
        parentId
      }
    }''';

    final request = GraphQLRequest<String>(document: graphQLDocument);

    final operation = Amplify.API.mutate(request: request);
    await operation.response;
  }

  static Future<void> updateTodo(Todo updatedTodo) async {
    String graphQLDocument = '''mutation UpdateTodo {
      updateTodo(
        input: {
          id: "${updatedTodo.id}",
          title: "${updatedTodo.title}"
          order: "${updatedTodo.order}",
          parentId: ${parentIdInputString(updatedTodo.parentId)},
          isComplete: ${updatedTodo.isComplete},
        }
      ) {
        id
        title
        order
        parentId
        isComplete
      }
    }''';

    final request = GraphQLRequest<String>(document: graphQLDocument);
    final operation = Amplify.API.mutate(request: request);

    await operation.response;
  }

  static Future<void> deleteTodo(Todo deletedTodo) async {
    String graphQLDocument = '''mutation DeleteTodo {
      deleteTodo(input: {id: "${deletedTodo.id}"}) {
        id
      }
    }''';

    final request = GraphQLRequest<String>(document: graphQLDocument);
    final operation = Amplify.API.mutate(request: request);
    await operation.response;
  }

  static Future<List<Todo>> listOrderedRootTodos() async => [];

  static Future<List<Todo>> listRootTodos() async {
    String graphQLDocument = '''query ListRootTodos {
      listTodos(filter: {parentId: {eq: null}}) {
        items {
          id
          title
          isComplete
          order
          parentId
        }
        nextToken
      }
    }''';

    final request = GraphQLRequest<String>(document: graphQLDocument);
    final operation = Amplify.API.query(request: request);
    final response = await operation.response;
    final data = json.decode(response.data);

    return convertResponseToTodoList(data['listTodos']['items']);
  }

  static Future<List<Todo>> listTodos() async {
    String graphQLDocument = '''query ListTodos {
      listTodos {
        items {
          id
          title
          isComplete
          order
          parentId
        }
        nextToken
      }
    }''';

    final request = GraphQLRequest<String>(document: graphQLDocument);
    final operation = Amplify.API.query(request: request);
    final response = await operation.response;
    final data = json.decode(response.data);

    return convertResponseToTodoList(data['listTodos']['items']);
  }

  static Future<List<Todo>> listTodoChildren(Todo todo) async {
    String graphQLDocument = '''query ListTodos {
      listTodos(filter: {parentId: {eq: "${todo.id}"}}) {
        items {
          id
          title
          isComplete
          order
          parentId
        }
        nextToken
      }
    }''';

    final request = GraphQLRequest<String>(document: graphQLDocument);
    final operation = Amplify.API.query(request: request);
    final response = await operation.response;
    final data = json.decode(response.data);

    return convertResponseToTodoList(data['listTodos']['items']);
  }

  static void observeCreateTodo(void Function(Todo) onNewTodo) {
    String gqlOnCreateTodo = '''subscription OnCreateTodo {
      onCreateTodo {
        id
        isComplete
        order
        parentId
        title
      }
    }''';

    Amplify.API.subscribe(
      request: GraphQLRequest<String>(document: gqlOnCreateTodo),
      onData: (event) {
        print('Create Subscription event data received: ${event.data}');
        final data = event.data;
        if (data != null) {
          final newTodoJSON = json.decode(data as String)['onCreateTodo'];
          final newTodo = convertDataToTodo(newTodoJSON);
          onNewTodo(newTodo);
        }
      },
      onEstablished: () => print('Create Subscription established'),
      onError: (e) => print('Create Subscription failed with error: $e'),
      onDone: () => print('Create Subscription has been closed successfully'),
    );
  }

  static void observeUpdateTodo(void Function(Todo) onUpdatedTodo) {
    String gqlOnCreateTodo = '''subscription MySubscription {
      onUpdateTodo {
        id
        isComplete
        order
        parentId
        title
      }
    }''';

    Amplify.API.subscribe(
      request: GraphQLRequest<String>(document: gqlOnCreateTodo),
      onData: (event) {
        print('Update Subscription event data received: ${event.data}');
        final data = event.data;
        if (data != null) {
          final updatedTodoJSON = json.decode(data as String)['onUpdateTodo'];
          final updatedTodo = convertDataToTodo(updatedTodoJSON);
          onUpdatedTodo(updatedTodo);
        }
      },
      onEstablished: () => print('Update Subscription established'),
      onError: (e) => print('Update Subscription failed with error: $e'),
      onDone: () => print('Update Subscription has been closed successfully'),
    );
  }

  static void observeDeleteTodo(void Function(String) onDeleteTodo) {
    String gqlOnCreateTodo = '''subscription OnDeleteTodo {
      onDeleteTodo {
        id
      }
    }''';

    Amplify.API.subscribe(
      request: GraphQLRequest<String>(document: gqlOnCreateTodo),
      onData: (event) {
        print('Delete Subscription event data received: ${event.data}');
        final data = event.data;
        if (data != null) {
          final deletedTodoId = json.decode(data as String)['onDeleteTodo']['id'];
          onDeleteTodo(deletedTodoId);
        }
      },
      onEstablished: () => print('Delete Subscription established'),
      onError: (e) => print('Delete Subscription failed with error: $e'),
      onDone: () => print('Delete Subscription has been closed successfully'),
    );
  }

  static Todo convertDataToTodo(dynamic responseData) => Todo(
        id: responseData['id'],
        title: responseData['title'],
        isComplete: responseData['isComplete'],
        order: responseData['order'],
        parentId: responseData['parentId'],
      );

  static List<Todo> convertResponseToTodoList(List<dynamic> items) {
    return items.map(convertDataToTodo).toList();
  }
}
