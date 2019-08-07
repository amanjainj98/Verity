import 'package:flutter/material.dart';
import 'dart:convert';
import 'session.dart';
import 'main.dart';

class VolunteerProfile extends StatefulWidget {
  static String tag = 'Articles';
  @override
  _VolunteerProfileState createState() => new _VolunteerProfileState();
}

class _VolunteerProfileState extends State<VolunteerProfile> {
  Map volunteerProfile;
  Map filemap;
  String text = '';
  bool loading = true;
  String name= '';
  double experience;
  double accuracy;

  makeRequest() async {
    Session s = new Session();
    print("Caflajflk sa");
    s.get(URL+'/VolunteerProfile').then((response)
    {
      print(response);
      var decodedJSON = json.decode(response);
      print(decodedJSON);
      setState(() {

        volunteerProfile = decodedJSON;
        name=volunteerProfile['data'][0]['name'];
        experience = volunteerProfile['ex_rating'];
        accuracy = volunteerProfile['acc_rating'];
        print("kuch bhi");
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
          title: const Text('Volunteer Profile'),
          actions: <Widget>[
            // action button
//            IconButton(
//              icon: Icon(Icons.home),
//              onPressed: () {},
//            ),

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
        body: loading==true
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
            padding: const EdgeInsets.all(15.0),
            margin: new EdgeInsets.all(15.0),
            child: new Column(
              children: <Widget>[
                new Container(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 20.0, left: 20.0, right: 20.0),
                  margin: new EdgeInsets.all(30.0),
                  decoration: new BoxDecoration(
                    color: Colors.green, shape: BoxShape.rectangle,borderRadius: new BorderRadius.all(new Radius.circular(32.0)),),
//                padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                ),
//              new Container(
//                child: new Row(
//                  crossAxisAlignment: CrossAxisAlignment.start,
//                  children: <Widget>[
//                    new Expanded(
//                        child: new Container(
//                          padding: const EdgeInsets.only(top: 15.0, bottom: 15.0, left: 15.0, right: 15.0),
//                          margin: new EdgeInsets.all(15.0),
//                          decoration: new BoxDecoration(
//                            color: Colors.indigoAccent, shape: BoxShape.rectangle,borderRadius: new BorderRadius.all(new Radius.circular(15.0))
//                          ),
//                          child: Text(
//                          "Rating: 7.0",
//                          style: TextStyle(
//                            fontWeight: FontWeight.bold,
//                            fontSize: 20.0,
//                          ),
//                            textAlign: TextAlign.center,
//                        ),
//
//                        )
//                    ),
//                    new Expanded(
//                        child: new Container(
//                          padding: const EdgeInsets.only(top: 15.0, bottom: 15.0, left: 15.0, right: 15.0),
//                          margin: new EdgeInsets.all(15.0),
//                          decoration: new BoxDecoration(
//                              color: Colors.indigoAccent, shape: BoxShape.rectangle,borderRadius: new BorderRadius.all(new Radius.circular(15.0))
//                          ),
//                          child: Text(
//                            "Reviews: 18",
//                            style: TextStyle(
//                              fontWeight: FontWeight.bold,
//                              fontSize: 20.0,
//                            ),
//                            textAlign: TextAlign.center,
//                          ),
//
//                        )
//                    ),
//                  ],
//                ),
//              ),
                Container(
                  child: new Text("Tags", textAlign: TextAlign.left),
                ),
                Expanded(
                    child: new Stack(
                        children: <Widget>[new ListView.builder(
                            padding: const EdgeInsets.all(5.0),

                            itemCount: volunteerProfile['tags'].length,
                            itemBuilder: (BuildContext _context, int i) {
                              if(i < volunteerProfile['tags'].length)
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
                                                    volunteerProfile['tags'][i]['tag_name'],
                                                  ))]),
                                        subtitle: Row(
                                          children: <Widget>[
                                            new Expanded(child: Text('Ex. Rating: '+volunteerProfile['tags'][i]['ex_rating'].toString(),textAlign: TextAlign.left)),
                                            new Expanded(child: Text('Acc. Rating: '+volunteerProfile['tags'][i]['acc_rating'].toString(),textAlign: TextAlign.right)),
                                          ],
                                        ),

                                        //                              new Text(volunteerProfile['tags'][i]['ex_rating'].toString()+' ' +volunteerProfile['tags'][i]['acc_rating'].toString()),
                                        onTap: () {}
                                    ),
                                    new Divider(color: Colors.indigoAccent),

                                  ],
                                );
                            })]))
              ],
            )
        ));

  }

}