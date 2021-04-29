import 'package:farmers_app/pending/account_not_approved.dart';
import 'package:farmers_app/super_admin/super_admin_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'user/home.dart';
import 'login/login.dart';
import 'admin/adminhome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  _SplashState() {
    _getimg();
  }

  @override
  void initState() {
    super.initState();
    _function().then((status) {
      _navigatetohome();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _function() async {
    await Future.delayed(Duration(milliseconds: 5000), () {});
    return true;
  }

  final databaseReference = FirebaseFirestore.instance;
  var imagee;

  _getimg() async {
    await databaseReference
        .collection("splash_screen").get().then((querySnapshot) {
      setState(() {
        imagee = querySnapshot.docs[0]['url'];
      });
    });
    return imagee;
  }

  var firebase = FirebaseAuth.instance;

  void _navigatetohome() async {
    var user = firebase.currentUser;

    if (user == null) {
      setState(() {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (BuildContext context) => LoginPage()));
      });
    } else {
      final databaseReference = FirebaseFirestore.instance;
      await databaseReference.collection("users").where(
          'email', isEqualTo: user.email).get().then((val) async {
        if (val.docs.isNotEmpty) {
          if (val.docs[0]['role'] == "admin") {
            if(val.docs[0]['status']=="Accepted"){
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AdminPage()),
              );
            }
            else{
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AccountNotApproved()),
              );
            }

          } else if (val.docs[0]['role'] == "super_admin") {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (BuildContext context) => SuperAdminHome()));
          }
          else {
            if(val.docs[0]['status']=="Accepted"){
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MyHomePage()),
              );
            }
            else{
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AccountNotApproved()),
              );
            }
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var showData = snapshot.data;
                return Container(
                  alignment: Alignment.center,
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      //Text("Welcome to app")
                      showData == null && showData == "" ? Text(
                        "Welcome to Rompin",
                        style: TextStyle(fontSize: 28),) : Image.network(
                        showData,
                        width: 300,
                      ),
                    ],
                  ),
                );
              }
              else {
                return Container(
                  alignment: Alignment.center,
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text("Welcome to Rompin", style: TextStyle(fontSize: 28),)
                    ],
                  ),
                );
              }
            }, future: _getimg()
        ));
  }


}
