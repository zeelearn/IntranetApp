import 'dart:convert';

import 'package:get/get.dart';
import 'package:Intranet/pages/home/v2/dashboard_screen_v2_controller.dart';
import 'package:Intranet/pages/notification/NotificationModel.dart';
import 'package:Intranet/pages/notification/bpms_card.dart';
import 'package:Intranet/pages/utils/theme/colors/light_colors.dart';
import 'package:Intranet/pages/widget/MyWebSiteView.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:saathi/screens/ticket/web/details.dart';

import '../../main.dart';
import '../helper/DatabaseHelper.dart';
import '../helper/LocalConstant.dart';
import '../helper/constants.dart';
import '../model/bpms_notification_model.dart';
import 'DetailPage.dart';
import 'package:Intranet/pages/summary%20dashboard/summary_dashboard.dart';

class UserNotification extends StatefulWidget {
  const UserNotification({Key? key}) : super(key: key);

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<UserNotification> {
  late List<NotificationModel> lessons = [];

  @override
  void initState() {
    NotificationController.resetBadgeCounter();
    super.initState();
    loadData();
  }

  void loadData() async {
    List<Map<String, dynamic>> list =
        await DBHelper().getData(LocalConstant.TABLE_NOTIFICATION);
    for (int index = 0; index < list.length; index++) {
      Map<String, dynamic> map = list[index];
      if (index > 60) break;
      lessons.add(NotificationModel(
          notificationId: map['id'] ?? index,
          subject: map['title'] ?? '',
          notificationtype: map['type'] ?? '',
          message: map['description'] ?? '',
          image_url: map['imageurl'] ?? '',
          bigImageUrl: map['bigImageUrl'] ?? '',
          logoUrl: map['logoUrl'] ?? '',
          webViewUrl: map['webViewLink'] ?? '',
          time: map['date'] ?? '',
          isSeen: map['is_seen'] ?? 0,
          indicatorValue: 1.0));
    }
    lessons = lessons.reversed.toList();
    setState(() {});
  }

  void markAsRead(NotificationModel model) async {
    if (model.isSeen == 0) {
      await DBHelper().markNotificationAsRead(model.notificationId);
      model.isSeen = 1;
      setState(() {});
      try {
        if (Get.isRegistered<DashboardScreenV2Controller>()) {
          Get.find<DashboardScreenV2Controller>().loadNotificationCount();
        }
      } catch (e) {
        debugPrint('Error updating controller notification count: $e');
      }
    }
  }

  deleteNotification(int id) async {
    await DBHelper().deleteNotification(LocalConstant.TABLE_NOTIFICATION, id);
    try {
      if (Get.isRegistered<DashboardScreenV2Controller>()) {
        Get.find<DashboardScreenV2Controller>().loadNotificationCount();
      }
    } catch (e) {
      debugPrint('Error updating controller notification count: $e');
    }
  }

  String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '');
  }

  @override
  Widget build(BuildContext context) {
    ListTile makeListTile(NotificationModel notificationModel) {
      final bool isUnread = notificationModel.isSeen == 0;
      return ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
        leading: Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: notificationModel.image_url.isNotEmpty
              ? Image.network(
                  notificationModel.logoUrl,
                  width: 32,
                  height: 32,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.notifications, color: Colors.grey),
                )
              : const Icon(Icons.notifications, color: Colors.grey),
        ),
        minLeadingWidth: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            if (isUnread)
              Container(
                margin: const EdgeInsets.only(right: 6),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            Expanded(
              child: Text(
                notificationModel.subject,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: LightColors.titleTextStyle.copyWith(
                  fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          children: [
            const SizedBox(
              height: 4,
            ),
            RichText(
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              strutStyle: const StrutStyle(fontSize: 10.0),
              text: TextSpan(
                  style: LightColors.smallTextStyle.copyWith(
                    color: isUnread ? Colors.black87 : Colors.black54,
                  ),
                  text: removeAllHtmlTags(notificationModel.message)),
            ),
            const SizedBox(
              height: 6,
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                DateFormat('MMM/dd,hh:mm a').format(
                    DateFormat('yyyy-MM-dd hh:mm a')
                        .parse(notificationModel.time)),
                textAlign: TextAlign.end,
                style: LightColors.smallTextStyle,
              ),
            )
          ],
        ),
        onTap: () async {
          markAsRead(notificationModel);
          if (notificationModel.notificationtype == 'td') {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TicketDetailInfo(
                          ticketId: notificationModel.webViewUrl,
                          businessID: '0',
                          //businessUserID: receivedAction.payload!['business_user_id']!,
                          //userID: routingData['u_id'],
                          //role: routingData['r'],
                          //dashboardClickListener: arguments?.$2,
                        )));
          } else if (notificationModel.notificationtype == 'EXPENSE') {
            await Hive.openBox('kidzeepref');
            var hive = Hive.box('kidzeepref');
            String? token = hive.get('authtoken');
            var uri = Uri.parse(notificationModel.webViewUrl);
            debugPrint('Url is 1 - ${uri}');
            var params = Map<String, String>.from(uri.queryParameters);
            params['token'] = token ?? '';
            uri = uri.replace(queryParameters: params);
            debugPrint('Url is 2 - ${uri}');
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyWebsiteView(
                      title: notificationModel.subject, url: uri.toString()),
                ));
          } else if (notificationModel.notificationtype == 'PJP') {
            final pjpId = notificationModel.webViewUrl;
            if (pjpId.isNotEmpty) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DayEventsScreen(
                      pjpId: pjpId,
                    ),
                  ));
            }
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        DetailPage(notificationModel: notificationModel)));
          }
        },
      );
    }

    Card makeCard(NotificationModel model) {
      final bool isUnread = model.isSeen == 0;
      return Card(
        elevation: isUnread ? 5.0 : 2.0,
        color: isUnread ? const Color(0xFFF4F8FF) : Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isUnread
              ? BorderSide(color: Colors.blue.shade100, width: 1)
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isUnread)
                Container(
                  width: 5,
                  color: Colors.blue.shade600,
                ),
              Expanded(
                child: makeListTile(model),
              ),
            ],
          ),
        ),
      );
    }

    final makeBody = lessons.isNotEmpty
        ? ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            // reverse: true,
            itemCount: lessons.length,
            itemBuilder: (BuildContext context, int index) {
              if (lessons[index].notificationtype == 'BPMS') {
                BpmsNotificationModelList bpmsList =
                    BpmsNotificationModelList.fromJson(
                  json.decode(
                          '{"data":${lessons[index].message.toString().replaceAll(',]', ']')}}')
                      as Map<String, dynamic>,
                );
                return Dismissible(
                    key: Key(lessons[index].notificationId.toString()),
                    onDismissed: (direction) {
                      setState(() {
                        deleteNotification(lessons[index].notificationId);
                        lessons.removeAt(index);
                      });
                    },
                    child: BPMSNotification(
                        bpmsList: bpmsList,
                        title: lessons[index].subject,
                        time: lessons[index].time,
                        isSeen: lessons[index].isSeen,
                        onMarkAsRead: () => markAsRead(lessons[index])));
              } else
                return Dismissible(
                    key: Key(lessons[index].notificationId.toString()),
                    onDismissed: (direction) {
                      setState(() {
                        deleteNotification(lessons[index].notificationId);
                        lessons.removeAt(index);
                      });
                    },
                    child: makeCard(lessons[index]));
            },
          )
        : Lottie.asset(no_Notification_Animtion);

    final makeBottom = SizedBox(
      height: 55.0,
      child: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.blur_on, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.hotel, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.account_box, color: Colors.white),
              onPressed: () {},
            )
          ],
        ),
      ),
    );
    final topAppBar = AppBar(
      elevation: 1.0,
      leadingWidth: 30,
      title: const Text(
        "Notifications",
      ),
      actions: [
        if (lessons.any((n) => n.isSeen == 0))
          TextButton.icon(
            onPressed: () async {
              await DBHelper().markAllNotificationsAsRead();
              for (var n in lessons) {
                n.isSeen = 1;
              }
              setState(() {});
              try {
                if (Get.isRegistered<DashboardScreenV2Controller>()) {
                  Get.find<DashboardScreenV2Controller>()
                      .loadNotificationCount();
                }
              } catch (e) {
                debugPrint('Error updating controller notification count: $e');
              }
            },
            icon: const Icon(Icons.done_all, size: 18, color: Colors.white),
            label: const Text("Mark all read",
                style: TextStyle(fontSize: 12, color: Colors.white)),
          ),
      ],
    );

    return Scaffold(
      backgroundColor: LightColors.kLightGray1,
      appBar: topAppBar,
      body: makeBody,
      //bottomNavigationBar: makeBottom,
    );
  }
}
