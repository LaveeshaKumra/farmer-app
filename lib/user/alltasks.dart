import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmers_app/super_admin/taskdetails.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';

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


  Future<bool> _ifinprogress(docid) {
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
            onPressed: () => update(docid,"Done"),
            child: new Text('Task Completed'),
          ),
        ],
      ),
    ) ??
        false;
  }

  Future<bool> _ifinpending(docid) {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Set Task Status'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () {update(docid,"In Progress");} ,
            child: new Text('In Progress'),
          ),
          new FlatButton(
            onPressed: () => update(docid,"Done"),
            child: new Text('Task Completed'),
          ),
        ],
      ),
    ) ??
        false;
  }

  update(docid,status) async {
    print(docid);
    print(status);

    final databaseReference = FirebaseFirestore.instance;

    await databaseReference
        .collection("tasks")
        .doc(docid)
        .update({
      'status':status
    }).then((value) {
      Toast.show("Status Updated", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      Navigator.pop(context);
    });

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
                    child: Center(child: Text(returnMonth(element['start_date'].toDate()),style: TextStyle(fontWeight: FontWeight.w400,fontSize: 18,color: Colors.teal),)),
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
                        if(snapshot.data()['status']=="Pending") _ifinpending(snapshot.id);
                        else _ifinprogress(snapshot.id);
                      }, icon: Icon(Icons.priority_high_rounded), label: Text("Set Status"),color: Colors.grey[200],):FlatButton.icon(onPressed:(){}, icon: Icon(Icons.done), label: Text(snapshot.data()['status']),color: Colors.green[200],),
                    ),
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TaskDetails(snapshot.data())),
                      );
                    },
                  ),
                );
              });

        },
      ),);
  }
}
