import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'leaveentilement2.dart';
class LeaveEntitlement extends StatefulWidget {
  var company;
  LeaveEntitlement(c){this.company=c;}
  @override
  _LeaveEntitlementState createState() => _LeaveEntitlementState(this.company);
}

class _LeaveEntitlementState extends State<LeaveEntitlement> {
  var company;
  _LeaveEntitlementState(c){this.company=c;}
  @override
  Widget build(BuildContext context) {
    Query collectionStream = FirebaseFirestore.instance
        .collection("users")
        .where('company', isEqualTo: company)
        .where('status', isEqualTo: 'Accepted').where('role',isEqualTo:'farmer');
    return Scaffold(
      appBar: AppBar(
        title: Text("All Workers"),

      ),
      body: StreamBuilder<QuerySnapshot>(
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
          if (snapshot.data.docs.length == 0) {
            return Center(
              child: Container(
                child: Image.asset(
                  "assets/nodata.png",
                  width: 300,
                ),
              ),
            );
          }
          return new ListView(
            children: snapshot.data.docs.map((DocumentSnapshot document) {
              return new Column(
                children: [
                  InkWell(
                    child: ListTile(
                      leading: document.data()['profile']==null || document.data()['profile']=="" ?Icon(Icons.person,size: 35,):Image.network(document.data()['profile'],width: 45,),
                      title: document.data()['username']==null?Text(''):Text(document.data()['username']),
                      subtitle: Text(document.data()['email']),
                    ),
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LeaveEntitlementUser(document.data()['email'],document.id)),
                      );
                    },
                  ),Divider(height: 5,)
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
