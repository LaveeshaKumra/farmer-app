import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmers_app/user/requestdetail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';

class Rewards extends StatefulWidget {
  var email;
  Rewards(e) {
    this.email = e;
  }
  @override
  _RewardsState createState() => _RewardsState(this.email);
}

class _RewardsState extends State<Rewards> {
  var email, user;
  _RewardsState(e) {
    this.email = e;
  }
  _convertdate(d) {
    final DateFormat formatter = DateFormat('dd MMMM yy');
    final String formatted = formatter.format(d);
    return formatted;
  }

  Future<bool> rewardialog(title, from, date, type,reward) {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text(title),
            content: new Text(
                "Reward Type : $type\n\nReward : $reward\n\nSent by : $from\n\nDate : ${_convertdate(date.toDate())}"),
            actions: <Widget>[
              new FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: new Text('OK'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Rewards"),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("rewards")
              .where("to", isEqualTo: FirebaseAuth.instance.currentUser.email)
              .orderBy('date', descending: true)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Something went wrong'));
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
            return GroupedListView(
                elements: snapshot.data.docs,
                groupBy: (element) => _convertdate(element['date'].toDate()),
                groupHeaderBuilder: (element) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                          child: Text(
                        _convertdate(element['date'].toDate()),
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 18,
                            color: Theme.of(context).primaryColor),
                      )),
                    ),
                indexedItemBuilder: (context, document, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      child: ListTile(
                        leading: document.data()['type'] == "Money"
                            ? Icon(Icons.monetization_on_outlined)
                            : Icon(Icons.wallet_giftcard_sharp),
                        //trailing: Text("${_convertdate(document.data()['date'].toDate())}"),
                        trailing: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection("users")
                                .where("email", isEqualTo: document.data()['from'])
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snap) {
                              if (snapshot.hasError || snap.data == null) {
                                return Text(document.data()['from']);
                              } else {
                                user = snap.data.docs[0].data()['username'];
                                return Text(
                                    snap.data.docs[0].data()['username']);
                              }
                            }),
                        title: Text("${document.data()['name']}"),
                        subtitle: Text("${document.data()['reward']}"),
                        //trailing: Text(document.data()['company']),
                      ),
                      onTap: () {
                        rewardialog(document.data()['name'], user,
                            document.data()['date'], document.data()['type'],document.data()['reward']);
                      },
                    ),
                  );
                });
          },
        ));
  }
}
