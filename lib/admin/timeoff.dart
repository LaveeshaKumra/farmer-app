import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmers_app/admin/timeoffreq.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class TimeOff extends StatefulWidget {
  var company;
  TimeOff(c){this.company=c;}
  @override
  _RequestsScreenState createState() => _RequestsScreenState(this.company);
}


class _RequestsScreenState extends State<TimeOff> {
  var company;
  _RequestsScreenState(c){this.company=c;}
  @override
  void initState() {
    super.initState();

  }
  _convertdate(d){
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    final String formatted = formatter.format(d);
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Leave Request"),

        ),
        body:
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection("timeoff").where('status',isEqualTo: 'Pending').where("company",isEqualTo: company).orderBy('start_date').snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                    subtitle: Text("From ${_convertdate(document.data()['start_date'].toDate())} to ${_convertdate(document.data()['end_date'].toDate())}"),
                    //trailing: Text(document.data()['company']),
                  ),
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TimeOffRequestPage(document.data(),document.id)),
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
