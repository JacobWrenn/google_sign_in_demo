import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_sign_in_demo/google.dart';
import 'package:google_sign_in_demo/user.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Sign In Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final auth = Google(
      serverClientID: 'YOUR SERVER CLIENT ID',
      domain: 'gmail.com',
      clientID: 'YOUR APP CLIENT ID',
      reversedClientID: 'YOUR REVERSED APP CLIENT ID',
      scopes: ["email", "profile"]);
  User user;
  bool login = false;

  void restoreUser() async {
    User googleUser;
    try {
      googleUser = await auth.restoreLogin();
    } catch (e) {}
    setState(() {
      user = googleUser;
      login = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!login && user == null) {
      restoreUser();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Google Sign In Demo'),
      ),
      body: login && user == null
          ? Center(
              child: FlatButton(
                color: Colors.blue,
                child: Text('Sign In'),
                onPressed: () async {
                  User googleUser = await auth.login();
                  setState(() {
                    user = googleUser;
                  });
                },
              ),
            )
          : user != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (user.refreshed) ...[
                        Container(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'User was signed in silently - serverAuthCode is not avaiable.',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                            )),
                        SizedBox(height: 16),
                      ] else ...[
                        Container(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'User was signed in interactively - serverAuthCode is avaialble.',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                            )),
                        SizedBox(height: 16),
                      ],
                      Column(
                        children: [
                          Text(
                            'Name: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('${user.name}'),
                        ],
                      ),
                      SizedBox(height: 16),
                      Column(
                        children: [
                          Text(
                            'ID: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(user.id),
                        ],
                      ),
                      SizedBox(height: 16),
                      Column(
                        children: [
                          Text(
                            'Email: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(user.email),
                        ],
                      ),
                      SizedBox(height: 16),
                      Column(
                        children: [
                          Text(
                            'serverAuthCode: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('${user.serverAuthCode}'),
                        ],
                      ),
                      SizedBox(height: 16),
                      FlatButton(
                        color: Colors.blue,
                        child: Text('Sign Out'),
                        onPressed: () async {
                          await auth.logout();
                          setState(() {
                            user = null;
                          });
                        },
                      ),
                    ],
                  ),
                )
              : SpinKitRing(
                  color: Colors.blue,
                ),
    );
  }
}
