import 'package:flutter/material.dart';
import 'dart:convert';
import 'session.dart';
import 'article_list.dart';
import 'writer_article_list.dart';

import 'writer_signup.dart';
void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Verity App',
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: Text('Verity'),
          ),
          body: MyLoginForm(),
        ),
        routes: {
          '/article_list': (context) => ArticleList(),
          '/writer_article_list': (context) => WriterArticleList(),
          '/writer_signup': (context) => WriterSignup(),
        }
    );
  }
}

// Create a Form Widget
class MyLoginForm extends StatefulWidget {
  @override
  MyLoginFormState createState() {
    return MyLoginFormState();
  }
}

class _LoginData {
  String userid = '';
  String password = '';
}

class MyLoginFormState extends State<MyLoginForm> {
  _LoginData _data = new _LoginData();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 48.0,
        child: Image.network('http://cleanmyemails.com/wp-content/uploads/2013/06/url-300x239.png'),
      ),
    );

    final username = TextFormField(
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      initialValue: 'w1',
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter username';
        }
      },
      onSaved: (String value) {
        this._data.userid = value;
      },
      decoration: InputDecoration(
        hintText: 'Username',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final password = TextFormField(
      autofocus: false,
      initialValue: 'w1',
      obscureText: true,
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter password';
        }
      },
      onSaved: (String value) {
        this._data.password = value;
      },
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
        shadowColor: Colors.lightBlueAccent.shade100,
        elevation: 5.0,
        child: MaterialButton(
          minWidth: 200.0,
          height: 42.0,
          onPressed: () {
            if (_formKey.currentState.validate()) {
              _formKey.currentState.save();

              print('Printing the login data.');
              print('Email: ${_data.userid }');
              print('Password: ${_data.password}');

              var login_info = new Map();
              login_info['username'] = _data.userid;
              login_info['password'] = _data.password;

//              var login_info = {"username":_data.userid,"password":_data.password};

              Session s = new Session();
              s.post(URL+'/Login',login_info).then((response)
              {
                final decodedJSON = json.decode(response);
                print(response);
                if(decodedJSON["status"]){
                  print('Logged in');
                  if(decodedJSON["data"][0] == "volunteer") {
                    Navigator.pushNamed(context, '/article_list');
                  }
                  else{
                    Navigator.pushNamed(context, '/writer_article_list');
                  }
                }
                else{
                  Scaffold.of(context).showSnackBar(SnackBar(content: Text('Login Failed')));

                }
              });
            }
          },
          color: Colors.lightBlueAccent,
          child: Text('Log In', style: TextStyle(color: Colors.white)),
        ),
      ),
    );



    final signUpButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        borderRadius: BorderRadius.circular(30.0),
        shadowColor: Colors.lightBlueAccent.shade100,
        elevation: 5.0,
        child: MaterialButton(
          minWidth: 200.0,
          height: 42.0,
          onPressed: () {
                    Navigator.pushNamed(context, '/writer_signup');
          },
          color: Colors.lightGreen,
          child: Text('Sign Up', style: TextStyle(color: Colors.white)),
        ),
      ),
    );



    return new ListView(
        children: <Widget>[Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 48.0),
              logo,
              SizedBox(height: 48.0),
              username,
              SizedBox(height: 16.0),
              password,
              SizedBox(height: 24.0),
              loginButton,
              SizedBox(height: 24.0),
              signUpButton,
            ],
          ),
        )]);
  }
}