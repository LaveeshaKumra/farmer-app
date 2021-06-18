import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'inoutlog.dart';

class Calendar2 extends StatefulWidget {
  @override
  _Calendar2State createState() => _Calendar2State();
}

class _Calendar2State extends State<Calendar2> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DateTime _dateTime;
  QuerySnapshot _userEventSnapshot,_userEventSnapshot2;
  int _beginMonthPadding=0;

  _Calendar2State() {
    _dateTime = DateTime.now();
    setMonthPadding();
  }

  Future<QuerySnapshot> _getCalendarData() async {
    var currentUser = await _auth.currentUser;

    if (currentUser != null) {
      QuerySnapshot userEvents = await FirebaseFirestore.instance
          .collection('timeoff')
          //.where(
         // 'start_date', isGreaterThanOrEqualTo: new DateTime(_dateTime.year, _dateTime.month))
          .where('email', isEqualTo: currentUser.email)
          .get();
      QuerySnapshot userEvents2 = await FirebaseFirestore.instance
          .collection('attendance')
      //.where(
      // 'start_date', isGreaterThanOrEqualTo: new DateTime(_dateTime.year, _dateTime.month))
          .where('email', isEqualTo: currentUser.email).where('out_time', isNotEqualTo: "")
          .get();
      _userEventSnapshot2=userEvents2;
      _userEventSnapshot = userEvents;
      return _userEventSnapshot;
    } else {
      return null;
    }
  }
  void setMonthPadding() {
    _beginMonthPadding = new DateTime(_dateTime.year, _dateTime.month, 1).weekday;
    _beginMonthPadding == 7 ? (_beginMonthPadding = 0) : _beginMonthPadding;
  }
  void _goToToday() {
    print("trying to go to the month of today");
    setState(() {
      _dateTime = DateTime.now();

      setMonthPadding();
    });
  }

  void _previousMonthSelected() {
    setState(() {
      if (_dateTime.month == DateTime.january)
        _dateTime = new DateTime(_dateTime.year - 1, DateTime.december);
      else
        _dateTime = new DateTime(_dateTime.year, _dateTime.month - 1);

      setMonthPadding();
    });
  }

  void _nextMonthSelected() {
    setState(() {
      if (_dateTime.month == DateTime.december)
        _dateTime = new DateTime(_dateTime.year + 1, DateTime.january);
      else
        _dateTime = new DateTime(_dateTime.year, _dateTime.month + 1);

      setMonthPadding();
    });
  }





  @override
  Widget build(BuildContext context) {
    final int numWeekDays = 7;
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    /*28 is for weekday labels of the row*/
    // 55 is for iPhoneX clipping issue.
    final double itemHeight = (size.height - kToolbarHeight-kBottomNavigationBarHeight-24-28-55) / 5;
    final double itemWidth = size.width / numWeekDays;

    return new Scaffold(
        backgroundColor: Colors.white,
        appBar: new AppBar(
          title: new FittedBox(
              fit: BoxFit.contain,
              child: new Text(
                getMonthName(_dateTime.month) + " " + _dateTime.year.toString(),
              )
          ),
          actions: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.today,
                  color: Colors.white,
                ),
                onPressed: _goToToday
            ),
            IconButton(
                icon: Icon(
                  Icons.chevron_left,
                  color: Colors.white,
                ),
                onPressed: _previousMonthSelected
            ),
            IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                ),
                onPressed: _nextMonthSelected
            ),
            // PopupMenuButton<_AppBarMenu>(
            //   onSelected: (_AppBarMenu value) {
            //     _handleAppbarMenu(context, value);
            //   },
            //   itemBuilder: (BuildContext context) => <PopupMenuItem<_AppBarMenu>>[
            //     const PopupMenuItem(
            //       value: _AppBarMenu.logout,
            //       child: FittedBox(
            //         fit: BoxFit.contain,
            //         child: Text('Logout', textAlign: TextAlign.center,),
            //       ),
            //     )
            //   ],
            // ),
          ],
        ),

        body:
        new FutureBuilder(
            future: _getCalendarData(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return new LinearProgressIndicator();
                case ConnectionState.done:
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: new ListView(
                      children: <Widget>[
                        new Row(
                          children: <Widget>[
                            new Expanded(
                                child: new Text('Sun',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500))),
                            new Expanded(
                                child: new Text('Mon',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500))),
                            new Expanded(
                                child: new Text('Tue',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500))),
                            new Expanded(
                                child: new Text('Wed',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500))),
                            new Expanded(
                                child: new Text('Thr',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500))),
                            new Expanded(
                                child: new Text('Fri',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500))),
                            new Expanded(
                                child: new Text('Sat',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500))),
                          ],
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          //mainAxisSize: MainAxisSize.min,
                        ),
                        Container(
                          // decoration: new BoxDecoration(
                          //     border: new Border.all(
                          //         color: Colors.grey)),
                          child: new GridView.count(
                            crossAxisCount: numWeekDays,
                            childAspectRatio: (itemWidth / itemHeight),
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            children: List.generate(
                                getNumberOfDaysInMonth(_dateTime.month),
                                    (index) {
                                  int dayNumber = index + 1;
                                  return new GestureDetector(
                                    // Used for handling tap on each day view
                                      onTap: () =>
                                          buildDialog(
                                              dayNumber ),
                                      child: new Container(
                                          margin: const EdgeInsets.all(1.0),
                                          padding: const EdgeInsets.all(1.0),
                                          // decoration: new BoxDecoration(
                                          //     border: new Border.all(
                                          //         color: Colors.grey)),
                                          child: new Column(
                                            children: <Widget>[
                                              buildDayNumberWidget(dayNumber),
                                              SizedBox(height: 5),
                                              buildattendancecircle(dayNumber),
                                              SizedBox(height: 5),
                                              buildDayEventInfoWidget(dayNumber)
                                            ],
                                          )));
                                }),
                          ),
                        )
                      ],
                    ),
                  );
                  break;
                default:
                  if (snapshot.hasError)
                    return new Text('Error: ${snapshot.error}');
                  else
                    return new Text('Result: ${snapshot.data}');
              }
            }
        )
    );
  }
  Widget buildattendancecircle(int dayNumber) {
    int eventCount = 0;
    DateTime eventDate,eventDate2;

    _userEventSnapshot2.docs.forEach((doc) {
      eventDate = doc.data()['in_time'].toDate();
      eventDate2= doc.data()['out_time'].toDate();
      if (eventDate != null
          && eventDate.day <= dayNumber - _beginMonthPadding && eventDate2.day >= dayNumber - _beginMonthPadding
          && eventDate.month == _dateTime.month
          && eventDate.year == _dateTime.year) {
        eventCount++;

      }
    });

    if (eventCount > 0) {
      return new Container(
        width: 10.0,
        height: 10.0,
        decoration: BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
      );
    } else {
      return new Container(
        width: 10.0,
        height: 10.0,
        // decoration: BoxDecoration(
        //   color: Colors.red,
        //   shape: BoxShape.circle,
        // ),
      );
    }
  }

  Align buildDayNumberWidget(int dayNumber) {
    //print('buildDayNumberWidget, dayNumber: $dayNumber');
    if ((dayNumber-_beginMonthPadding) == DateTime.now().day
        && _dateTime.month == DateTime.now().month
        && _dateTime.year == DateTime.now().year) {
      // Add a circle around the current day
      return Align(
        alignment: Alignment.topLeft,
        child: Container(
          width: 35.0, // Should probably calculate these values
          height: 35.0,
          padding: EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            //color: Colors.orange,
            border: Border.all(color: Theme.of(context).primaryColor),
          ),
          child: new Text(
            (dayNumber - _beginMonthPadding).toString(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.title,
          ),
        ),
      );
    } else {
      // No circle around the current day
      return Align(
        alignment: Alignment.topLeft,
        child: Container(
          width: 35.0, // Should probably calculate these values
          height: 35.0,
          padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
          child: new Text(
            dayNumber <= _beginMonthPadding ? ' ' : (dayNumber - _beginMonthPadding).toString(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline,
          ),
        ),
      );
    }
  }

  converttime(t) {
    TimeOfDay time=TimeOfDay(hour: t.hour,minute: t.minute);
    return time;
  }
  _deletereq(docid) async {
    final databaseReference = FirebaseFirestore.instance;
    await databaseReference.collection("timeoff").doc(docid).delete().then((value) {
      Navigator.pop(context,true);
      Navigator.pop(context,true);
    });

  }
   buildDialog(int dayNumber) {
    int eventCount = 0;
    DateTime eventDate,eventDate2;
    var eventtitle,eventdesc,eventstatus,docid,starttime;

    _userEventSnapshot.docs.forEach((doc) {
      eventDate = doc.data()['start_date'].toDate();
      eventDate2= doc.data()['end_date'].toDate();
      if (eventDate != null
          && eventDate.day <= dayNumber - _beginMonthPadding && eventDate2.day >= dayNumber - _beginMonthPadding
          && eventDate.month == _dateTime.month
          && eventDate.year == _dateTime.year) {
        eventCount++;
        eventtitle=doc.data()['title'];
        eventdesc=doc.data()['description'];
        eventstatus=doc.data()['status'];
        starttime=doc.data()['start_date'].toDate();
        docid=doc.id;
      }
    });

    if (eventCount > 0) {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("$eventtitle"),
            content: Text("$eventdesc\nStatus : $eventstatus"),
            actions: [
              starttime.isAfter(DateTime.now())?FlatButton(
                child: Text("Delete Request",style: TextStyle(color: Colors.red),),
                onPressed: () {
                  _deletereq(docid);
                },
              ):Container(),
              FlatButton(
                child: Text("OK",style: TextStyle(color: Colors.green),),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      // return new Expanded(
      //   child:
      //   new Text(
      //     "$eventtitle",
      //     maxLines: 2,
      //     style: new TextStyle(fontWeight: FontWeight.normal,
      //         background: Paint()..color = Theme.of(context).primaryColorAccent),
      //   ),
      // );
    } else {

      int eventCount2=0;
      var intime,outtime;
      _userEventSnapshot2.docs.forEach((doc) {
        eventDate = doc.data()['in_time'].toDate();
        if (eventDate != null
            && eventDate.day == dayNumber - _beginMonthPadding
            && eventDate.month == _dateTime.month
            && eventDate.year == _dateTime.year) {
          eventCount2++;
          intime=doc.data()['in_time'];
          outtime=doc.data()['out_time'];
        }
      });
      if(eventCount2>0){
        // return showDialog(
        //   context: context,
        //   builder: (BuildContext context) {
        //     return AlertDialog(
        //       title: Text("${outtime.toDate().difference(intime.toDate()).inHours} Hours"),
        //       content: Text("You Worked From ${converttime(intime.toDate()).format(context)} to ${converttime(outtime.toDate()).format(context)}"),
        //       actions: [
        //         FlatButton(
        //           child: Text("OK"),
        //           onPressed: () {
        //             Navigator.of(context).pop();
        //           },
        //         ),
        //       ],
        //     );
        //   },
        // );
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ClockInClockOutLog()),
        );
      }
      else{
        return  showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("No Data Found"),
              actions: [
                FlatButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
     }
  }

  Widget buildDayEventInfoWidget(int dayNumber) {
    int eventCount = 0;
    DateTime eventDate,eventDate2;
    var eventtitle,eventstatus;

    _userEventSnapshot.docs.forEach((doc) {
      eventDate = doc.data()['start_date'].toDate();
      eventDate2= doc.data()['end_date'].toDate();
      if (eventDate != null
          && eventDate.day <= dayNumber - _beginMonthPadding && eventDate2.day >= dayNumber - _beginMonthPadding
          && eventDate.month == _dateTime.month
          && eventDate.year == _dateTime.year) {
        eventCount++;
        eventtitle=doc.data()['title'];
        eventstatus=doc.data()['status'];
      }
    });

    if (eventCount > 0) {
      return new Expanded(
        child:
        new Text(
          "$eventtitle",
          maxLines: 2,
          style: new TextStyle(fontWeight: FontWeight.normal,
              background: Paint()..color = eventstatus=="Pending"?Colors.yellowAccent:eventstatus=="Rejected"?Colors.red:Colors.green),
        ),
      );
    } else {
      return new Container();
    }
  }

  int getNumberOfDaysInMonth(final int month) {
    int numDays = 28;

    // Months are 1, ..., 12
    switch (month) {
      case 1:
        numDays = 31;
        break;
      case 2:
        numDays = 28;
        break;
      case 3:
        numDays = 31;
        break;
      case 4:
        numDays = 30;
        break;
      case 5:
        numDays = 31;
        break;
      case 6:
        numDays = 30;
        break;
      case 7:
        numDays = 31;
        break;
      case 8:
        numDays = 31;
        break;
      case 9:
        numDays = 30;
        break;
      case 10:
        numDays = 31;
        break;
      case 11:
        numDays = 30;
        break;
      case 12:
        numDays = 31;
        break;
      default:
        numDays = 28;
    }
    return numDays + _beginMonthPadding;
  }

  String getMonthName(final int month) {
    // Months are 1, ..., 12
    switch (month) {
      case 1:
        return "January";
      case 2:
        return "February";
      case 3:
        return "March";
      case 4:
        return "April";
      case 5:
        return "May";
      case 6:
        return "June";
      case 7:
        return "July";
      case 8:
        return "August";
      case 9:
        return "September";
      case 10:
        return "October";
      case 11:
        return "November";
      case 12:
        return "December";
      default:
        return "Unknown";
    }
  }

  // Future _handleAppbarMenu(BuildContext context, _AppBarMenu value) async {
  //   switch(value) {
  //     case _AppBarMenu.logout:
  //       await _auth.signOut();
  //       Navigator.of(context).pushNamedAndRemoveUntil(Constants.splashRoute, (Route<dynamic> route) => false);
  //       break;
  //   }
  // }

  Future _onBottomBarItemTapped(int index) async {
    switch(index) {
      case 0:
        break;
      case 1:
        //Navigator.pushNamed(context, Constants.calContactsRoute);
        break;
    }
  }
}
