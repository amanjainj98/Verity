import 'package:flutter/material.dart';
import 'dart:convert';
import 'session.dart';
import 'main.dart';
import 'writer_article_list.dart';
import 'writer_section_detail.dart';

class WriterArticle extends StatefulWidget {
  static String tag = 'Writer Articles';
  static String article_id;

  WriterArticle(String art_id){
    article_id = art_id;
  }

  @override
  _WriterArticleState createState() => new _WriterArticleState(article_id);
}

class _WriterArticleState extends State<WriterArticle> {

  Map sectionsmap;
  var startindices = [];
  bool loading = true;
  int startindex = 0;
  String article_id;
  int max_comments;

  _WriterArticleState(String art_id){
    article_id = art_id;
  }

  makeRequest() {

    Session s = new Session();
    print("Sending request");
    s.get(URL+'/WriterViewArticle?article_id='+article_id.toString()).then((response){
      var decodedJSON = json.decode(response);
      sectionsmap = decodedJSON;
      print(sectionsmap);

      startindices = [];
      startindex = 0;max_comments=0;
      for(int i=0;i<sectionsmap['data2'].length;i++){
        startindices.add(startindex);
        startindex+=sectionsmap['data2'][i]['length'];
        if(sectionsmap['data2'][i]['count'] > max_comments) max_comments = sectionsmap['data2'][i]['count'];
      }

      print(startindices);

      setState(() {
        loading = false;
      });
    });
  }


  @override
  void initState() {
    this.makeRequest();
    super.initState();
  }

  Color getColor(int numComment) {
    if (numComment < max_comments/4) {
      return Colors.white70;
    } else if (numComment < max_comments/2) {
      return Colors.lightGreenAccent;
    }else if (numComment < max_comments*3/4) {
      return Colors.limeAccent;
    }
    else return Colors.orangeAccent;
  }

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
        appBar: new AppBar(
          title: loading == true
              ? Text('Loading Title')
              : Text(sectionsmap['data1'][0]['title'].toString()),
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
        loading == false
            ?
        new ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            if(index<sectionsmap['data2'].length){
              int a = startindices[index];
              int b = startindices[index]+sectionsmap['data2'][index]['length']-1;
              int numcomments = sectionsmap['data2'][index]['count'];
              return new Container(                    color: getColor(numcomments),
            child: ListTile(
                  title: new Container(
                  alignment: Alignment.centerLeft,
//                  color: getColor(numcomments),
                  child:  new Text(sectionsmap['data1'][0]['body'].toString().substring(a,b))),
                  onTap: () {
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (BuildContext context) =>
                            new WriterSectionDetail(article_id, sectionsmap['data2'][index]['section_id'].toString(),sectionsmap['data1'][0]['body'].toString().substring(a,b))));
                  }
              ));
            }
          },
        )
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