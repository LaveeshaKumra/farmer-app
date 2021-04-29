import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'taskdetails.dart';

class AllTasks extends StatefulWidget {
  @override
  _AllTasksState createState() => _AllTasksState();
}

class _AllTasksState extends State<AllTasks> {
  @override
  void initState() {
    super.initState();

  }


  @override
  Widget build(BuildContext context) {
    Query  collectionStream = FirebaseFirestore.instance.collection('tasks').orderBy('start_date',descending: true);
    return Scaffold(

        body:Center(
          child:StreamBuilder<QuerySnapshot>(
            stream: collectionStream.snapshots(),
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
                  return new Column(
                    children: [
                      InkWell(
                        child: ListTile(
                          leading: Icon(Icons.grading_rounded),
                          title: Text(document.data()['title']),
                          subtitle: Text(document.data()['company']),
                          trailing: Text(document.data()['status']),
                        ),
                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => TaskDetails(document.data())),
                          );
                        },
                      ),Divider(height: 5,)
                    ],
                  );
                }).toList(),
              );
            },
          )
        ));
  }
}

