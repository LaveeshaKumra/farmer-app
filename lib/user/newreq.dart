import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmers_app/admin/addtask.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:awesome_dialog/awesome_dialog.dart';


class AddReq extends StatefulWidget {
  var email,company,name;
  AddReq(e,n,c){this.email=e;this.name=n;this.company=c;}
  @override
  _AddReqState createState() => _AddReqState(this.email,this.name,this.company);
}

class _AddReqState extends State<AddReq> {
  var email,_type,company,name;
  _AddReqState(e,n,c){this.email=e;this.name=n;this.company=c;}
  List<String> _leavetype=[
    "Sick Leave","Day Off","Others"
  ];
  var _progress=false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();

  bool _success;

  TextEditingController _textEditingController = TextEditingController();
  DateTime _startdate=DateTime.now();
  DateTime _enddate=DateTime.now();

  _showdialog(){
    return AwesomeDialog(
      context: context,
      dialogType: DialogType.SUCCES,
      animType: AnimType.TOPSLIDE,
      title: 'Leave Request Sent Successfully',
      desc: 'We Have Sent Your Request to manager!',
      //showCloseIcon: true,
      // btnCancelOnPress: () {},
      btnOkOnPress: () {Navigator.pop(context);},
    )..show();
  }

  _selectDate(BuildContext context) async {
    DateTime newSelectedDate = await showDatePicker(
        context: context,
        initialDate: _startdate != null ? _startdate : DateTime.now(),
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
        _enddate = newSelectedDate;
      });

      _textEditingController2
        ..text = DateFormat.yMMMd().format(_enddate)
        ..selection = TextSelection.fromPosition(TextPosition(
            offset: _textEditingController2.text.length,
            affinity: TextAffinity.upstream));
    }
  }

  addwork() async {
    setState(() {
      _progress=true;
    });
    print(_enddate.runtimeType);
    print(_startdate.runtimeType);
    final databaseReference = FirebaseFirestore.instance;
    await databaseReference.collection("timeoff")
        .add({
      'email':email,
      'title': _title.text,
      'description':_description.text,
      'company':company,
      'username':name,
      "end_date":_enddate,
      "start_date":_startdate,
      "status":"Pending"
    }).then((value) async {
      print(value);
      //await sendAndRetrieveMessage('${list1[i]}-Vrinda');
      setState(() {
        _progress=false;
      });

      _showdialog();
    });



  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Request"),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          color: Colors.grey[100],
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)), //here
                  ),

              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ListView(
                  children: [
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
                            return 'Please enter a valid subject';
                          }
                          return null;
                        },
                        cursorColor: Colors.teal,
                        decoration: InputDecoration(
                            hintText: "Leave Subject",

                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 25, vertical: 13)),
                      ),
                    ),

                    SizedBox(
                      height: 20,
                    ), Material(
                      color: Colors.grey[200],
                      elevation: 2.0,
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal:20.0),
                        child: DropdownButton(

                          isExpanded: true,
                          hint: Text('Leave Type'),
                          value: _type,
                          items: _leavetype
                              .map((e) =>
                              DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _type = value;
                            });
                          },
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
                      child: TextFormField(
                        controller: _description,
                        cursorColor: Colors.teal,
                        minLines: 3,
                        maxLines: 20,
                        decoration: InputDecoration(
                            hintText: "Notes",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 25, vertical: 13)),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    RoundedButton(
                      text: "Apply Now",
                      state: _progress,
                      press: () {

                        if (_formKey.currentState.validate()) {
                          setState(() {
                            _progress=true;
                          });
                          addwork();
                        }
                        // }
                      },
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Text(_success == null
                          ? ''
                          : (_success
                          ? 'Request Successfully Sent'
                          : ' failed')),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
