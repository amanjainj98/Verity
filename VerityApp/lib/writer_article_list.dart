import 'package:flutter/material.dart';
import 'dart:convert';
import 'session.dart';
import 'main.dart';
import 'writer_article_overview.dart';
import 'article_list.dart';
import 'writer_create_article.dart';

class WriterArticleList extends StatefulWidget {
  static String tag = 'Writer Articles';
  @override
  _WriterArticleListState createState() => new _WriterArticleListState();
}

class _WriterArticleListState extends State<WriterArticleList> {

  Map articlesmap;
  bool loading = true;
  int length = 0;
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
    s.get(URL+'/WriterAllArticles').then((response)
    {
      var decodedJSON = json.decode(response);
      print(response);
      setState(() {
        articlesmap = decodedJSON;
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
        automaticallyImplyLeading: false,
        title: const Text('Writer Articles'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.swap_vertical_circle),
              onPressed: () {
                Session s = new Session();

                s.get(URL + '/Switch?switchto=1').then((response) {
                  var decodedJSON = json.decode(response);
                  print(decodedJSON);
                  if (decodedJSON['status']) {
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (BuildContext context) =>
                            new ArticleList()));
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
                              child : new Center(child:Text('You are not a Volunteer yet')),
                            ),
                          );
                        }
                    );
                    //Scaffold.of(context).showSnackBar(SnackBar(content: Text('You are not a Vounteer yet')));
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
      Center(
          child: _buildSuggestions()
      ),
    );
  }


  Widget _buildSuggestions() {
    if(loading) {
      return new Center(
        child: new SizedBox(
          height: 50.0,
          width: 50.0,
          child: new CircularProgressIndicator(
            value: null,
            strokeWidth: 7.0,
          ),
        ),
      );

    }else if(articlesmap['data'].length==0) {
      print(articlesmap['data'].length);
      return
        new Stack(
            children: <Widget>[
              new  Center(
                child: new Text('No Article Submitted'),
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
                                new WriterCreateArticle()));
                      }
                  ))]);

    }
    else {
      return new Stack(
          children: <Widget>[new ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: articlesmap['data'].length,
              itemBuilder: (BuildContext _context, int i) {
                if(i < articlesmap['data'].length){
                  return new Column(
                      children: <Widget>[
                        new Divider(color: Colors.indigoAccent),
                        new ListTile(
                            title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  new Container(
                                      alignment: Alignment.centerLeft,
                                      child: new Text(
                                        articlesmap['data'][i]['title'],
                                      ))]),
                            subtitle: Row(
                              children: <Widget>[
                                new Expanded(child: Text(articlesmap['data'][i]['publish_time'].toString().substring(0, 2)+' ' + month[articlesmap['data'][i]['publish_time'].toString().substring(5,7)] + ' ' + articlesmap['data'][i]['publish_time'].toString().substring(0,4),textAlign: TextAlign.left)),
                                new Expanded(child: Text(parseTime(articlesmap['data'][i]['publish_time'].toString().substring(11,19)), textAlign: TextAlign.right)),
                              ],
                            ),
                            onTap: () {

                              Navigator.push(
                                  context,
                                  new MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                      new WriterArticleOverview(articlesmap['data'][i]['article_id'].toString())));
                              print("tapped");
                            }
                        ),
                        new Divider(color: Colors.indigoAccent)
                      ]);
                }
              }),
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
                            new WriterCreateArticle()));
                  }
              ))
          ]
      );
    }


  }

}