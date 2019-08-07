import 'package:flutter/material.dart';
import 'dart:convert';
import 'session.dart';
import 'article_list.dart';
import 'main.dart';
import 'add_comment.dart';
import 'package:flutter_rating/flutter_rating.dart';

class SectionComment extends StatefulWidget {
  static String tag = 'Articles';
  int ArticleID, SectionID;
  String SectionText;
  SectionComment(int articleid, int sectionid, String sectiontext){
    ArticleID = articleid;
    SectionID = sectionid;
    SectionText = sectiontext;
  }

  @override
  _SectionCommentState createState() => new _SectionCommentState(ArticleID,SectionID,SectionText);
}

class _SectionCommentState extends State<SectionComment> {
  Map commentsmap;
  bool loading = true;
  int ArticleID, SectionID;
  String SectionText;

  List<double> rating = new List();
  int starCount = 10;

  _SectionCommentState(int articleid, int sectionid, String sectionText){
    ArticleID = articleid;
    SectionID = sectionid;
    SectionText = sectionText;
  }

  makeRequest() async {

    Session s = new Session();
    s.get(URL+'/VolunteerGetComments?article_id='+ArticleID.toString()+'&section_id='+SectionID.toString()).then((response)
    {
      var decodedJSON = json.decode(response);
      print(response);
      setState(() {
        commentsmap = decodedJSON;
        for(int i=0;i<commentsmap.length;i++){
          rating.add(0.0);
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
        loading == false
            ?
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

              Expanded(
                  child: new Stack(
                      children: <Widget>[new ListView.builder(
                        itemBuilder: (BuildContext context, int index) {
                          if(index<commentsmap['data'].length){
                            return new Container(
//                                decoration: new BoxDecoration(
//                                    border: new Border.all(color: Colors.blueAccent)
//                                ),
                                   child: new Column(children : <Widget> [
                                     new Divider(color: Colors.indigoAccent),
                                      new ListTile(
                                        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                                        title: Text(commentsmap['data'][index]['text'].toString(),
                                          style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold),
                                        ),
                                        // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),
                                      ),
                                      new StarRating(
                                        size: 20.0,
                                        rating: this.rating[index],
                                        color: Colors.orange,
                                        borderColor: Colors.grey,
                                        starCount: starCount,
                                        onRatingChanged: (rating) => setState(
                                              () {
                                            this.rating[index] = rating;
                                            //print(this.rating[index]);
                                            Session s = new Session();
                                            s.get(URL+'/VolunteerRateComment?article_id='+ArticleID.toString()+'&section_id='+SectionID.toString()+'&comment_id='+commentsmap['data'][index]['comment_id'].toString()+'&rating='+this.rating[index].round().toString()).then((response)
                                                {
                                                  print(response);
                                                });
                                          },
                                        ),
                                      ),
                                     new Divider(color: Colors.indigoAccent),
                                    ],

                                )
                                );
                          }
                        },
                      ),
                      new Positioned(
                          right: 10.0,
                          bottom: 10.0,
                          child:
                          new FloatingActionButton(
                              elevation: 5.0,
                              child: new Icon(Icons.add),
                              backgroundColor: new Color(0xFFE57373),
                              onPressed: (){
                                Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                        new AddComment(ArticleID, SectionID, SectionText)));
                              }
                          )),
                      ])
              ),

            ],
          ),
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