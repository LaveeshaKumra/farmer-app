import 'package:farmers_app/login/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toast/toast.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  var _firebaseAuth=FirebaseAuth.instance;
  _sendemail() {
    return _firebaseAuth.sendPasswordResetEmail(email: _emailController.text).then((value){
      Toast.show("Email sent to ${_emailController.text}", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      setState(() {
        _progress=false;
      });
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
          LoginPage()), (Route<dynamic> route) => false);

    });

  }
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var _code;
  final TextEditingController _emailController = TextEditingController();
  bool isValidEmail(val) {
    return RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(val);
  }
  bool _success, _progress = false;


  @override
  Widget build(BuildContext context) {


    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            "Back",
            style: TextStyle(color: Colors.black),
          ),
          leading: new IconButton(
            icon: new Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          elevation: 0,
        ),
        body: Padding(
            padding: const EdgeInsets.all(25.0),
            child: SingleChildScrollView(
                child: Column(children: [
              SizedBox(
                height: 100,
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Forget Your Password?",
                  style: TextStyle(fontSize: 29.9, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Text("Enter email id associated with your account",
                    style: TextStyle(color: Colors.grey, fontSize: 18)),
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 30,
                    ),
                    // IntlPhoneField(
                    //   decoration: InputDecoration(
                    //     labelText: 'Phone Number',
                    //     border: OutlineInputBorder(
                    //       borderSide: BorderSide(),
                    //     ),
                    //   ),
                    //   initialCountryCode: 'MY',
                    //   controller: _mobileno,
                    //   onChanged: (phone) {
                    //     _code = phone.completeNumber;
                    //   },
                    // ),

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
                      height: 25,
                    ),

                    Container(
                      child: RoundedButton(
                        text: "Send",
                        state: _progress,
                        press: () {
                          if (_formKey.currentState.validate()) {
                            setState(() {
                              _progress = true;
                            });
                            _sendemail();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 30,
              ),
            ]))));
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
