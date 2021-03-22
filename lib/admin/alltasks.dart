import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'taskdetail.dart';


class AllTasksAssignedByUser extends StatefulWidget {
  var email;
  AllTasksAssignedByUser(e){
    this.email=e;
  }
  @override
  _AllTasksState createState() => _AllTasksState(this.email);
}

class _AllTasksState extends State<AllTasksAssignedByUser> {
  var email;
  _AllTasksState(e){
    this.email=e;
  }
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
    await databaseReference.collection("tasks").where("assigned_by",isEqualTo: email).get().then(
            (value) {val = value;
        });
    return val;
  }
  _getuser(input) async {
    var val;
    var document = await FirebaseFirestore.instance.collection('users').where('email',isEqualTo: input);
    document.get().then((document) {
      val=document.docs[0]["username"];
      // setState(() {
      //   user=val;
      // });
      return val;
    });
  }
  String _get(val){
    return _getuser(val);
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
          title: Text("All Tasks Assigned By You"),
          actions: [
            InkWell(child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.refresh),
            ),onTap: (){
              _goback();
            },),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          elevation: 10,
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
                            // child: ListTile(
                            //   leading: Icon(Icons.grading_rounded),
                            //   title: Text(d[index]['title']),
                            //   //subtitle: Text("${_convert(d[index]['start_date'])} to ${_convert(d[index]['end_date'])}"),
                            //   subtitle: Wrap(children: <Widget>[Column(
                            //     children: [
                            //   Text("${_convertdate(d[index]['start_date'].toDate())} to ${_convertdate(d[index]['end_date'].toDate())}"),
                            //       Text("Assigned To : ${(d[index]['assigned_to'])}")
                            //     ],
                            //   )]),
                            //   trailing: Text(d[index]['status']),
                            // ),
                            child: Card(
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
                                          child: Text("Title: ${d[index]['title']}",style: TextStyle(fontSize: 18,fontWeight:FontWeight.bold),),
                                        ),



                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Icon(Icons.watch_later_outlined),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text("${_convertdate(d[index]['start_date'].toDate())} to ${_convertdate(d[index]['end_date'].toDate())}",style: TextStyle(fontSize: 16)),
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
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text("Assigned To : ${(d[index]['assigned_to'])}",style: TextStyle(fontSize: 16))
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: d[index]['status']=="Pending"?Icon(Icons.error,color: Colors.red,):d[index]['status']=="Done"?Icon(Icons.done,color: Colors.green,):Icon(Icons.warning,color: Colors.yellow,),
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text("Status : ${(d[index]['status'])}",style: TextStyle(fontSize: 16))
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                            onTap: (){
                              Route route =MaterialPageRoute(builder: (context) => TaskDetailsInAdmin(d[index]));
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

