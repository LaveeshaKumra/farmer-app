import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmers_app/super_admin/user.dart';
import 'package:flutter/material.dart';

class WorkerRequestsScreen extends StatefulWidget {
  var company;
  WorkerRequestsScreen(c){this.company=c;}
  @override
  _RequestsScreenState createState() => _RequestsScreenState(this.company);
}


class _RequestsScreenState extends State<WorkerRequestsScreen> {
  var company;
  _RequestsScreenState(c){this.company=c;}
  Future myFuture;
  @override
  void initState() {
    super.initState();

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Worker ID Requests"),

        ),
        body:
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection("users").where('role',isEqualTo: 'farmer').where('status',isEqualTo: 'Pending').where("company",isEqualTo: company).snapshots(),
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
                return new InkWell(
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
                );
              }).toList(),
            );
          },
        )

    );
  }
}
