import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmers_app/admin/leaveentitlement.dart';
import 'package:farmers_app/admin/profile.dart';
import 'package:farmers_app/admin/timeoff.dart';
import 'package:farmers_app/admin/workerRequest.dart';
import 'package:farmers_app/login/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'addtask.dart';
import 'allteam.dart';
import 'homepageadmin.dart';
import 'allrewards.dart';
import 'myprofile.dart';
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
      var topic='admin$company';
      var topic2=topic.replaceAll(' ', "");
      var topic3=email.replaceAll('@',"");
      var topic4=topic3.replaceAll('.', "");
      print(topic2);
      print(topic4);
      FirebaseMessaging.instance.subscribeToTopic(topic2);
      FirebaseMessaging.instance.subscribeToTopic(topic4);
    });
  }

  void initState() {

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: ListTile(
                title: Text(message.notification.title),
                subtitle: Text(message.notification.body),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Ok'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          );
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print(message.data['screen']);
      print('A new onMessageOpenedApp event was published!');
      switch (message.data['screen']) {
        case "TimeoffAdmin":
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TimeOff(company)),
          );
          break;
        case "AllTasksAdmin":

          break;
        case "NewRegister":
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WorkerRequestsScreen(company)),
          );
          break;
        case "login":
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
          break;
        default:
          break;
      }

      // Navigator.pushNamed(context, '/message',
      //     arguments: MessageArguments(message, true));
    });
    // _fcm.configure(
    //   onMessage: (Map<String, dynamic> message) async {
    //     print("onMessage: $message");
    //     showDialog(
    //       context: context,
    //       builder: (context) => AlertDialog(
    //         content: ListTile(
    //           title: Text(message['notification']['title']),
    //           subtitle: Text(message['notification']['body']),
    //         ),
    //         actions: <Widget>[
    //           FlatButton(
    //             child: Text('Ok'),
    //             onPressed: () => Navigator.of(context).pop(),
    //           ),
    //         ],
    //       ),
    //     );
    //   },
    //   onLaunch: (Map<String, dynamic> message) async {
    //     print("onLaunch: $message");
    //     // TODO optional
    //   },
    //   onResume: (Map<String, dynamic> msg) async {
    //     switch (msg['data']['screen']) {
    //       case "OPEN_HOMEWORK_PAGE":
    //         Navigator.push(
    //           context,
    //           MaterialPageRoute(builder: (context) => CalPage(clas, branch)),
    //         );
    //         break;
    //       case "OPEN_UPDATE_PAGE":
    //         Navigator.push(
    //           context,
    //           MaterialPageRoute(builder: (context) => Updates()),
    //         );
    //         break;
    //       default:
    //         break;
    //     }
    //   },
    // );
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
    await firebase.signOut().then((value)  {
      var topic='admin$company';
      var topic2=topic.replaceAll(' ', "");
      var topic3=email.replaceAll('@',"");
      var topic4=topic3.replaceAll('.', "");
      print(topic2);
      FirebaseMessaging.instance.unsubscribeFromTopic(topic2);
      FirebaseMessaging.instance.unsubscribeFromTopic(topic4);
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => LoginPage()),
              (Route<dynamic> route) => false);
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
                  MaterialPageRoute(builder: (context) => MyProfilePage(email)),
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
            title: Text('Leave Entitlement'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => LeaveEntitlement(company)),
              )
            },
          ),
          ListTile(
            leading: Icon(Icons.work_off_outlined),
            title: Text('Leave Requests'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TimeOff(company)),
              )
            },
          ),
          ListTile(
            leading: Icon(Icons.card_giftcard_sharp),
            title: Text('Rewards'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AllRewards(email)),
              )
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyProfilePage(email)),
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
