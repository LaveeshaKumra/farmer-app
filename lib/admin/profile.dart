import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmers_app/login/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:toast/toast.dart';

import 'package:intl/intl.dart';


class ProfilePage extends StatefulWidget {
  var email;
  ProfilePage(i){
    this.email=i;
    print(email);
  }
  @override
  _ProfilePageState createState() => _ProfilePageState(this.email);
}

class _ProfilePageState extends State<ProfilePage> {
  var email;
  TextEditingController _textEditingController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
var genders=["Male","Female","Others"];
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _companyid = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _mobileno = TextEditingController();
  final TextEditingController _jobtitle = TextEditingController();

  DateTime _selectedDate=DateTime.now();

  bool _success, _progress = false;var _gender;
  _ProfilePageState(i) {
    email=i;
    _getUser();

  }


  List<String> _genderdropdown=[
    "Male","Female","Other"
  ];



  _selectDate(BuildContext context) async {
    DateTime newSelectedDate = await showDatePicker(
        context: context,
        initialDate: _selectedDate != null ? _selectedDate : DateTime.now(),
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
      _selectedDate = newSelectedDate;
      _textEditingController
        ..text = DateFormat.yMMMd().format(_selectedDate)
        ..selection = TextSelection.fromPosition(TextPosition(
            offset: _textEditingController.text.length,
            affinity: TextAffinity.upstream));
    }
  }
  _check(){
    if(_selectedDate!=null){
      _textEditingController
        ..text = DateFormat.yMMMd().format(_selectedDate)
        ..selection = TextSelection.fromPosition(TextPosition(
            offset: _textEditingController.text.length,
            affinity: TextAffinity.upstream));
    }

  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool isValidEmail(val) {
    return RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(val);
  }

  final databaseReference = FirebaseFirestore.instance;

  _getUser() async {
    // var _user = await FirebaseAuth.instance.currentUser;
    // setState(() {
    //   id = _user.email;
    // });
    // print(id);
    final databaseReference = FirebaseFirestore.instance;
    await databaseReference
        .collection("users")
        .where('email', isEqualTo: email)
        .get()
        .then((value) {
          print(value);
          print(value.docs);
      setState(() {
        _jobtitle.text = value.docs[0]['role'];
        _emailController.text = value.docs[0]['email'];
        _mobileno.text = value.docs[0]['mobileno'];
        print(_mobileno.text);
        _username.text=value.docs[0]['username'];
        _companyid.text = value.docs[0]['company'];
        _address.text = value.docs[0]['address'];
        _selectedDate = value.docs[0]['dateofbirth'].toDate();
        _check();
        _gender = value.docs[0]['gender'];


      });
    });
  }

  _updateuser(context) async {

    await databaseReference
        .collection("users")
        .where('email', isEqualTo: _emailController.text)
        .get()
        .then((value) async {
      var i = value.docs[0].id;
      print(i);
      await databaseReference
          .collection("users")
          .doc(i)
          .update({
        'username': _username.text,
        'mobileno': _mobileno.text,
        'gender': _gender,
        'dateofbirth': _selectedDate,
        'address': _address.text
      }).then((value) {
        Toast.show("Profile Uploaded", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        setState(() {
          _progress = false;
        });
      });
    });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View Profile"),

      ),
      body: _emailController.text == null
          ? Center(
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
      )
          : Form(
          key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
        children: <Widget>[

                    Material(
                      color: Colors.grey[200],
                      elevation: 2.0,
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      child: TextFormField(
                        controller: _username,
                        validator: (var value) {
                          if (value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                        cursorColor: Theme.of(context).primaryColor,
                        decoration: InputDecoration(
                            hintText: "User name",

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
                        // controller: _emailController,
enabled: false,
                        keyboardType: TextInputType.emailAddress,
                        cursorColor: Theme.of(context).primaryColor,
                        decoration: InputDecoration(
                            hintText: _emailController.text,

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
                        controller: _mobileno,

                        keyboardType: TextInputType.number,
                        cursorColor: Theme.of(context).primaryColor,
                        decoration: InputDecoration(
                            hintText: "Mobile No",

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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal:20.0),
                        child: DropdownButton(

                          isExpanded: true,
                          hint: Text('Gender'),
                          value: _gender,
                          items: _genderdropdown
                              .map((e) =>
                              DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _gender = value;
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
                      child: TextField(
                        //focusNode: AlwaysDisabledFocusNode(),
                        controller: _textEditingController,
                        onTap: () {
                          _selectDate(context);
                        },

                        cursorColor: Theme.of(context).primaryColor,
                        decoration: InputDecoration(
                            hintText: "Date of Birth",
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
                        controller: _address,
                        validator: (var value) {
                          if (value.isEmpty) {
                            return 'Please enter your address';
                          }
                          return null;
                        },
                        cursorColor: Theme.of(context).primaryColor,
                        decoration: InputDecoration(
                            hintText: "Address",
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
                enabled: false,
                //controller: _companyid,

                cursorColor: Theme.of(context).primaryColor,

                decoration: InputDecoration(
                    hintText: _companyid.text,
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal:20.0),
                child: TextFormField(
                  enabled: false,
                  //controller: _jobtitle,

                  cursorColor: Theme.of(context).primaryColor,
                  decoration: InputDecoration(
                      hintText: _jobtitle.text=="admin"?"Farmer":"Worker",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 25, vertical: 13)),
                ),
              ),
          ),
          SizedBox(height: 30,),
          Container(
            child: RoundedButton(
              text: "Update",
              state: _progress,
              press: () {
                if (_formKey.currentState.validate()) {
                  setState(() {
                    _progress = true;
                  });
                  _updateuser(context);
                }
              },
            ),
          ),
        ],
      ),
            ),
          ),
    );
  }
}