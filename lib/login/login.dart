import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmers_app/admin/adminhome.dart';
import 'package:farmers_app/pending/account_not_approved.dart';
import 'package:farmers_app/super_admin/super_admin_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'forgetpsw.dart';
import '../user/home.dart';
import 'register.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _success, _progress = false;
  _register() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Register()),
    );
  }


  void _signIn() async {

      FirebaseAuth.instance.signInWithEmailAndPassword(email: _emailController.text,
          password: _passwordController.text).then((value) async {
            final databaseReference = FirebaseFirestore.instance;
        await databaseReference.collection("users").where('email',isEqualTo: value.user.email).get().then((val) async {
          if(val.docs.isNotEmpty){
            if(val.docs[0]['role']=="super_admin"){
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SuperAdminHome()),
              );
            }
            else if(val.docs[0]['role']=="admin"){
              if(val.docs[0]['status']=="Accepted"){
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AdminPage()),
                );
              }
              else{
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AccountNotApproved()),
                );
              }

            }
            else{
              if(val.docs[0]['status']=="Accepted"){
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MyHomePage()),
                );
              }
              else{
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AccountNotApproved()),
                );
              }

            }
            setState(() {
              _success = true;
            });
          }
          else{
            setState(() {
              _success = false;
            });
          }
          setState(() {
            _progress=true;
          });

        });
      }).catchError((e){
        print(e);
        setState(() {
          _progress=false;
        });
        if(e.code == 'user-not-found') {
          setState(() {
            _progress=false;
            //_stepNumber=1;
          });
          Toast.show("Email id do not exist", context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);

        }
        else
        Toast.show("Something went wrong", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);

      });


  }

  _forgetpswd() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ForgotPassword()),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  "Farmer Management App",
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
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 30,
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
                      elevation: 2.0,
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      child: TextFormField(
                        controller: _passwordController,
                        validator: (var value) {
                          if (value.isEmpty) {
                            return 'Password can not be null';
                          }
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
                    InkWell(
                      child: Container(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "Forget Password?",
                          )),
                      onTap: () {
                        _forgetpswd();
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      child: RoundedButton(
                        text: "Login",
                        state: _progress,
                        press: () {
                          if (_formKey.currentState.validate()) {
                            setState(() {
                              _progress = true;
                            });
                            _signIn();
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
                              ? 'Successfully Login ' + _emailController.text
                              : 'Login failed')),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            "Don't have Account? Sign Up Here",
                          )),
                      onTap: () {
                        _register();
                      },
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
