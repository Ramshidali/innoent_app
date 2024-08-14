import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './authentication/loginScreen.dart';
import './HomeScreen.dart';
import './authentication/AuthState.dart'; // Import the AuthState class

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthState(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Innoent Exiem',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Consumer<AuthState>(
        builder: (context, authState, _) {
          if (authState.token != null) {
            return HomeScreen();
          } else {
            return LoginScreen();
          }
        },
      ),
    );
  }
}
