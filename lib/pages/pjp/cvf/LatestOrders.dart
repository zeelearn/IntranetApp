import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../helper/constants.dart';
import '../../model/order.dart';
import 'OrderCard.dart';


class LatestOrders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top:50.0, right: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Icon(Icons.settings)
                ],
              ),
            ),
            // SizedBox(height: 5),
            CircleAvatar(
              backgroundImage: AssetImage('assets/images/man.png'),
              backgroundColor: Colors.yellow,

              radius: 50,
            ),
            SizedBox(height: 10),
            Text('Antonio Perex', style:TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18
            )),
            Text('134,679 XP'),
            SizedBox(height: 20),
            Container(
              width: 300,
              height: 60,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey,
                        blurRadius: 10.0,
                        offset: Offset(4.0, 4.0),
                        spreadRadius: 1.0)
                  ]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text('BADGES', style: TextStyle(color: Colors.indigo[900]),),

                  Text('FRIENDS',style: TextStyle(color: Colors.grey),),

                  Text('SCORES',style: TextStyle(color: Colors.grey),),
                ],
              ),
            ),


            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(bottom:10.0,right: 10, left: 10),
              child: Container(
                // width: 300,
                // height: 60,
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey,
                            blurRadius: 10.0,
                            offset: Offset(4.0, 4.0),
                            spreadRadius: 1.0)
                      ]),
                  child:Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage('assets/images/medal.png'),
                        ),
                        title: Text('Perfectionist'),
                        subtitle: Text('Finish all lectures of a chapter'),
                      ),
                      Divider(height: 1,color: kGrayColor,),
                      ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage('assets/icons/app_logo.png'),
                        ),
                        title: Text('Achiever'),
                        subtitle: Text('Complete all excercise'),
                      ),
                      Divider(height: 1,color: kGrayColor,),

                      ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage('assets/images/formula.png'),
                        ),
                        title: Text('Scholar'),
                        subtitle: Text('Study two courses'),
                      ),
                      Divider(height: 1,color: kGrayColor,),
                      ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage('assets/images/trophy.png'),
                        ),
                        title: Text('Champion'),
                        subtitle: Text('Finish #1 on the score board'),
                      ),
                      Divider(height: 1,color: kGrayColor,),
                      ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage('assets/images/bullseye.png'),
                        ),
                        title: Text('Focused'),
                        subtitle: Text('Study everyday for 30 days'),
                      ),
                      Divider(height: 1,color: kGrayColor,),
                      ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage('assets/images/solution.png'),
                        ),
                        title: Text('Achiever'),
                        subtitle: Text('Complete all excercise'),
                      ),
                      Divider(height: 1,color: kGrayColor,),
                      ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage('assets/images/formula.png'),
                        ),
                        title: Text('Scholar'),
                        subtitle: Text('Study two courses'),
                      ),
                      Divider(height: 1,color: kGrayColor,),
                      ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage('assets/images/trophy.png'),
                        ),
                        title: Text('Champion'),
                        subtitle: Text('Finish #1 on the score board'),
                      ),
                      Divider(height: 1,color: kGrayColor,),
                      ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage('assets/images/bullseye.png'),
                        ),
                        title: Text('Focused'),
                        subtitle: Text('Study everyday for 30 days'),
                      ),
                    ],
                  )
              ),
            ),
          ],
        ),
      ),

    );
  }
}