import 'package:flutter/material.dart';
import 'dart:convert';
import 'writer_article_list.dart';
import 'session.dart';
import 'main.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';


class WriterCreateArticle extends StatefulWidget {
  static String tag = 'Articles';
  @override
  _WriterCreateArticleState createState() => new _WriterCreateArticleState();
}

class _WriterCreateArticleState extends State<WriterCreateArticle>{
  final TextEditingController _typeAheadController = TextEditingController();
  List <String> tagSelectedlist = new List<String>();
  List <String> tagNames = new List<String>();
  Map tagsmap;
  String title;
  String description;
  String body;
  String max_users;
  bool loading = true;
  int length = 0;
  final dateFormat = DateFormat("EEEE, MMMM d, yyyy 'at' h:mma");
  DateTime date = DateTime.now();
  final _formKey = GlobalKey<FormState>();

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
    final titleField = new TextFormField(
      keyboardType: TextInputType.text,
      autofocus: false,
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter title';
        }
      },
      onSaved: (String value) {
        title = value;
      },
      decoration: InputDecoration(
        hintText: 'title',
        labelText: 'Name',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );


    final descriptionField = TextFormField(
      keyboardType: TextInputType.text,
      autofocus: false,
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter description';
        }
      },
      onSaved: (String value) {
        description = value;
      },
      decoration: InputDecoration(
        hintText: 'Desciption',
        labelText: 'Description',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final bodyField = TextFormField(
      keyboardType: TextInputType.multiline,
      maxLines: 8,
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter some text';
        }
      },
      onSaved: (String value) {
        body = value;
      },
      decoration: InputDecoration(
        hintText: 'Article Body',
        labelText: 'Article Body',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final dateTimeField = DateTimePickerFormField(
      format: dateFormat,
      decoration: InputDecoration(labelText: 'Deadline',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
      onChanged: (dt) => setState(() => date = dt),
    );


    final MaxusersField = TextFormField(
      keyboardType: TextInputType.number,
      autofocus: false,
      initialValue: '10',
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter maximum users you want the article to route to';
        }
      },
      onSaved: (value) {
        max_users = value;
      },
      decoration: InputDecoration(
        hintText: 'Max Users',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final tagsSelected = Text(
        tagSelectedlist.toString()
    );

    final tagField = SingleChildScrollView(child: TypeAheadField(

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
        return SingleChildScrollView(child: ListTile(
          title: Text(suggestion),
        ));
      },
      onSuggestionSelected: (suggestion) {
        this._typeAheadController.text = "";
        setState(() {
          tagSelectedlist.add(suggestion);
        });
      },
    ));


    final submitButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        borderRadius: BorderRadius.circular(30.0),
        shadowColor: Colors.lightBlueAccent.shade100,
        elevation: 5.0,
        child: MaterialButton(
          minWidth: 200.0,
          height: 42.0,
          onPressed: ()
          {
            if (_formKey.currentState.validate())
            {
              _formKey.currentState.save();
              print('Printing the tag list');
              print(tagSelectedlist.toString());
              Session s = new Session();
              print(date.toString());
              print(tagSelectedlist.toString());
              print(URL + '/WriterCreateArticle?title='+title+'&description='+description+'&body='+body+'&tags=' + tagSelectedlist.toString() + '&max_users='+max_users+'&end_time='+date.toString());
              s.get(URL + '/WriterCreateArticle?title='+title+'&description='+description+'&body='+body+'&tags=' + tagSelectedlist.toString() + '&max_users='+max_users+'&end_time='+date.toString()).then((response) {
                print(response);
                final decodedJSON = json.decode(response);
                print(decodedJSON);
                if (decodedJSON["status"]) {
                  print('Successfully submitted article');
                  Navigator.pushNamed(context, '/writer_article_list');
                }
                else {
                  showDialog(
                      context: context,
                      builder:(BuildContext context) {
                        return AlertDialog(
                          title:Center(child:Text('Alert')),
                          content: new Container(
                            width : 300.0,
                            height : 100.0,
                            child : new Center(child:Text('Article Submission Failed')),
                          ),
                        );
                      }
                  );
                }
              }
              );
            }
          },
          color: Colors.lightBlueAccent,
          child: Text('Submit', style: TextStyle(color: Colors.white)),
        ),
      ),
    );


    ListView list = new ListView.builder(
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
        });


    return new Scaffold(
        appBar: new AppBar(
          title: const Text('Submit Article'),
          actions: <Widget>[
            // action button
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (BuildContext context) =>
                        new WriterArticleList()));
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

        new SingleChildScrollView(
            child :         new Column(
                children: <Widget>[
                  Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(height: 20.0),
                          titleField,
                          SizedBox(height: 20.0),
                          descriptionField,
                          SizedBox(height: 30.0),
                          tagsSelected,
                          SizedBox(height: 30.0),
                          tagField,
                          SizedBox(height: 30.0),
                          bodyField,
                          SizedBox(height: 20.0),
                          dateTimeField,
                          SizedBox(height: 20.0),
                          MaxusersField,
                          SizedBox(height: 20.0),
                          submitButton
                        ],
                      )),

                ]))


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