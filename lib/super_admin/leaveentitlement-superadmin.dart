import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmers_app/admin/view%20leaves.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class LeaveEntitlementUserSuperUser extends StatefulWidget {
  var email,docid;
  LeaveEntitlementUserSuperUser(e,id) {
    print(id);
    this.email = e;
    this.docid=id;
  }
  @override
  _LeaveEntilementUserState createState() =>
      _LeaveEntilementUserState(this.email,this.docid);
}

class _LeaveEntilementUserState extends State<LeaveEntitlementUserSuperUser> {

  var keys = [];
  var values = [];
  var email,docid;
  _LeaveEntilementUserState(e,id) {
    this.email = e;
    this.docid=id;
  }
  TextEditingController _controller=new TextEditingController();
  @override
  Widget build(BuildContext context) {
    Query collectionStream = FirebaseFirestore.instance
        .collection("users")
        .where('email', isEqualTo: email);

    return Scaffold(
      appBar: AppBar(
        title: Text("Leave Entitlement"),
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

          return new ListView(
            children: snapshot.data.docs.map((DocumentSnapshot document) {
              if (document.data()['leaveEnt'].length == 0) {
                return Center(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: Image.asset(
                      "assets/nodata.png",
                      width: 300,
                    ),
                  ),
                );
              } else {
                print(document.data()['leaveEnt']);
                keys=[];
                values=[];
                document.data()['leaveEnt'].forEach((ent, val) {
                  keys.add(ent);
                  values.add(val);
                });
              }
              return new Column(
                children: List.generate(keys.length, (index) {
                  return Card(
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(keys[index]),
                          subtitle: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection("timeoff")
                                  .where('email', isEqualTo: email)
                                  .where("status", isEqualTo: "Accepted")
                                  .where("leavetype", isEqualTo: keys[index])
                                  .snapshots(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<QuerySnapshot> snapshot2) {
                                if (snapshot.hasError) {
                                  return Text('Something went wrong');
                                }

                                if (snapshot2.connectionState ==
                                    ConnectionState.waiting) {
                                  return Text("...");
                                }

                                var leaves = snapshot2.data.docs.length;
                                if (leaves == 0) {
                                  return Text(
                                      "${values[index]} / ${values[index]} days leave remaining");
                                } else {
                                  var days, hours = 0;
                                  for (var i = 0; i < leaves; i++) {
                                    hours += snapshot2.data.docs[i]
                                        .data()['end_date']
                                        .toDate()
                                        .difference(snapshot2.data.docs[i]
                                        .data()['start_date']
                                        .toDate())
                                        .inHours;
                                  }
                                  days = hours / 24;
                                  return Text(
                                      "${int.parse(values[index]) - days.ceil()} / ${values[index]} days leave remaining");
                                }
                              }),
                          leading: InkWell(
                            child: Icon(
                              Icons.remove_red_eye,
                              color: Colors.green,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        UserLeaves(document.data()['email'],keys[index])),
                              );
                            },
                          ),
                          trailing: InkWell(
                            child: Icon(Icons.edit),
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //       builder: (context) =>
                              //           EditLeaveEntitlement(document.data()['email'],keys[index])),
                              // );
                              _dailog(values[index],keys[index]);
                            },
                          ),
                        )
                      ],
                    ),
                  );
                }),
              );
            }).toList(),
          );
        },
      ),
    );


  }
  Future<bool> _dailog(num,key) {
    _controller.text=num;
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Number of Leaves in $key'),
        content:new TextField(
            style: TextStyle(
                decoration: TextDecoration.none),
            maxLines: 1,
            autofocus: true,
            controller: _controller),
        actions: <Widget>[
          new FlatButton(
            onPressed: () {update(_controller.text,key);} ,
            child: new Text('Done'),
          ),
          new FlatButton(
            onPressed: () =>  Navigator.pop(context),
            child: new Text('Cancel'),
          ),
        ],
      ),
    ) ??
        false;
  }

  update(num,key) async {
    print(num);
    final databaseReference = FirebaseFirestore.instance;
    await databaseReference
        .collection("users")
        .doc(docid)
        .update({
      'leaveEnt': {key:num}
    }).then((value) {
      Toast.show("Leaves Updated", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      Navigator.pop(context);

    });

  }
}
