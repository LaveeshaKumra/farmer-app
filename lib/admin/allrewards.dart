import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'addreward.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';

class AllRewards extends StatefulWidget {
  var email,company;
  AllRewards(e,c) {
    this.email = e;
    this.company=c;

  }
  @override
  _RewardsState createState() => _RewardsState(this.email,    this.company );
}

class _RewardsState extends State<AllRewards> {
  var email, user,company;
  _RewardsState(e,c) {
    this.email = e;
    this.company=c;
  }
  _convertdate(d) {
    final DateFormat formatter = DateFormat('dd MMMM yy');
    final String formatted = formatter.format(d);
    return formatted;
  }
_Delete(id) async {
  final databaseReference = FirebaseFirestore.instance;
  await databaseReference.collection("rewards").doc(id).delete().then((value) {
    Navigator.pop(context,true);
  });
}
  Future<bool> rewardialog(title, from, date, type,id,reward) {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text(title),
            content: new Text(
                "Reward Type : $type\n\nReward : $reward\n\nSent To : $from\n\nDate : ${_convertdate(date.toDate())}"),
            actions: <Widget>[
              new FlatButton(
                onPressed: () {
                  print(id);
                  _Delete(id);
                },
                child: new Text('Delete',style: TextStyle(color: Colors.red),),
              ),
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
    return Center(
      child: Scaffold(
          appBar: AppBar(
            title: Text("Rewards"),
          ),
          floatingActionButton: FloatingActionButton.extended(
            icon:  Icon(Icons.add),
            label: Text("Add Rewards"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddReward(email,company)),
              );
            },
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("rewards")
                .where("from", isEqualTo: email)
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
                          subtitle: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection("users")
                                  .where("email", isEqualTo: document.data()['to'])
                                  .snapshots(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<QuerySnapshot> snap) {
                                if (snapshot.hasError || snap.data == null) {
                                  return Text(document.data()['to']);
                                } else {
                                  user = snap.data.docs[0].data()['username'];
                                  return Text(
                                      snap.data.docs[0].data()['username']);
                                }
                              }),
                          title: Text("${document.data()['name']}"),
                          //trailing: Text(document.data()['company']),
                        ),
                        onTap: () {
                          rewardialog(document.data()['name'], user,
                              document.data()['date'], document.data()['type'],document.id,document.data()['reward']);
                        },
                      ),
                    );
                  });
            },
          )),
    );
  }
}
