import 'package:flutter/material.dart';

class UserNotificationDetailScreen extends StatefulWidget {
  const UserNotificationDetailScreen({super.key});

  @override
  State<UserNotificationDetailScreen> createState() =>
      _UserNotificationDetailScreenState();
}

class _UserNotificationDetailScreenState
    extends State<UserNotificationDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: kWhiteColor,
      appBar: AppBar(title: const Text('Notification')),
      body: FittedBox(
        child: Container(
          // height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: const [BoxShadow(blurRadius: 2.0)]),
          child: const Column(
            children: [
              Text(
                'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
              ),
              SizedBox(height: 16.0),
              // Image(image: AssetImage(manShoes)),
              SizedBox(height: 16.0),
              Text(
                "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged.",
              ),
              SizedBox(height: 16.0),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '11/Feb/2021 04:42 PM',
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
