import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/svg.dart';

import '../../../helper/constants.dart';
import '../../../utils/theme/colors/light_colors.dart';
import '../../../utils/widgets/top_container.dart';
import '../question_controller.dart';
import 'progress_bar.dart';
import 'question_card.dart';

class Body extends StatelessWidget {
  const Body({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // So that we have acccess our controller
    double width = MediaQuery.of(context).size.width;
    QuestionController _questionController = Get.put(QuestionController());
    return Stack(
      children: [
        SvgPicture.asset("assets/icons/bg.svg", fit: BoxFit.fill),
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TopContainer(
                height: 60,
                width: width,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: LightColors.kDarkBlue, size: 25.0),
                            color: Colors.white,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          Text(
                            'Sudhir Patil',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 22.0,
                              color: LightColors.kDarkBlue,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text('    ')
                        ],
                      ),
                    ]),
              ),
              DecoratedBox(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.white,
                        Colors.white,
                        Colors.white70
                        //add more colors
                      ]),
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.5),
                            //shadow for button
                            blurRadius: 5) //blur radius of shadow
                      ]),
                  child: Padding(
                      padding: EdgeInsets.only(left: 30, right: 30),
                      child: DropdownButton(
                        value: "Section 1",
                        items: [
                          DropdownMenuItem(
                            child: Text("Section 1"),
                            value: "Section 1",
                          ),
                          DropdownMenuItem(
                            child: Text("Section 2"),
                            value: "Section 2",
                          ),
                          DropdownMenuItem(
                            child: Text("Section 3"),
                            value: "Section 3",
                          ),
                        ],
                        onChanged: (value) {},
                        isExpanded: true,
                        //make true to take width of parent widget
                        underline: Container(),
                        //empty line
                        style: TextStyle(fontSize: 18, color: Colors.black),
                        dropdownColor: LightColors.kLavender,
                        iconEnabledColor: Colors.white, //Icon color
                      ))),
              SizedBox(height: 10),
              /*Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                child: ProgressBar(),
              ),*/
              /*SizedBox(height: kDefaultPadding),*/

              new Container(
                  margin: EdgeInsets.only(left: 10.0,right: 10.0),
                  height: 32.0,
                  child: ListView.builder(
                    shrinkWrap:  true,
                    scrollDirection: Axis.horizontal,
                    itemCount: _questionController.questions.length,
                    itemBuilder: (context,index){
                      return ClipOval(
                        child: Container(
                          color: _questionController.questionNumber.value==index ? LightColors.kLavender : Colors.white,
                          margin: EdgeInsets.only(left: 20),
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Center(
                            child: Text(
                              '${_questionController.questions[index].id.toString()}',
                              style: TextStyle(color: _questionController.questionNumber.value==index ? LightColors.kDarkBlue : Colors.grey, fontSize: 20),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ),
              Divider(thickness: 1.5),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                child: Obx(
                  () => Text.rich(
                    TextSpan(
                      text:
                          "Question ${_questionController.questionNumber.value}",
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1
                          ?.copyWith(color: kSecondaryColor),
                      children: [
                        TextSpan(
                          text: "/${_questionController.questions.length}",
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              ?.copyWith(color: kSecondaryColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Divider(thickness: 1.5),
              SizedBox(height: kDefaultPadding),
              Expanded(
                child: PageView.builder(
                  // Block swipe to next qn

                  controller: _questionController.pageController,
                  onPageChanged: _questionController.updateTheQnNum,
                  itemCount: _questionController.questions.length,
                  itemBuilder: (context, index) => QuestionCard(
                      question: _questionController.questions[index]),
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      _questionController.previousQuestion();
                    },
                    child: Container(
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Previous',
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1
                                ?.copyWith(color: kBlackColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      _questionController.nextQuestion();
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '  Next  ',
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1
                                ?.copyWith(color: kBlackColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}
