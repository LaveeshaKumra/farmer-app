import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmers_app/admin/profile.dart';
import 'package:farmers_app/admin/timeoff.dart';
import 'package:farmers_app/admin/workerRequest.dart';
import 'package:farmers_app/login/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'addtask.dart';
import 'allteam.dart';
import 'homepageadmin.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  var image, company, email;
  _AdminPageState() {
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
      drawer: NavDrawer(image, company, email),
      appBar: AppBar(title: Text("Farmer's Page")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTask(email, company)),
          );
        },
        child: Icon(Icons.add),
        elevation: 10,
      ),
      body: HomePageAdmin(email,company),
    );
  }
}

class NavDrawer extends StatefulWidget {
  var image, company, email;
  NavDrawer(i, c, e) {
    this.email = e;
    this.image = i;
    this.company = c;
  }

  @override
  _NavDrawerState createState() =>
      _NavDrawerState(this.email, this.image, this.company);
}

class _NavDrawerState extends State<NavDrawer> {
  var image, company, email;
  _NavDrawerState(e, i, c) {
    this.email = e;
    this.image = i;
    this.company = c;
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
            title: Text('All Team members'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AllUsersincompany(company)),
              )
            },
          ),
          // ListTile(
          //   leading: Icon(Icons.grading_rounded),
          //   title: Text('All Tasks'),
          //   onTap: () => {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //           builder: (context) =>
          //               AllTasksAssignedByUser(email, company)),
          //     )
          //   },
          // ),
          ListTile(
            leading: Icon(Icons.person_add_alt_1),
            title: Text('Workers Request'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => WorkerRequestsScreen(company)),
              )
            },
          ),
          ListTile(
            leading: Icon(Icons.access_time),
            title: Text('TimeOff Request'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TimeOff(company)),
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
