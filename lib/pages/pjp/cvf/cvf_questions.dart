import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intranet/api/request/cvf/questions_request.dart';
import 'package:intranet/api/request/cvf/save_cvfquestions_request.dart';
import 'package:intranet/pages/helper/DatabaseHelper.dart';

import '../../../api/APIService.dart';
import '../../../api/response/cvf/QuestionResponse.dart';
import '../../../api/response/cvf/cvfanswers_response.dart';
import '../../../api/response/pjp/pjplistresponse.dart';
import '../../helper/LightColor.dart';
import '../../helper/utils.dart';
import '../../utils/theme/colors/light_colors.dart';

class QuestionListScreen extends StatefulWidget {
  GetDetailedPJP cvfView;
  String mCategory;
  int PJPCVF_Id;
  int employeeId;

  QuestionListScreen({Key? key,required this.PJPCVF_Id,required this.employeeId, required this.cvfView, required this.mCategory})
      : super(key: key);

  @override
  State<QuestionListScreen> createState() => _QuestionListScreenState();
}

class _QuestionListScreenState extends State<QuestionListScreen> {
  List<QuestionMaster> mQuestionMaster = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
// your code goes here
      loadData();
    });
  }

  List<bool> ischeck = [];

  loadData() {
    print('load data');
    Utility.showLoaderDialog(context);
    mQuestionMaster.clear();
    DateTime time = DateTime.now();
    QuestionsRequest request =
        QuestionsRequest(Category_Id: '1', Business_id: '1',PJPCVF_Id: widget.cvfView.PJPCVF_Id);
    APIService apiService = APIService();
    apiService.getCVFQuestions(request).then((value) {
      print(value.toString());
      if (value != null) {
        if (value == null || value.responseData == null) {
          Utility.showMessage(context, 'data not found');
        } else if (value is QuestionResponse) {
          QuestionResponse response = value;
          if (response != null && response.responseData != null) {
            if (widget.mCategory.isEmpty || widget.mCategory == 'All') {
              List<Purpose> purposeList = getUniqueCategory();
              for (int index = 0;
                  index < response.responseData.length;
                  index++) {
                for (int jIndex = 0; jIndex < purposeList.length; jIndex++) {
                  if (purposeList[jIndex].categoryName ==
                      response.responseData[index].categoryName) {
                    mQuestionMaster.add(response.responseData[index]);
                  }
                }
              }
            } else {
              for (int index = 0;
                  index < response.responseData.length;
                  index++) {
                if (widget.mCategory ==
                    response.responseData[index].categoryName) {
                  mQuestionMaster.add(response.responseData[index]);
                }
              }
            }
            setState(() {});
          }
          print('summery list ${response.responseData.length}');
        } else {
          Utility.showMessage(context, 'data not found');
        }
      }
      Navigator.of(context).pop();
      setState(() {});
    });
  }

  List<Purpose> getUniqueCategory() {
    List<Purpose> list = [];
    var mySet = <String>{};
    for (int index = 0; index < widget.cvfView.purpose!.length; index++) {
      if (!mySet.contains(widget.cvfView.purpose![index].categoryName)) {
        list.add(widget.cvfView.purpose![index]);
        mySet.add(widget.cvfView.purpose![index].categoryName);
        print(widget.cvfView.purpose![index].categoryName);
      }
    }
    return list;
  }

  saveAnswers() {
    Utility.showLoaderDialog(context);
    String docXml = '<root>';
    for(int index=0;index<mQuestionMaster.length;index++){
      for(int jIndex=0;jIndex<mQuestionMaster[index].allquestion.length;jIndex++){
        if(mQuestionMaster[index].allquestion[jIndex].userAnswers.isNotEmpty)
          docXml='${docXml}<tblPJPCVF_Answer><SubmissionDate>${Utility.convertShortDate(DateTime.now())}</SubmissionDate><Question_Id>${mQuestionMaster[index].allquestion[jIndex].Question_Id}</Question_Id><AnswerId>${mQuestionMaster[index].allquestion[jIndex].userAnswers}</AnswerId><Remarks></Remarks></tblPJPCVF_Answer>';
      }
    }
    docXml = '${docXml} </root>';
    SaveCVFAnswers request = SaveCVFAnswers(PJPCVF_Id: widget.PJPCVF_Id, DocXml: docXml, UserId: widget.employeeId);
    print(request.toJson());
    APIService apiService = APIService();
    apiService.saveCVFAnswers(request).then((value) {
      print(value.toString());
      if (value != null) {
        if (value == null || value.responseData == null) {
          Utility.showMessage(context, 'data not found');
        } else if (value is CVFAnswersResponse) {
          CVFAnswersResponse response = value;
          if (response != null) {

          }
          setState(() {});

        } else {
          Utility.showMessage(context, 'data not found');
        }
      }
      Navigator.of(context).pop();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Questions'),
          actions: [
            IconButton(
              icon: const Icon(Icons.done),
              tooltip: 'Filter',
              onPressed: () {
                saveAnswers();
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            getView(widget.cvfView),
            Container(
              margin: EdgeInsets.only(top: 100, left: 0, right: 0, bottom: 0),
              child: SingleChildScrollView(
                child: getWidget(),
              ),
            )
          ],
        ));
  }

  getWidget() {
    if (mQuestionMaster.isEmpty) {
      return ListTile(title: Text('List'));
    }
    return Column(
      children:
          mQuestionMaster.map<Widget>((club) => showQuestions(club)).toList(),
    );
  }

  getView(GetDetailedPJP cvfView) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
      child: Container(
        width: double.infinity,
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
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            Utility.shortTime(
                                Utility.convertTime(cvfView.visitTime)),
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            Utility.shortTimeAMPM(
                                Utility.convertTime(cvfView.visitTime)),
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(flex: 5, child: getCVFView(cvfView)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  getCVFView(GetDetailedPJP cvfView) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(5, 4, 12, 4),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                child: Text(
                  'Franchisee Code : ${cvfView.franchiseeCode}',
                  style: TextStyle(
                    fontFamily: 'Lexend Deca',
                    color: Color(0xFF4B39EF),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                child: Text(
                  '${Utility.shortDate(Utility.convertDate(cvfView.visitDate))}',
                  style: TextStyle(
                    fontFamily: 'Lexend Deca',
                    color: Color(0xFF4B39EF),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.85,
          height: 1,
          decoration: BoxDecoration(
            color: Color(0xFFF1F4F8),
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(5, 4, 12, 4),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                child: Text(
                  '${cvfView.franchiseeName}',
                  style: TextStyle(
                    fontFamily: 'Lexend Deca',
                    color: Color(0xFF090F13),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        /*Padding(
          padding: EdgeInsetsDirectional.fromSTEB(5, 4, 12, 8),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 4),
                child: Icon(
                  Icons.schedule,
                  color: Color(0xFF4B39EF),
                  size: 20,
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(4, 0, 0, 0),
                child: Text(
                  '${Utility.shortDate(Utility.convertDate(cvfView.visitDate))} : ${Utility.shortTimeFormat(Utility.convertDate(cvfView.visitDate))}',
                  style: TextStyle(
                    fontFamily: 'Lexend Deca',
                    color: Color(0xFF4B39EF),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),*/
        Padding(
            padding: EdgeInsetsDirectional.fromSTEB(5, 4, 12, 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: _buildRowList(cvfView), /*[
                  cvfView.purpose!.length > 0
                      ? getTextCategory(
                          cvfView, cvfView.purpose![0].categoryName)
                      : Text(''),
                  cvfView.purpose!.length > 1
                      ? getTextCategory(
                          cvfView, cvfView.purpose![1].categoryName)
                      : Text(''),
                  cvfView.purpose!.length > 2
                      ? getTextCategory(
                          cvfView, cvfView.purpose![2].categoryName)
                      : Text(''),
                  cvfView.purpose!.length > 3
                      ? getTextCategory(
                          cvfView, cvfView.purpose![3].categoryName)
                      : Text(''),
                  cvfView.purpose!.length > 4
                      ? getTextCategory(
                          cvfView, cvfView.purpose![4].categoryName)
                      : Text(''),
                ],*/
              ),
            )),

        /*Padding(
          padding: EdgeInsetsDirectional.fromSTEB(5, 4, 12, 8),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 4),
                child: Icon(
                  Icons.category,
                  color: Color(0xFF4B39EF),
                  size: 20,
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(4, 0, 0, 0),
                child: Text(
                  '${Utility.shortDate(Utility.convertDate(cvfView.visitDate))} : ${Utility.shortTimeFormat(Utility.convertDate(cvfView.visitDate))}',
                  style: TextStyle(
                    fontFamily: 'Lexend Deca',
                    color: Color(0xFF4B39EF),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),*/
      ],
    );
  }

  List<Widget> _buildRowList(GetDetailedPJP cvfView) {
    List<Widget> _rowWidget = []; // this will hold Rows according to available lines
    for(int index=0;index<cvfView.purpose!.length;index++){
      _rowWidget.add(getTextCategory(cvfView,cvfView.purpose![index].categoryName));
    }
    return _rowWidget;
  }

  getTextCategory(GetDetailedPJP cvfView, String categoryname) {
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: EdgeInsets.only(left: 10, right: 10, top: 6, bottom: 6),
        child: Text('${categoryname} ',
            textAlign: TextAlign.center,
            style: TextStyle(
              background: Paint()
                ..color = widget.mCategory == categoryname
                    ? LightColors.kLightRed
                    : LightColors.kLightBlue
                ..strokeWidth = 20
                ..strokeJoin = StrokeJoin.round
                ..strokeCap = StrokeCap.round
                ..style = PaintingStyle.stroke,
              color: Colors.black,
            )),
      ),
    );
  }

  Widget showQuestions(QuestionMaster questionMaster) {
    return ExpansionTile(
      key: PageStorageKey<QuestionMaster>(questionMaster),
      title: Padding(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Text(
          questionMaster.categoryName,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
      ),
      children: questionMaster.allquestion
          .map<Widget>((player) => showPlayers(player))
          .toList(),
    );
  }

  updateAnswers(Allquestion questions,String answers){
    for(int index=0;index<mQuestionMaster.length;index++){
      for(int jIndex=0;jIndex<mQuestionMaster[index].allquestion.length;jIndex++){
          if(mQuestionMaster[index].allquestion[jIndex].question == questions.question){
            mQuestionMaster[index].allquestion[jIndex].userAnswers = answers;
          }
      }
    }
  }

  Widget showPlayers(Allquestion player) {
    return ListTile(
      title: Padding(
          padding: EdgeInsets.all(0),
          child: Column(children: [
            Divider(
              height: 2,
              color: Colors.blue,
            ),
            SizedBox(
              height: 5,
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Text(player.question,
                  style: TextStyle(color: Colors.black, fontSize: 14)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _buildYesNoAnswers(player), /*[
                Expanded(
                  child: CheckboxListTile(
                    value: player.userAnswers == 'Yes' ? true : false,
                    title: Text(
                      player.answers[0].answerName,
                      style: TextStyle(fontSize: 12),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (checked) {
                      //ischeck[getCheckboxIndex(player.question)] = false;
                      player.userAnswers = 'Yes';
                      updateAnswers(player, 'Yes');
                      setState(() {});
                    },
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    value: player.userAnswers == 'No' ? true : false,
                    title: Text(
                      player.answers[1].answerName,
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.left,
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (checked) {
                      player.userAnswers = 'No';
                      updateAnswers(player, 'No');
                      setState(() {});
                    },
                  ),
                ),
                const Expanded(
                    child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.photo,
                    size: 20,
                  ),
                )),
              ],*/
            ),
          ])),
    );
  }

  List<Widget> _buildYesNoAnswers(Allquestion question) {
    List<Widget> _rowWidget = []; // this will hold Rows according to available lines
    for(int index=0;index<question.answers.length;index++){
      bool answers = (question.userAnswers == question.answers[index].answerName || question.SelectedAnswer == question.answers[index].answerName) ? true : false;
      _rowWidget.add(_generateYesNoAnswers(question,question.answers[index].answerName,answers));
    }
    return _rowWidget;
  }

  _generateYesNoAnswers(Allquestion question,String Answer_Name, bool value){
    return Expanded(
      child: CheckboxListTile(
        value: value,
        title: Text(
          Answer_Name,
          style: TextStyle(fontSize: 12),
        ),
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: (checked) {
          //ischeck[getCheckboxIndex(player.question)] = false;
          //question.userAnswers = Answer_Name;
          updateAnswers(question, Answer_Name);
          setState(() {});
        },
      ),
    );
  }

  int getCheckboxIndex(String questions) {
    int counter = 1;
    bool isBreak = false;
    for (int index = 0; index < mQuestionMaster.length; index++) {
      for (int jIndex = 0;
          jIndex < mQuestionMaster[index].allquestion.length;
          jIndex++) {
        if (questions == mQuestionMaster[index].allquestion[jIndex].question) {
          isBreak = true;
          break;
        }
        counter = counter + 1;
      }
      if (isBreak) {
        break;
      }
    }
    print('counter is ${counter}');
    return counter;
  }

  showAnswers(Answers answers, String userAnswers) {
    return CheckboxListTile(
      value: userAnswers == 'true' ? true : false,
      title: Text(answers.answerName),
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (checked) {
        userAnswers = 'true';
      },
    );
  }

  void updatelist() async {
    DBHelper helper = DBHelper();
    helper.getPjpList();
    mQuestionMaster = mQuestionMaster;
    print('data updated');
    setState() {}
    ;
    print('data updated');
  }

  void onItemChanged(bool? checked) {
    //ischeck[getCheckboxIndex(player.question)] = false;
    //player.userAnswers = '1';
    setState() {
      print('data updated');
      //player.userAnswers = '1';
    }
  }
}
