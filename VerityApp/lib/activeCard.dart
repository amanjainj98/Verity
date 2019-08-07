//import 'package:flutter/material.dart';
//import 'dart:convert';
//import 'session.dart';
//import 'main.dart';
//
//
//class ArticleList extends StatefulWidget {
//  static String tag = 'Articles';
//  @override
//  _ArticleListState createState() => new _ArticleListState();
//}
//
//class _ArticleListState extends State<ArticleList> {
//  Map dd;
//  String text = '';
//  bool loading = true;
//  int length = 0;
//  makeRequest() async {
//
//    Session s = new Session();
//    s.get(URL+'/VolunteerAllArticles').then((response)
//    {
//      var decodedJSON = json.decode(response);
//      print(response);
//      setState(() {
//
//        dd = decodedJSON;
//
//        loading = false;
//      });
//    });
//  }
//
//
//  @override
//  void initState() {
//    this.makeRequest();
//    super.initState();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return new Scaffold(
//        appBar: new AppBar(
//          title: const Text('Chats'),
//          actions: <Widget>[
//            // action button
//            IconButton(
//              icon: Icon(Icons.home),
//              onPressed: () {},
//            ),
//            IconButton(
//              icon: Icon(Icons.exit_to_app),
//              onPressed: () {
//                Session s = new Session();
//                s.get(URL + '/VolunteerLogout').then((response) {
//                  Navigator.push(
//                      context,
//                      new MaterialPageRoute(
//                          builder: (BuildContext context) =>
//                          new MyApp()));
//                });
//              },
//            ),
//          ],
//        ),
//        body: new Container(
//          color: new Color.fromRGBO(106, 94, 175, 1.0),
//          alignment: Alignment.center,
//          child: dd.length > 0
//              ? new Stack(
//              alignment: AlignmentDirectional.center,
//
//              children: dd['data'].map((item) {
////                if (dd['data'].indexOf(item) != dd.length - 1) {
//                return Dismissible(
//                    key: Key(item),
//                    onDismissed: (direction) {
//                      if (direction == DismissDirection.startToEnd) {
//                        print('swiped right');
//                      }
//                      else if (direction == DismissDirection.endToStart) {
//                        print('swiped left');
//                      }
//                    },
//                    child:
//                    new Container(
//                      width: 15.0,
//                      height: 15.0,
//                      margin: new EdgeInsets.only(bottom: 20.0),
//                      alignment: Alignment.center,
//                      child: new Text(
////                        dd['data'][item].toString(),
//                        'abcd',
//                        style: new TextStyle(fontSize: 10.0),
//                      ),
//                      decoration: new BoxDecoration(
//                          color: Colors.red, shape: BoxShape.circle),
//                    ));
////            } else {
////                  return Dismissible(
////                      key: Key(item),
////                      child:
////                        new Container(
////                            width: 15.0,
////                            height: 15.0,
////                            margin: new EdgeInsets.only(bottom: 20.0),
////                            alignment: Alignment.center,
////                            decoration: new BoxDecoration(
////                            color: Colors.red, shape: BoxShape.circle),
////                        ) );
////                }
//              }).toList())
//              : new Text("No Event Left",
//              style: new TextStyle(color: Colors.white, fontSize: 50.0)),
//        ));
//  }
//}