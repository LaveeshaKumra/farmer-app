import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'memberdetail.dart';

class AllUsersincompany extends StatefulWidget {
  var company;

  AllUsersincompany(c){
    this.company=c;
  }
  @override
  _AllUsersState createState() => _AllUsersState(this.company);
}

class _AllUsersState extends State<AllUsersincompany> {
  var company;

  _AllUsersState(c){
    this.company=c;
  }
  Future myFuture;
  @override
  void initState() {
    super.initState();
    setState(() {
      myFuture = _getpendingReq();
    });
  }
  _goback(){

    //initState();
    setState(() {
      myFuture = _getpendingReq();
    });
  }

  _getpendingReq() async {
    var val;
    final databaseReference = FirebaseFirestore.instance;
    await databaseReference.collection("users").where('company',isEqualTo: company).where('status',isEqualTo: 'Accepted').get().then(
            (value) {val = value;
        });
    return val;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("All Team Members"),
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
                              leading: Icon(Icons.person),
                              title: d[index]['username']==null?Text(''):Text(d[index]['username']),
                              subtitle: Text(d[index]['email']),
                              trailing: Text(d[index]['role']),
                            ),
                            onTap: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => MemberDetail(d[index])),
                              );
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
