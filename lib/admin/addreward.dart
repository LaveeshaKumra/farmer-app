import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:intl/intl.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:http/http.dart';


class AddReward extends StatefulWidget {
  var email,company;
  AddReward(e,c){this.email=e;    this.company=c;
  }
  @override
  _AddTaskState createState() => _AddTaskState(this.email,this.company);
}

class _AddTaskState extends State<AddReward> {
  var email,company,_assignedto,type;
  _AddTaskState(e,c){this.email=e;    this.company=c;
  _getallworkers();print(company);print(email);}
  var _progress=false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _reward = TextEditingController();

  List<String> giftdropdown=[
    "Money","Gift"
  ];
  bool _success;



  //final String serverToken = 'AAAAkgw6AJk:APA91bGRPBagwJydmgRcvUNkr0KHx6jo6GMaJ67NWguNw3fOrMBz--9TC4btXxO1q1_RIxqUXz8VWUm-LRgTaR_WHr-02iCS1Aibtiatk4bxlSRiBg9PL-tDT3udvDnbxyxRA2IhEEr7';
  //final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  sendAndRetrieveMessage(topic) async {
    // // var t2=topic.replaceAll('.', "");
    // // var t3=t2.replaceAll(new RegExp(r"\s+"), "");
    // //
    // // await firebaseMessaging.requestNotificationPermissions(
    // //   const IosNotificationSettings(sound: true, badge: true, alert: true),
    // // );
    // try {
    //   var url = Uri.parse('https://fcm.googleapis.com/fcm/send');
    //   var header = {
    //     "Content-Type": "application/json",
    //     "Authorization":
    //     "key=$serverToken",
    //   };
    //   var request = {
    //     "notification": {
    //       "title": "New Task uploaded",
    //       "body": _title.text,
    //       "sound": "default",
    //       "tag":"New Task Updates from Farmer"
    //     },
    //     "data": {
    //       "click_action": "FLUTTER_NOTIFICATION_CLICK",
    //       "screen": "OPEN_HOMEWORK_PAGE",
    //     },
    //     "priority": "high",
    //     "to": '/topics/$email',
    //   };
    // //
    //    var client = new Client();
    //   var response =
    //   await client.post(url, headers: header, body: json.encode(request));
    //   print(response.body);
    //   print(response.statusCode);
    //   return true;
    // } catch (e, s) {
    //   print(e);
    //   return false;
    //  }
  }

  TextEditingController _textEditingController = TextEditingController();
  DateTime _startdate=DateTime.now();
  DateTime _enddate=DateTime.now();

  _selectDate(BuildContext context) async {
    DateTime newSelectedDate = await showDatePicker(
        context: context,
        initialDate: _startdate != null ? _startdate : DateTime.now(),
        firstDate: DateTime(1970),
        lastDate: DateTime(DateTime.now().year+1),
        builder: (BuildContext context, Widget child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(
                primary: Theme.of(context).primaryColor,
                onPrimary: Colors.white,
                surface: Theme.of(context).primaryColor,
                onSurface: Colors.black,
              ),
              dialogBackgroundColor: Colors.grey[100],
            ),
            child: child,
          );
        });

    if (newSelectedDate != null) {
      setState(() {
        _startdate = newSelectedDate;
      });
      _textEditingController
        ..text = DateFormat.yMMMd().format(_startdate)
        ..selection = TextSelection.fromPosition(TextPosition(
            offset: _textEditingController.text.length,
            affinity: TextAffinity.upstream));
    }
  }

  TextEditingController _textEditingController2 = TextEditingController();

  _selectDate2(BuildContext context) async {
    DateTime newSelectedDate = await showDatePicker(
        context: context,
        initialDate: _enddate != null ? _enddate : DateTime.now(),
        firstDate: DateTime(1970),
        lastDate: DateTime(DateTime.now().year+1),
        builder: (BuildContext context, Widget child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(
                primary: Theme.of(context).primaryColor,
                onPrimary: Colors.white,
                surface: Theme.of(context).primaryColor,
                onSurface: Colors.black,
              ),
              dialogBackgroundColor: Colors.grey[100],
            ),
            child: child,
          );
        });

    if (newSelectedDate != null) {
      setState(() {
        _enddate = newSelectedDate;
      });

      _textEditingController2
        ..text = DateFormat.yMMMd().format(_enddate)
        ..selection = TextSelection.fromPosition(TextPosition(
            offset: _textEditingController2.text.length,
            affinity: TextAffinity.upstream));
    }
  }

  _showdialog(context){
    return AwesomeDialog(
      context: context,
      dialogType: DialogType.SUCCES,
      animType: AnimType.TOPSLIDE,
      title: 'Rewards Added Successfully',
      desc: 'We Have Sent Reward to Worker!',
      //showCloseIcon: true,
      // btnCancelOnPress: () {},
      btnOkOnPress: () {Navigator.pop(context);},
    )..show();
  }

  addreward(context) async {
    setState(() {
      _progress=true;
    });

    final databaseReference = FirebaseFirestore.instance;
    await databaseReference.collection("rewards")
        .add({
      'name': _title.text,
      'from':FirebaseAuth.instance.currentUser.email,
      'to':_assignedto,
      "type":type,
      'reward':_reward.text,
      "date":DateTime.now()
    }).then((value) async {
      //await sendAndRetrieveMessage('${list1[i]}-Vrinda');
      _sendnotification();
      setState(() {
        _progress=false;
      });
    });

    _showdialog(context);

    // Toast.show("Task is uploaded",context,duration: Toast.LENGTH_SHORT, gravity:  Toast.TOP);
    Navigator.pop(context);
    Navigator.pop(context);

  }

  var allnames,allemails;
  List<DropdownMenuItem> items = [];
  _getallworkers() async {
    var val;
    final databaseReference = FirebaseFirestore.instance;
    await databaseReference.collection("users").where('company',isEqualTo: company).where('status',isEqualTo: 'Accepted').where('role',isEqualTo: 'farmer').get().then(
            (value) {val = value;
        });
    int length=val.docs.length;
    print(length);
    for(int i=0;i<length;i++){
      setState(() {
        items.add(DropdownMenuItem(
          child: Text(val.docs[i]['username']),
          value: val.docs[i]['email'],
        ));
      });
    }

  }
  TimeOfDay _starttime = TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endtime = TimeOfDay(hour: 18, minute: 0);
  bool _startcolor=false;bool _endcolor=false;
  var serverToken="AAAAwaoyCQk:APA91bGBDoI9m0Ih3cEeEUVTMY6JtrV2xy2nKI88OcRXd6Pj3ee_4K0yM3ZVPoWOBUmiVg9p-jqwLStOkxS0Xmp8QCYaoGY7wWd-4qCgR0k35zoDV1dmOBq04YQQ-WdfLxJYV3UrQGBQ";
  _sendnotification() async {
var topic3=_assignedto.replaceAll('@',"");
      var topic4=topic3.replaceAll('.', "");
    try {
      var url = Uri.parse('https://fcm.googleapis.com/fcm/send');
      var header = {
        "Content-Type": "application/json",
        "Authorization":
        "key=$serverToken",
      };
      var request = {
        "notification": {
          "title": "You earned a reward",
          "body": 'From $email',
          "sound": "default",
          "tag":"New Updates from Rompin"
        },
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "screen": "Reward",
        },
        "priority": "high",
        "to": '/topics/$topic4',
      };
      var client = new Client();
      var response =
      await client.post(url, headers: header, body: json.encode(request));
      print(response.body);
      print(response.statusCode);
      return true;
    } catch (e, s) {
      print(e);
      return false;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Reward"),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: ListView(
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              Material(
                color: Colors.grey[200],
                elevation: 2.0,
                borderRadius: BorderRadius.all(Radius.circular(5)),
                child: TextFormField(
                  controller: _title,
                  validator: (var value) {
                    if (value.isEmpty) {
                      return 'Please enter a valid reward title';
                    }
                    return null;
                  },
                  minLines: 1,
                  maxLines: 5,
                  cursorColor: Theme.of(context).primaryColor,
                  decoration: InputDecoration(
                      hintText: "Reward Title",

                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 25, vertical: 13)),
                ),
              ),

              SizedBox(
                height: 20,
              ),
              Material(
                color: Colors.grey[200],
                elevation: 2.0,
                borderRadius: BorderRadius.all(Radius.circular(5)),
                // child:  SearchableDropdown.single(
                //   items: items,
                //   value: _assignedto,
                //   hint: "Assign Task To",
                //   searchHint: null,
                //   onChanged: (value) {
                //     setState(() {
                //       _assignedto = value;
                //     });
                //   },
                //   dialogBox: false,
                //   isExpanded: true,
                //   menuConstraints: BoxConstraints.tight(Size.fromHeight(350)),
                // )
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SearchableDropdown.single(
                    // validator: (var value) {
                    //   if (value==null) {
                    //     return 'Please enter a farmer';
                    //   }
                    //   return null;
                    // },
                    items: items,
                    value: _assignedto,
                    hint: "Reward To",
                    searchHint: "Select One Worker",
                    onChanged: (value) {
                      setState(() {
                        _assignedto = value;
                      });
                    },
                    isExpanded: true,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Material(
                color: Colors.grey[200],
                elevation: 2.0,
                borderRadius: BorderRadius.all(Radius.circular(5)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal:20.0),
                  child: DropdownButton(

                    isExpanded: true,
                    hint: Text('Reward Type'),
                    value: type,
                    items: giftdropdown
                        .map((e) =>
                        DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        type = value;
                      });
                    },
                  ),
                ),
              ),

              type!=null?SizedBox(
                height: 20,
              ):Container(),
              type!=null?Material(
                color: Colors.grey[200],
                elevation: 2.0,
                borderRadius: BorderRadius.all(Radius.circular(5)),
                child: TextFormField(
                  controller: _reward,
                  validator: (var value) {
                    if (value.isEmpty) {
                      return 'Please enter a valid reward';
                    }
                    return null;
                  },
                  minLines: 1,
                  maxLines: 5,
                  cursorColor: Theme.of(context).primaryColor,
                  decoration: InputDecoration(
                      hintText: type=="Gift"?"Name of Gift":"Money Amount",

                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 25, vertical: 13)),
                ),
              ):Container(),

              SizedBox(
                height: 20,
              ),
              Container(
                //width: MediaQuery.of(context).size.width ,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: RoundedButton(
                    text: "Send Reward",
                    state: _progress,
                    color: Theme.of(context).primaryColor,
                    press: () {

                      // if(_assignedto==null){
                      //   Toast.show("Add A farmer to assign task",context,duration: Toast.LENGTH_SHORT, gravity:  Toast.TOP);
                      // }
                      // else{
                      if (_formKey.currentState.validate()) {
                        setState(() {
                          _progress=true;
                        });
                        addreward(context);
                      }
                      // }
                    },
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: Text(_success == null
                    ? ''
                    : (_success
                    ? 'Successfully published '
                    : ' failed')),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RoundedButton extends StatelessWidget {
  final String text;
  final Function press;
  final Color color, textColor;
  final bool state;
  const RoundedButton({
    Key key,
    this.text,
    this.state,
    this.press,
    this.color,
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      width: size.width ,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: FlatButton(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
          color: color,
          onPressed: press,
          child: state
              ? CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          )
              : Text(
            text,
            style: TextStyle(color: textColor),
          ),
        ),
      ),
    );
  }
}

class RoundedButton2 extends StatelessWidget {
  final String text;
  final Function press;
  final Color color, textColor;
  final bool state;
  const RoundedButton2({
    Key key,
    this.text,
    this.state,
    this.press,
    this.color ,
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      width: size.width * 0.4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: FlatButton(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
          color: color,
          onPressed: press,
          child: state
              ? CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          )
              : Text(
            text,
            style: TextStyle(color: textColor),
          ),
        ),
      ),
    );
  }
}
