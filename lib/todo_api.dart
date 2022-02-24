import 'dart:convert';

import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:todo/todo.dart';

/// idk just gets all the todos.
const String todoFieldQuery = Todo.todoFieldQuery;

const todoFieldQueryItems = 'items $todoFieldQuery';

class TodoApi {
  static Future<void> createTodo(Todo newTodo) async {
    String graphQLDocument = '''
    mutation CreateTodo(\$id: ID!, \$title: String!, \$order: String!, \$isComplete: Boolean!, \$parentId: ID) {
      createTodo(
        input: {
          id: \$id,
          title: \$title,
          order: \$order,
          parentId: \$parentId,
          isComplete: \$isComplete,
        }
      )
      $todoFieldQuery
    }''';

    final request = GraphQLRequest<String>(
      document: graphQLDocument,
      variables: {
        'id': newTodo.id,
        'title': newTodo.title,
        'order': newTodo.order,
        'parentId': newTodo.parentId,
        'isComplete': newTodo.isComplete,
      },
    );

    final operation = Amplify.API.mutate(request: request);
    await operation.response;
  }

  static Future<void> updateTodo(Todo updatedTodo) async {
    String graphQLDocument = '''
    mutation UpdateTodo(\$title: String!, \$order: String!, \$isComplete: Boolean!, \$parentId: ID) {
      updateTodo(
        input: {
          id: "${updatedTodo.id}",
          title: \$title,
          order: \$order,
          parentId: \$parentId,
          isComplete: \$isComplete,
        }
      ) 
      $todoFieldQuery
    }''';

    final request = GraphQLRequest<String>(
      document: graphQLDocument,
      variables: {
        'title': updatedTodo.title,
        'order': updatedTodo.order,
        'parentId': updatedTodo.parentId,
        'isComplete': updatedTodo.isComplete,
      },
    );
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

  static Stream<List<Todo>> loadRootTodos([String? nextToken]) async* {
    // The use of `notContains` is because sometimes parentId being set to null actually just
    // deletes the value for that column entirely and then it doesn't show up here later.
    String graphQLDocument = '''query ListRootTodos(\$nextToken: String) {
      listTodos(filter: {parentId: {notContains: "-"}}, nextToken: \$nextToken) {
        $todoFieldQueryItems
        nextToken
      }
    }''';

    final operation = Amplify.API.query(
      request: GraphQLRequest<String>(
        document: graphQLDocument,
        variables: {'nextToken': nextToken},
      ),
    );
    final response = await operation.response;
    final data = json.decode(response.data);

    yield convertResponseToTodoList(data['listTodos']['items']);

    // If a nextToken exists, get those todos too. Else, close the stream.
    if (data['listTodos']['nextToken'] is String) {
      yield* loadRootTodos(data['listTodos']['nextToken']);
    }
  }

  static Stream<List<Todo>> loadTodoChildren(Todo todo, [String? nextToken]) async* {
    String graphQLDocument = '''query ListTodos(\$nextToken: String) {
      listTodos(filter: {parentId: {eq: "${todo.id}"}}, nextToken: \$nextToken) {
        $todoFieldQueryItems
        nextToken
      }
    }''';

    final operation = Amplify.API.query(
      request: GraphQLRequest<String>(
        document: graphQLDocument,
        variables: {'nextToken': nextToken},
      ),
    );
    final response = await operation.response;
    final data = json.decode(response.data);

    yield convertResponseToTodoList(data['listTodos']['items']);

    // If a nextToken exists, get those todos too. Else, close the stream.
    if (data['listTodos']['nextToken'] is String) {
      yield* loadTodoChildren(todo, data['listTodos']['nextToken']);
    }
  }

  static void observeCreateTodo(void Function(Todo) onNewTodo) {
    String gqlOnCreateTodo = '''subscription OnCreateTodo {
      onCreateTodo $todoFieldQuery
    }''';

    Amplify.API.subscribe(
      request: GraphQLRequest<String>(document: gqlOnCreateTodo),
      onData: (event) {
        print('Create Subscription event data received: ${event.data}');
        final data = event.data;
        if (data != null) {
          final newTodoJSON = json.decode(data as String)['onCreateTodo'];
          final newTodo = convertDataToTodo(newTodoJSON, true);
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
      onUpdateTodo $todoFieldQuery
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

  static Todo convertDataToTodo(dynamic responseData, [bool isLoaded = false]) => Todo(
        id: responseData['id'],
        title: responseData['title'],
        parentId: responseData['parentId'],
        order: responseData['order'],
        childrenIds: Set(),
        isChildrenLoaded: isLoaded,
        isComplete: responseData['isComplete'],
      );

  static List<Todo> convertResponseToTodoList(List<dynamic> items) {
    return items.map(convertDataToTodo).toList();
  }
}
