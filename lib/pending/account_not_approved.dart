import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmers_app/admin/adminhome.dart';
import 'package:farmers_app/login/login.dart';
import 'package:farmers_app/super_admin/super_admin_home.dart';
import 'package:farmers_app/user/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AccountNotApproved extends StatefulWidget {

  @override
  _AccountNotApprovedState createState() => _AccountNotApprovedState();
}

class _AccountNotApprovedState extends State<AccountNotApproved> {
  _AccountNotApprovedState(){
    _check();
  }
  var status,email;
  var firebase = FirebaseAuth.instance;
  void _check() async {
    var user = firebase.currentUser;

    if (user == null) {
      setState(() {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (BuildContext context) => LoginPage()));
      });
    } else {
      final databaseReference = FirebaseFirestore.instance;
     email=user.email;
      await databaseReference.collection("users").where(
          'email', isEqualTo: user.email).get().then((val) async {
        if (val.docs.isNotEmpty) {
          setState(() {
            status=val.docs[0]['status'];
          });
          print(val.docs[0]['username']);
          if (val.docs[0]['role'] == "admin") {
            if(val.docs[0]['status']=="Approved"){
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AdminPage()),
              );
            }

          } else if (val.docs[0]['role'] == "super_admin") {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (BuildContext context) => SuperAdminHome()));
          }
          else {
            if(val.docs[0]['status']=="Approved"){
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MyHomePage()),
              );
            }
          }
        }
      });
    }
  }
  _logout() async {
    await firebase.signOut().then((value) {
      var topic3 = firebase.currentUser.email.replaceAll('@', "");
      var topic4 = topic3.replaceAll('.', "");
      FirebaseMessaging.instance.unsubscribeFromTopic(topic4);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        //title:
        actions: [
        Container(
          child: FlatButton(
            splashColor: Colors.teal,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
        Text("Logout",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                  SizedBox(width: 5,),
                  Icon(
                    Icons.logout,color: Colors.black,
                  ),
                ],
              ),
            ),
            onPressed: (){_logout();},
          ),

        ),
        ],
        // actions[]: new
        elevation: 0,
      ),
      body:Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: [
            SizedBox(
              height: 50,
            ),

            status=="Pending"?
            Container(
              alignment: Alignment.center,
              child: Text(
                "Your Account is not yet Approved",
                style: TextStyle(fontSize: 25.9, fontWeight: FontWeight.bold,color: Colors.teal[900]),
                textAlign: TextAlign.center,
              ),
            ):Container(
              alignment: Alignment.center,
              child: Text(
                "Your Account has been Rejected",
                style: TextStyle(fontSize: 25.9, fontWeight: FontWeight.bold,color: Colors.teal[900]),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              alignment: Alignment.center,
              child: Text(
                "Contact Your Manager",
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold,color: Colors.teal),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Image.asset("assets/401.png"),
            SizedBox(
              height: 10,
            ),

          ],

        ),
      ),
    );
  }
}
