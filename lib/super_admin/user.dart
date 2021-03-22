import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class User extends StatefulWidget {
  var data;
  User(d) {
    this.data = d;
  }
  @override
  _UserState createState() => _UserState(this.data);
}

class _UserState extends State<User> {
  var data;
  _UserState(d) {
    this.data = d;
    _getid();
  }
  _convertdate(d){
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
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
  _reject() async {
    print(docid);
    final databaseReference = FirebaseFirestore.instance;
    await databaseReference.collection("users").doc(docid).update({'status':'Rejected'}).then((value) {
      Navigator.pop(context,true);
    });

  }

  _accept() async {
    final databaseReference = FirebaseFirestore.instance;
    await databaseReference.collection("users").doc(docid).update({'status':'Accepted'}).then((value) {
      Navigator.pop(context,true);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Details"),
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
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          child: RoundedButton2(
                            text: "Accept",
                            state: false,
                            color: Colors.green,
                            press: () {
                              _accept();
                            },
                          ),
                        ),

                        Padding(padding: EdgeInsets.only(left: 8)),
                        Container(
                          child: RoundedButton2(
                            text: "Reject",
                            state: false,
                            color: Colors.red,
                            press: () {
                             _reject();
                            },
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20,),
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
                    "Hourly Rate",
                    style: TextStyle(color: Colors.teal, fontSize: 12.0),
                  ),
                  subtitle: Text(
                    data['hourlyrate'],
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
              ],
            ),

    );
  }
}

class RoundedButton2 extends StatelessWidget {
  final String text;
  final Function press;
  final Color color, textColor;
  final bool state;
  const RoundedButton2({
    Key key,
    this.text,
    this.state,
    this.press,
    this.color = Colors.teal,
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      width: size.width * 0.38,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: FlatButton(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
          color: color,
          onPressed: press,
          child: state
              ? CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          )
              : Text(
            text,
            style: TextStyle(color: textColor),
          ),
        ),
      ),
    );
  }
}

