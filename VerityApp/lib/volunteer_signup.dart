import 'package:flutter/material.dart';
import 'dart:convert';
import 'session.dart';
import 'main.dart';
import 'article_list.dart';
import 'writer_article_list.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class VolunteerSignup extends StatelessWidget {
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
          body: VolunteerSignupForm(),
        ),
        routes: {
          '/article_list': (context) => ArticleList(),
          '/writer_article_list': (context) => WriterArticleList(),
        }
    );
  }
}

class VolunteerSignupForm extends StatefulWidget {
  @override
  VolunteerSignupFormState createState() {
    return VolunteerSignupFormState();
  }
}


class VolunteerSignupFormState extends State<VolunteerSignupForm> {
  final TextEditingController _typeAheadController = TextEditingController();
  List <String> tagSelectedlist = new List<String>();
  List <String> tagNames = new List<String>();
  Map tagsmap;
  bool loading = true;
  int length = 0;

  makeRequest() async {
    Session s = new Session();
    print("getting tags");
    s.get(URL+'/GetTags').then((response)
    {
      var decodedJSON = json.decode(response);
      print(response);
      print(decodedJSON['data'].length);
      print(decodedJSON['status']);
      setState(() {
        for(int i=0;i<decodedJSON['data'].length;i++){
          tagNames.add(decodedJSON['data'][i]['tag_name']);
        }
        loading = false;
      });
    });
  }

  @override
  void initState() {
    this.makeRequest();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final tagField = TypeAheadField(

      textFieldConfiguration: TextFieldConfiguration(
        autofocus: true,
        controller: this._typeAheadController,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: 'Search by tag name',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        ),
      ),
      suggestionsCallback: (pattern) {
        print(pattern);
        List<String> list = new List<String>();
        for (int i = 0; i < tagNames.length; i++) {
          if (tagNames[i].toLowerCase().startsWith(pattern.toLowerCase())) {
            print(tagNames[i]);
            list.add(tagNames[i].toString());
          }
        }
        print('list = ' + list.toString());
        return list;
      },

      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(suggestion),
        );
      },
      onSuggestionSelected: (suggestion) {
        this._typeAheadController.text = "";
        setState(() {
          tagSelectedlist.add(suggestion);
        });
      },
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
            print('Printing the tag list');
            print(tagSelectedlist.toString());

            Session s = new Session();
            s.get(URL + '/VolunteerSignUp?tags=' + tagSelectedlist.toString()).then((response) {
              print(response);
              final decodedJSON = json.decode(response);
              print(decodedJSON);
              if (decodedJSON["status"]) {
                print('Successfully signed up');
                  Navigator.pushNamed(context, '/article_list');
              }
              else {
                Scaffold.of(context).showSnackBar(
                    SnackBar(content: Text('Signup Failed')));
              }
            });
          },
          color: Colors.lightBlueAccent,
          child: Text('Sign Up', style: TextStyle(color: Colors.white)),
        ),
      ),
    );

    return new Scaffold(
        appBar: new AppBar(
          title: const Text('Volunteer Sign Up'),
          actions: <Widget>[
            // action button
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (BuildContext context) =>
                        new ArticleList()));
              },
            ),

            // overflow menu
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                Session s = new Session();
                s.get(URL + '/VolunteerLogout').then((response) {
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (BuildContext context) =>
                          new MyApp()));
                });
              },
            ),
          ],
        ),
        body:
        loading == false
            ?
        Center(
            child: Column(
              children: <Widget>[tagField,
              new Expanded(child: new ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: tagSelectedlist.length,
                  itemBuilder: (BuildContext _context, int i) {
                    if(i < tagSelectedlist.length)
                      return new ListTile(
                          title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                new Container(
                                    alignment: Alignment.centerLeft,
                                    child: new Text(
                                      tagSelectedlist[i],
                                    ))]),
                          onTap: () {
                            print("tapped");
                          }
                      );
                  })),
              signUpButton
              ],
            ))
            :
        new Center(
          child: new SizedBox(
            height: 50.0,
            width: 50.0,
            child: new CircularProgressIndicator(
              value: null,
              strokeWidth: 7.0,
            ),
          ),
        ));
  }

}