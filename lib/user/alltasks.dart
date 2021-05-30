import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';
import 'taskdetail.dart';
import 'package:http/http.dart';
import 'dart:convert';

class AllTasks extends StatefulWidget {
  var email,company;
  AllTasks(e,c){
    this.email=e;
    this.company=c;
    print(company);
    print(email);
  }
  @override
  _AllTasksState createState() => _AllTasksState(this.email,this.company);
}

class _AllTasksState extends State<AllTasks> {
  var email,company;
  _AllTasksState(e,c){
    this.email=e;
    this.company=c;
    print(company);
    print(email);
  }
  Future<bool> confirm(docid,status,tasktitle,company) {
    print(status);
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are You Sure , to set status as $status'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: new Text('No'),
          ),
          new FlatButton(
            onPressed: () {
              if(status=="Task Complete"){
                update(docid,"Done",tasktitle,company);
              }
              else if(status=="In Progress"){
                update(docid,"In Progress",tasktitle,company);
              }
            } ,
            child: new Text('Yes'),
          ),
        ],
      ),
    ) ??
        false;
  }


  Future<bool> _ifinprogress(docid,tasktitle,company) {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Set Task Status'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: new Text('Cancel'),
          ),
          new FlatButton(
            onPressed: ()  {confirm(docid, "Task Complete",tasktitle,company);},
            child: new Text('Task Completed'),
          ),
        ],
      ),
    ) ??
        false;
  }

  Future<bool> _ifinpending(docid,tasktitle,company) {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Set Task Status'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () {confirm(docid, "In Progress",tasktitle,company);} ,
            child: new Text('In Progress'),
          ),
          new FlatButton(
            onPressed: () => confirm(docid, "Task Complete",tasktitle,company),
            child: new Text('Task Completed'),
          ),
        ],
      ),
    ) ??
        false;
  }

  Future<bool> resetstatus(docid,tasktitle,company) {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are You Sure?'),
        content:new Text('Do You Want To Reset Status?') ,
        actions: <Widget>[
          new FlatButton(
            onPressed: () {update(docid,"Pending",tasktitle,company);} ,
            child: new Text('Yes'),
          ),
          new FlatButton(
            onPressed: () =>  Navigator.pop(context),
            child: new Text('No'),
          ),
        ],
      ),
    ) ??
        false;
  }
  update(docid,status,tasktitle,company) async {

    final databaseReference = FirebaseFirestore.instance;

    await databaseReference
        .collection("tasks")
        .doc(docid)
        .update({
      'status':status
    }).then((value) {
      _sendnotification(tasktitle,company);
      Toast.show("Status Updated", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      Navigator.pop(context);
      if(status=="Pending"){

      }
      else{
        Navigator.pop(context);
      }
    });

  }
  var serverToken="AAAAwaoyCQk:APA91bGBDoI9m0Ih3cEeEUVTMY6JtrV2xy2nKI88OcRXd6Pj3ee_4K0yM3ZVPoWOBUmiVg9p-jqwLStOkxS0Xmp8QCYaoGY7wWd-4qCgR0k35zoDV1dmOBq04YQQ-WdfLxJYV3UrQGBQ";
  _sendnotification(tasktitle,company) async {
    var topic='admin$company';
    var topic2=topic.replaceAll(' ', "");
    try {
      var url = Uri.parse('https://fcm.googleapis.com/fcm/send');
      var header = {
        "Content-Type": "application/json",
        "Authorization":
        "key=$serverToken",
      };
      var request = {
        "notification": {
          "title": "Task Status is Updated",
          "body": tasktitle,
          "sound": "default",
          "tag":"New Updates from Rompin"
        },
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "screen":"AllTasksAdmin",
        },
        "priority": "high",
        "to": '/topics/$topic2',
      };
      var client = new Client();
      var response =
      await client.post(url, headers: header, body: json.encode(request));
      print(response.body);
      print(response.statusCode);
      return true;
    } catch (e, s) {
      print(e);
      return false;
    }
  }

  String returnMonth(DateTime date) {
    return new DateFormat.MMMM().format(date);
  }
  @override
  Widget build(BuildContext context) {
    Query collectionStream = FirebaseFirestore.instance
        .collection("tasks")
        .where('company', isEqualTo: company)
         .where('assigned_to', isEqualTo: email);
    return Scaffold(
      appBar: AppBar(
        title: Text("All Tasks"),
        // actions: [
        //   InkWell(
        //     child: Padding(
        //       padding: const EdgeInsets.all(10.0),
        //       child: Icon(Icons.calendar_today),
        //     ),
        //     onTap: (){
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(builder: (context) => TaskCalendar()),
        //       );
        //     },
        //   )
        // ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: collectionStream.snapshots(),
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
          return GroupedListView(
              elements: snapshot.data.docs,
              groupBy: (element) => element['start_date'].toDate().month,
              groupHeaderBuilder: (element) =>
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(child: Text(returnMonth(element['start_date'].toDate()),style: TextStyle(fontWeight: FontWeight.w400,fontSize: 18,color: Theme.of(context).primaryColor),)),
                  ),
              indexedItemBuilder: (context, snapshot, int index) {
                return  Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    child: ListTile(
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.assignment,size: 20,),
                          Text(snapshot.data()['status'])
                        ],
                      ),
                      title: snapshot.data()['title']==null?Text(''):Text(snapshot.data()['title'],maxLines: 1,),
                      subtitle: Text(snapshot.data()['description'],maxLines: 2,),
                      //trailing: Text(snapshot.data()['status']),
                      trailing: snapshot.data()['status']!="Done"?FlatButton.icon(onPressed:(){
                        if(snapshot.data()['status']=="Pending") _ifinpending(snapshot.id,snapshot.data()['title'],snapshot.data()['company']);
                        else _ifinprogress(snapshot.id,snapshot.data()['title'],snapshot.data()['company']);
                      }, icon: Icon(Icons.priority_high_rounded), label: Text("Set Status"),color: Colors.grey[200],):FlatButton.icon(onPressed:(){}, icon: Icon(Icons.done), label: Text(snapshot.data()['status']),color: Colors.green[200],),
                    ),
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TaskDetailsInfarmer(snapshot.data(),snapshot.id)),
                      );
                    },
                  ),
                );
              });

        },
      ),);
  }
}
