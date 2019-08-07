import 'package:flutter/material.dart';
import 'dart:convert';
import 'session.dart';
import 'article_list.dart';
import 'writer_article_list.dart';
import 'volunteer_signup.dart';

class WriterSignup extends StatelessWidget {
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
            title: Text('Sign Up'),
          ),
          body: WriterSignupForm(),
        ),
        routes: {
          '/article_list': (context) => ArticleList(),
          '/writer_article_list': (context) => WriterArticleList(),

          '/volunteer_signup': (context) => VolunteerSignupForm(),
        }
    );
  }
}

// Create a Form Widget
class WriterSignupForm extends StatefulWidget {
  @override
  WriterSignupFormState createState() {
    return WriterSignupFormState();
  }
}

class _WriterSignupData {
  String name = '';
  String user_id = '';
  String password = '';
}

class WriterSignupFormState extends State<WriterSignupForm> {
  _WriterSignupData _data = new _WriterSignupData();
  final _formKey = GlobalKey<FormState>();
  bool checkBoxValue = false;

  @override
  Widget build(BuildContext context) {

    final name = TextFormField(
      keyboardType: TextInputType.text,
      autofocus: false,
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter name';
        }
      },
      onSaved: (String value) {
        this._data.name = value;
      },
      decoration: InputDecoration(
        hintText: 'Name',
        labelText: 'Name',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final username = TextFormField(
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter username';
        }
      },
      onSaved: (String value) {
        this._data.user_id = value;
      },
      decoration: InputDecoration(
        hintText: 'Username',
        labelText: 'Username',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final password = TextFormField(
      autofocus: false,
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
        labelText: 'Password',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final checkBox= new Column(
      children: <Widget>[
        new CheckboxListTile(
          value: checkBoxValue,
          onChanged: (value) {
            setState(() {
              checkBoxValue = value;
            });
          },
          title: new Text('I want to be a Volunteer'),
          controlAffinity: ListTileControlAffinity.leading,
          subtitle: new Text('Provide more details on the next page'),
          activeColor: Colors.red,
        ),
      ],
    );

    final signupButton = Padding(
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

              print('Printing the signup data.');
              print('Name: ${_data.name }');
              print('Username: ${_data.user_id }');
              print('Password: ${_data.password}');

              var signup_info = new Map();
              signup_info['username'] = _data.user_id;
              signup_info['password'] = _data.password;
              signup_info['name'] = _data.name;


              Session s = new Session();
              s.post(URL+'/WriterSignUp',signup_info).then((response)
              {
                final decodedJSON = json.decode(response);
                print(response);
                if(decodedJSON['status']) {
                  print('Successfully signed up for writer');
                  if (checkBoxValue) {
                    print("navigating to volunteer signup");
                    Navigator.pushNamed(context, '/volunteer_signup');
                  }
                  else{
                    Navigator.pushNamed(context, '/article_list');
                  }
                }
                else{
                  Scaffold.of(context).showSnackBar(SnackBar(content: Text('Signup Failed')));
                }
              });
            }
          },
          color: Colors.lightBlueAccent,
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
              SizedBox(height: 35.0),
              name,
              SizedBox(height: 35.0),
              username,
              SizedBox(height: 35.0),
              password,
              SizedBox(height: 35.0),
              checkBox,
              SizedBox(height: 24.0),
              signupButton,
            ],
          ),
        )]);
  }
}