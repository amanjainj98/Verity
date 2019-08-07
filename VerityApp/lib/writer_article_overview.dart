import 'package:flutter/material.dart';
import 'dart:convert';
import 'session.dart';
import 'main.dart';
import 'writer_article.dart';

class WriterArticleOverview extends StatefulWidget {
  static String tag = 'Writer Article Overview';
  static String article_id;

  WriterArticleOverview(String art_id){
    article_id = art_id;
  }

  @override
  _WriterArticleOverviewState createState() => new _WriterArticleOverviewState(article_id);
}

class _WriterArticleOverviewState extends State<WriterArticleOverview> {

  Map articledetailmap;
  String article_id;
  bool loading = true;
  int length = 0;

  _WriterArticleOverviewState(String art_id){
    article_id = art_id;
  }

  makeRequest() async {

    Session s = new Session();
    print("sending request");
//    print("Article ID = "+ article_id);
    s.get(URL+'/WriterArticleDetails?article_id='+article_id.toString()).then((response)
    {
      print(response);
      var decodedJSON = json.decode(response);
      setState(() {
        articledetailmap = decodedJSON;
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
        title: const Text('Overview'),
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
      body: loading == true
        ? new Center(
        child: new SizedBox(
          height: 50.0,
          width: 50.0,
          child: new CircularProgressIndicator(
            value: null,
            strokeWidth: 7.0,
          ),
        ),
      )
        :
        new SingleChildScrollView(
            child : Center(
          child: Column(
            children: <Widget>[
              new Container(
                margin: new EdgeInsets.all( 15.0),
                padding: new EdgeInsets.all( 20.0),
                alignment: Alignment.center,
                child: new Text(articledetailmap['article_data'][0]['title'],style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                decoration: new BoxDecoration(
                    borderRadius: new BorderRadius.all(new Radius.circular(32.0)),color: Colors.tealAccent, shape: BoxShape.rectangle),
              ),

              new Container(
                margin: new EdgeInsets.all( 15.0),
                padding: new EdgeInsets.all( 20.0),
                alignment: Alignment.center,
                child: new Text(articledetailmap['article_data'][0]['description'],style: TextStyle(color: Colors.black87, fontWeight: FontWeight.normal)),

                decoration: new BoxDecoration(
                    borderRadius: new BorderRadius.all(new Radius.circular(30.0)),color: Colors.cyanAccent, shape: BoxShape.rectangle),
              ),
              new Container(
                child: Row(
                  children: <Widget>[
                    new Expanded(child:
                    new Container(
                      margin: new EdgeInsets.all( 15.0),
                      padding: new EdgeInsets.all( 20.0),
                      child: Text("Reviews = "+ articledetailmap['num_users'].toString(),style: TextStyle(color: Colors.indigoAccent, fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                      decoration: new BoxDecoration(
                          borderRadius: new BorderRadius.all(new Radius.circular(30.0)),color: Colors.cyanAccent, shape: BoxShape.rectangle),
                    )),
                    new Expanded(child: new Container(
                      margin: new EdgeInsets.all( 15.0),
                      padding: new EdgeInsets.all( 20.0),
                      child: new Text("Comments= "+ articledetailmap['num_comments'][0]['count'].toString(),style: TextStyle(color: Colors.indigoAccent, fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                      decoration: new BoxDecoration(
                          borderRadius: new BorderRadius.all(new Radius.circular(30.0)),color: Colors.cyanAccent, shape: BoxShape.rectangle),
                    ))
                  ],
                )
              ),
//              new Container(
//                margin: new EdgeInsets.all( 5.0),
//                padding: new EdgeInsets.all( 10.0),
//                alignment: Alignment.center,
//                child: new Text("Accuracy Rating  :  "+articledetailmap['accuracy'].toString(),style: TextStyle(color: Colors.green, fontWeight: FontWeight.normal)),
//              ),
              new Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Material(
                  borderRadius: BorderRadius.circular(30.0),
                  shadowColor: Colors.lightBlueAccent.shade100,
                  elevation: 5.0,
                  child: MaterialButton(
                    minWidth: double.infinity,
                    height: 42.0,
                    onPressed: (){
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (BuildContext context) =>
                              new WriterArticle(article_id)));

                    },
                    color: Colors.lightBlueAccent,
                    child: Text('View Article', style: TextStyle(color: Colors.white)),
                  )),
              )
            ],
          )
        )
      ),
    );
  }



}