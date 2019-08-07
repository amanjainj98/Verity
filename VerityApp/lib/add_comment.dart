import 'package:flutter/material.dart';
import 'dart:convert';
import 'session.dart';
import 'article_list.dart';
import 'main.dart';
import 'section_comment.dart';

class AddComment extends StatefulWidget {
  static String tag = 'Add Comment';
  int ArticleID, SectionID;
  String SectionText;
  AddComment(int articleid, int sectionid, String sectiontext){
    ArticleID = articleid;
    SectionID = sectionid;
    SectionText = sectiontext;
  }

  @override
  _AddCommentState createState() => new _AddCommentState(ArticleID,SectionID,SectionText);
}

class _AddCommentState extends State<AddComment> {
  Map commentsmap;
  int ArticleID, SectionID;
  String SectionText;

  _AddCommentState(int articleid, int sectionid, String sectionText){
    ArticleID = articleid;
    SectionID = sectionid;
    SectionText = sectionText;
  }

//  makeRequest() async {
//
//    Session s = new Session();
//    s.get(URL+'/VolunteerGetComments?article_id='+ArticleID.toString()+'&section_id='+SectionID.toString()).then((response)
//    {
//      var decodedJSON = json.decode(response);
//      print(response);
//      setState(() {
//        commentsmap = decodedJSON;
//      });
//    });
//  }


  @override
  void initState() {
//    this.makeRequest();
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    String text;

    return new Scaffold(
        appBar: new AppBar(
          title: const Text('Comments'),
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
                s.get(URL+'/VolunteerLogout').then((response)
                {
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (BuildContext context) =>
                          new MyApp()));              });
              },
            ),
          ],
        ),
        body:
        new ListView(
        children: <Widget>[
        Center(
          child: Column(

            children: <Widget>[
              new Container(
                margin: new EdgeInsets.all( 15.0),
                padding: new EdgeInsets.all( 20.0),
                alignment: Alignment.center,
                child: new Text(SectionText,style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                decoration: new BoxDecoration(
                    borderRadius: new BorderRadius.all(new Radius.circular(32.0)),color: Colors.lightBlueAccent, shape: BoxShape.rectangle),
              ),
              new SingleChildScrollView( child:
              new Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Container(
                      margin: const EdgeInsets.all(30.0),
                        color: Color.fromRGBO(10, 42, 75, 0.1),

                        //padding: const EdgeInsets.all(30.0),

                        child : TextFormField(
                      keyboardType: TextInputType.multiline,
                      maxLines: 8,

                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter some text';
                        }
                      },

                      onSaved: (String value) {
                        text = value;
                      },
                    ))
                    ,
                    new Container(
                      alignment: Alignment.center,
                    child : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: RaisedButton(
                        color: Colors.lightBlueAccent,
                        child: Text('Submit', style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          // Validate will return true if the form is valid, or false if
                          // the form is invalid.
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            // If the form is valid, we want to show a Snackbar
//                            Scaffold.of(context)
//                                .showSnackBar(SnackBar(content: Text('Processing Data')));


                            Session s = new Session();
                            s.get(URL+'/VolunteerCreateComment?article_id='+ArticleID.toString()+'&section_id='+SectionID.toString()+'&text='+text).then((response)
                            {
                              final decodedJSON = json.decode(response);
                              print(response);
                              if(decodedJSON["status"]){
                                print('Comment created');
//                                Scaffold.of(context).showSnackBar(SnackBar(content: Text('Comment Added')));
                                Navigator.pushReplacement(
                                    context,
                                new MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                    new SectionComment(ArticleID, SectionID, SectionText)));
                              }
                              else{
//                                Scaffold.of(context).showSnackBar(SnackBar(content: Text('Comment create Failed')));
                              print('Comment create failed');

                              }
                            });
                          }
                        },

                      ),
                    )),
                  ],
                ),
              ))
            ],
          ),
        )]
    ));
  }

}