import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'taskdetails.dart';

class AllTasks extends StatefulWidget {
  @override
  _AllTasksState createState() => _AllTasksState();
}

class _AllTasksState extends State<AllTasks> {
  Future myFuture;
  @override
  void initState() {
    super.initState();
    setState(() {
      myFuture = _getalltasks();
    });
  }
  _goback(){
    setState(() {
      myFuture = _getalltasks();
    });
  }
  _getalltasks() async {
    var val;
    final databaseReference = FirebaseFirestore.instance;
    await databaseReference.collection("tasks").get().then(
            (value) {val = value;
        });
    return val;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Tasks"),
        actions: [
          InkWell(child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.refresh),
          ),onTap: (){
            _goback();
          },),
        ],
      ),
        body:Center(
          child: FutureBuilder(
            builder: (context, projectSnap) {
              print(projectSnap.data);
              if (projectSnap.hasData) {
                var d = projectSnap.data.docs;
                print(d);
                if(d.length>0){

                  return ListView.builder(
                    itemCount: d.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          InkWell(
                            child: ListTile(
                              leading: Icon(Icons.grading_rounded),
                              title: Text(d[index]['title']),
                              subtitle: Text(d[index]['company']),
                              //trailing: Text(d[index].data['role']),
                            ),
                            onTap: (){
                              Route route =MaterialPageRoute(builder: (context) => TaskDetails(d[index]));
                              Navigator.push(context, route).then(_goback());
                            },
                          ),Divider(height: 5,)
                        ],
                      );
                    },
                  );
                }
                else{
                  return Container(
                    child: Image.asset("assets/nodata.png",width: 300,),
                  );
                }
              } else {
                return Column(
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
                );
              }
            },
            future: myFuture,
          ),
        ));
  }
}

