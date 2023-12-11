// ignore_for_file: public_member_api_docs, sort_constructors_first
class NotificationModel {
  int notificationId;
  String subject;
  String notificationtype;
  String message;
  String image_url;
  String webViewUrl;
  String logoUrl;
  String bigImageUrl;
  String time;
  int isSeen;
  double indicatorValue;

  NotificationModel(
      {required this.notificationId,
      required this.subject,
      required this.notificationtype,
      required this.message,
      required this.image_url,
      required this.webViewUrl,
      required this.logoUrl,
      required this.bigImageUrl,
      required this.time,
      required this.isSeen,
      required this.indicatorValue});
}
