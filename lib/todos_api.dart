import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_api/amplify_api.dart';

void createTodo() async {
  try {
    String graphQLDocument = '''mutation CreateTodo(\$name: String!, \$description: String) {
              createTodo(input: {name: \$name, description: \$description}) {
                id
                name
                description
              }
        }''';
    var variables = {
      "name": "my first todo",
      "description": "todo description",
    };
    var request = GraphQLRequest<String>(document: graphQLDocument, variables: variables);

    var operation = Amplify.API.mutate(request: request);
    var response = await operation.response;

    var data = response.data;

    print('Mutation result: ' + data);
  } on ApiException catch (e) {
    print('Mutation failed: $e');
  }
}

void listTodos() async {
  try {
    String graphQLDocument = '''query ListTodos {
      listTodos {
        items {
          id
          title
          isComplete
        }
        nextToken
      }
    }''';

    var operation = Amplify.API.query(
        request: GraphQLRequest<String>(
      document: graphQLDocument,
    ));

    var response = await operation.response;
    var data = response.data;
    print('Query result: ' + data);
  } on ApiException catch (e) {
    print('Query failed: $e');
  }
}
