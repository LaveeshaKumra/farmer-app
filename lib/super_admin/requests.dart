import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmers_app/super_admin/user.dart';
import 'package:flutter/material.dart';

class RequestsScreen extends StatefulWidget {
  @override
  _RequestsScreenState createState() => _RequestsScreenState();
}


class _RequestsScreenState extends State<RequestsScreen> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    Query  collectionStream = FirebaseFirestore.instance.collection("users").where('role',isEqualTo: 'admin').where('status',isEqualTo: 'Pending');
    return Scaffold(
        appBar: AppBar(
        title: Text("Admin Requests"),
    ),
    body:Center(
      child: StreamBuilder<QuerySnapshot>(
        stream: collectionStream.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
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
            );
          }
          if(snapshot.data.docs.length==0){
            return Center(
              child: Container(
                child: Image.asset("assets/nodata.png",width: 300,),
              ),
            );
          }
          return new ListView(
            children: snapshot.data.docs.map((DocumentSnapshot document) {
              return new Column(
                children: [
                  InkWell(
                    child: ListTile(
                      leading: Icon(Icons.person),
                      title: document.data()['username']==null?Text(''):Text(document.data()['username']),
                      subtitle: Text(document.data()['email']),
                      trailing: Text(document.data()['company']),
                    ),
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => User(document.data())),
                      );

                    },
                  ),Divider(height: 5,)
                ],
              );
            }).toList(),
          );
        },
      )
    ));
  }
}
