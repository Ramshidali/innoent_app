import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './AuthState.dart'; // Import the AuthState class
import './AuthService.dart'; // Import the AuthService class
import '../HomeScreen.dart'; 

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController(text: '');
  final TextEditingController _passwordController = TextEditingController(text: '');

  String _errorMessage = '';

  Future<void> _login(BuildContext context) async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    try {
      // Call AuthService.login
      final token = await AuthService.login(username, password);
      
      // Set the token in AuthState
      Provider.of<AuthState>(context, listen: false).setToken(token);

      // Navigate to home screen upon successful login
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } catch (e) {
      // Error occurred during login, display error message
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 80.0, // Set the desired height for the logo
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () => _login(context),
              child: Text('Login'),
            ),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
