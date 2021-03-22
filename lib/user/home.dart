import 'package:farmers_app/login/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Farmer Home"),

    ),
      drawer: NavDrawer(),
    );
  }
}


class NavDrawer extends StatefulWidget {

  @override
  _NavDrawerState createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are you sure?'),
        content: new Text('Do you want to LogOut'),
        actions: <Widget>[
          new FlatButton(
            onPressed: (){
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

  var firebase = FirebaseAuth.instance;

  _logout() async {
    await firebase.signOut().then((value) => {

      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
          LoginPage()), (Route<dynamic> route) => false),

    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(
              'Side menu',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            decoration: BoxDecoration(
                color: Colors.green,
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('assets/nodata.png'))),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () => {},
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text('All Team members'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: Icon(Icons.grading_rounded),
            title: Text('All Tasks'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: Icon(Icons.person_add_alt_1),
            title: Text('Workers Request'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () => {Navigator.of(context).pop()},
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
