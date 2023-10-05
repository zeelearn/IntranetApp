import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Intranet/api/ServiceHandler.dart';
import 'package:Intranet/api/request/report/myreport_request.dart';
import 'package:Intranet/pages/iface/onResponse.dart';
import 'package:Intranet/pages/reports.dart';

import '../../api/response/report/my_report.dart';
import '../helper/constants.dart';
import '../helper/utils.dart';
import '../model/filter.dart';
import '../pjp/mypjp.dart';
import '../pjp/pjp_report.dart';
import '../utils/theme/colors/light_colors.dart';

class MyReportsScreen extends StatefulWidget {
  @override
  _MyReportScreenState createState() => _MyReportScreenState();
}

class _MyReportScreenState extends State<MyReportsScreen>
    implements onResponse {
  List<ReportInfo> mReportList = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      this.loadData();
    });
  }

  loadData() async {
    MyReportRequest request = MyReportRequest(Usertype: 'All');
    IntranetServiceHandler.getMyReport(request, this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('My Reports'),
        // You can add title here
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.blue.withOpacity(0.7),
        //You can make this transparent
        elevation: 0.0, //No shadow
      ),
      body: RefreshIndicator(
          onRefresh: _pullRefresh,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Card(
                    child: getListView(),
                  ),
                ),
              ],
            ),
          )),
    );
  }

  Future<void> _pullRefresh() async {
    MyReportRequest request = MyReportRequest(Usertype: 'All');
    IntranetServiceHandler.getMyReport(request, this);
  }

  getListView() {
    if (mReportList == null || mReportList.length <= 0) {
      debugPrint('data not found');
      return Utility.emptyDataSet(context,"Reports are not avaliable");
    } else {
      return ListView.builder(
        controller: ScrollController(),
        itemCount: mReportList.length,
        shrinkWrap: true,

        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              if(index==0){
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            MyPjpReportScreen(
                              mFilterSelection: FilterSelection(
                                  filters: [],
                                  type: FILTERStatus.MYTEAM),)));
              }else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            MyReportScreen(
                                title: mReportList[index].title,
                                url: mReportList[index].webViewURL)));
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10,),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 3,
                        color: Color(0x430F1113),
                        offset: Offset(0, 1),
                      )
                    ],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    title: Text(mReportList[index].title),
                    trailing: Icon(Icons.navigate_next),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  @override
  void onError(value) {
    Navigator.of(context).pop();
  }

  @override
  void onStart() {
    Utility.showLoaderDialog(context);
  }

  @override
  void onSuccess(value) {
    Navigator.of(context).pop();
    if (value is MyReportResponse) {
      MyReportResponse response = value;
      if (response != null && response.responseData != null) {
        mReportList.clear();
        mReportList.add(ReportInfo(title: 'PJP CVF Report', webViewURL: '') );
        mReportList.addAll(response.responseData);
        setState(() {});
      }
    }
  }
}
