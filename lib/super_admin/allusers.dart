import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'userdetail.dart';

class AllUsers extends StatefulWidget {
  var company;

  AllUsers(c){
    this.company=c;
  }
  @override
  _AllUsersState createState() => _AllUsersState(this.company);
}

class _AllUsersState extends State<AllUsers> {
  var company;

  _AllUsersState(c){
    this.company=c;
  }
  @override
  void initState() {
    super.initState();

  }


  @override
  Widget build(BuildContext context) {
    Query  collectionStream = FirebaseFirestore.instance.collection("users").where('company',isEqualTo: company).where('status',isEqualTo: 'Accepted');
    return Scaffold(
        appBar: AppBar(
          title: Text("All users in $company"),

        ),
        body:Center(
          child: StreamBuilder<QuerySnapshot>(
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
                          leading: document.data()['profile']==null || document.data()['profile']=="" ?Icon(Icons.person,size: 35,):Image.network(document.data()['profile'],width: 45,),
                          title: document.data()['username']==null?Text(''):Text(document.data()['username']),
                          subtitle: Text(document.data()['email']),
                          trailing:document.data()['role']=="admin"? Text("Farmer"):Text("Worker"),
                        ),
                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => UserDetail(document.data())),
                          );
                        },
                      ),Divider(height: 5,)
                    ],
                  );
                }).toList(),
              );
            },
          ),
        ));
  }
}
