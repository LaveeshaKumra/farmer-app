import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';

class ReportPage extends StatefulWidget {
  var email;
  ReportPage(e){this.email=e;}
  @override
  _ReportPageState createState() => _ReportPageState(this.email);
}

class _ReportPageState extends State<ReportPage> {
  List<charts.Series<Data, String>> _seriesBarData;
  List<Data> mydata;
  var monthdata={'January':0,'February':0,'March':0,'April':0,'May':0,'June':0,'July':0,'August':0,'September':0,'October':0,'November':0,'December':0};

  var email;
  @override
  void initState() {
    super.initState();
  }


  _convertmonth(d){
    final DateFormat formatter = DateFormat('MMMM');
    final String formatted = formatter.format(d);
    return formatted;
  }




  _ReportPageState(e){this.email=e;}
  List<charts.Series> seriesList;

  _generateData(mydata) {
    _seriesBarData = List<charts.Series<Data, String>>();
    _seriesBarData.add(
      charts.Series(
        domainFn: (Data sales, _) => sales.month.substring(0,3),
        measureFn: (Data sales, _) => sales.hours/60,
        colorFn: (Data sales, _) =>
            charts.ColorUtil.fromDartColor(Colors.red),
        id: 'Records',
        data: mydata,
        labelAccessorFn: (Data row, _) => "${row.month}",
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Report for ${DateTime.now().year}')),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('attendance').where("email",isEqualTo: email).where("out_time",isNotEqualTo: "").snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return LinearProgressIndicator();
            } else {

              var x;
              List<Data> data = snapshot.data.docs
                  .map((documentSnapshot) {
                    if(documentSnapshot.data()['in_time'].toDate().year==DateTime.now().year){
                      monthdata[_convertmonth(documentSnapshot.data()['in_time'].toDate())]=monthdata[_convertmonth(documentSnapshot.data()['in_time'].toDate())]+(documentSnapshot.data()['out_time'].toDate()).difference(documentSnapshot.data()['in_time'].toDate()).inMinutes;
                    }

              })
                  .toList();
              var xx;
               List<Data> data2=[];
               if(monthdata==null){
               }
               var arr=monthdata.keys.toList();
               for(int i=0;i<monthdata.keys.length;i++){
                  x={'month':arr[i],'hours':monthdata[arr[i]]};
                  data2.add(Data.fromMap(x));
               }

              return _buildChart(context, data2);
            }
          },
        ),
      ],
    );
  }
  Widget _buildChart(BuildContext context, List<Data> saledata) {
    mydata = saledata;
    _generateData(mydata);
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
        height: MediaQuery.of(context).size.height*0.8,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: charts.BarChart(_seriesBarData,
            animate: true,
            //vertical: true,
            animationDuration: Duration(seconds:1),
          ),
        ),
      ),
    );
  }

 }



class Data{
  final String month;
  final int hours;
  Data(this.month,this.hours);

  Data.fromMap(Map<String, dynamic> map)
      : assert(map['month'] != null),
        assert(map['hours'] != null),
        month = map['month'],
        hours = map['hours'];

  @override
  String toString() => "Recordinsidedata<$month -> month:$hours -> hours>";
}