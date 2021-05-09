import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'calendar2.dart';
import 'dart:convert';
import 'package:http/http.dart';

class Attendance extends StatefulWidget {
  var email,company,name;
  Attendance(e,c,n) {
    this.email = e;
    this.company=c;
    this.name=n;
  }
  @override
  _AttendanceState createState() => _AttendanceState(this.email,this.company,this.name);
}

class _AttendanceState extends State<Attendance> {
  var email,company,name;
  var d1, d2,d, bol = 'none';
  _AttendanceState(e,c,n) {
    this.email = e;
    this.company=c;
    this.name=n;
     d = DateTime.now();
    d1 = new DateTime(d.year, d.month, d.day, 0, 0, 0, 0, 0);
    d2 = new DateTime(d.year, d.month, d.day, 23, 59, 59, 0, 0);
  }


  converttime(t) {
    TimeOfDay time=TimeOfDay(hour: t.hour,minute: t.minute);
    return time;
  }

  var serverToken="AAAAwaoyCQk:APA91bGBDoI9m0Ih3cEeEUVTMY6JtrV2xy2nKI88OcRXd6Pj3ee_4K0yM3ZVPoWOBUmiVg9p-jqwLStOkxS0Xmp8QCYaoGY7wWd-4qCgR0k35zoDV1dmOBq04YQQ-WdfLxJYV3UrQGBQ";
  _sendnotificationin() async {
    var topic='admin$company';
    var topic2=topic.replaceAll(' ', "");
    try {
      var url = Uri.parse('https://fcm.googleapis.com/fcm/send');
      var header = {
        "Content-Type": "application/json",
        "Authorization":
        "key=$serverToken",
      };
      var request = {
        "notification": {
          "title": "$name Clocks In",
          "body": 'At ${converttime(DateTime.now()).format(context)} ',
          "sound": "default",
          "tag":"New Updates from Rompin"
        },
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "screen": "",
        },
        "priority": "high",
        "to": '/topics/${topic2}',
      };
      var client = new Client();
      var response =
      await client.post(url, headers: header, body: json.encode(request));
      print(response.body);
      print(response.statusCode);
      return true;
    } catch (e, s) {
      print(e);
      return false;
    }
  }
  _sendnotificationout() async {
    var topic='admin$company';
    var topic2=topic.replaceAll(' ', "");
    try {
      var url = Uri.parse('https://fcm.googleapis.com/fcm/send');
      var header = {
        "Content-Type": "application/json",
        "Authorization":
        "key=$serverToken",
      };
      var request = {
        "notification": {
          "title": "$name Clocks Out",
          "body": 'At ${converttime(DateTime.now()).format(context)} ',
          "sound": "default",
          "tag":"New Updates from Rompin"
        },
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "screen": "",
        },
        "priority": "high",
        "to": '/topics/${topic2}',
      };
      var client = new Client();
      var response =
      await client.post(url, headers: header, body: json.encode(request));
      print(response.body);
      print(response.statusCode);
      return true;
    } catch (e, s) {
      print(e);
      return false;
    }
  }

  _updatein() async {
    final databaseReference = FirebaseFirestore.instance;
    var d=DateTime.now();
      await databaseReference
          .collection("attendance")
          .add({
        'email':email,
        'in_time': d,
        'out_time':"",
        'date':DateTime(d.year,d.month,d.day,0,0,0,0,0)
      }).then((value) {
        _sendnotificationin();
        Toast.show("In Time is ${converttime(d).format(context)}", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      });
  }

  _updateout(i) async{
     final databaseReference = FirebaseFirestore.instance;

      await databaseReference
          .collection("attendance")
          .doc(i)
          .update({
        'out_time': DateTime.now(),
      }).then((value) {
        _sendnotificationout();
        Toast.show("Out Time is ${converttime(DateTime.now()).format(context)}", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      });

  }


  @override
  Widget build(BuildContext context) {

    Query  collectionStream = FirebaseFirestore.instance.collection('attendance').where("email",isEqualTo: email).where('in_time', isGreaterThanOrEqualTo: d1).where('in_time',isLessThanOrEqualTo: d2).orderBy('in_time',descending: true);
    return Scaffold(
      appBar: AppBar(
        title: Text("Attendance"),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.calendar_today_rounded),
        elevation: 5,
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Calendar2()),
          );
        },
      ),
      body: ListView(
        shrinkWrap: true,
        children: [

          StreamBuilder<QuerySnapshot>(
            stream: collectionStream.snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {

              if (snapshot.hasError) {
                return Text('Something went wrong');
              }
              if (snapshot.connectionState == ConnectionState.waiting || snapshot.data==null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        child: CircularProgressIndicator(
                            valueColor: new AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor)),
                        width: 30,
                        height: 30,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text("Loading.."),
                      )
                    ],
                  ),
                );
              }
              if(snapshot.data.docs.length==0){
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                          child: Text(
                            "Please Mark Your Attendance for Today",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                          )),
                    ),
                    SizedBox(height: 100,),
                    ConstrainedBox(
                      constraints:
                      BoxConstraints.tightFor(width: 200, height: 200),
                      child: ElevatedButton(
                        child: Text(
                          'IN',
                          style: TextStyle(fontSize: 24),
                        ),
                        onPressed: () {
                          _updatein();
                        },
                        style: ElevatedButton.styleFrom(
                            shape: CircleBorder(), primary: Colors.green),
                      ),
                    ),
                  ],
                );
              }
              print(snapshot.data.docs[0].data());
              if(snapshot.data.docs[0].data()['out_time']=="" ) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                          child: Text(
                            "Please Mark Your Attendance for Today",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                          )),
                    ),
                    SizedBox(height: 100,),
                    ConstrainedBox(
                      constraints:
                      BoxConstraints.tightFor(width: 200, height: 200),
                      child: ElevatedButton(
                        child: Text(
                          'OUT',
                          style: TextStyle(fontSize: 24),
                        ),
                        onPressed: () {
                          _updateout(snapshot.data.docs[0].id);
                        },
                        style: ElevatedButton.styleFrom(
                            shape: CircleBorder(), primary: Colors.red),
                      ),
                    ),
                  ],
                );
              }
              else{
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                          child: Text(
                            "Please Mark Your Attendance for Today",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                          )),
                    ),
                    SizedBox(height: 100,),
                    ConstrainedBox(
                      constraints:
                      BoxConstraints.tightFor(width: 200, height: 200),
                      child: ElevatedButton(
                        child: Text(
                          'IN',
                          style: TextStyle(fontSize: 24),
                        ),
                        onPressed: () {
                          _updatein();
                        },
                        style: ElevatedButton.styleFrom(
                            shape: CircleBorder(), primary: Colors.green),
                      ),
                    ),
                  ],
                );
              }
              // else{
              //   if(snapshot.data.docs[0].data()['out_time']==null) {
              //     return Column(
              //       children: [
              //         Padding(
              //           padding: const EdgeInsets.all(20.0),
              //           child: Center(
              //               child: Text(
              //                 "Please Mark Your Attendance for Today",
              //                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              //               )),
              //         ),
              //         SizedBox(height: 100,),
              //         ConstrainedBox(
              //           constraints:
              //           BoxConstraints.tightFor(width: 200, height: 200),
              //           child: ElevatedButton(
              //             child: Text(
              //               'OUT',
              //               style: TextStyle(fontSize: 24),
              //             ),
              //             onPressed: () {
              //               _updateout();
              //             },
              //             style: ElevatedButton.styleFrom(
              //                 shape: CircleBorder(), primary: Colors.red),
              //           ),
              //         ),
              //       ],
              //     );
              //   }
              //   else{
              //     return Column(
              //       children: [
              //         SizedBox(height: 50,),
              //         Padding(
              //           padding: const EdgeInsets.all(8.0),
              //           child: Text("We Appreciate Your Work",style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),),
              //         ),
              //         Padding(
              //           padding: const EdgeInsets.all(8.0),
              //           child: Text("Sit Back and Relax, You Did a Great Job",style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
              //         ),
              //         SizedBox(height: 50,),
              //         Image.asset("assets/icons/relax.png",width: 200,),
              //         SizedBox(height: 50,),
              //
              //         Padding(
              //           padding: const EdgeInsets.all(8.0),
              //           child: Text("Your Today's IN Time was : ${converttime(snapshot.data.docs[0].data()['in_time'].toDate()).format(context)}",style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              //         ),
              //         Padding(
              //           padding: const EdgeInsets.all(8.0),
              //           child: Text("Your Today's OUT Time was : ${converttime(snapshot.data.docs[0].data()['out_time'].toDate()).format(context)}",style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              //         ),
              //         Padding(
              //           padding: const EdgeInsets.all(8.0),
              //           child: Text("Your Worked For ${snapshot.data.docs[0].data()['out_time'].toDate().difference(snapshot.data.docs[0].data()['in_time'].toDate()).inHours} hours today.",style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              //         )
              //       ],
              //     );
              //   }
              // }


               //return new Text("hey");
            },
          ),
          // bol == 'out'
          //     ? Container()
          //     : bol == 'none'
          //         ?
          //         : ConstrainedBox(
          //             constraints:
          //                 BoxConstraints.tightFor(width: 200, height: 200),
          //             child: ElevatedButton(
          //               style: ElevatedButton.styleFrom(
          //                   shape: CircleBorder(), primary: Colors.red),
          //               child: Text(
          //                 'OUT',
          //                 style: TextStyle(fontSize: 24),
          //               ),
          //               onPressed: () {},
          //             ),
          //           ),
        ],
      ),
    );
  }
}
