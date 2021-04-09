import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'addtask.dart';

class TimeOffRequestPage extends StatefulWidget {
  var data;
  TimeOffRequestPage(d) {
    this.data = d;
  }
  @override
  _TimeOffRequestPageState createState() => _TimeOffRequestPageState(this.data);
}

class _TimeOffRequestPageState extends State<TimeOffRequestPage> {
  var data;
  _TimeOffRequestPageState(d) {
    this.data = d;
    _getid();
  }
  _convertdate(d){
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    final String formatted = formatter.format(d);
    return formatted;
  }
  var docid;
  _getid() async {
    final databaseReference = FirebaseFirestore.instance;
    await databaseReference.collection("timeoff").where('email',isEqualTo: data['email']).get().then((value){setState(() {
      docid= value.docs[0].id;
    });});

  }
  _reject() async {
    print(docid);
    final databaseReference = FirebaseFirestore.instance;
    await databaseReference.collection("timeoff").doc(docid).update({'status':'Rejected'}).then((value) {
      Navigator.pop(context,true);
    });

  }

  _accept() async {
    final databaseReference = FirebaseFirestore.instance;
    await databaseReference.collection("timeoff").doc(docid).update({'status':'Accepted'}).then((value) {
      Navigator.pop(context,true);
    });
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
              style: TextStyle(color: Colors.teal, fontSize: 12.0),
            ),
            subtitle: Text(
              data['username'],
              style: TextStyle(fontSize: 18.0),
            ),
          ),
          Divider(),
          ListTile(
            title: Text(
              "TimeOff Reason",
              style: TextStyle(color: Colors.teal, fontSize: 12.0),
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
              style: TextStyle(color: Colors.teal, fontSize: 12.0),
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
              style: TextStyle(color: Colors.teal, fontSize: 12.0),
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
              style: TextStyle(color: Colors.teal, fontSize: 12.0),
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
              style: TextStyle(color: Colors.teal, fontSize: 12.0),
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
              style: TextStyle(color: Colors.teal, fontSize: 12.0),
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