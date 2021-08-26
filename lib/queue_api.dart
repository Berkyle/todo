import 'dart:convert';

import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:todo/models/Queue.dart';
import 'package:todo/todo_api.dart';

class QueueApi {
  static Queue convertDataToQueue(dynamic responseData) => Queue(
        id: responseData['id'],
        title: responseData['title'],
        favorited: responseData['favorited'],
        order: responseData['order'],
        todos: (responseData['todos']['items'] as List<dynamic>)
            .map(TodoApi.convertDataToTodo)
            .toList(),
      );

  static List<Queue> convertResponseToQueueList(List<dynamic> items) {
    return items.map(convertDataToQueue).toList();
  }

  static Future<void> createQueue(Queue newQueue) async {
    String graphQLDocument = '''mutation CreateQueue {
      createQueue(input: {id: "${newQueue.id}", favorited: false, title: "${newQueue.title}", order: "${newQueue.order}"}) {
        id
        title
        favorited
        order
        todos {
          items {
            id
            isComplete
            order
            queueId
            title
          }
          nextToken
        }
      }
    }''';

    final request = GraphQLRequest<String>(document: graphQLDocument);

    final operation = Amplify.API.mutate(request: request);
    await operation.response;
  }

  static Future<void> updateQueue(Queue updatedQueue) async {
    String graphQLDocument = '''mutation UpdateQueue {
      updateQueue(input: {id: "${updatedQueue.id}", favorited: ${updatedQueue.favorited}, order: "${updatedQueue.order}", title: "${updatedQueue.title}"}) {
        id
        title
        favorited
        order
        todos {
          items {
            id
            isComplete
            order
            queueId
            title
          }
          nextToken
        }
      }
    }''';

    final request = GraphQLRequest<String>(document: graphQLDocument);
    final operation = Amplify.API.mutate(request: request);
    await operation.response;
  }

  static Future<void> deleteQueue(Queue deletedQueue) async {
    String graphQLDocument = '''mutation DeleteQueue {
      deleteQueue(input: {id: "${deletedQueue.id}"}) {
        id
      }
    }''';

    final request = GraphQLRequest<String>(document: graphQLDocument);
    final operation = Amplify.API.mutate(request: request);
    await operation.response;
  }

  static Future<List<Queue>> listQueues() async {
    String graphQLDocument = '''query ListQueues {
      listQueues {
        items {
          id
          order
          favorited
          title
          todos {
            items {
              id
              isComplete
              order
              queueId
              title
            }
            nextToken
          }
        }
      }
    }''';

    final request = GraphQLRequest<String>(document: graphQLDocument);
    final operation = Amplify.API.query(request: request);
    final response = await operation.response;
    final data = json.decode(response.data);

    return convertResponseToQueueList(data['listQueues']['items']);
  }

  static void observeCreateQueue(void Function(Queue) onNewQueue) {
    String gqlOnCreateQueue = '''subscription OnCreateQueue {
      onCreateQueue {
        id
        order
        favorited
        title
        todos {
          items {
            id
            isComplete
            order
            queueId
            title
          }
          nextToken
        }
      }
    }''';

    Amplify.API.subscribe(
      request: GraphQLRequest<String>(document: gqlOnCreateQueue),
      onData: (event) {
        print('Create Subscription event data received: ${event.data}');
        final data = event.data;
        if (data != null) {
          final newQueueJSON = json.decode(data as String)['onCreateQueue'];
          final newQueue = convertDataToQueue(newQueueJSON);
          onNewQueue(newQueue);
        }
      },
      onEstablished: () => print('Create Subscription established'),
      onError: (e) => print('Create Subscription failed with error: $e'),
      onDone: () => print('Create Subscription has been closed successfully'),
    );
  }

  static void observeUpdateQueue(void Function(Queue) onUpdatedQueue) {
    String gqlOnCreateQueue = '''subscription OnDeleteQueue {
      onUpdateQueue {
        id
        order
        favorited
        title
        todos {
          items {
            id
            isComplete
            order
            queueId
            title
          }
          nextToken
        }
      }
    }''';

    Amplify.API.subscribe(
      request: GraphQLRequest<String>(document: gqlOnCreateQueue),
      onData: (event) {
        print('Update Subscription event data received: ${event.data}');
        final data = event.data;
        if (data != null) {
          final updatedQueueJSON = json.decode(data as String)['onUpdateQueue'];
          final updatedQueue = convertDataToQueue(updatedQueueJSON);
          onUpdatedQueue(updatedQueue);
        }
      },
      onEstablished: () => print('Update Subscription established'),
      onError: (e) => print('Update Subscription failed with error: $e'),
      onDone: () => print('Update Subscription has been closed successfully'),
    );
  }

  static void observeDeleteQueue(void Function(String) onDeleteQueue) {
    String gqlOnCreateQueue = '''subscription OnDeleteQueue {
      onDeleteQueue {
        id
      }
    }''';

    Amplify.API.subscribe(
      request: GraphQLRequest<String>(document: gqlOnCreateQueue),
      onData: (event) {
        print('Delete Subscription event data received: ${event.data}');
        final data = event.data;
        if (data != null) {
          final deletedQueueId = json.decode(data as String)['onDeleteQueue']['id'];
          onDeleteQueue(deletedQueueId);
        }
      },
      onEstablished: () => print('Delete Subscription established'),
      onError: (e) => print('Delete Subscription failed with error: $e'),
      onDone: () => print('Delete Subscription has been closed successfully'),
    );
  }
}
