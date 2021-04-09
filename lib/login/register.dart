import 'package:farmers_app/pending/account_not_approved.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';

import 'login.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final GlobalKey<FormState> _formKey1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey2 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey3 = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _companyid = TextEditingController();
  //final TextEditingController _mobileno = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _confirmpasswordController = TextEditingController();

  bool _success, _progress = false;var _gender,jobtitle,_mobileno,_mobile;
List<String> _genderdropdown=[
    "Male","Female","Other"
  ];
  List<String> _jobtitledropdown=[
    "admin","farmer"
  ];
  int _stepNumber = 1;
  void saveData1(BuildContext context) {
    _formKey1.currentState.save();
  }
  void saveData2(BuildContext context) {
    _formKey2.currentState.save();
  }
  void saveData3(BuildContext context) {
    _formKey3.currentState.save();
  }
  void previousPage(BuildContext context) {

    setState(() {

        _stepNumber = _stepNumber-1;
    });
  }
  void nextPage(BuildContext context) {
print(_mobileno);
    setState(() {
      _stepNumber = _stepNumber+1;
    });
  }

  addnewUser(context) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text).then((value) async {
        final databaseReference = FirebaseFirestore.instance;
        await databaseReference.collection("users")
            .add({
          'email': _emailController.text,
          'username': _username.text,
          'mobileno':_mobileno.toString(),
          'gender':_gender,
          'dateofbirth':_selectedDate,
          'address':_address.text,
          'company':_companyid.text,
          'role':jobtitle,
          'status':'Pending'

        }).then((value) async{
          var x=FirebaseAuth.instance.currentUser;
          //print("current user details");
          print(x);
         // x.updatePhoneNumber(_mobileno.toPhoneAuthCredential());
          Toast.show("Successfully Registered !", context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
          setState(() {
            _success = true;
            _progress=false;
          });
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AccountNotApproved()),
          );

        });
        //     .catchError((e){
        //   print(e.toString());
        //   Toast.show("Something went Wrong ! Try again Later", context,
        //       duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        // }
        // );
      });
    } catch(signUpError) {
      print("inside catch");
      print(signUpError);
        if(signUpError.code == 'email-already-in-use') {
          setState(() {
            _progress=false;
            _stepNumber=1;
          });
          Toast.show("Email id already in use!", context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);

        }
    }

  }

  DateTime _selectedDate=DateTime.now();


  _login() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
  TextEditingController _textEditingController = TextEditingController();

  _selectDate(BuildContext context) async {
    DateTime newSelectedDate = await showDatePicker(
        context: context,
        initialDate: _selectedDate != null ? _selectedDate : DateTime.now(),
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
      _selectedDate = newSelectedDate;
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
    _passwordController.dispose();
    super.dispose();
  }

  bool isValidEmail(val) {
    return RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(val);
  }



formOneBuilder(BuildContext context) {
    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.all(25.0),
            child: SingleChildScrollView(
                child: Column(children: [
                  SizedBox(
                    height: 50,
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Sign Up",
                      style: TextStyle(fontSize: 29.9, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                        "Connect with your manager and check your daily task and schedule",
                        style: TextStyle(color: Colors.grey, fontSize: 18)),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("STEP 1 : Enter Personal Details",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.teal),)
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
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
                          cursorColor: Colors.teal,
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
                          controller: _emailController,
                          validator: (var value) {
                            if (!isValidEmail(value) || value.isEmpty) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.emailAddress,
                          cursorColor: Colors.teal,
                          decoration: InputDecoration(
                              hintText: "Email id",

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
                        child: IntlPhoneField(
                          validator: (var value) {
                            if (value.isEmpty) {
                              return 'Please enter mobile number';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(),
                            ),
                          ),
                          initialCountryCode: 'MY',
                          //controller: _mobileno,
                          initialValue: _mobile,
                          onChanged: (phone) {
                            print(phone.completeNumber);
                            setState(() {
                              _mobileno=phone.completeNumber;
                              _mobile=phone.number;
                            });
                          },
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
                          focusNode: AlwaysDisabledFocusNode(),
                          controller: _textEditingController,
                          onTap: () {
                            _selectDate(context);
                          },

                          cursorColor: Colors.teal,
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
                          cursorColor: Colors.teal,
                          decoration: InputDecoration(
                              hintText: "Address",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 13)),
                        ),
                      ),

                    ],
                  ),
                  SizedBox(height: 30,),
                  Container(
                    child: RoundedButton(
                      text: "Update Data",
                      state: false,
                      press: () {
                        if (_formKey1.currentState.validate()) {
                          saveData1(context);
                          nextPage(context);
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          "Already have Account? Login Here",
                        )),
                    onTap: () {
                      _login();
                    },
                  ),

                ]))));
  }

   formTwoBuilder(BuildContext context) {

    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.all(25.0),
            child: SingleChildScrollView(
                child: Column(children: [
                  SizedBox(
                    height: 50,
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Sign Up",
                      style: TextStyle(fontSize: 29.9, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                        "Connect with your manager and check your daily task and schedule",
                        style: TextStyle(color: Colors.grey, fontSize: 18)),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("STEP 2 : Enter Job Details",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.teal)),
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
                          controller: _companyid,
                          validator: (var value) {
                            if (value.isEmpty) {
                              return 'Please enter company';
                            }
                            return null;
                          },
                          cursorColor: Colors.teal,
                          decoration: InputDecoration(
                              hintText: "Company",
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
                            hint: Text('Job Title'),
                            value: jobtitle,
                            items: _jobtitledropdown
                                .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                jobtitle = value;
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
                                  text: "Previous",
                                  state: false,
                                  press: () {
                                    previousPage(context);
                                  },
                                ),
                              ),

                              Padding(padding: EdgeInsets.only(left: 8)),
                              Container(
                                child: RoundedButton2(
                                  text: "Next",
                                  state: false,
                                  press: () {
                                    if (_formKey2.currentState.validate()) {
                                      saveData2(context);nextPage(context);
                                    }
                                  },
                                ),
                              ),

                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 30,),
                  InkWell(
                    child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          "Already have Account? Login Here",
                        )),
                    onTap: () {
                      _login();
                    },
                  ),

                ]))));

  }

   formThreeBuilder(BuildContext context) {

    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.all(25.0),
            child: SingleChildScrollView(
                child: Column(children: [
                  SizedBox(
                    height: 50,
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Sign Up",
                      style: TextStyle(fontSize: 29.9, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                        "Connect with your manager and check your daily task and schedule",
                        style: TextStyle(color: Colors.grey, fontSize: 18)),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("STEP 3 : Set Password ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.teal)),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Material(
                        elevation: 2.0,color: Colors.grey[200],
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        child: TextFormField(
                          controller: _passwordController,
                          validator: (var value) {
                            if (value.isEmpty) {
                              return 'Password can not be null';
                            }
                            if(value != _confirmpasswordController.text)
                              return "Password Doesn't Match";
                            return null;
                          },
                          cursorColor: Colors.teal,
                          obscureText: true,
                          decoration: InputDecoration(
                              hintText: "Password",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 13)),
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Material(
                        elevation: 2.0,color: Colors.grey[200],
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        child: TextFormField(
                          controller: _confirmpasswordController,
                          validator: (var value) {
                            if (value.isEmpty) {
                              return 'Password can not be null';
                            }
                            if(value != _passwordController.text)
                              return "Password Doesn't Match";
                            return null;
                          },
                          cursorColor: Colors.teal,
                          obscureText: true,
                          decoration: InputDecoration(
                              hintText: "Confirm Password",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 13)),
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                child: RoundedButton(
                                  text: "Previous",
                                  state: false,
                                  press: () {
                                    previousPage(context);
                                  },
                                ),
                              ),

                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  //SizedBox(height: 30,),
                  Container(
                    child: RoundedButton(
                      text: "Sign up",
                      state: _progress,
                      press: () {
                        if (_formKey3.currentState.validate()) {
                          setState(() {
                            _progress = true;
                          });
                          saveData3(context);
                          addnewUser(context);
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Text(_success == null
                        ? ''
                        : (_success
                        ? 'Successfully Registered ' + _emailController.text
                        : 'Registeration failed')),
                  ),

                  InkWell(
                    child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          "Already have Account? Login Here",
                        )),
                    onTap: () {
                      _login();
                    },
                  ),

                ]))));

  }



  @override
  Widget build(BuildContext context) {
    switch (_stepNumber) {
      case 1:
        return Form(
          key: _formKey1,
          child:
          this.formOneBuilder(context),
        );
        break;

      case 2:
        return Form(
          key: _formKey2,
          child:
          this.formTwoBuilder(context),
        );
        break;
      case 3:
        return Form(
          key: _formKey3,
          child:
          this.formThreeBuilder(context),
        );
        break;
    }
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
    this.color = Colors.teal,
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      width: size.width * 0.8,
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
this.color = Colors.teal,
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


class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}