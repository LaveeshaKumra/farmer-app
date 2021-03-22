import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'userdetail2.dart';

class TaskDetails extends StatefulWidget {
  var data;
  TaskDetails(d) {
    this.data = d;
  }
  @override
  _TaskDetailsState createState() => _TaskDetailsState(this.data);
}

class _TaskDetailsState extends State<TaskDetails> {
  var data,manager,user;
  _TaskDetailsState(d) {
    this.data = d;
    _getmanager(data['assigned_by']);
    _getuser(data['assigned_to']);
  }
  _convertdate(d){
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    final String formatted = formatter.format(d);
    return formatted;
  }
   _getmanager(input) async {
     var val;
    var document = await FirebaseFirestore.instance.collection('users').where('email',isEqualTo: input);
    document.get().then((document) {
    val=document.docs[0]["username"];
    setState(() {
      manager=val;
    });
    });
  }

   _getuser(input) async {
     var val;
     var document = await FirebaseFirestore.instance.collection('users').where('email',isEqualTo: input);
     document.get().then((document) {
       val=document.docs[0]["username"];
       setState(() {
         user=val;
       });
     });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Task Details"),
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

          SizedBox(height: 20,),
          ListTile(
            title: Text(
              "Task Title",
              style: TextStyle(color: Colors.teal, fontSize: 12.0),
            ),
            subtitle: Text(
              data['title'],
              style: TextStyle(fontSize: 18.0),
            ),
          ),
          Divider(),
          ListTile(
            title: Text(
              "Task Description",
              style: TextStyle(color: Colors.teal, fontSize: 12.0),
            ),
            subtitle: Text(
              data['description'],
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
              "Starting Date",
              style: TextStyle(color: Colors.teal, fontSize: 12.0),
            ),
            subtitle: Text(
              _convertdate(data['start_date'].toDate()),
              style: TextStyle(fontSize: 18.0),
            ),
          ),
          Divider(),
          ListTile(
            title: Text(
              "Ending Date",
              style: TextStyle(color: Colors.teal, fontSize: 12.0),
            ),
            subtitle: Text(
              _convertdate(data['end_date'].toDate()),
              style: TextStyle(fontSize: 18.0),
            ),
          ),
          Divider(),
          ListTile(
            title: Text(
              "Assigned By",
              style: TextStyle(color: Colors.teal, fontSize: 12.0),
            ),
            subtitle: Text(
             manager!=null?manager:"",
              style: TextStyle(fontSize: 18.0),
            ),
            trailing: InkWell(child: Icon(Icons.remove_red_eye),onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserDetail2(data['assigned_by'])),
              );
            },),
          ),
          Divider(),
          ListTile(
            title: Text(
              "Assigned To",
              style: TextStyle(color: Colors.teal, fontSize: 12.0),
            ),
            subtitle: Text(
                user!=null?user:"",
              style: TextStyle(fontSize: 18.0),
            ),
            trailing: InkWell(child: Icon(Icons.remove_red_eye),onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserDetail2(data['assigned_to'])),
              );
            },),
          ),
          Divider(),
          SizedBox(
            height: 20,
          ),
        ],
      ),

    );
  }
}
