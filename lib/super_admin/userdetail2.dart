import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserDetail2 extends StatefulWidget {
  var data;
  UserDetail2(d) {
    this.data = d;
  }
  @override
  _UserDetailState2 createState() => _UserDetailState2(this.data);
}

class _UserDetailState2 extends State<UserDetail2> {
  var data;
  _UserDetailState2(d) {
    this.data = d;
  }
  _convertdate(d){
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    final String formatted = formatter.format(d);
    return formatted;
  }
  _getuserdetails() async {
    var val;
    final databaseReference = FirebaseFirestore.instance;
    await databaseReference.collection("users").where('email',isEqualTo: data).get().then(
            (value) {val = value;
        });
    return val;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Details"),
      ),
        body:Center(
          child: FutureBuilder(
            builder: (context, projectSnap) {
              print(projectSnap.data);
              if (projectSnap.hasData) {
                var d = projectSnap.data.docs[0];
                if(d!=null){

                  return ListView(
                    children: <Widget>[

                      SizedBox(height: 20,),
                      ListTile(
                        title: Text(
                          "User Name",
                          style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.0),
                        ),
                        subtitle: Text(
                          d['username'],
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                      Divider(),
                      ListTile(
                        title: Text(
                          "Email id",
                          style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.0),
                        ),
                        subtitle: Text(
                          d['email'],
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                      Divider(),
                      ListTile(
                        title: Text(
                          "Mobile no.",
                          style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.0),
                        ),
                        subtitle: Text(
                          d['mobileno'],
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                      Divider(),
                      ListTile(
                        title: Text(
                          "Company",
                          style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.0),
                        ),
                        subtitle: Text(
                          d['company'],
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                      Divider(),
                      ListTile(
                          title: Text(
                            "Role",
                            style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.0),
                          ),
                          subtitle: d['role']=="admin"?Text(
                            "Farmer",

                            style: TextStyle(fontSize: 18.0),
                          ):Text(
                            "Worker",

                            style: TextStyle(fontSize: 18.0),
                          )
                      ),

                      Divider(),
                      ListTile(
                        title: Text(
                          "Gender",
                          style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.0),
                        ),
                        subtitle: Text(
                          d['gender'],
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                      Divider(),
                      ListTile(
                        title: Text(
                          "Date of Birth",
                          style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.0),
                        ),
                        subtitle: Text(
                          _convertdate(d['dateofbirth'].toDate()),
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                      Divider(),
                      ListTile(
                        title: Text(
                          "Address",
                          style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.0),
                        ),
                        subtitle: Text(
                          d['address'],
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  );
                }
                else{
                  return Container(
                    child: Image.asset("assets/nodata.png",width: 300,),
                  );
                }
              } else {
                return Column(
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
                );
              }
            },
            future: _getuserdetails(),
          ),
        ));
  }
}
