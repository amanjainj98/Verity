import 'package:flutter/material.dart';
import 'dart:convert';
import 'session.dart';
import 'section_comment.dart';
import 'main.dart';
import 'article_list.dart';

class ArticleDetail extends StatefulWidget {
  static String tag = 'Articles';
  int ID;
  //String filepath;
  ArticleDetail(int id){
    ID = id;
    //this.filepath = filepath;
  }

  @override
  _ArticleDetailState createState() => new _ArticleDetailState(ID);
}

class _ArticleDetailState extends State<ArticleDetail> {
  Map filemap;
  Map sectionsmap;
  var startindices = [];
  String text = '';
  bool loading = true;
  int ID = 0;
  String filepath;
  int startindex = 0;

  _ArticleDetailState(int id){
    ID = id;
  }

  makeRequest() {

    Session s = new Session();

    s.get(URL+'/VolunteerGetSections?article_id='+ID.toString()).then((response){
      var decodedJSON = json.decode(response);
      sectionsmap = decodedJSON;
      print(sectionsmap);

      startindices = [];
      startindex = 0;
      for(int i=0;i<sectionsmap['section'].length;i++){
        startindices.add(startindex);
        startindex+=sectionsmap['section'][i]['length'];
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

  @override
  Widget build(BuildContext context) {

    final submitButton = Padding(

      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        borderRadius: BorderRadius.circular(30.0),
        shadowColor: Colors.lightBlueAccent.shade100,
        elevation: 5.0,
        child: MaterialButton(
          minWidth: double.infinity,
          height: 42.0,
          onPressed: ()
          {
            Session s = new Session();

            s.get(URL+'/VolunteerSubmitArticle?article_id='+ID.toString()).then((response){
              print(response);
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (BuildContext context) =>
                      new ArticleList()));
            });

          },
          color: Colors.lightBlueAccent,
          child: Text('Submit', style: TextStyle(color: Colors.white)),
        ),
      ),
    );

    return new Scaffold(
        appBar: new AppBar(
          title: loading == true
              ? Text('Loading Title')
              : Text('Article Detail'),//Text(sectionsmap['body'][0]['title']),
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
        loading == false
            ?
        new Column(children: <Widget>[
          new Expanded(child: ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              if(index<sectionsmap['section'].length-1){
                int a = startindices[index];
                int b = startindices[index]+sectionsmap['section'][index]['length']-1;
                return new ListTile(

                  title: new Container(
                      alignment: Alignment.centerLeft,
                      child: new Text(sectionsmap['body'][0]['body'].toString().substring(a,b))),


//                title: Column(
//                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                    children: <Widget>[
//                      new Flexible(child: new Container(
//                          alignment: Alignment.centerLeft,
//                          child: new Text("text")))]), //new Text(sectionsmap['body'][0]['body'].toString().substring(a,b))))]),
                  onTap: () {
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (BuildContext context) =>
                            new SectionComment(ID, sectionsmap['section'][index]['section_id'],sectionsmap['body'][0]['body'].toString().substring(a,b))));
                  },

                );
              }
            },
          )),
          submitButton
        ])
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