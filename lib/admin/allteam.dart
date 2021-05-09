import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'memberdetail.dart';

class AllUsersincompany extends StatefulWidget {
  var company;

  AllUsersincompany(c) {
    this.company = c;
  }
  @override
  _AllUsersState createState() => _AllUsersState(this.company);
}

class _AllUsersState extends State<AllUsersincompany> {
  var company;

  _AllUsersState(c) {
    this.company = c;
  }
  Future myFuture;
  @override
  void initState() {
    super.initState();
    setState(() {
      myFuture = _getpendingReq();
    });
  }

  
  _getpendingReq() async {
    var val;
    final databaseReference = FirebaseFirestore.instance;
    await databaseReference
        .collection("users")
        .where('company', isEqualTo: company)
        .where('status', isEqualTo: 'Accepted')
        .get()
        .then((value) {
      val = value;
    });
    return val;
  }

  @override
  Widget build(BuildContext context) {
    Query collectionStream = FirebaseFirestore.instance
        .collection("users")
        .where('company', isEqualTo: company)
        .where('status', isEqualTo: 'Accepted');
    return Scaffold(
      appBar: AppBar(
        title: Text("All Team Members"),

      ),
      body: StreamBuilder<QuerySnapshot>(
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
                      leading: Icon(Icons.person),
                      title: document.data()['username']==null?Text(''):Text(document.data()['username']),
                      subtitle: Text(document.data()['email']),
                      trailing: Text(document.data()['role']),
                    ),
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MemberDetail(document.data())),
                      );
                    },
                  ),Divider(height: 5,)
                ],
              );
            }).toList(),
          );
        },
      ),
      // body:Center(
      //   child: FutureBuilder(
      //     builder: (context, projectSnap) {
      //       print(projectSnap.data);
      //       if (projectSnap.hasData) {
      //         var d = projectSnap.data.docs;
      //         print(d);
      //         if(d.length>0){
      //
      //           return Container();
      //         }
      //         else{
      //           return Container(
      //             child: Image.asset("assets/nodata.png",width: 300,),
      //           );
      //         }
      //       } else {
      //         return Column(
      //           mainAxisAlignment: MainAxisAlignment.center,
      //           crossAxisAlignment: CrossAxisAlignment.center,
      //           children: <Widget>[
      //             SizedBox(
      //               child: CircularProgressIndicator(
      //                   valueColor: new AlwaysStoppedAnimation<Color>(
      //                       Theme.of(context).primaryColor)),
      //               width: 30,
      //               height: 30,
      //             ),
      //             Padding(
      //               padding: const EdgeInsets.only(top: 16.0),
      //               child: Text("Loading.."),
      //             )
      //           ],
      //         );
      //       }
      //     },
      //     future: myFuture,
      //   ),
      // )
    );
  }
}
