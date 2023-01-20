import 'package:intranet/pages/helper/utils.dart';

class NotificationDataModel {
  late String message;
  late String title;
  late String image;
  late String URL;
  late String type;
  late String time;

  NotificationDataModel({required this.message,required this.title,required this.image,required this.URL,required this.type,required this.time});

  NotificationDataModel.fromJson(Map<String, dynamic> json) {
    message = json['message'] ?? "";
    title = json['title'] ?? "";
    image = json['image'] ?? "";
    URL = json['URL'] ?? "";
    type = json['type'] ?? "";
    time = json['time'] ?? Utility.shortDate(DateTime.now());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['message'] = this.message;
    data['image'] = this.image;
    data['URL'] = this.URL;
    data['type'] = this.type;
    data['time'] = this.time;
    return data;
  }
}


class NotificationActionModel {
  late String type;
  late String message;
  late String title;


  NotificationActionModel({required this.type,required this.message,required this.title});

  NotificationActionModel.fromJson(Map<String, dynamic> json) {
    type = json['type'] ?? "";
    message = json['message'] ?? "";
    title = json['title'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['type'] = this.type;
    data['title'] = this.title;
    return data;
  }
}
