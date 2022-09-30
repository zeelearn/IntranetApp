import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intranet/api/response/employee_list_response.dart';
import 'package:intranet/pages/helper/LocalConstant.dart';
import 'package:intranet/pages/helper/utils.dart';
import 'package:intranet/pages/model/NotificationDataModel.dart';
import 'package:intranet/pages/utils/theme/colors/light_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/APIService.dart';
import 'helper/DatabaseHelper.dart';

class NotificationListScreen extends StatefulWidget {

  NotificationListScreen({Key? key}) : super(key: key);

  @override
  _NotificationListScreenState createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen>
    with WidgetsBindingObserver {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();
  int employeeId = 0;

  List<NotificationDataModel> mNotificationList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getUserInfo();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('didChangeAppLifecycleState ${state} ');
    if (state == AppLifecycleState.resumed) {
      getNotifications();
    }
  }

  getNotifications() async {
    DBHelper helper=new DBHelper();
    List<NotificationDataModel> notificationList =  await helper.getNotificationList();
    for(int index=0;index<notificationList.length;index++){
      try {
        if(notificationList[index].type.isEmpty){
          String message = notificationList[index].message;
          message = message.replaceAll("{", "{\"");
          message = message.replaceAll("}", "\"}");
          message = message.replaceAll(":", "\":\"");
          message = message.replaceAll(", ", "\",\"");
          //print(message);
          var json = jsonDecode(message);
          notificationList[index].type=json['type'];
        }

        if (notificationList[index].type.trim() == 'ATNDC' ||
            notificationList[index].type.trim() == 'OutDoor' ||
            notificationList[index].type.trim() == 'Leave' ||
            notificationList[index].type.trim() == 'LVREQ') {
          String message = notificationList[index].message;
          //print(message);
          message = message.replaceAll("{", "{\"");
          message = message.replaceAll("}", "\"}");
          message = message.replaceAll(":", "\":\"");
          message = message.replaceAll(", ", "\",\"");
          //print(message);
          var json = jsonDecode(message);
          String time = notificationList[index].time=='' || notificationList[index].time ==null ? 'NA' :  getParsedShortDate(notificationList[index].time);

          //print('decode ${json}');
          mNotificationList.add(NotificationDataModel(message: json['message'],
              title: json['title'],
              image: '',
              URL: '',
              type: json['type'],
          time: time));

          //print(json['message']);
        } else if (notificationList[index].type.trim() == 'promo' ||
            notificationList[index].title.contains('URL')) {
          String message = notificationList[index].message;
          print('message is '+message);
          message = message.replaceAll("{", "{\"");
          message = message.replaceAll("}", "\"}");
          message = message.replaceAll(":", "\":\"");
          message = message.replaceAll(", ", "\",\"");
          message = message.replaceAll("\"", "");
          //message = message.replaceAll("https://", "____");
          print('message was '+message);
          var json = jsonDecode(message);
          print(mNotificationList[index].image);
          String time = notificationList[index].time=='' || notificationList[index].time ==null ? 'NA' :  getParsedShortDate(notificationList[index].time);
          mNotificationList.add(NotificationDataModel(message: json['message'],
              title: json['title'],
              image: json['image'].toString().replaceAll('____', 'https://'),
              URL: json['URL'],
              type: json['type'],
              time: time));
        } else {
          mNotificationList.add(notificationList[index]);
        }
      }catch(e){
        print(e.toString());
      }
    }
    setState(() {

    });
  }

  String getParsedShortDate(String value) {
    return DateFormat("MMM-dd").format(parseDateTime(value));
  }

  DateTime parseDateTime(String value) {
    DateTime dt = DateTime.now();
    //2022-09-27T32:12:02
    try {
      dt = new DateFormat('yyyy-MM-ddTmm:hh:ss').parse(value);
      //print('asasdi   ' + dt.day.toString());
    } catch (e) {
      e.toString();
    }
    return dt;
  }

  Future<void> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    employeeId =
        int.parse(prefs.getString(LocalConstant.KEY_EMPLOYEE_ID) as String);
    getNotifications();
  }




  @override
  Widget build(BuildContext context) {
    double width = MediaQuery
        .of(context)
        .size
        .width;
    return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: LightColors.kLightYellow,
        appBar: AppBar(title: const Text('Notification Center')),
        body: SafeArea(
          child: RefreshIndicator(
            key: _refreshIndicatorKey,
            color: Colors.white,
            backgroundColor: Colors.blue,
            strokeWidth: 4.0,
            onRefresh: () async {
              // Replace this delay with the code to be executed during refresh
              // and return a Future when code finishs execution.
              return Future<void>.delayed(const Duration(seconds: 3));
            },
            // Pull from top to show refresh indicator.
            child: Column(
              children: [
                /*Container(
                  color: LightColors.kLightBlue,
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      InkWell(
                        onTap: () {
                          //search functionality
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.search_sharp,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),*/

                getNotificationListView(),
              ],
            ),
          ),
        ));
  }

  getNotificationListView() {
    if (mNotificationList == null || mNotificationList.length <= 0) {
      print('data not found');
      return Utility.emptyDataSet(context,"Notification tray is Empty");
    } else {
      return Flexible(
          child: ListView.builder(
            itemCount: mNotificationList.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return getRow(mNotificationList[index]);
            },
          ));
    }
  }

  getRow(NotificationDataModel info) {

    return ListTile(
      leading: info.image=='' ? SizedBox(
          height: 30.0,
          width: 30.0, // fixed width and height
          child: Image.asset('assets/icons/app_logo.png')
      ) : SizedBox(
          height: 40.0,
          width: 40.0, // fixed width and height
          child: Image.network('https://cdn-ha.dyntube.net/play/use-s/data/FMOoz0QVsU6XrUrvZXjRIQ/videos/lCdpAHGSsUW3TlBNbP7w/v1/images/pubsrv/oya5RvaHdUeLtCNKsoIV0A01-sm.jpg')
      ),
      title: Text(
        '${info.title}',
      ),
      subtitle: Text(info.message),
      trailing: Text('${info.time}',style: TextStyle(fontSize: 9,),),

    );
  }


}
