import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/app_cubit.dart';
import 'package:todo/loading_view.dart';
import 'package:todo/queue_cubit.dart';
import 'package:todo/todo_cubit.dart';
import 'package:todo/home.dart';

// Amplify Flutter Packages
import 'package:amplify_flutter/amplify.dart';
// import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_api/amplify_api.dart';

// Generated in previous step
// import 'models/ModelProvider.dart';
import 'amplifyconfiguration.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _amplifyConfigured = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AppCubit>(
            create: (BuildContext context) => AppCubit(),
          ),
          BlocProvider<QueueCubit>(
            create: (context) => QueueCubit()
              ..getQueues()
              ..observeQueues(),
          ),
          BlocProvider<TodoCubit>(
            create: (context) => TodoCubit()
              ..getTodos()
              ..observeTodos(),
          ),
        ],
        child: _amplifyConfigured ? Home() : LoadingView(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  void _configureAmplify() async {
    // Once Plugins are added, configure Amplify
    try {
      await Amplify.addPlugin(AmplifyAPI());
      await Amplify.addPlugin(AmplifyAuthCognito());
      // await Amplify.addPlugin(AmplifyDataStore(modelProvider: ModelProvider.instance));
      await Amplify.configure(amplifyconfiguration);
      setState(() {
        _amplifyConfigured = true;
      });
    } catch (e) {
      print(e);
    }
  }
}
