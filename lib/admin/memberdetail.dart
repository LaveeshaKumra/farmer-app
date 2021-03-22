import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MemberDetail extends StatefulWidget {
  var data;
  MemberDetail(d) {
    this.data = d;
  }
  @override
  _UserDetailState createState() => _UserDetailState(this.data);
}

class _UserDetailState extends State<MemberDetail> {
  var data;
  _UserDetailState(d) {
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
    await databaseReference.collection("users").where('email',isEqualTo: data['email']).get().then((value){setState(() {
      docid= value.docs[0].id;
    });});

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Details"),
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
              "Mobile no.",
              style: TextStyle(color: Colors.teal, fontSize: 12.0),
            ),
            subtitle: Text(
              data['mobileno'],
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
              "Role",
              style: TextStyle(color: Colors.teal, fontSize: 12.0),
            ),
            subtitle: Text(
              data['role'],
              style: TextStyle(fontSize: 18.0),
            ),
          ),
          Divider(),
          ListTile(
            title: Text(
              "Hourly Rate",
              style: TextStyle(color: Colors.teal, fontSize: 12.0),
            ),
            subtitle: Text(
              data['hourlyrate'],
              style: TextStyle(fontSize: 18.0),
            ),
          ),
          Divider(),
          ListTile(
            title: Text(
              "Gender",
              style: TextStyle(color: Colors.teal, fontSize: 12.0),
            ),
            subtitle: Text(
              data['gender'],
              style: TextStyle(fontSize: 18.0),
            ),
          ),
          Divider(),
          ListTile(
            title: Text(
              "Date of Birth",
              style: TextStyle(color: Colors.teal, fontSize: 12.0),
            ),
            subtitle: Text(
              _convertdate(data['dateofbirth'].toDate()),
              style: TextStyle(fontSize: 18.0),
            ),
          ),
          Divider(),
          ListTile(
            title: Text(
              "Address",
              style: TextStyle(color: Colors.teal, fontSize: 12.0),
            ),
            subtitle: Text(
              data['address'],
              style: TextStyle(fontSize: 18.0),
            ),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),

    );
  }
}
