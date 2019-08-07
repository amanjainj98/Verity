import 'package:flutter/material.dart';
import 'dart:convert';
import 'session.dart';
import 'main.dart';

class WriterSectionDetail extends StatefulWidget {
  static String tag = 'Section Review';
  static String article_id;
  static String section_id;
  static String section_text;
  WriterSectionDetail(String art_id, String sec_id,String sec_text){
    article_id = art_id;
    section_id = sec_id;
    section_text = sec_text;
  }
  @override
  _WriterSectionDetailState createState() => new _WriterSectionDetailState(article_id,section_id,section_text);
}

class _WriterSectionDetailState extends State<WriterSectionDetail> {

  Map commentsmap;
  String section_id;
  String article_id;
  String section_text;
  bool loading = true;
  int length = 0;

  _WriterSectionDetailState(String art_id, String sec_id, String sec_text){
    article_id = art_id;
    section_id = sec_id;
    section_text = sec_text;
  }


  makeRequest() async {

    Session s = new Session();
    s.get(URL+'/WriterSectionDetails?article_id='+article_id+'&section_id='+section_id).then((response)
    {
      var decodedJSON = json.decode(response);
      print(response);
      setState(() {
        commentsmap = decodedJSON;
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
    return new Scaffold(
      appBar: new AppBar(
        //automaticallyImplyLeading: false,
        title: const Text('Section Details'),
        actions: <Widget>[
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
      Center(
          child: _buildSuggestions()
      ),
    );
  }


  Widget _buildSuggestions() {
    if (loading) {
      return new Text(
          'Loading'
      );
    } else {
      return new Center(
        child: Column(
          children: <Widget>[
            new Container(
              margin: new EdgeInsets.all(15.0),
              padding: new EdgeInsets.all(20.0),
              alignment: Alignment.center,
              child: new Text(section_text, style: TextStyle(
                  color: Colors.blueGrey, fontWeight: FontWeight.bold)),
              decoration: new BoxDecoration(
                  borderRadius: new BorderRadius.all(new Radius.circular(32.0)),
                  color: Colors.lightBlueAccent,
                  shape: BoxShape.rectangle),
            ),

            Expanded(
                child: new Stack(
                    children: <Widget>[new ListView.builder(
                      itemBuilder: (BuildContext context, int index) {
                        if (index < commentsmap['data'].length) {
                          return new Container(
                              decoration: new BoxDecoration(
                                  border: new Border.all(
                                      color: Colors.blueAccent)
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 10.0),
                                title: Text(
                                  commentsmap['data'][index]['text'].toString(),
                                  style: TextStyle(color: Colors.blueGrey,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Row(
                                  children: <Widget>[
                                    new Expanded(child: Text('Average Rating : ' + commentsmap['data'][index]['avg'].substring(0, 4),textAlign: TextAlign.left)),
                                    new Expanded(child: Text('Total Ratings :' + commentsmap['data'][index]['cnt'].toString(),textAlign: TextAlign.right)),
                                  ],
                                ),
                                // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),
                              ));
                        }
                      },
                    )
                    ]
                ))
          ],
        ),
      );
    }
  }
}