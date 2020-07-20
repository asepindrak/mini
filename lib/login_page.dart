import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  static String tag = 'login-page';
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final textphone = TextEditingController();
  final textpassword = TextEditingController();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  var alert = '';
  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.
    super.dispose();
    textphone.dispose();
    textpassword.dispose();
  }

  void checkLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var dataUser = prefs.getString('user');

    if (dataUser != null) {
      print(dataUser);
      final user = json.decode(dataUser);
      /*Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePage()));*/

    }

    textphone.text = '088786876343';
    textpassword.text = '123456';
  }

  void login() async {
    var message = '';
    setState(() {
      alert = message;
    });
    Map data = {'phone': textphone.text, 'password': textpassword.text};
    //encode Map to JSON
    var body = json.encode(data);
    // This example uses the Google Books API to search for books about http.
    // https://developers.google.com/books/docs/overview
    var url = apiurl + 'login_app';

    print(url);
    // Await the http get response, then decode the json-formatted response.
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: body);
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      var responses = Responses(jsonResponse);
      if (responses.success == "true") {
        //print('echo: ' + json.encode(responses.data));
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('user', responses.data);
        message = 'Login sukses';
        var result = json.decode(responses.data);
        print(result);
        /*
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => HomePageSiswa()));
            */
      } else {
        //print('login gagal');
        message = 'Login gagal!';
        setState(() {
          alert = message;
        });
      }
    } else {
      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      print('Request failed with status: ${response.statusCode}.');
      message = 'Login gagal!';
      setState(() {
        alert = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 60.0,
        child: Image.asset('assets/logo.jpg'),
      ),
    );

    final email = TextFormField(
      controller: textphone,
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'NIS / No HP',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final password = TextFormField(
      controller: textpassword,
      autofocus: false,
      obscureText: true,
      decoration: InputDecoration(
        hintText: 'Password',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        borderRadius: BorderRadius.circular(30.0),
        shadowColor: Colors.lightGreenAccent.shade100,
        elevation: 5.0,
        child: MaterialButton(
          minWidth: 200.0,
          height: 42.0,
          onPressed: () {
            login();
          },
          color: Colors.lightGreenAccent,
          child: Text('Log In', style: TextStyle(color: Colors.white)),
        ),
      ),
    );

    final forgotLabel = FlatButton(
      child: Text(
        'Forgot password?',
        style: TextStyle(color: Colors.black54),
      ),
      onPressed: () {},
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            logo,
            SizedBox(height: 48.0),
            email,
            SizedBox(height: 8.0),
            password,
            SizedBox(height: 24.0),
            Text(alert),
            loginButton,
            forgotLabel
          ],
        ),
      ),
    );
  }
}

class Dialogs {
  static Future<void> showLoadingDialog(
      BuildContext context, GlobalKey key) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  key: key,
                  backgroundColor: Colors.black54,
                  children: <Widget>[
                    Center(
                      child: Column(children: [
                        CircularProgressIndicator(),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Please Wait....",
                          style: TextStyle(color: Colors.blueAccent),
                        )
                      ]),
                    )
                  ]));
        });
  }
}

class Responses {
  String success;
  String message;
  String data;
  Responses(Map<String, dynamic> item) {
    success = item['success'];
    message = item['message'];
    data = item['data'];
  }
}
