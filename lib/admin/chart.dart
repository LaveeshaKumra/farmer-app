import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';

class UserReportChart extends StatefulWidget {
  var email;
  UserReportChart(e){this.email=e;}
  @override
  _ReportPageState createState() => _ReportPageState(this.email);
}

class _ReportPageState extends State<UserReportChart> {
  List<charts.Series<Data, String>> _seriesBarData;
  List<Data> mydata;
  var monthdata={'January':0,'February':0,'March':0,'April':0,'May':0,'June':0,'July':0,'August':0,'September':0,'October':0,'November':0,'December':0};

  var email;
  @override
  void initState() {
    super.initState();
  }
  _convertdate(d){
    final DateFormat formatter = DateFormat('dd MMMM');
    final String formatted = formatter.format(d);
    return formatted;
  }

  _convertmonth(d){
    final DateFormat formatter = DateFormat('MMMM');
    final String formatted = formatter.format(d);
    return formatted;
  }




  _ReportPageState(e){this.email=e;print(this.email);}
  List<charts.Series> seriesList;

  _generateData(mydata) {
    print(mydata);
    _seriesBarData = List<charts.Series<Data, String>>();
    _seriesBarData.add(
      charts.Series(
        domainFn: (Data sales, _) => sales.month.substring(0,3),
        measureFn: (Data sales, _) => sales.hours/60,
        colorFn: (Data sales, _) =>
            charts.ColorUtil.fromDartColor(Theme.of(context).primaryColor),
        id: "Report",
        data: mydata,
        //domainLowerBoundFn: (Data sales, _) => sales.hours.toString(),
        keyFn: (Data row, _) => row.hours.toString(),

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
              // List<Sales> sales = snapshot.data.docs
              //     .map((documentSnapshot) {
              //       print(documentSnapshot.data());
              //   Sales.fromMap(documentSnapshot.data());
              //   })
              //     .toList();
              // for(int i=0;i<sales.length;i++){
              //   print(_convertmonth(sales[i].intime));
              //   int index=sales[i].intime.month-1;
              //   monthdata[index][_convertmonth(sales[i].intime)]=monthdata[index][_convertmonth(sales[i].intime)]+1;
              //
              // }
              // print(sales);
              // print(monthdata);
              var x;
              List<Data> data = snapshot.data.docs
                  .map((documentSnapshot) {
                if(documentSnapshot.data()['in_time'].toDate().year==DateTime.now().year){
                  print("in 1");
                  print(monthdata[_convertmonth(documentSnapshot.data()['in_time'].toDate())]);
                  monthdata[_convertmonth(documentSnapshot.data()['in_time'].toDate())]=monthdata[_convertmonth(documentSnapshot.data()['in_time'].toDate())]+(documentSnapshot.data()['out_time'].toDate()).difference(documentSnapshot.data()['in_time'].toDate()).inMinutes;
                  //x={ 'month':_convertmonth(documentSnapshot.data()['in_time'].toDate()),'hours':monthdata[_convertmonth(documentSnapshot.data()['in_time'].toDate())]};
                }

              })
                  .toList();
              print("data");
              print(monthdata);
              var xx;
              List<Data> data2=[];
              if(monthdata==null){
              }
              var arr=monthdata.keys.toList();
              for(int i=0;i<monthdata.keys.length;i++){
                x={'month':arr[i],'hours':monthdata[arr[i]]};
                data2.add(Data.fromMap(x));
              }
              // monthdata.map((key, value) {
              //   print(key+"kkkkkkkkkkkkk");
              //   print(value);
              //   x={'month':key,'hours':value};
              //   print("$x xxxxxxxx");
              //
              //   data2.add(Data.fromMap(x));
              // });
              print(data2);
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
//
//   static List<charts.Series<Data, String>> _createSampleData() {
//     final data = [
//       new Data('2014', 5),
//       new Data('2015', 25),
//       new Data('2016', 100),
//       new Data('2017', 75),
//     ];
//
//     return [
//       new charts.Series<Data, String>(
//         id: 'Sales',
//         colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
//         domainFn: (Data sales, _) => sales.month,
//         measureFn: (Data sales, _) => sales.hours ,
//         data: data,
//       )
//     ];
//   }
// }
}
//
// class Data{
//   final String month;
//   final int hours;
//   Data(this.month,this.hours);
//
// }

class Sales {
  final DateTime intime;
  final DateTime outtime;
  final int diff;
  Sales(this.intime,this.outtime,this.diff);

  Sales.fromMap(Map<String, dynamic> map)
      : assert(map['in_time'] != null),
        assert(map['out_time'] != null),
        intime = map['in_time'].toDate(),
        outtime = map['out_time'].toDate(),
        diff=(map['out_time'].toDate().difference(map['in_time'].toDate()).inHours);
  // saleYear=map['saleYear'];

  @override
  String toString() => "Record<$intime:$diff>";
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