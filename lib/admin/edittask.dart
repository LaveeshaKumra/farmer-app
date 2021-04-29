import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'addtask.dart';

class EditTask extends StatefulWidget {
  var data,docid;
  EditTask(d,i){
    this.data=d;
    this.docid=i;
  }
  @override
  _EditTaskState createState() => _EditTaskState(this.data,this.docid);
}

class _EditTaskState extends State<EditTask> {
  var data,docid;
  TimeOfDay _starttime ;
  TimeOfDay _endtime ;
  _EditTaskState(e,i){
    this.data=e;
    this.docid=i;
    _title.text= data['title'];
    _description.text=data['description'];
    company.text=data['company'];
    assigned_to=data['assigned_to'];
    _enddate=data['end_date'].toDate();
    _startdate=data['start_date'].toDate();
    _stime=data['start_time'];
    _etime=data['end_time'];
    status=data['status'];
    _getallworkers();
    _check();

  }
  var _progress=false;
  List<String> _statusoptions=["Pending","In Progress","Done"];
var status;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();

  bool _success;

  @override
  void initState() {
    _settime();

  }

  _settime(){
  int idx = _stime.indexOf(":");
  var hr=int.parse(_stime.substring(0,idx).trim());
  var b=(_stime.substring(idx+1).trim());
  int ind=b.indexOf(" ");
  var min=int.parse(b.substring(0,ind).trim());
  var tym=b.substring(ind+1).trim();
  print(hr);
  print(min);
  print(tym);
  if(tym=="PM") {setState(() {
    _starttime=TimeOfDay(hour: hr+12, minute: min);
  });}
  else{
    _starttime=TimeOfDay(hour: hr, minute: min);
  }

  int idx2 = _etime.indexOf(":");
  var hr2=int.parse(_etime.substring(0,idx2).trim());
  var b2=(_etime.substring(idx2+1).trim());
  int ind2=b2.indexOf(" ");
  var min2=int.parse(b2.substring(0,ind2).trim());
  var tym2=b2.substring(ind2+1).trim();
  print(hr2);
  print(min2);
  print(tym2);
  if(tym2=="PM") {setState(() {
    _endtime=TimeOfDay(hour: hr2+12, minute: min2);
  });}
  else{
    _endtime=TimeOfDay(hour: hr2, minute: min2);
  }
}

  var serverToken="AAAAwaoyCQk:APA91bGBDoI9m0Ih3cEeEUVTMY6JtrV2xy2nKI88OcRXd6Pj3ee_4K0yM3ZVPoWOBUmiVg9p-jqwLStOkxS0Xmp8QCYaoGY7wWd-4qCgR0k35zoDV1dmOBq04YQQ-WdfLxJYV3UrQGBQ";
  _sendnotification() async {
var topic3=assigned_to.replaceAll('@',"");
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
          "title": "Task is Updated",
          "body": _title.text,
          "sound": "default",
          "tag":"New Updates from Rompin"
        },
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "screen": "Alltasks",
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

  TextEditingController _textEditingController = TextEditingController();
  DateTime _startdate=DateTime.now();
  DateTime _enddate=DateTime.now();
  var assigned_to;

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
  TextEditingController company = TextEditingController();

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
        _enddate = newSelectedDate;
      });

      _textEditingController2
        ..text = DateFormat.yMMMd().format(_enddate)
        ..selection = TextSelection.fromPosition(TextPosition(
            offset: _textEditingController2.text.length,
            affinity: TextAffinity.upstream));
    }
  }

  _check(){
    if(_startdate!=null){
      _textEditingController
        ..text = DateFormat.yMMMd().format(_startdate)
        ..selection = TextSelection.fromPosition(TextPosition(
            offset: _textEditingController.text.length,
            affinity: TextAffinity.upstream));
    }
    if(_enddate!=null){
      _textEditingController2
        ..text = DateFormat.yMMMd().format(_enddate)
        ..selection = TextSelection.fromPosition(TextPosition(
            offset: _textEditingController2.text.length,
            affinity: TextAffinity.upstream));
    }

  }



  void _selectstartingtime() async {
    final TimeOfDay newTime = await showTimePicker(
      context: context,
      helpText: "Starting Time",
      initialTime: _starttime,
    );
    if (newTime != null) {
      setState(() {
        _starttime = newTime;
      });
    }
  }
  void _selectendingtime() async {
    final TimeOfDay newTime = await showTimePicker(
      context: context,
      helpText: "Ending Time",
      initialTime: _endtime,
    );
    if (newTime != null) {
      setState(() {
        _endtime = newTime;
      });
    }
  }
  _showdialog(context){
    return AwesomeDialog(
      context: context,
      dialogType: DialogType.SUCCES,
      animType: AnimType.TOPSLIDE,
      title: 'Task Updated Successfully',
      // desc: 'We Have Sent Task to Worker!',
      //showCloseIcon: true,
      // btnCancelOnPress: () {},
      btnOkOnPress: () {},
    )..show();
  }
var _stime,_etime;
  var allnames,allemails;
  List<DropdownMenuItem> items = [];
  updatetask(context) async {
    setState(() {
      _progress = true;
    });
    final databaseReference = FirebaseFirestore.instance;

    await databaseReference
        .collection("tasks")
        .doc(docid)
        .update({
      'title': _title.text,
      'description': _description.text,
      'assigned_to': assigned_to,
      'start_date': _startdate,
      'end_date': _enddate,
      'start_time':_starttime.format(context),
      'end_time':_endtime.format(context),
      'status':status
    }).then((value) {

      _sendnotification();
      Toast.show("Task Updated", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);

      setState(() {
        _progress = false;
      });
      Navigator.pop(context);
      //_showdialog(context);
    });

  }
  _getallworkers() async {
    var val;
    final databaseReference = FirebaseFirestore.instance;
    await databaseReference.collection("users").where('company',isEqualTo: data["company"]).where('status',isEqualTo: 'Accepted').where('role',isEqualTo: 'farmer').get().then(
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

  _deleteTask() async {
      final databaseReference = FirebaseFirestore.instance;
      print(docid);
      await databaseReference.collection("tasks").doc(docid).delete().then((value) {
        Navigator.pop(context,true);
      });

  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Task"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(child: Icon(Icons.delete),onTap: (){
              _deleteTask();
            },),
          )
        ],
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
                      return 'Please enter a valid title';
                    }
                    return null;
                  },
                  cursorColor: Colors.teal,
                  decoration: InputDecoration(
                      hintText: "Task Title",

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
                child: TextFormField(
                  controller: _description,
                  cursorColor: Colors.teal,
                  minLines: 1,
                  maxLines: 20,
                  decoration: InputDecoration(
                      hintText: "Task Description",
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
                    value: assigned_to,
                    hint: "Assign Task To",
                    searchHint: "Select One Worker",
                    onChanged: (value) {
                      setState(() {
                        assigned_to = value;
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
                child: TextFormField(
                  validator: (var value) {
                    if (value.isEmpty) {
                      return 'Please enter a valid date';
                    }
                    return null;
                  },
                  //focusNode: AlwaysDisabledFocusNode(),
                  controller: _textEditingController,
                  onTap: () {
                    _selectDate(context);
                  },

                  cursorColor: Colors.teal,
                  decoration: InputDecoration(
                      hintText: "Starting Date",
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
                child: TextFormField(
                  validator: (var value) {
                    if (value.isEmpty) {
                      return 'Please enter a valid date';
                    }
                    return null;
                  },
                  //focusNode: AlwaysDisabledFocusNode(),
                  controller: _textEditingController2,
                  onTap: () {
                    _selectDate2(context);
                  },

                  cursorColor: Colors.teal,
                  decoration: InputDecoration(
                      hintText: "Ending Date",
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
                child:  Padding(
                  padding: const EdgeInsets.symmetric(horizontal:20.0),
                  child: DropdownButton(

                    isExpanded: true,
                    hint: Text('Status'),
                    value: status,
                    items: _statusoptions
                        .map((e) =>
                        DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        status = value;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),

              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        child: RoundedButton2(
                          text: _starttime==null?"Starting time":_starttime.format(context),
                          state: false,
                          color: Colors.grey,
                          press: () {
                            _selectstartingtime();
                          },
                        ),
                      ),

                      Padding(padding: EdgeInsets.only(left: 8)),
                      Container(
                        child: RoundedButton2(
                          text: _endtime==null?"Ending time":_endtime.format(context),
                          state: false,
                          color: Colors.grey,
                          press: () {
                            _selectendingtime();
                          },
                        ),
                      ),

                    ],
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
                child: TextFormField(
                 // controller: _title,

                  cursorColor: Colors.teal,
                  decoration: InputDecoration(
                      hintText: company.text,

                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 25, vertical: 13)),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                //width: MediaQuery.of(context).size.width ,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: RoundedButton(
                    text: "Update Task",
                    state: _progress,
                    press: () {
                      if (_formKey.currentState.validate()) {
                        setState(() {
                          _progress=true;
                        });
                        updatetask(context);
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