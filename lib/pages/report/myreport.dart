import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intranet/api/ServiceHandler.dart';
import 'package:intranet/api/request/report/myreport_request.dart';
import 'package:intranet/pages/iface/onResponse.dart';
import 'package:intranet/pages/reports.dart';

import '../../api/response/report/my_report.dart';
import '../helper/utils.dart';
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
      backgroundColor: LightColors.kLightYellow,
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
            child: Stack(
              children: [
                SafeArea(
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
      print('data not found');
      return Utility.emptyDataSet(context);
    } else {
      return Flexible(
          child: ListView.builder(
        controller: ScrollController(),
        itemCount: mReportList.length,
        shrinkWrap: true,
        physics: AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyReportScreen(
                          title: mReportList[index].title,
                          url: mReportList[index].webViewURL)));
            },
            child: Container(
              height: 50,
              color: Colors.white,
              child: Center(child: Text(mReportList[index].title)),
            ),
          );
        },
      ));
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
        mReportList.addAll(response.responseData);
        setState(() {});
      }
    }
  }
}
