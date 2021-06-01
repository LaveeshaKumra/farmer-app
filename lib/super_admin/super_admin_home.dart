import 'package:farmers_app/super_admin/workerRequest.dart';
import 'package:farmers_app/login/login.dart';
import 'package:farmers_app/super_admin/requests.dart';
import 'package:farmers_app/super_admin/tasks.dart';
import 'package:farmers_app/super_admin/team.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boom_menu/flutter_boom_menu.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Theme.dart';

class SuperAdminHome extends StatefulWidget {

  @override
  SuperAdminHomeState createState() => SuperAdminHomeState();
}

class SuperAdminHomeState extends State<SuperAdminHome> {
  SuperAdminHome(){
    FirebaseMessaging.instance.subscribeToTopic('superadmin');
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
        case "AdminReq":
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RequestsScreen()),
          );
          break;

        default:
          break;
      }

    });

  }

  Future<bool> _onBackPressed2() {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are you sure?'),
        content: new Text('Do you want to exit'),
        actions: <Widget>[
          new FlatButton(
            onPressed: (){  Navigator.of(context).pop(false);},
            child: new Text('No'),
          ),
          new FlatButton(
            onPressed: (){ Navigator.of(context).pop(true);},
            child: new Text('Yes'),
          ),
        ],
      ),
    ) ??
        false;
  }



  var firebase = FirebaseAuth.instance;

  Future<bool> _onBackPressed(context) {
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
            onPressed: () => _logout(context),
            child: new Text('Yes'),
          ),
        ],
      ),
    ) ??
        false;
  }

  _logout(context) async {
    final themeNotifier = Provider.of<ThemeNotifier>(context,listen: false);

    await firebase.signOut().then((value) async {
      FirebaseMessaging.instance.unsubscribeFromTopic('superadmin');
      var prefs=await  SharedPreferences.getInstance();
      prefs.setString("theme", "tealTheme");
      themeNotifier.setTheme(tealTheme);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginPage()),
              (Route<dynamic> route) => false);
    });
  }
  @override
  Widget build(BuildContext context) {


    return WillPopScope(
      onWillPop: _onBackPressed2,
      child: Scaffold(

       floatingActionButton:BoomMenu(
         animatedIcon: AnimatedIcons.menu_close,
         animatedIconTheme: IconThemeData(size: 22.0),
         scrollVisible: true,
         overlayColor: Colors.black,
         overlayOpacity: 0.7,
         children: [
           MenuItem(
             child: Icon(Icons.people, color: Colors.black),
             title: "View Team Details",
             subtitle: "",
             onTap: () =>    Navigator.push(
               context,
               MaterialPageRoute(
                   builder: (context) => TeamsScreen()),
             )
           ),
           MenuItem(
             child: Icon(Icons.person_add_alt_1, color: Colors.black),
             title: "Farmer ID Request",
             subtitle: "",
             onTap: () =>   Navigator.push(
               context,
               MaterialPageRoute(builder: (context) => RequestsScreen()),
             )
           ),
           MenuItem(
               child: Icon(Icons.person_add_alt_1, color: Colors.black),
               title: "Worker ID Request",
               subtitle: "",
               onTap: () =>   Navigator.push(
                 context,
                 MaterialPageRoute(builder: (context) => WorkerRequestsScreen()),
               )
           ),
           MenuItem(
               child: Icon(Icons.logout, color: Colors.black),
               title: "Logout",
               subtitle: "",
               onTap: () =>   _onBackPressed(context)
           ),


         ],
       ),

        //drawer: NavDrawer(),
        appBar: AppBar(
          title: Text("All Tasks"),

        ),
        body: AllTasks(),
      ),
    );
  }
}


// class NavDrawer extends StatefulWidget {
//
//
//   @override
//   _NavDrawerState createState() =>
//       _NavDrawerState();
// }
// class _NavDrawerState extends State<NavDrawer> {
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: ListView(
//         // padding: EdgeInsets.zero,
//         children: <Widget>[
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: InkWell(
//               child: DrawerHeader(
//                 child: Text(
//                   '',
//                   style: TextStyle(color: Colors.white, fontSize: 25),
//                 ),
//                 decoration: BoxDecoration(
//                   //color: Colors.green,
//                     image: DecorationImage(
//                         fit: BoxFit.contain,
//                         image: AssetImage('assets/male.png')
//                             )),
//               ),
//               onTap: () {
//                 // Navigator.push(
//                 //   context,
//                 //   MaterialPageRoute(builder: (context) => ProfilePage(email)),
//                 // );
//               },
//             ),
//           ),
//           ListTile(
//             leading: Icon(Icons.calendar_today_rounded),
//             title: Text('All Tasks'),
//             onTap: () => {Navigator.of(context).pop()},
//           ),
//           ListTile(
//             leading: Icon(Icons.people),
//             title: Text('Team'),
//             onTap: () =>
//             {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) => TeamsScreen()),
//               )
//             },
//           ),
//
//
//           ListTile(
//             leading: Icon(Icons.person),
//             title: Text('Farmer\'s Requests'),
//             onTap: () =>
//             {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => RequestsScreen()),
//               )
//             },
//           ),
//           // ListTile(
//           //   leading: Icon(Icons.image),
//           //   title: Text('Change Image'),
//           //   onTap: () =>
//           //   {
//           //     // Navigator.push(
//           //     //   context,
//           //     //   MaterialPageRoute(builder: (context) => RequestsScreen()),
//           //     // )
//           //   },
//           // ),
//           ListTile(
//             leading: Icon(Icons.exit_to_app),
//             title: Text('Logout'),
//             onTap: () => {_onBackPressed()},
//           ),
//         ],
//       ),
//     );
//   }
// }