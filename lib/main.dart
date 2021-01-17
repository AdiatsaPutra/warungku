import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warungku/login_status.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  LoginStatus loginStatus = LoginStatus.notLoggedIn;
  bool secureText = true;

  showHideText() {
    setState(() {
      secureText = !secureText;
    });
  }

  String url = 'http://192.168.1.104:8090/warungku_backend/api/login.php';
  login() async {
    final response = await http.post(url, body: {
      'username': usernameController.text,
      'password': passwordController.text
    });
    final data = jsonDecode(response.body);
    int value = data['value'];
    String message = data['message'];
    if (value == 1) {
      setState(() {
        loginStatus = LoginStatus.loggedIn;
        // safePref
        safePref(value);
      });
      print(message);
    } else {
      print(message);
    }
    print(data);
  }

  safePref(int value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      sharedPreferences.setInt("value", value);
    });
  }

  var value;
  getPref() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      value = sharedPreferences.getInt("value");
      loginStatus = value == 1 ? LoginStatus.loggedIn : LoginStatus.notLoggedIn;
    });
  }

  signOut() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      sharedPreferences.setInt("value", null);
      loginStatus = LoginStatus.notLoggedIn;
    });
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    switch (loginStatus) {
      case LoginStatus.notLoggedIn:
        return Scaffold(
          appBar: AppBar(
            title: Text('Login Page'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(33.0),
            child: ListView(
              children: [
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(labelText: 'Username'),
                ),
                TextField(
                  obscureText: secureText,
                  controller: passwordController,
                  decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                          onPressed: () {
                            showHideText();
                          },
                          icon: Icon(secureText
                              ? Icons.visibility_off
                              : Icons.visibility))),
                ),
                RaisedButton(
                    child: Text('Login'),
                    onPressed: () {
                      login();
                    })
              ],
            ),
          ),
        );
        break;
      case LoginStatus.loggedIn:
        return MainMenu(signOut);
        break;
    }
  }
}

class MainMenu extends StatefulWidget {
  final VoidCallback signOut;

  MainMenu(this.signOut);

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  signOut() {
    setState(() {
      widget.signOut();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu Utama'),
        actions: [
          IconButton(
              icon: Icon(Icons.lock_open),
              onPressed: () {
                signOut();
              })
        ],
      ),
    );
  }
}
