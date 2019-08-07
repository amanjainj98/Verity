import 'package:flutter/material.dart';
import 'dart:convert';
import 'article_detail.dart';
import 'session.dart';
import 'main.dart';
import 'writer_article_list.dart';
import 'volunteer_profile.dart';

class ArticleList extends StatefulWidget {
  static String tag = 'Articles';
  @override
  _ArticleListState createState() => new _ArticleListState();
}

class _ArticleListState extends State<ArticleList> {
  Map articlesmap;
  Map filemap;
  String text = '';
  bool loading = true;
  int length = 0;
  int currentID = 0;
  String firstTitle,firstDescription,firstTag,firstTime;
  String secondTitle,secondDescription,secondTag,secondTime;

  Map month= {
    '01': 'Jan',
    '02': 'Feb',
    '03': 'March',
    '04': 'April',
    '05': 'May',
    '06': 'June',
    '07': 'July',
    '08': 'Aug',
    '09': 'Sept',
    '10': 'Oct',
    '11': 'Nov',
    '12': 'Dec'
  };

  static String parseTime(String str){
    if(str.isEmpty)
      return '';
    String finalString= '';
    int hr= int.parse(str.substring(0, 2));
    if(hr <= 12)
      finalString+= hr.toString()+ str.substring(2, 5) + ' AM';
    else
      finalString+= (hr-12).toString()+ str.substring(2, 5) + ' PM';

    return finalString;
  }

  makeRequest() async {

    Session s = new Session();
    s.get(URL+'/VolunteerAllArticles').then((response)
    {
      print("Entered Vol All articles");
      var decodedJSON = json.decode(response);

      print(response);
      setState(() {

        articlesmap = decodedJSON;
        length = articlesmap['data'].length;
        print(articlesmap['data'].length);
        if(length>0){

          firstTitle = articlesmap['data'][0]['title'];
          firstDescription = articlesmap['data'][0]['description'];
          //firstTag = articlesmap['data'][0]['tags'].toString();
          firstTag = "";
          for(int i=0;i<articlesmap['tags'].length;i++){
            if(articlesmap['tags'][i][2]==articlesmap['data'][0]['article_id']){
              if(firstTag=='') firstTag+=articlesmap['tags'][i][1].toString();
              else firstTag+=", "+articlesmap['tags'][i][1].toString();
            }
          }
          firstTime = articlesmap['data'][0]['publish_time'];


        }
        if (length > 1) {
          setState(() {
            secondTitle = articlesmap['data'][1]['title'];
            secondDescription = articlesmap['data'][1]['description'];
            secondTag = '';
            for(int i=0;i<articlesmap['tags'].length;i++){
              if(articlesmap['tags'][i][2]==articlesmap['data'][1]['article_id']){
                if(secondTag=='') secondTag+=articlesmap['tags'][i][1].toString();
                else secondTag+=", "+articlesmap['tags'][i][1].toString();
              }
            }
            articlesmap['data'][1]['tags'].toString();
            secondTime = articlesmap['data'][1]['publish_time'];
            loading = false;
          });

        }

        else {
          setState(() {
            loading = false;
          }
          );

        }
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
          automaticallyImplyLeading: false,
          title: const Text('Articles'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.people),
              onPressed: () {
                Session s = new Session();
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (BuildContext context) =>
                        new VolunteerProfile()));
              },
            ),


            IconButton(
                icon: Icon(Icons.swap_vertical_circle),
                onPressed: () {
                  Session s = new Session();

                  s.get(URL + '/Switch?switchto=0').then((response) {
                    var decodedJSON = json.decode(response);
                    print(decodedJSON);
                    if (decodedJSON['status']) {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (BuildContext context) =>
                              new WriterArticleList()));
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
                                child : new Center(child:Text('You are not a Writer yet')),
                              ),
                            );
                          }
                      );
                    }
                  },
                  );
                }
            ),


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


        loading==true
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
            : new Container(
            color: new Color.fromRGBO(50, 48, 85, 1.0),
            alignment: Alignment.center,
            child: currentID==length
                ? new Text(
              'Nothing left to review',
              style: new TextStyle(fontSize: 30.0),
              textAlign: TextAlign.center,
            )
                : currentID==length-1
                ? new Stack(
                alignment: AlignmentDirectional.center,

                children:<Widget> [
                  new Dismissible(
                      key: Key(articlesmap['data'][currentID]['article_id'].toString()),
                      onDismissed: (direction) {
                        setState(() {
                          firstDescription = secondDescription;
                          firstTitle = secondTitle;
                          firstTag = secondTag;
                        });
                        if (direction == DismissDirection.startToEnd) {
                          print('swiped right');
                          setState(() {
                            currentID++;
                          });
                          Navigator.push(
                              context,
                              new MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                  new ArticleDetail(articlesmap['data'][currentID-1]['article_id'])));

                        }
                        else if (direction == DismissDirection.endToStart) {
                          print('swiped left');

                          setState(() {
                            currentID++;
                          });

                          Session s = new Session();

                          s.get(URL + '/VolunteerIgnoreArticle?article_id='+articlesmap['data'][currentID-1]['article_id'].toString()).then((response){
                            print(response);

                          });
                        }
                      },
                      child:
                      new Container(
                        decoration: new BoxDecoration(
                          color: Colors.lightGreen, shape: BoxShape.rectangle,borderRadius: new BorderRadius.all(new Radius.circular(32.0)),),
                        padding: const EdgeInsets.all(50.0),
                        margin: new EdgeInsets.all(30.0),
                        child: new ListView(children: <Widget>[Row(
                          children: [
                            Expanded(
                              child:
                              new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Text(
                                      firstTitle,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30.0,
                                      ),
                                    ),
                                  ),
                                  Container(
                                      padding: const EdgeInsets.only(top: 20.0),
                                      child: Text(
                                        firstTag,
                                        style: TextStyle(
                                          color: Colors.teal,
                                        ),
                                      )),
                                  Container(
                                    padding: const EdgeInsets.only(top: 35.0),
                                    child: Text(
                                      firstDescription,
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 20.0,
                                          fontFamily: 'RobotoMono'
                                      ),
                                    ),
                                  ),

                                  Container(
                                      padding: const EdgeInsets.only(top: 100.0),
                                      //margin : const EdgeInsets.only(bottom: 10.0),
                                      child: Text(
                                        'Publish Time',
                                        style: TextStyle(
                                          color: Colors.teal,
                                        ),
                                      )),

                                  Row(
                                    children: <Widget>[
                                      new Expanded(child: new Text(firstTime.substring(0, 2)+' ' + month[firstTime.substring(5,7)]+ ' ' + firstTime.substring(0,4), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal), textAlign: TextAlign.left)),
                                      new Expanded(child: new Text(parseTime(firstTime.substring(11,19)), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal), textAlign: TextAlign.right))
                                    ],
//                                  padding: const EdgeInsets.only(top: 20.0),
                                  ),

                                ],
                              ),
                            ),
                          ],
                        )]),
                      ))]
            )
                : new Stack(
                alignment: AlignmentDirectional.center,

                children:<Widget> [

                  new Container(
                    decoration: new BoxDecoration(
                      color: Colors.green, shape: BoxShape.rectangle,borderRadius: new BorderRadius.all(new Radius.circular(32.0)),),
                    padding: const EdgeInsets.all(50.0),
                    margin: new EdgeInsets.only(right: 45.0, left: 15.0, bottom: 45.0, top: 15.0),
                    child: new ListView(children: <Widget>[Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Text(
                                  secondTitle,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30.0,
                                  ),
                                ),
                              ),
                              Container(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: Text(
                                    secondTag,
                                    style: TextStyle(
                                      color: Colors.teal,
                                    ),
                                  )),
                              Container(
                                padding: const EdgeInsets.only(top: 35.0),
                                child: Text(
                                  secondDescription,
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 20.0,
                                      fontFamily: 'RobotoMono'
                                  ),
                                ),
                              ),

                              Container(
                                  padding: const EdgeInsets.only(top: 100.0),
                                  //margin : const EdgeInsets.only(bottom: 10.0),
                                  child: Text(
                                    'Publish Time',
                                    style: TextStyle(
                                      color: Colors.teal,
                                    ),
                                  )),

                              Row(
                                children: <Widget>[
                                  new Expanded(child: new Text(secondTime.substring(0, 2)+' ' + month[secondTime.substring(5,7)]+' ' + secondTime.substring(0,4), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal), textAlign: TextAlign.left)),
                                  new Expanded(child: new Text(parseTime(secondTime.substring(11,19)), style: TextStyle(fontWeight: FontWeight.bold,color: Colors.teal), textAlign: TextAlign.right))
                                ],
//                                  padding: const EdgeInsets.only(top: 20.0),
                              ),


                            ],
                          ),
                        ),
                      ],
                    )]),
                  ),
                  new Dismissible(
                      key: Key(articlesmap['data'][currentID]['article_id'].toString()),
                      onDismissed: (direction) {
                        setState(() {
                          firstDescription = secondDescription;
                          firstTitle = secondTitle;
                          firstTag = secondTag;
                          firstTime = secondTime;

                          if(currentID<length-2) {
                            int cid = currentID;

                            setState(() {
                              secondTitle = articlesmap['data'][cid + 2]['title'];
                              secondDescription = articlesmap['data'][cid + 2]['description'];
                              secondTag = '';
                              for(int i=0;i<articlesmap['tags'].length;i++){
                                if(articlesmap['tags'][i][2]==articlesmap['data'][cid + 2]['article_id']){
                                  if(secondTag=='') secondTag+=articlesmap['tags'][i][1].toString();
                                  else secondTag+=", "+articlesmap['tags'][i][1].toString();
                                }
                              }
                              secondTime = articlesmap['data'][cid + 2]['publish_time'];
                            });


//                            Session s = new Session();
//                            s.get(URL+'/'+ articlesmap['data'][cid + 2]['filepath'].toString()).then((result) {
//                              print(result);
//                              filemap = json.decode(result);
//                              setState(() {
//                                secondTitle = (filemap['title']);
//                                secondDescription = filemap['description'];
//                                secondTag = filemap['tags'].toString();
//                                secondTime =
//                                articlesmap['data'][cid + 2]['publish_time'];
//                              });
//                            });
                          }

                        });
                        if (direction == DismissDirection.startToEnd) {
                          print('swiped right');
                          setState(() {
                            currentID++;
                          });
                          Navigator.push(
                              context,
                              new MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                  new ArticleDetail(articlesmap['data'][currentID-1]['article_id'])));
                        }
                        else if (direction == DismissDirection.endToStart) {
                          print('swiped left');

                          setState(() {
                            currentID++;
                          });

                          Session s = new Session();

                          s.get(URL + '/VolunteerIgnoreArticle?article_id='+articlesmap['data'][currentID]['article_id'].toString()).then((response){
                            print(response);
                          });



                        }
                      },
                      child:
                      new Container(
                        decoration: new BoxDecoration(
                          color: Colors.lightGreen, shape: BoxShape.rectangle,borderRadius: new BorderRadius.all(new Radius.circular(32.0)),),
                        padding: const EdgeInsets.all(50.0),
                        margin: new EdgeInsets.all(30.0),

//                          borderRadius : new BorderRadius.all(new Radius.circular(32.0)),

                        child: new ListView(children: <Widget>[Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Text(
                                      firstTitle,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30.0,
                                      ),
                                    ),
                                  ),
                                  Container(
                                      padding: const EdgeInsets.only(top: 20.0),
                                      child: Text(
                                        firstTag,
                                        style: TextStyle(
                                          color: Colors.teal,
                                        ),
                                      )),
                                  Container(
                                    padding: const EdgeInsets.only(top: 35.0),
                                    child: Text(
                                      firstDescription,
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 20.0,
                                          fontFamily: 'RobotoMono'
                                      ),
                                    ),
                                  ),

                                  Container(
                                      padding: const EdgeInsets.only(top: 100.0),
                                      //margin : const EdgeInsets.only(bottom: 10.0),
                                      child: Text(
                                        'Publish Time',
                                        style: TextStyle(
                                          color: Colors.teal,
                                        ),
                                      )),

                                  Row(
                                    children: <Widget>[
                                      new Expanded(child: new Text(firstTime.substring(0, 2)+' ' + month[firstTime.substring(5,7)]+ ' ' + firstTime.substring(0,4), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal), textAlign: TextAlign.left)),
                                      new Expanded(child: new Text(parseTime(firstTime.substring(11,19)), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal), textAlign: TextAlign.right))
                                    ],
//                                  padding: const EdgeInsets.only(top: 20.0),
                                  ),

                                ],
                              ),
                            ),
                          ],
                        )]),
                      ))

                ]
            )
        ));

  }

}