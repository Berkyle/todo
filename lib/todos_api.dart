import 'dart:convert';

import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:todo/models/Todo.dart';

class TodoApi {
  static Todo convertDataToTodo(dynamic responseData) => Todo(
        id: responseData['id'],
        title: responseData['title'],
        isComplete: responseData['isComplete'],
        order: responseData['order'],
        queueId: responseData['queueId'],
      );

  static List<Todo> convertResponseToTodoList(List<dynamic> items) {
    // final data = json.decode(response.data);
    // return data['listTodos']['items'].map(convertDataToTodo).toList();
    return items.map(convertDataToTodo).toList();
  }

  static Future<void> createTodo(Todo newTodo) async {
    String graphQLDocument = '''mutation CreateTodo {
      createTodo(input: {id: "${newTodo.id}",isComplete: false, title: "${newTodo.title}", order: "${newTodo.order}"}) {
        id
        title
        isComplete
        order
        queueId
      }
    }''';

    final request = GraphQLRequest<String>(document: graphQLDocument);

    final operation = Amplify.API.mutate(request: request);
    await operation.response;
  }

  static Future<void> updateTodo(Todo updatedTodo) async {
    String graphQLDocument = '''mutation UpdateTodo {
      updateTodo(input: {id: "${updatedTodo.id}", isComplete: ${updatedTodo.isComplete}, order: "${updatedTodo.order}", title: "${updatedTodo.title}"}) {
        id
        title
        isComplete
        order
        queueId
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

  static Future<List<Todo>> listOrderedTodos() async {
    String graphQLDocument = '''query ListTodosByOrder {
      todosByOrder {
        items {
          id
          isComplete
          order
          queueId
          title
        }
        nextToken
      }
    }''';

    final request = GraphQLRequest<String>(document: graphQLDocument);
    final operation = Amplify.API.query(request: request);
    final response = await operation.response;
    final data = json.decode(response.data);

    return convertResponseToTodoList(data['todosByOrder']['items']);
  }

  static Future<List<Todo>> listTodos() async {
    String graphQLDocument = '''query ListTodos {
      listTodos {
        items {
          id
          title
          isComplete
          order
          queueId
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
        queueId
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
        queueId
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
}
