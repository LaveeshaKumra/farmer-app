import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmers_app/super_admin/taskdetails.dart';
import 'package:farmers_app/user/attendance.dart';
import 'package:farmers_app/user/graph.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'alltasks.dart';
import 'leavereq.dart';

class HomePageFarmer extends StatefulWidget {
  @override
  _HomePageFarmerState createState() => _HomePageFarmerState();
}

class _HomePageFarmerState extends State<HomePageFarmer> {
  var email,company,name;
  DateTime _choosedate=DateTime.now();

  _HomePageFarmerState() {
    _getUser();


  }
  var firebase = FirebaseAuth.instance;

  _selectDate(BuildContext context) async {
    DateTime newSelectedDate = await showDatePicker(
        context: context,
        initialDate:  DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2040),
        builder: (BuildContext context, Widget child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(
                primary: Colors.teal,
                onPrimary: Colors.white,
                surface: Colors.teal,
                onSurface: Colors.black,
              ),
              dialogBackgroundColor: Colors.grey[100],
            ),
            child: child,
          );
        });

    if (newSelectedDate != null) {
      setState(() {
        _choosedate = newSelectedDate;
        print('inside function $_choosedate');
      });
    }
  }

  _getUser() async {
    var user = firebase.currentUser;
    final databaseReference = FirebaseFirestore.instance;
    await databaseReference
        .collection("users")
        .where('email', isEqualTo: user.email)
        .get()
        .then((val) async {
      setState(() {
        company = val.docs[0]['company'];
        email = val.docs[0]['email'];
        name=val.docs[0]['username'];
      });
    });
  }

  _convertdate(d){
    final DateFormat formatter = DateFormat('dd MMMM,yy');
    final String formatted = formatter.format(d);
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        shrinkWrap: true,
        children: [
          Container(
              padding: EdgeInsets.all(20.0),
              height: MediaQuery.of(context).size.height * 0.1,
              decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15))),
              child: Column(
                children: [
                  InkWell(
                    onTap: (){_selectDate(context);},
                    child: Row(
                      children: [
                        Icon(Icons.date_range, color: Colors.white),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.03,
                        ),

                        Text("${_convertdate(_choosedate)}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white)),

                      ],
                    ),
                  )
                ],
              )),
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.22,
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.black),
                borderRadius: BorderRadius.circular(10)),
            child: Card(
              child: Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "Upcoming Tasks",
                          style: TextStyle(color: Colors.black26, fontSize: 18),
                        )
                      ],
                    ),
                    Flexible(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection("tasks").where("assigned_to",isEqualTo: email).where('end_date',isGreaterThanOrEqualTo: _choosedate).snapshots(),
                        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return Center(child: Text('Something went wrong'));
                          }
    //                       List<DocumentSnapshot> snapshotfilter;
    //                       snapshot.data.docs.map((DocumentSnapshot d){
    // if (d.data()['end_date'].toDate().isBefore(_choosedate) && d.data()['start_date'].toDate().isAfter(_choosedate)){
    //   snapshotfilter.add(d.data());
    // }
    //                       });

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
                                child: Text("No Task for ${_convertdate(_choosedate)}"),
                              ),
                            );
                          }
                          return new ListView(
                            children: snapshot.data.docs.map((DocumentSnapshot document) {
                             //  print(_choosedate);
                             //  print(document.data()['end_date'].toDate());
                             //  print(document.data()['end_date'].toDate().isBefore(_choosedate));
                             // // if (document.data()['end_date'].toDate().isBefore(_choosedate) && document.data()['start_date'].toDate().isAfter(_choosedate)){
                             //    return Container(
                             //        child:(document.data()['end_date'].toDate().isAfter(_choosedate) && document.data()['start_date'].toDate().isBefore(_choosedate))?
                             //        Text("Hey"):InkWell(
                             //  child: ListTile(
                             //  //leading: Icon(Icons.work_off),
                             //  trailing: document.data()['status']=="Pending"?Icon(Icons.warning,color: Colors.yellow,):document.data()['status']=="Rejected"?Icon(Icons.cancel_rounded,color: Colors.red,):Icon(Icons.check_circle,color: Colors.green,),
                             //  title: document.data()['title']==null?Text(''):Text(document.data()['title']),
                             //  subtitle: Text("From ${_convertdate(document.data()['start_date'].toDate())} to ${_convertdate(document.data()['end_date'].toDate())}"),
                             //  //trailing: Text(document.data()['company']),
                             //  ),
                             //  onTap: (){
                             //  Navigator.push(
                             //  context,
                             //  MaterialPageRoute(builder: (context) => TaskDetails(document.data())),
                             //  );
                             //  },
                             //  ));
                              return new InkWell(
                                child: ListTile(
                                  trailing: document.data()['status']=="Pending"?Icon(Icons.warning,color: Colors.yellow,):document.data()['status']=="Rejected"?Icon(Icons.cancel_rounded,color: Colors.red,):Icon(Icons.check_circle,color: Colors.green,),
                                  title: document.data()['title']==null?Text(''):Text(document.data()['title']),
                                  subtitle: Text("From ${_convertdate(document.data()['start_date'].toDate())} to ${_convertdate(document.data()['end_date'].toDate())}"),
                                ),
                                onTap: (){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => TaskDetails(document.data())),
                                  );
                                },
                              );
                            }).toList(),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Container(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        child: Card(
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Image.asset("assets/icons/tasks.png",width: 80,),
                                ),
                                Text("All Tasks\n",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),)
                              ],
                            ),
                          ),
                        ),
                        onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AllTasks(email,company)),
                          )
                        },
                      ),
                      InkWell(
                        child: Card(
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Image.asset("assets/icons/working hours.png",width: 80,),
                                ),
                                Text("Working Hours\nReport",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),)
                              ],
                            ),
                          ),
                        ),
                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ReportPage()),
                          );
                        },
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap:(){
                  Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Attendance(email)),
                  );
                  },
                        child: Card(
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Image.asset("assets/icons/calendar.png",width: 80,),
                                ),
                                Text("Attendance\n",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),)
                              ],
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        child: Card(
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Image.asset("assets/icons/leave.png",width: 80,),
                                ),
                                Text("Apply For\nLeave",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),)
                              ],
                            ),
                          ),
                        ),
                        onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PastReq(email,name,company)),
                          )
                        },
                      ),

                    ],
                  ),
                )
              ],
            ),
            // child: GridView(
            //     shrinkWrap: true,
            //     children:
            //     category.map((data)  {return Container(
            //       padding: EdgeInsets.all(10.0),
            //       child: Card(
            //
            //         child: Center(child: Column(
            //           children: [
            //             Container(height: MediaQuery.of(context).size.height*0.05,),
            //             Icon(Icons.adb_sharp),
            //             Container(height: MediaQuery.of(context).size.height*0.01,),
            //             Text(data),
            //           ],
            //         )),
            //       ),
            //     );}).toList()
            //     ,
            //     gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            //         childAspectRatio: 3 / 3,
            //         crossAxisSpacing: 8,
            //         mainAxisSpacing: 6,
            //         maxCrossAxisExtent: 200)
            //       ),
          )
        ],
      ),
    );
  }
}
