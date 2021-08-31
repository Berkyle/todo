import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Amplify Flutter Packages
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
// import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_api/amplify_api.dart';

import 'package:todo/app_cubit.dart';
import 'package:todo/loading_view.dart';
import 'package:todo/home.dart';

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
      // theme: ThemeData(
      //   pageTransitionsTheme: PageTransitionsTheme(builders: {
      //     TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      //     TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      //   }),
      // ),
      home: BlocProvider(
        create: (BuildContext context) => AppCubit()..getInitialData(),
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
      await Amplify.configure(amplifyconfig);
      setState(() {
        _amplifyConfigured = true;
      });
    } catch (e) {
      print(e);
    }
  }
}
