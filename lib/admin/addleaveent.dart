import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

import 'addreward.dart';

class AddLeaveEntitlement extends StatefulWidget {
  var email;
  AddLeaveEntitlement(e) {
    this.email = e;
  }

  @override
  _AddLeaveEntitlementState createState() => _AddLeaveEntitlementState( this.email);
}

class _AddLeaveEntitlementState extends State<AddLeaveEntitlement> {
  var email;
  _AddLeaveEntitlementState(e) {
    this.email = e;
    _getid();
  }

  var docid;
  _getid() async {
    final databaseReference = FirebaseFirestore.instance;
    await databaseReference.collection("users").where('email',isEqualTo: email).get().then((value){setState(() {
      docid= value.docs[0].id;
    });});

  }
  var _progress=false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _title = TextEditingController();
  List<String> giftdropdown=[
    "Hospitalisation leave","Emergency Leave","Maternity Leave","Paternity Leave","Compassionate Leave","Annual Leave","Sick Leave","Others"
  ];
  bool isNumericUsingRegularExpression(String string) {
    final numericRegex =
    RegExp(r'^-?(([0-9]*)|(([0-9]*)\.([0-9]*)))$');

    return numericRegex.hasMatch(string);
  }
  var type;
  bool _success;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Leave Entitlement"),
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal:20.0),
                  child: DropdownButton(

                    isExpanded: true,
                    hint: Text('Leave Entitlement'),
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
                    if (value.isEmpty || !isNumericUsingRegularExpression(value)) {
                      return 'Please enter valid number';
                    }
                    return null;
                  },
                  minLines: 1,
                  maxLines: 5,
                  cursorColor: Theme.of(context).primaryColor,
                  decoration: InputDecoration(
                      hintText: "Enter number of leave entitlement",

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
                    text: "Add Leave Entitlement",
                    state: _progress,
                    color:Theme.of(context).primaryColor,
                    press: () {

                      // if(_assignedto==null){
                      //   Toast.show("Add A farmer to assign task",context,duration: Toast.LENGTH_SHORT, gravity:  Toast.TOP);
                      // }
                      // else{
                      if (_formKey.currentState.validate()) {
                        setState(() {
                          _progress=true;
                        });
                        addleave();
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
                    ? 'Successfully Added '
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

  addleave() async {
    final databaseReference = FirebaseFirestore.instance;
    await databaseReference
        .collection("users")
        .doc(docid).get().then((value) async {
          var x= (value.data()['leaveEnt']);
          x[type]=_title.text;
          print(x);
      await databaseReference
          .collection("users")
          .doc(docid)
          .update({
        'leaveEnt': x
      }).then((value) {
        Toast.show("Leave Entitlement Added", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        Navigator.pop(context);

      });
    });



  }
}
