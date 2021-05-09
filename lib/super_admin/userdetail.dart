import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmers_app/admin/addreward.dart';
import 'package:farmers_app/admin/calendar.dart';
import 'package:farmers_app/admin/chart.dart';
import 'package:farmers_app/admin/leaveentilement2.dart';
import 'package:farmers_app/admin/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boom_menu/flutter_boom_menu.dart';
import 'package:intl/intl.dart';

class UserDetail extends StatefulWidget {
  var data;
  UserDetail(d) {
    this.data = d;
  }
  @override
  _UserDetailState createState() => _UserDetailState(this.data);
}

class _UserDetailState extends State<UserDetail> {
  var data;
  _UserDetailState(d) {
    this.data = d;
    _getid();
  }
  _convertdate(d){
    final DateFormat formatter = DateFormat('dd MMMM yy');
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
        actions: [
          data['role']=='admin'?Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(child: Icon(Icons.edit),onTap: (){
              print(data['email']);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfilePage(data['email'])),
              );
            },),
          ):Container()
        ],
      ),

      floatingActionButton: data['role']=='admin'?Container():BoomMenu(
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 22.0),
        //child: Icon(Icons.add),
        onOpen: () => print('OPENING DIAL'),
        onClose: () => print('DIAL CLOSED'),
        scrollVisible: true,
        overlayColor: Colors.black,
        overlayOpacity: 0.7,
        children: [
          MenuItem(
            child: Icon(Icons.edit, color: Colors.black),
            title: "Edit Profile",
            titleColor: Colors.white,
            subtitle: "You Can Edit Worker's Details",
            subTitleColor: Colors.white,
            backgroundColor: Colors.deepOrange,
            onTap: () =>  Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => ProfilePage(data['email'])),
            ),
          ),
      //     MenuItem(
      //       child: Icon(Icons.calendar_today, color: Colors.black),
      //       title: "Calendar",
      //       titleColor: Colors.white,
      //       subtitle: "Check Worker's Calender",
      //       subTitleColor: Colors.white,
      //       backgroundColor: Colors.green,
      //       onTap: () =>  Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //             builder: (context) => Calendar(data['email'])),
      //       ),
      //     ),
      //     MenuItem(
      //       child: Icon(Icons.bar_chart, color: Colors.black),
      //       title: "Report",
      //       titleColor: Colors.white,
      //       subtitle: "Check Working Hours Report",
      //       subTitleColor: Colors.white,
      //       backgroundColor: Colors.blue,
      //       onTap: () =>  Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //             builder: (context) => UserReportChart(data['email'])),
      //       ),
      //     ),
      //     MenuItem(
      //       child: Icon(Icons.access_time, color: Colors.black),
      //       title: "Leaves Entitlement",
      //       titleColor: Colors.white,
      //       subtitle: "View All Leaves Entitlement",
      //       subTitleColor: Colors.white,
      //       backgroundColor: Colors.redAccent,
      //       onTap: () =>  Navigator.push(
      //         context,
      //         MaterialPageRoute(builder: (context) => LeaveEntitlementUser(data['email'],docid)),
      //       ),
      //     ),
      //     MenuItem(
      //       child: Icon(Icons.card_giftcard, color: Colors.black),
      //       title: "Rewards",
      //       titleColor: Colors.white,
      //       subtitle: "Send Reward",
      //       subTitleColor: Colors.white,
      //       backgroundColor: Colors.deepPurpleAccent,
      //       onTap: () =>  Navigator.push(
      //         context,
      //         MaterialPageRoute(builder: (context) => AddReward(data['email'])),
      //       ),
      //     )
        ],
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
