import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'calendar2.dart';
import 'requestdetail.dart';
import 'newreq.dart';
import 'package:intl/intl.dart';

class PastReq extends StatefulWidget {
  var email,company,name;
  PastReq(e,n,c){this.email=e;this.name=n;this.company=c;}
  @override
  _PastReqState createState() => _PastReqState(this.email,this.name,this.company);
}

class _PastReqState extends State<PastReq> {
  var email,company,name;
  _PastReqState(e,n,c){this.email=e;this.name=n;this.company=c;}
  _convertdate(d){
    final DateFormat formatter = DateFormat('dd MMMM yy');
    final String formatted = formatter.format(d);
    return formatted;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Leave Request"),
        actions: [
          GestureDetector(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.calendar_today_rounded),
            ),
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Calendar2()),
              );
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 5,
        child: Icon(Icons.add),
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddReq(this.email,name,company)),
          );
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("timeoff").where("email",isEqualTo: email).orderBy('start_date',descending: true).snapshots(),
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
                  leading: Icon(Icons.work_off),
                  trailing: document.data()['status']=="Pending"?Icon(Icons.warning,color: Colors.yellow,):document.data()['status']=="Rejected"?Icon(Icons.cancel_rounded,color: Colors.red,):Icon(Icons.check_circle,color: Colors.green,),
                  title: document.data()['title']==null?Text(''):Text(document.data()['title']),
                  subtitle: Text("From ${_convertdate(document.data()['start_date'].toDate())} to ${_convertdate(document.data()['end_date'].toDate())}"),
                  //trailing: Text(document.data()['company']),
                ),
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RequestDetail(document.data())),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
