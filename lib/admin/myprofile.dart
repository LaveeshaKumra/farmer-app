import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmers_app/login/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:toast/toast.dart';

import 'package:intl/intl.dart';


class MyProfilePage extends StatefulWidget {
  var email;
  MyProfilePage(i){
    this.email=i;
    print(email);
  }
  @override
  _ProfilePageState createState() => _ProfilePageState(this.email);
}

class _ProfilePageState extends State<MyProfilePage> {
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
  var  profile;
  var  _image;
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
        profile=value.docs[0]['profile'];
      });
    });
  }
  var _firebaseAuth=FirebaseAuth.instance;
  _sendemail() {
    return _firebaseAuth.sendPasswordResetEmail(email: _emailController.text).then((value){

      _showdialog();

    });

  }

  _showdialog(){
    return AwesomeDialog(
      context: context,
      dialogType: DialogType.SUCCES,
      animType: AnimType.TOPSLIDE,
      title: 'Reset your password',
      desc: 'Email Sent Successfully to ${_emailController.text}',
      //showCloseIcon: true,
      // btnCancelOnPress: () {},
      btnOkOnPress: () {Navigator.pop(context);},
    )..show();
  }

  Future<bool> resetpswddialog() {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are You Sure?'),
        content:new Text('Do You Want To Reset Your Password?') ,
        actions: <Widget>[
          new FlatButton(
            onPressed: () {_sendemail();} ,
            child: new Text('Yes'),
          ),
          new FlatButton(
            onPressed: () =>  Navigator.pop(context),
            child: new Text('No'),
          ),
        ],
      ),
    ) ??
        false;
  }
  _updateuser(context) async {
   if(_image!=null){
     var url;
     FirebaseStorage storageReference = FirebaseStorage.instance;
     Reference ref=storageReference.ref()
         .child('profile/${_image.path.split('/').last}');

     UploadTask  uploadTask = ref.putFile(_image);
     uploadTask.then((res) async {
       url=await res.ref.getDownloadURL();
       print(url);
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
           'address': _address.text,
           'profile': url
         }).then((value) {
           Toast.show("Profile Uploaded", context,
               duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
           setState(() {
             _progress = false;
           });
         });
       });
     });
   }
   else{
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

  }

  ///image
  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  _removeProfile(context) async {
    setState(() {
      _image = null;
      profile = null;
    });
  }

  void _profile(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.edit),
                      title: new Text('Change Profile'),
                      onTap: () {
                        _showPicker(context);
                      }),
                  new ListTile(
                    leading: new Icon(Icons.delete),
                    title: new Text('Remove Profile'),
                    onTap: () {
                      _removeProfile(context);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }



  _imgFromCamera() async {
    var picker=ImagePicker();
    var pickedFile = await picker.getImage(
        source: ImageSource.camera, imageQuality: 50);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        profile = "";
        Toast.show("Uploading....", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);

        // updateImage();
      } else {
        Toast.show("No image selected", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      }
    });

  }
  _imgFromGallery() async {
    var picker=ImagePicker();
    var pickedFile = await picker.getImage(
        source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        profile = "";
        Toast.show("Uploading....", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);

        //updateImage();
      } else {
        Toast.show("No image selected", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      }
    });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Profile"),
        actions: [
          InkWell(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.vpn_key),
            ),
            onTap: (){
              resetpswddialog();
            },
          )
        ],
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Center(
                    child: profile != null && profile != ""
                        ? GestureDetector(
                      onTap: () {
                        _profile(context);
                      },
                      child: Container(
                        // margin: const EdgeInsets.all(15.0),
                        // padding: const EdgeInsets.all(3.0),
                        // decoration: BoxDecoration(
                        //     border: Border.all(color: Colors.blueAccent)
                        // ),
                        //borderRadius: BorderRadius.circular(50),
                        child: Image.network(
                          profile,
                          width: 150,
                          height: 150,
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                        : _image != null
                        ? Container(
                      //borderRadius:
                      //BorderRadius.circular(50),
                      child: Image.file(
                        _image,
                        width: 150,
                        height: 150,
                        fit: BoxFit.fitHeight,
                      ),
                    )
                        : GestureDetector(
                      onTap: () {
                        _showPicker(context);
                      },
                      child: Container(
                        // margin: const EdgeInsets.all(15.0),
                        // padding: const EdgeInsets.all(3.0),
                        decoration: BoxDecoration(
                          //border: Border.all(color: Theme.of(context).primaryColor,width: 5),
                          color: Colors.grey[200],

                        ),

                        width: 150,
                        height: 150,
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30,),
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
                        hintText: _jobtitle.text,
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
                  color: Theme.of(context).primaryColor,

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