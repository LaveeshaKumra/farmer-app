import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'taskdetail.dart';

class HomePageAdmin extends StatefulWidget {
  var email,company;
  HomePageAdmin(e,c) {
    this.email = e;
    this.company=c;
  }
  @override
  _HomePageAdminState createState() => _HomePageAdminState(this.email,this.company);
}

class _HomePageAdminState extends State<HomePageAdmin> {
  var email,selected = "Today's Deadline";
  var options = [
    "Today's Deadline",
    "Upcoming Tasks",
    "Past Tasks",
    "All Tasks"
  ];

  var d1, d2,company;

  _HomePageAdminState(e,c) {
    this.company=c;
    this.email = e;
    var d=DateTime.now();
    d1=new DateTime(d.year,d.month,d.day,0,0,0,0,0);
    d2=new DateTime(d.year,d.month,d.day,23,59,59,0,0);
  }

  _convertdate(d) {
    final DateFormat formatter = DateFormat('dd MMMM , yy');
    final String formatted = formatter.format(d);
    return formatted;
  }


  @override
  Widget build(BuildContext context) {

    //upcoming
    Query collectionStream = FirebaseFirestore.instance
        .collection('tasks')
        .where("assigned_by", isEqualTo: email)
        .where('end_date', isGreaterThanOrEqualTo: DateTime.now());
    //past
    Query collectionStream2 = FirebaseFirestore.instance
        .collection('tasks')
        .where("assigned_by", isEqualTo: email)
        .where('end_date', isLessThan: d1)
        .orderBy('end_date', descending: true);
    //all
    Query collectionStream3 = FirebaseFirestore.instance
        .collection('tasks')
        .where("assigned_by", isEqualTo: email)
        .orderBy('start_date', descending: true);
    //todays
    Query collectionStream4 = FirebaseFirestore.instance
        .collection('tasks')
        .where("assigned_by", isEqualTo: email)
        .where('end_date',
        isGreaterThanOrEqualTo: d1,
        isLessThan: d2);
    //.orderBy('start_date', descending: true);

    return  Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          // shrinkWrap: true,
          children: [
            Container(
              //height: 100,
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.08,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.4,
                      child: DropdownButton(
                        isExpanded: true,
                        hint: Text('Tasks'),
                        value: selected,
                        items: options
                            .map(
                                (e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selected = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: selected == "Past Tasks"
                  ? StreamBuilder<QuerySnapshot>(
                stream: collectionStream2.snapshots(),
                //stream: bothStreams,
                builder: (context, snapshot) {
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
                                valueColor:
                                new AlwaysStoppedAnimation<Color>(
                                    Theme
                                        .of(context)
                                        .primaryColor)),
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
                  } else {
                    if(snapshot.data.docs.length==0){
                      return Center(
                        child: Container(
                          child: Image.asset("assets/nodata.png",width: 300,),
                        ),
                      );
                    }
                    return new ListView(
                      children: snapshot.data.docs
                          .map((DocumentSnapshot document) {

                        // return new ListTile(
                        //   title: new Text(document.data()['title']),
                        //   subtitle: new Text(document.data()['company']),
                        // );
                        return InkWell(
                          child: Card(
                            elevation: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Icon(Icons.grading_rounded),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Title: ${document.data()['title']}",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Icon(
                                            Icons.watch_later_outlined),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                            "${_convertdate(
                                                document.data()['start_date']
                                                    .toDate())} to ${_convertdate(
                                                document.data()['end_date']
                                                    .toDate())}",
                                            style: TextStyle(fontSize: 16)),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Icon(Icons.person),
                                      ),
                                      Padding(
                                          padding:
                                          const EdgeInsets.all(8.0),
                                          child: StreamBuilder<QuerySnapshot>(
                                            stream: FirebaseFirestore.instance.collection('users').where("email",isEqualTo: document
                                                .data()['assigned_to']).snapshots(),
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
                                                        width: 5,
                                                        height: 5,
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.only(top: 16.0),
                                                        child: Text("Loading.."),
                                                      )
                                                    ],
                                                  ),
                                                );
                                              }

                                              return Text(
                                                  "Assigned To : ${(snapshot.data.docs[0]
                                                      .data()['username'])}",
                                                  style:
                                                  TextStyle(fontSize: 16));
                                            },
                                          )
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: document.data()['status'] ==
                                            "Pending"
                                            ? Icon(
                                          Icons.error,
                                          color: Colors.red,
                                        )
                                            : document.data()['status'] ==
                                            "Done"
                                            ? Icon(
                                          Icons.done,
                                          color: Colors.green,
                                        )
                                            : Icon(
                                          Icons.warning,
                                          color: Colors.yellow,
                                        ),
                                      ),
                                      Padding(
                                          padding:
                                          const EdgeInsets.all(8.0),
                                          child: Text(
                                              "Status : ${(document
                                                  .data()['status'])}",
                                              style:
                                              TextStyle(fontSize: 16))),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                          onTap: () {
                            // Route route =MaterialPageRoute(builder: (context) => TaskDetailsInAdmin(d[index]));
                            // Navigator.push(context, route).then(_goback());
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      TaskDetailsInAdmin(document.data(),document.id)),
                            );
                          },
                        );
                      }).toList(),
                    );
                  }
                },
              )
                  : selected == "Upcoming Tasks"
                  ? StreamBuilder<QuerySnapshot>(
                stream: collectionStream.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            child: CircularProgressIndicator(
                                valueColor:
                                new AlwaysStoppedAnimation<Color>(
                                    Theme
                                        .of(context)
                                        .primaryColor)),
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
                  } else {
                    if(snapshot.data.docs.length==0){
                      return Center(
                        child: Container(
                          child: Image.asset("assets/nodata.png",width: 300,),
                        ),
                      );
                    }
                    return new ListView(
                      children: snapshot.data.docs
                          .map((DocumentSnapshot document) {
                        // return new ListTile(
                        //   title: new Text(document.data()['title']),
                        //   subtitle: new Text(document.data()['company']),
                        // );
                        return InkWell(
                          child: Card(
                            elevation: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding:
                                        const EdgeInsets.all(5.0),
                                        child:
                                        Icon(Icons.grading_rounded),
                                      ),
                                      Padding(
                                        padding:
                                        const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Title: ${document.data()['title']}",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight:
                                              FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding:
                                        const EdgeInsets.all(5.0),
                                        child: Icon(
                                            Icons.watch_later_outlined),
                                      ),
                                      Padding(
                                        padding:
                                        const EdgeInsets.all(8.0),
                                        child: Text(
                                            "${_convertdate(
                                                document.data()['start_date']
                                                    .toDate())} to ${_convertdate(
                                                document.data()['end_date']
                                                    .toDate())}",
                                            style: TextStyle(
                                                fontSize: 16)),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding:
                                        const EdgeInsets.all(5.0),
                                        child: Icon(Icons.person),
                                      ),
                                      Padding(
                                          padding:
                                          const EdgeInsets.all(8.0),
                                          child: StreamBuilder<QuerySnapshot>(
                                            stream: FirebaseFirestore.instance.collection('users').where("email",isEqualTo: document
                                                .data()['assigned_to']).snapshots(),
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
                                                        width: 5,
                                                        height: 5,
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.only(top: 16.0),
                                                        child: Text("Loading.."),
                                                      )
                                                    ],
                                                  ),
                                                );
                                              }

                                              return Text(
                                                  "Assigned To : ${(snapshot.data.docs[0]
                                                      .data()['username'])}",
                                                  style:
                                                  TextStyle(fontSize: 16));
                                            },
                                          )),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding:
                                        const EdgeInsets.all(5.0),
                                        child: document
                                            .data()['status'] ==
                                            "Pending"
                                            ? Icon(
                                          Icons.error,
                                          color: Colors.red,
                                        )
                                            : document.data()[
                                        'status'] ==
                                            "Done"
                                            ? Icon(
                                          Icons.done,
                                          color: Colors.green,
                                        )
                                            : Icon(
                                          Icons.warning,
                                          color:
                                          Colors.yellow,
                                        ),
                                      ),
                                      Padding(
                                          padding:
                                          const EdgeInsets.all(8.0),
                                          child: Text(
                                              "Status : ${(document
                                                  .data()['status'])}",
                                              style: TextStyle(
                                                  fontSize: 16))),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                          onTap: () {
                            // Route route =MaterialPageRoute(builder: (context) => TaskDetailsInAdmin(d[index]));
                            // Navigator.push(context, route).then(_goback());
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      TaskDetailsInAdmin(
                                          document.data(),document.id)),
                            );
                          },
                        );
                      }).toList(),
                    );
                  }
                },
              )
                  : selected == "All Tasks"
                  ? StreamBuilder<QuerySnapshot>(
                stream: collectionStream3.snapshots(),
                //stream: bothStreams,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment:
                        CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            child: CircularProgressIndicator(
                                valueColor:
                                new AlwaysStoppedAnimation<
                                    Color>(
                                    Theme
                                        .of(context)
                                        .primaryColor)),
                            width: 30,
                            height: 30,
                          ),
                          Padding(
                            padding:
                            const EdgeInsets.only(top: 16.0),
                            child: Text("Loading.."),
                          )
                        ],
                      ),
                    );
                  } else {
                    if(snapshot.data.docs.length==0){
                      return Center(
                        child: Container(
                          child: Image.asset("assets/nodata.png",width: 300,),
                        ),
                      );
                    }
                    return new ListView(
                      children: snapshot.data.docs
                          .map((DocumentSnapshot document) {
                        // return new ListTile(
                        //   title: new Text(document.data()['title']),
                        //   subtitle: new Text(document.data()['company']),
                        // );
                        return InkWell(
                          child: Card(
                            elevation: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding:
                                        const EdgeInsets.all(
                                            5.0),
                                        child: Icon(
                                            Icons.grading_rounded),
                                      ),
                                      Padding(
                                        padding:
                                        const EdgeInsets.all(
                                            8.0),
                                        child: Text(
                                          "Title: ${document.data()['title']}",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight:
                                              FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding:
                                        const EdgeInsets.all(
                                            5.0),
                                        child: Icon(Icons
                                            .watch_later_outlined),
                                      ),
                                      Padding(
                                        padding:
                                        const EdgeInsets.all(
                                            8.0),
                                        child: Text(
                                            "${_convertdate(
                                                document.data()['start_date']
                                                    .toDate())} to ${_convertdate(
                                                document.data()['end_date']
                                                    .toDate())}",
                                            style: TextStyle(
                                                fontSize: 16)),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding:
                                        const EdgeInsets.all(
                                            5.0),
                                        child: Icon(Icons.person),
                                      ),
                                      Padding(
                                          padding:
                                          const EdgeInsets.all(
                                              8.0),
                                          child: StreamBuilder<QuerySnapshot>(
                                            stream: FirebaseFirestore.instance.collection('users').where("email",isEqualTo: document
                                                .data()['assigned_to']).snapshots(),
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
                                                        width: 5,
                                                        height: 5,
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.only(top: 16.0),
                                                        child: Text("Loading.."),
                                                      )
                                                    ],
                                                  ),
                                                );
                                              }

                                              return Text(
                                                  "Assigned To : ${(snapshot.data.docs[0]
                                                      .data()['username'])}",
                                                  style:
                                                  TextStyle(fontSize: 16));
                                            },
                                          )),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding:
                                        const EdgeInsets.all(
                                            5.0),
                                        child: document.data()[
                                        'status'] ==
                                            "Pending"
                                            ? Icon(
                                          Icons.error,
                                          color: Colors.red,
                                        )
                                            : document.data()[
                                        'status'] ==
                                            "Done"
                                            ? Icon(
                                          Icons.done,
                                          color: Colors
                                              .green,
                                        )
                                            : Icon(
                                          Icons.warning,
                                          color: Colors
                                              .yellow,
                                        ),
                                      ),
                                      Padding(
                                          padding:
                                          const EdgeInsets.all(
                                              8.0),
                                          child: Text(
                                              "Status : ${(document
                                                  .data()['status'])}",
                                              style: TextStyle(
                                                  fontSize: 16))),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                          onTap: () {
                            // Route route =MaterialPageRoute(builder: (context) => TaskDetailsInAdmin(d[index]));
                            // Navigator.push(context, route).then(_goback());
                            print(document.data());
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      TaskDetailsInAdmin(
                                          document.data(),document.id)),
                            );
                          },
                        );
                      }).toList(),
                    );
                  }
                },
              )
                  : StreamBuilder<QuerySnapshot>(
                stream: collectionStream4.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment:
                        CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            child: CircularProgressIndicator(
                                valueColor:
                                new AlwaysStoppedAnimation<
                                    Color>(
                                    Theme
                                        .of(context)
                                        .primaryColor)),
                            width: 30,
                            height: 30,
                          ),
                          Padding(
                            padding:
                            const EdgeInsets.only(top: 16.0),
                            child: Text("Loading.."),
                          )
                        ],
                      ),
                    );
                  } else {
                    if(snapshot.data.docs.length==0){
                      return Center(
                        child: Container(
                          child: Image.asset("assets/nodata.png",width: 300,),
                        ),
                      );
                    }
                    return new ListView(
                      children: snapshot.data.docs
                          .map((DocumentSnapshot document) {
                        // return new ListTile(
                        //   title: new Text(document.data()['title']),
                        //   subtitle: new Text(document.data()['company']),
                        // );
                        return InkWell(
                          child: Card(
                            elevation: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding:
                                        const EdgeInsets.all(
                                            5.0),
                                        child: Icon(
                                            Icons.grading_rounded),
                                      ),
                                      Padding(
                                        padding:
                                        const EdgeInsets.all(
                                            8.0),
                                        child: Text(
                                          "Title: ${document.data()['title']}",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight:
                                              FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding:
                                        const EdgeInsets.all(
                                            5.0),
                                        child: Icon(Icons
                                            .watch_later_outlined),
                                      ),
                                      Padding(
                                        padding:
                                        const EdgeInsets.all(
                                            8.0),
                                        child: Text(
                                            "${_convertdate(
                                                document.data()['start_date']
                                                    .toDate())} to ${_convertdate(
                                                document.data()['end_date']
                                                    .toDate())}",
                                            style: TextStyle(
                                                fontSize: 16)),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding:
                                        const EdgeInsets.all(
                                            5.0),
                                        child: Icon(Icons.person),
                                      ),
                                      Padding(
                                          padding:
                                          const EdgeInsets.all(
                                              8.0),
                                          child: StreamBuilder<QuerySnapshot>(
                                            stream: FirebaseFirestore.instance.collection('users').where("email",isEqualTo: document
                                                .data()['assigned_to']).snapshots(),
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
                                                        width: 5,
                                                        height: 5,
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.only(top: 16.0),
                                                        child: Text("Loading.."),
                                                      )
                                                    ],
                                                  ),
                                                );
                                              }

                                              return Text(
                                                  "Assigned To : ${(snapshot.data.docs[0]
                                                      .data()['username'])}",
                                                  style:
                                                  TextStyle(fontSize: 16));
                                            },
                                          )),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding:
                                        const EdgeInsets.all(
                                            5.0),
                                        child: document.data()[
                                        'status'] ==
                                            "Pending"
                                            ? Icon(
                                          Icons.error,
                                          color: Colors.red,
                                        )
                                            : document.data()[
                                        'status'] ==
                                            "Done"
                                            ? Icon(
                                          Icons.done,
                                          color: Colors
                                              .green,
                                        )
                                            : Icon(
                                          Icons.warning,
                                          color: Colors
                                              .yellow,
                                        ),
                                      ),
                                      Padding(
                                          padding:
                                          const EdgeInsets.all(
                                              8.0),
                                          child: Text(
                                              "Status : ${(document
                                                  .data()['status'])}",
                                              style: TextStyle(
                                                  fontSize: 16))),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                          onTap: () {
                            // Route route =MaterialPageRoute(builder: (context) => TaskDetailsInAdmin(d[index]));
                            // Navigator.push(context, route).then(_goback());
                            print(document.data());
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      TaskDetailsInAdmin(
                                          document.data(),document.id)),
                            );
                          },
                        );
                      }).toList(),
                    );
                  }
                },
              ),
            ),
          ],
        ),

    );
  }
}