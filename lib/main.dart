import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Amplify Flutter Packages
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_api/amplify_api.dart';

import 'package:todo/loading_view.dart';
import 'package:todo/home.dart';
import 'package:todo/todos_cubit.dart';

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
    return BlocProvider(
      create: (BuildContext context) => TodosCubit()..initialize(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _amplifyConfigured ? Home() : LoadingView(),
      ),
      // child: WidgetsApp(color: Colors.amber),
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
      await Amplify.configure(amplifyconfig);
      setState(() {
        _amplifyConfigured = true;
      });
    } catch (e) {
      print(e);
    }
  }
}
