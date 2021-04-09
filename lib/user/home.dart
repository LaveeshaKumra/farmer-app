import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmers_app/admin/profile.dart';
import 'package:farmers_app/login/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'alltasks.dart';
import 'farmerhome.dart';
import 'leavereq.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var image, company, email,name;
  _MyHomePageState() {
    _getUser();
  }
  var firebase = FirebaseAuth.instance;

  _getUser() async {
    var user = firebase.currentUser;
    final databaseReference = FirebaseFirestore.instance;
    await databaseReference
        .collection("users")
        .where('email', isEqualTo: user.email)
        .get()
        .then((val) async {
      setState(() {
        company = val.docs[0]['company'];
        email = val.docs[0]['email'];
        name=val.docs[0]['username'];
      });
      if (val.docs[0]['gender'] == "Male") {
        setState(() {
          image = "assets/male.png";
        });
      } else if (val.docs[0]['gender'] == "Female") {
        setState(() {
          image = "assets/female.png";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(image, company, email,name),
      appBar: AppBar(title: Text("Hello $name"),
      actions: [
        InkWell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.add_alert_rounded),
          ),
      )
        ],elevation: 0,),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (context) => AddTask(email, company)),
      //     );
      //   },
      //   child: Icon(Icons.add),
      //   elevation: 10,
      // ),
      body: HomePageFarmer(),

    );
  }
}

class NavDrawer extends StatefulWidget {
  var image, company, email,name;
  NavDrawer(i, c, e,n) {
    this.email = e;
    this.image = i;
    this.company = c;
    this.name=n;
  }

  @override
  _NavDrawerState createState() =>
      _NavDrawerState(this.email, this.image, this.company,this.name);
}

class _NavDrawerState extends State<NavDrawer> {
  var image, company, email,name;
  _NavDrawerState(e, i, c,n) {
    this.email = e;
    this.image = i;
    this.company = c;
    this.name=n;
  }
  var firebase = FirebaseAuth.instance;

  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are you sure?'),
        content: new Text('Do you want to LogOut'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: new Text('No'),
          ),
          new FlatButton(
            onPressed: () => _logout(),
            child: new Text('Yes'),
          ),
        ],
      ),
    ) ??
        false;
  }

  _logout() async {
    await firebase.signOut().then((value) => {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginPage()),
              (Route<dynamic> route) => false),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // padding: EdgeInsets.zero,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              child: DrawerHeader(
                child: Text(
                  '',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
                decoration: BoxDecoration(
                  //color: Colors.green,
                    image: DecorationImage(
                        fit: BoxFit.contain,
                        image: image == null
                            ? AssetImage('assets/others.png')
                            : AssetImage(image))),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage(email)),
                );
              },
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text('All Tasks'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AllTasks(email,company)),
              )
             },
          ),
          ListTile(
            leading: Icon(Icons.calendar_today_rounded),
            title: Text('Attendance'),
            onTap: () => {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //       builder: (context) => WorkerRequestsScreen(company)),
              // )
            },
          ),
          ListTile(
            leading: Icon(Icons.bar_chart),
            title: Text('Working Hours'),
            onTap: () => {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //       builder: (context) => WorkerRequestsScreen(company)),
              // )
            },
          ),
          ListTile(
            leading: Icon(Icons.access_time),
            title: Text('TimeOff Request'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PastReq(email,name,company)),
              )
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage(email)),
              )
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () => {_onBackPressed()},
          ),
        ],
      ),
    );
  }
}



