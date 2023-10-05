import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Intranet/pages/pjp/cvf/question_controller.dart';

import '../../utils/theme/colors/light_colors.dart';
import '../../utils/widgets/top_container.dart';
import 'components/body.dart';

class QuizScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    QuestionController _controller = Get.put(QuestionController());
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      /*appBar: AppBar(
        // Fluttter show the back button automatically
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          FlatButton(onPressed: _controller.nextQuestion, child: Text("Skip")),
        ],
      ),*/

          backgroundColor: LightColors.kLightYellow,
          body: SafeArea(
              child: Stack(
                children: [
                  Body(),
                ],
              ), /*Column(
                  children: <Widget>[
                    *//*TopContainer(
                      height: 60,
                      width: width,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Icon(Icons.menu,
                                    color: LightColors.kDarkBlue, size: 30.0),
                                Text(
                                  'Sudhir Patil',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontSize: 22.0,
                                    color: LightColors.kDarkBlue,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add,
                                      color: LightColors.kDarkBlue, size: 25.0),
                                  color: Colors.white,
                                  onPressed: () {

                                  },
                                ),

                              ],
                            ),

                          ]),
                    ),*//*

                    Body(),

                  ]
              )*/
          )
    );
  }
}
