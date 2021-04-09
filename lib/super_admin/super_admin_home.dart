import 'package:farmers_app/login/login.dart';
import 'package:farmers_app/super_admin/requests.dart';
import 'package:farmers_app/super_admin/tasks.dart';
import 'package:farmers_app/super_admin/team.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class SuperAdminHome extends StatefulWidget {

  @override
  SuperAdminHomeState createState() => SuperAdminHomeState();
}

class SuperAdminHomeState extends State<SuperAdminHome> {
  PersistentTabController _controller=PersistentTabController(initialIndex: 0);



  List<Widget> _buildScreens() {
    return [
      TeamsScreen(),
      RequestsScreen(),
      AllTasks(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.people_alt),
        title: ("Teams"),
        activeColorPrimary: Colors.teal,
        activeColorSecondary: Colors.white,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),

      PersistentBottomNavBarItem(
        icon: Icon(Icons.person_add_rounded),
        title: ("Requests"),
        activeColorPrimary: Colors.teal,
        activeColorSecondary: Colors.white,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.grading_rounded),
        title: ("Tasks"),
        activeColorPrimary: Colors.teal,
        activeColorSecondary: Colors.white,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
    ];
  }

  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are you sure?'),
        content: new Text('Do you want to Log Out'),
        actions: <Widget>[
          new FlatButton(
            onPressed: (){ setState(() {
              _controller=PersistentTabController(initialIndex: 0);
            });},
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

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        actions: [
          InkWell(child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.logout),
          ),onTap: (){
            _onBackPressed();
          },),
        ],
      ),
      body: PersistentTabView(
        context,
        controller: _controller,
        screens: _buildScreens(),
        items: _navBarsItems(),
        navBarStyle: NavBarStyle.style7,
          confineInSafeArea: true,
          //backgroundColor: Colors.white,
          //handleAndroidBackButtonPress: true,
          resizeToAvoidBottomInset: true, // This needs to be true if you want to move up the screen when keyboard appears.
          stateManagement: true,
          hideNavigationBarWhenKeyboardShows: true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument.
          decoration: NavBarDecoration(
            borderRadius: BorderRadius.circular(10.0),
            colorBehindNavBar: Colors.white,
          ),
          popAllScreensOnTapOfSelectedTab: true,
          popActionScreens: PopActionScreensType.all,
          itemAnimationProperties: ItemAnimationProperties( // Navigation Bar's items animation properties.
          duration: Duration(milliseconds: 200),
      curve: Curves.ease,
      ),
      screenTransitionAnimation: ScreenTransitionAnimation( // Screen transition animation on change of selected tab.
      animateTabTransition: true,
      curve: Curves.ease,
      duration: Duration(milliseconds: 200),
      ),
      ),
    );
  }
}

