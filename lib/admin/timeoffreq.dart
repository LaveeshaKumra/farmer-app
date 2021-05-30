import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'addtask.dart';

class TimeOffRequestPage extends StatefulWidget {
  var data,id;
  TimeOffRequestPage(d,i) {
    this.data = d;
    this.id=i;
  }
  @override
  _TimeOffRequestPageState createState() => _TimeOffRequestPageState(this.data,this.id);
}

class _TimeOffRequestPageState extends State<TimeOffRequestPage> {
  var data,id,name;
  _TimeOffRequestPageState(d,i) {
    this.data = d;
    this.id=i;
  }


  _convertdate(d){
    final DateFormat formatter = DateFormat('dd MMMM yy');
    final String formatted = formatter.format(d);
    return formatted;
  }

  _reject() async {
    final databaseReference = FirebaseFirestore.instance;
    await databaseReference.collection("timeoff").doc(id).update({'status':'Rejected'}).then((value) {
      _sendnotification('Rejected');
      Navigator.pop(context,true);
    });

  }

  _accept() async {
    final databaseReference = FirebaseFirestore.instance;
    await databaseReference.collection("timeoff").doc(id).update({'status':'Accepted'}).then((value) {
      _sendnotification('Approved');
      Navigator.pop(context,true);
    });
  }

  var serverToken="AAAAwaoyCQk:APA91bGBDoI9m0Ih3cEeEUVTMY6JtrV2xy2nKI88OcRXd6Pj3ee_4K0yM3ZVPoWOBUmiVg9p-jqwLStOkxS0Xmp8QCYaoGY7wWd-4qCgR0k35zoDV1dmOBq04YQQ-WdfLxJYV3UrQGBQ";
  _sendnotification(status) async {
var topic3=data['email'].replaceAll('@',"");
      var topic4=topic3.replaceAll('.', "");
var user = FirebaseAuth.instance.currentUser;
final databaseReference = FirebaseFirestore.instance;
await databaseReference
    .collection("users")
    .where('email', isEqualTo: user.email)
    .get()
    .then((val) async {
  setState(() {
    name = val.docs[0]['username'];
  });
});
      print(name);
    try {
      var url = Uri.parse('https://fcm.googleapis.com/fcm/send');
      var header = {
        "Content-Type": "application/json",
        "Authorization":
        "key=$serverToken",
      };
      var request = {
        "notification": {
          "title": "Your Time Off Request has been $status by $name",
          "body": 'From ${_convertdate(data['start_date'].toDate())} to ${_convertdate(data['end_date'].toDate())}',
          "sound": "default",
          "tag":"New Updates from Rompin"
        },
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "screen": "TimeoffPage",
        },
        "priority": "high",
        "to": '/topics/${topic4}',
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Leave Details"),
      ),
      body: data == null || data == ""
          ? Center(
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
      )
          : ListView(
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: RoundedButton2(
                      text: "Accept",
                      state: false,
                      color: Colors.green,
                      press: () {
                        _accept();
                      },
                    ),
                  ),

                  Padding(padding: EdgeInsets.only(left: 8)),
                  Container(
                    child: RoundedButton2(
                      text: "Reject",
                      state: false,
                      color: Colors.red,
                      press: () {
                        _reject();
                      },
                    ),
                  ),

                ],
              ),
            ),
          ),
          SizedBox(height: 20,),
          ListTile(
            title: Text(
              "User Name",
              style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.0),
            ),
            subtitle: Text(
              data['username'],
              style: TextStyle(fontSize: 18.0),
            ),
          ),
          Divider(),
          ListTile(
            title: Text(
              "Leave Reason",
              style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.0),
            ),
            subtitle: Text(
              data['title'],
              style: TextStyle(fontSize: 18.0),
            ),
          ),
          data['description']==""?Container():Divider(),
          data['description']==""?Container():ListTile(
            title: Text(
              "Note",
              style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.0),
            ),
            subtitle: Text(
              data['description'],
              style: TextStyle(fontSize: 18.0),
            ),
          ),
          Divider(),
          ListTile(
            title: Text(
              "Email id",
              style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.0),
            ),
            subtitle: Text(
              data['email'],
              style: TextStyle(fontSize: 18.0),
            ),
          ),
          Divider(),
          ListTile(
            title: Text(
              "Company",
              style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.0),
            ),
            subtitle: Text(
              data['company'],
              style: TextStyle(fontSize: 18.0),
            ),
          ),
          Divider(),
          ListTile(
            title: Text(
              "From",
              style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.0),
            ),
            subtitle: Text(
              _convertdate(data['start_date'].toDate()),
              style: TextStyle(fontSize: 18.0),
            ),
          ),
          Divider(),
          ListTile(
            title: Text(
              "To",
              style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.0),
            ),
            subtitle: Text(
              _convertdate(data['end_date'].toDate()),
              style: TextStyle(fontSize: 18.0),
            ),
          ),
        ],
      ),

    );
  }
}