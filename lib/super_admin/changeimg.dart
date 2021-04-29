// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
//
// class ChangeImg extends StatefulWidget {
//   @override
//   _ChangeImgState createState() => _ChangeImgState();
// }
//
// class _ChangeImgState extends State<ChangeImg> {
//   Query  collectionStream = FirebaseFirestore.instance.collection('splash_screen');
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Change Image of Login Screen"),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: collectionStream.snapshots(),
//         builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (snapshot.hasError) {
//             return Text('Something went wrong');
//           }
//
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: <Widget>[
//                   SizedBox(
//                     child: CircularProgressIndicator(
//                         valueColor: new AlwaysStoppedAnimation<Color>(
//                             Theme.of(context).primaryColor)),
//                     width: 30,
//                     height: 30,
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(top: 16.0),
//                     child: Text("Loading.."),
//                   )
//                 ],
//               ),
//             );
//           }
//           if(snapshot.data.docs.length==0){
//             return Center(
//               child: Container(
//                 child: Image.asset("assets/nodata.png",width: 300,),
//               ),
//             );
//           }
//           return new ListView(
//             children: snapshot.data.docs.map((DocumentSnapshot document) {
//               return new ListTile(
//                 title: new Text(document.data()['title']),
//                 subtitle: new Text(document.data()['description']),
//               );
//             }).toList(),
//           );
//         },
//       ),
//     );
//   }
// }
