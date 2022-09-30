import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intranet/api/request/cvf/questions_request.dart';
import 'package:intranet/api/request/cvf/save_cvfquestions_request.dart';
import 'package:intranet/pages/firebase/storageutil.dart';
import 'package:intranet/pages/helper/DatabaseHelper.dart';
import 'package:intranet/pages/helper/LocalConstant.dart';
import 'package:intranet/pages/iface/onResponse.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../api/APIService.dart';
import '../../../api/ServiceHandler.dart';
import '../../../api/response/cvf/QuestionResponse.dart';
import '../../../api/response/cvf/cvfanswers_response.dart';
import '../../../api/response/cvf/update_status_response.dart';
import '../../../api/response/pjp/pjplistresponse.dart';
import '../../firebase/anylatics.dart';
import '../../helper/DBConstant.dart';
import '../../helper/constants.dart';
import '../../helper/utils.dart';
import '../../iface/onClick.dart';
import '../../iface/onUploadResponse.dart';
import '../../utils/theme/colors/light_colors.dart';

class QuestionListScreen extends StatefulWidget {
  GetDetailedPJP cvfView;
  String mCategory;
  String mCategoryId;
  int PJPCVF_Id = 0;
  int employeeId;

  QuestionListScreen(
      {Key? key,
      required this.PJPCVF_Id,
      required this.employeeId,
      required this.cvfView,
      required this.mCategory,
      required this.mCategoryId})
      : super(key: key);

  @override
  State<QuestionListScreen> createState() => _QuestionListScreenState();
}

class _QuestionListScreenState extends State<QuestionListScreen> implements onUploadResponse, onResponse,onClickListener{
  List<QuestionMaster> mQuestionMaster = [];
  bool isLoading = true;
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFileList;
  Map<String, String> userAnswerMap = Map();

  TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
// your code goes here
      getPrefQuestions(widget.mCategoryId);
      getUsersAnswers();
    });
  }

  getUsersAnswers() async {
    DBHelper helper = DBHelper();
    userAnswerMap = await helper.getUsersAnswerList(widget.PJPCVF_Id);
  }

  List<bool> ischeck = [];

  getPrefQuestions(String categoryid) async {
    final prefs = await SharedPreferences.getInstance();
    print('in pref questions');
    try {
      var cvfQuestions = prefs.getString(widget.PJPCVF_Id.toString() +
          categoryid +
          LocalConstant.KEY_CVF_QUESTIONS);
      print('in pref questions :   ${jsonDecode(cvfQuestions.toString())}');

      if (false && cvfQuestions is QuestionResponse) {
        QuestionResponse response = cvfQuestions as QuestionResponse;
        print('data found');
      } else if (true || cvfQuestions.toString().isEmpty) {
        print('empty');
        loadData();
      } else {
        print('in else');
        try {
          QuestionResponse cvfQuestionsModel = QuestionResponse.fromJson(
            json.decode(cvfQuestions.toString()),
          );
          print('Data from the Preference ${cvfQuestionsModel}');
          mQuestionMaster.addAll(cvfQuestionsModel.responseData);
          isLoading = false;
          setState(() {});
        } catch (e) {
          loadData();
        }
      }
    } catch (e) {
      loadData();
    }
  }

  saveCvfQuestionsPref(String categoryid, String data) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        widget.PJPCVF_Id.toString() +
            categoryid +
            LocalConstant.KEY_CVF_QUESTIONS,
        data);
  }

  loadData() {
    isLoading = true;
    mQuestionMaster.clear();
    DateTime time = DateTime.now();
    QuestionsRequest request = QuestionsRequest(
        Category_Id: widget.mCategoryId,
        Business_id: '1',
        PJPCVF_Id: widget.cvfView.PJPCVF_Id);
    APIService apiService = APIService();
    apiService.getCVFQuestions(request).then((value) {
      isLoading = false;
      if (value != null) {
        if (value == null || value.responseData == null) {
          Utility.showMessage(context, 'data not found');
        } else if (value is QuestionResponse) {
          QuestionResponse response = value;

          if (response != null && response.responseData != null) {
            saveCvfQuestionsPref(
                widget.mCategoryId, json.encode(response.toJson()));
            mQuestionMaster.addAll(response.responseData);
            //Utility.showMessageSingleButton(context, "Thanks for submitting Data", this);
            /*if (widget.mCategory.isEmpty || widget.mCategory == 'All') {
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
            }*/
            insertQuestions();
            setState(() {});
          }
        } else {
          Utility.showMessage(context, 'data not found');
        }
      }
      // Navigator.of(context).pop();
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
      }
    }
    return list;
  }

  insertQuestions() async {
    DBHelper dbHelper = DBHelper();
    HashMap<String, String> map = HashMap();
    for (int index = 0; index < mQuestionMaster.length; index++) {
      for (int jIndex = 0;
          jIndex < mQuestionMaster[index].allquestion.length;
          jIndex++) {
        if (!map.containsKey(mQuestionMaster[index].categoryId)) {
          dbHelper.deleteCategory(int.parse(mQuestionMaster[index].categoryId));
          map.putIfAbsent(mQuestionMaster[index].categoryId,
              () => mQuestionMaster[index].categoryId);
        }

        Map<String, Object> data = {
          DBConstant.QUESTION_ID:
              mQuestionMaster[index].allquestion[jIndex].Question_Id,
          DBConstant.QUESTION:
              mQuestionMaster[index].allquestion[jIndex].question,
          DBConstant.CATEGORY_ID: mQuestionMaster[index].categoryId,
          DBConstant.CATEGORY_NAME: mQuestionMaster[index].categoryName,
          DBConstant.IS_COMPULSARY:
              mQuestionMaster[index].allquestion[jIndex].isCompulsory,
        };
        dbHelper.insert(LocalConstant.TABLE_CVF_QUESTIONS, data);
        for (int kIndex = 0;
            kIndex < mQuestionMaster[index].allquestion[jIndex].answers.length;
            kIndex++) {
          Map<String, Object> data = {
            DBConstant.QUESTION_ID:
                mQuestionMaster[index].allquestion[jIndex].Question_Id,
            DBConstant.QUESTION:
                mQuestionMaster[index].allquestion[jIndex].question,
            DBConstant.ANSWER_NAME: mQuestionMaster[index]
                .allquestion[jIndex]
                .answers[kIndex]
                .answerName,
            DBConstant.ANSWER_TYPE: mQuestionMaster[index]
                .allquestion[jIndex]
                .answers[kIndex]
                .answerType,
          };
          dbHelper.insert(LocalConstant.TABLE_CVF_ANSWER_MASTER, data);
        }
      }
    }
  }

  saveAnswers() {
    Utility.showLoaderDialog(context);
    String docXml = '<root>';
    for (int index = 0; index < mQuestionMaster.length; index++) {
      for (int jIndex = 0;
          jIndex < mQuestionMaster[index].allquestion.length;
          jIndex++) {
        if (mQuestionMaster[index].allquestion[jIndex].userAnswers.isNotEmpty) {
          docXml =
          '${docXml}<tblPJPCVF_Answer><SubmissionDate>${Utility
              .convertShortDate(DateTime
              .now())}</SubmissionDate><Question_Id>${mQuestionMaster[index]
              .allquestion[jIndex]
              .Question_Id}</Question_Id><AnswerId>${mQuestionMaster[index]
              .allquestion[jIndex]
              .userAnswers}</AnswerId><Remarks></Remarks></tblPJPCVF_Answer>';
        }else if(userAnswerMap[mQuestionMaster[index].allquestion[jIndex].Question_Id].toString().isNotEmpty){
          docXml =
          '${docXml}<tblPJPCVF_Answer><SubmissionDate>${Utility
              .convertShortDate(DateTime
              .now())}</SubmissionDate><Question_Id>${mQuestionMaster[index]
              .allquestion[jIndex]
              .Question_Id}</Question_Id><Files>${mQuestionMaster[index]
              .allquestion[jIndex].files}</Files><AnswerId>${userAnswerMap[mQuestionMaster[index].allquestion[jIndex].Question_Id].toString()}</AnswerId><Remarks></Remarks></tblPJPCVF_Answer>';
        }
      }
    }
    docXml = '${docXml} </root>';
    print(docXml);
    SaveCVFAnswers request = SaveCVFAnswers(
        PJPCVF_Id: widget.PJPCVF_Id, DocXml: docXml, UserId: widget.employeeId);
    //print(request.toJson());
    APIService apiService = APIService();
    apiService.saveCVFAnswers(request).then((value) {
      //print(value.toString());
      if (value != null) {
        if (value == null || value.responseData == null) {
          Utility.showMessage(context, 'data not found');
        } else if (value is CVFAnswersResponse) {
          CVFAnswersResponse response = value;
          if (response != null) {}
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
    FirebaseAnalyticsUtils().sendAnalyticsEvent('CVFQuestions');
    return Scaffold(
        appBar: AppBar(
          title: const Text('Questions'),
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
              margin:
                  const EdgeInsets.only(top: 100, left: 0, right: 0, bottom: 0),
              /*child: getWidget(),*/
              child: SingleChildScrollView(
                child: getWidget(),
              ),
            )
          ],
        ));
  }

  getWidget() {
    if (isLoading) {
      return Center(
        child: Image.asset(
          "assets/images/loading.gif",
        ),
      );
    } else {
      /*return getCVFQuestions(); */
      return Column(
        children:
            mQuestionMaster.map<Widget>((club) => showQuestions(club)).toList(),
      );
    }
  }

  getCVFQuestions() {
    if (isLoading) {
      return Center(
        child: Image.asset(
          "assets/images/loading.gif",
        ),
      );
    } else if (mQuestionMaster.isEmpty) {
      //print('List not avaliable');
      return Utility.emptyDataSet(context,"CVF Questions are not avaliable");
    } else {
      return Flexible(
          child: ListView.builder(
        itemCount: mQuestionMaster.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Card(
            child: Padding(
              padding: EdgeInsets.only(
                  top: 36.0, left: 6.0, right: 6.0, bottom: 6.0),
              child: ExpansionTile(
                title: Text(mQuestionMaster[index].categoryName),
                children: <Widget>[
                  Text('Parent'),
                  ListView.builder(
                      itemCount: mQuestionMaster[index].allquestion.length,
                      physics: ClampingScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int jindex) {
                        return generateQuestionView(
                            mQuestionMaster[index].allquestion[jindex]);
                      }),
                ],
              ),
            ),
          );
        },
      ));
    }
  }

  generateQuestionView(Allquestion question) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Text(question.question,
              style: const TextStyle(color: Colors.black, fontSize: 14)),
        ),
        _getYesNo(question)
      ],
    );
  }

  getAnswerView(Allquestion question) {}

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
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            Utility.shortTimeAMPM(
                                Utility.convertTime(cvfView.visitTime)),
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            Utility.shortDate(
                                Utility.convertServerDate(cvfView.visitTime)),
                            style: TextStyle(
                              fontSize: 12.0,
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

  getCvfInfo(GetDetailedPJP cvfView){
    return ListTile(
      leading: Expanded(
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
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  Utility.shortTimeAMPM(
                      Utility.convertTime(cvfView.visitTime)),
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.black,
                  ),
                ),
                Text(
                  Utility.shortDate(
                      Utility.convertServerDate(cvfView.visitTime)),
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      title: Text(cvfView.franchiseeName != 'NA'
          ? '${cvfView.franchiseeName}'
          : '${cvfView.Address}'),
      subtitle: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(5, 4, 12, 4),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                cvfView.purpose!.length > 0
                    ? getTextCategory(
                    cvfView,
                    cvfView.purpose![0].categoryName,
                    cvfView.purpose![0].categoryId)
                    : Text(''),
                cvfView.purpose!.length > 1
                    ? getTextCategory(
                    cvfView,
                    cvfView.purpose![1].categoryName,
                    cvfView.purpose![1].categoryId)
                    : Text(''),
                cvfView.purpose!.length > 2
                    ? getTextCategory(
                    cvfView,
                    cvfView.purpose![2].categoryName,
                    cvfView.purpose![2].categoryId)
                    : Text(''),
                cvfView.purpose!.length > 3
                    ? getTextCategory(
                    cvfView,
                    cvfView.purpose![3].categoryName,
                    cvfView.purpose![3].categoryId)
                    : Text(''),
                cvfView.purpose!.length > 4
                    ? getTextCategory(
                    cvfView,
                    cvfView.purpose![4].categoryName,
                    cvfView.purpose![4].categoryId)
                    : Text(''),
              ],
            ),
          )),
      trailing: getTextRounded(cvfView, 'Fill CVF'),
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
                  'Fran Code : ${cvfView.franchiseeCode}',
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
                  'Ref Id :  C-${cvfView.PJPCVF_Id}',
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
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(5, 4, 12, 4),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                        child: Text(
                          cvfView.franchiseeName != 'NA'
                              ? '${cvfView.franchiseeName}'
                              : '${cvfView.Address}',
                          style: TextStyle(
                            fontFamily: 'Lexend Deca',
                            color: Color(0xFF090F13),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(flex: 1, child: getTextRounded(cvfView, 'Fill CVF')),
          ],
        ),
        Padding(
            padding: EdgeInsetsDirectional.fromSTEB(5, 4, 12, 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  cvfView.purpose!.length > 0
                      ? getTextCategory(
                          cvfView,
                          cvfView.purpose![0].categoryName,
                          cvfView.purpose![0].categoryId)
                      : Text(''),
                  cvfView.purpose!.length > 1
                      ? getTextCategory(
                          cvfView,
                          cvfView.purpose![1].categoryName,
                          cvfView.purpose![1].categoryId)
                      : Text(''),
                  cvfView.purpose!.length > 2
                      ? getTextCategory(
                          cvfView,
                          cvfView.purpose![2].categoryName,
                          cvfView.purpose![2].categoryId)
                      : Text(''),
                  cvfView.purpose!.length > 3
                      ? getTextCategory(
                          cvfView,
                          cvfView.purpose![3].categoryName,
                          cvfView.purpose![3].categoryId)
                      : Text(''),
                  cvfView.purpose!.length > 4
                      ? getTextCategory(
                          cvfView,
                          cvfView.purpose![4].categoryName,
                          cvfView.purpose![4].categoryId)
                      : Text(''),
                ],
              ),
            )),
      ],
    );
  }

  getTextRounded(GetDetailedPJP cvfView, String name) {
    return GestureDetector(
      onTap: () {
        if(isComplete()) {
          IntranetServiceHandler.updateCVFStatus(
              widget.employeeId, cvfView.PJPCVF_Id, Utility.getDateTime(),
              'Completed', this);

        }else{
          Utility.showMessage(context, 'Please Fill all questions/feedback and try again');
        }
      },
      child: Container(
        margin: EdgeInsets.only(right: 2),
        decoration: BoxDecoration(
            shape: BoxShape.rectangle, // BoxShape.circle or BoxShape.retangle
            /*color: Colors.red,*/
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 10.0,
              ),
            ]),
        child: Padding(
          padding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
          child: Text('${cvfView.Status} ',
              textAlign: TextAlign.center,
              style: TextStyle(
                  background: Paint()
                    ..color = LightColors.kAbsent
                    ..strokeWidth = 15
                    ..strokeJoin = StrokeJoin.round
                    ..strokeCap = StrokeCap.round
                    ..style = PaintingStyle.stroke,
                  color: Colors.black,
                  fontSize: 12)),
        ),
      ),
    );
  }

  List<Widget> _buildRowList(GetDetailedPJP cvfView) {
    List<Widget> _rowWidget =
        []; // this will hold Rows according to available lines
    for (int index = 0; index < cvfView.purpose!.length; index++) {
      _rowWidget.add(getTextCategory(
          cvfView,
          cvfView.purpose![index].categoryName,
          cvfView.purpose![index].categoryId));
    }
    return _rowWidget;
  }

  getTextCategory(
      GetDetailedPJP cvfView, String categoryname, String categoryId) {
    return GestureDetector(
      onTap: () {
        widget.mCategoryId = categoryId;
        loadData();
      },
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

  updateAnswers(Allquestion questions, String answers) {
    if (userAnswerMap.containsKey(questions.Question_Id.toString())) {
      userAnswerMap.update(
          questions.Question_Id.toString(), (value) => answers);
    } else {
      userAnswerMap.putIfAbsent(
          questions.Question_Id.toString(), () => answers);
    }
    for (int index = 0; index < mQuestionMaster.length; index++) {
      for (int jIndex = 0;
          jIndex < mQuestionMaster[index].allquestion.length;
          jIndex++) {
        if (mQuestionMaster[index].allquestion[jIndex].question ==
            questions.question) {
          mQuestionMaster[index].allquestion[jIndex].SelectedAnswer = answers;
          mQuestionMaster[index].allquestion[jIndex].userAnswers = answers;
          DBHelper helper = DBHelper();
          //print('update ansert');
          helper.updateUserAnswer(
              widget.PJPCVF_Id,
              widget.PJPCVF_Id,
              mQuestionMaster[index].allquestion[jIndex].Question_Id,
              mQuestionMaster[index].allquestion[jIndex].categoryName,
              answers);
          break;
        }
      }
    }
    setState(() {

    });
  }

  Widget showPlayers(Allquestion player) {
    //print(player.toJson().toString());
    return Padding(padding: EdgeInsets.only(left: 20,right: 25),
    child: Column(
      children: [
        Divider(height: 1,),
        ListTile(
          title: Text(
            '${player.Question_Id}. ${player.question}',
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
        _getAnswerWidget(player)
      ],
    ));
  }

  _getAnswerWidget(Allquestion questions) {
    if (questions.answers[0].answerType == 'YesNo') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          /*Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Expanded(
            child: Text(questions.question,
                style: const TextStyle(color: Colors.black, fontSize: 14)),
            ),
          ),*/
          Expanded(
            flex: 1,
            child: CheckboxListTile(
              value: questions.SelectedAnswer == 'Yes' ||
                      (userAnswerMap.containsKey(questions.Question_Id) &&
                          userAnswerMap[questions.Question_Id] == 'Yes')
                  ? true
                  : false,
              title: const Text(
                'Yes',
                style: TextStyle(fontSize: 12),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (checked) {
                //ischeck[getCheckboxIndex(player.question)] = false;
                questions.SelectedAnswer = 'Yes';
                setState(() {
                  updateAnswers(questions, 'Yes');
                });
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: CheckboxListTile(
              value: questions.SelectedAnswer == 'No' ||
                      (userAnswerMap.containsKey(questions.Question_Id) &&
                          userAnswerMap[questions.Question_Id] == 'No')
                  ? true
                  : false,
              title: const Text(
                'No',
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.left,
              ),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (checked) {
                questions.SelectedAnswer = 'No';
                updateAnswers(questions, 'No');
                setState(() {});
              },
            ),
          ),
          GestureDetector(
            onTap: () {
              if(questions.files.isNotEmpty){
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return DetailScreen(imageUrl: getImageUrl(questions.files), question: questions,listener: this,);
                }));
              }else {
                pickImage(questions);
              }
            },
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: questions.files.isEmpty
                  ? Icon(
                      Icons.photo,
                      size: 20,
                    )
                  : Image.network(getImageUrl(questions.files),
                  // width: 300,
                  height: 80,
                  fit:BoxFit.fill

              ),
            ),
          )
        ],
      );
    } else {
      return Column(
        children: getDescriptionWidget(questions),
      );
    }
  }

  getDescriptionWidget(Allquestion questions) {
    //print(getImageUrl(questions.files));
    final size = MediaQuery.of(context).size;
    List<Widget> _rowWidget = [];
    for (int index = 0; index < questions.answers.length; index++) {
      _rowWidget.add(ListTile(
        /*title: Text(
          '${questions.Question_Id}. ${questions.question}',
          style: Theme.of(context).textTheme.bodyText1,
        ),*/
        title: GestureDetector(
          onTap: (){
            showBottomSheet(questions,questions.answers[index].answerName);
          },
          child: Container(
            margin: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
            height: 50,
            width: size.width / 1.3,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey),
            ),
            child: Center(child: Text(
                questions.SelectedAnswer.isNotEmpty
                    ? questions.SelectedAnswer
                    : (userAnswerMap.containsKey(questions.Question_Id) &&
                    userAnswerMap[questions.Question_Id].toString().isNotEmpty)
                    ? userAnswerMap[questions.Question_Id].toString()
                    : questions.answers[index].answerName)),
          ),
        ),
        trailing: GestureDetector(
          onTap: () {
            pickImage(questions);
          },
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: true || questions.files.isEmpty
                ? Icon(
                    Icons.photo,
                    size: 20,
                  )
                : Image.file(
                    File(getImageUrl(questions.files)),
              width: 30,height: 30,
                  ),
          ),
        ),
      ));
    }
    return _rowWidget;
  }

  getImageUrl(String url){
    String weburl= url.replaceAll('___','&');
    weburl = Uri.decodeFull(weburl);
    print(weburl);
    return weburl;
  }

  showBottomSheet(Allquestion question,String hint){

    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.white,
      // set this when inner content overflows, making RoundedRectangleBorder not working as expected
      clipBehavior: Clip.antiAlias,
      // set shape to make top corners rounded
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      context: context,
      builder: (context) {
        final MediaQueryData mediaQueryData = MediaQuery.of(context);
        return Padding(
          padding: mediaQueryData.viewInsets,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.only(left: 15,right: 15,bottom: 25),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _textEditingController,
                      cursorColor: Theme.of(context).primaryColor,
                      maxLength: 60,
                      decoration: InputDecoration(
                        icon: Icon(Icons.description),
                        labelText: hint,
                        labelStyle: TextStyle(
                          color: Color(0xFF6200EE),
                        ),
                        helperText: hint,
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.check_circle,
                          ),
                          onPressed: () {
                            // do something
                            if(_textEditingController.text.toString().isNotEmpty) {
                              updateAnswers(question,
                                  _textEditingController.text.toString());
                              Navigator.of(context).pop();
                            }

                          },
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF6200EE)),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  _getYesNo(Allquestion question) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: CheckboxListTile(
            value: question.userAnswers == 'Yes' ? true : false,
            title: Text(
              'Yes',
              style: TextStyle(fontSize: 12),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (checked) {
              //ischeck[getCheckboxIndex(player.question)] = false;
              question.userAnswers = 'Yes';
              updateAnswers(question, 'Yes');
              setState(() {});
            },
          ),
        ),
        Expanded(
          child: CheckboxListTile(
            value: question.userAnswers == 'No' ? true : false,
            title: Text(
              'No',
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.left,
            ),
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (checked) {
              question.userAnswers = 'No';
              updateAnswers(question, 'No');
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
      ],
    );
  }

  _buildYesNoAnswers(Allquestion question) {
    List<Widget> _rowWidget =
        []; // this will hold Rows according to available lines
    for (int index = 0; index < question.answers.length; index++) {
      bool answers =
          (question.userAnswers == question.answers[index].answerName ||
                  question.SelectedAnswer == question.answers[index].answerName)
              ? true
              : false;
      _rowWidget.add(_generateYesNoAnswers(
          question, question.answers[index].answerName, answers));
    }
    return Row(children: _rowWidget);
  }

  _generateYesNoAnswers(Allquestion question, String Answer_Name, bool value) {
    return Expanded(
      child: CheckboxListTile(
        value: value,
        title: Text(
          Answer_Name,
          style: TextStyle(fontSize: 12),
          textAlign: TextAlign.left,
        ),
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: (checked) {
          question.userAnswers = Answer_Name;
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
    //print('counter is ${counter}');
    return counter;
  }

  isComplete(){
    bool isCompleted = true;
    for(int index=0;index<mQuestionMaster.length;index++){
      for(int jIndex=0;jIndex<mQuestionMaster[index].allquestion.length;jIndex++){
        if(mQuestionMaster[index].allquestion[jIndex].isCompulsory=='1' && mQuestionMaster[index].allquestion[jIndex].SelectedAnswer.isEmpty || mQuestionMaster[index].allquestion[jIndex].SelectedAnswer=='null' ){
          isCompleted = false;
        }
      }
    }
    return isCompleted;
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
    //print('data updated');

    //print('data updated');
  }

  void onItemChanged(bool? checked) {
    //ischeck[getCheckboxIndex(player.question)] = false;
    //player.userAnswers = '1';
    setState() {
      //print('data updated');
      //player.userAnswers = '1';
    }
  }

  void pickImage(Allquestion player) async {
    try {
      final XFile? pickedFileList = await _picker.pickImage(
        source: ImageSource.camera,
          maxHeight: 800,
          imageQuality :100
      );
      setState(() {
        _imageFileList = pickedFileList;
        //player.files = pickedFileList![0].path;
        updateImage(player, player.files);
        String name = widget.employeeId.toString()+'_c'+widget.PJPCVF_Id.toString()+'_q'+player.Question_Id;
        FirebaseStorageUtil().uploadFile(player,_imageFileList!.path, name, this);
      });
    } catch (e) {
      /*setState(() {
        _pickImageError = e;
      });*/
    }
  }

  updateImage(Allquestion questions, String path) {
    for (int index = 0; index < mQuestionMaster.length; index++) {
      for (int jIndex = 0;
          jIndex < mQuestionMaster[index].allquestion.length;
          jIndex++) {
        if (mQuestionMaster[index].allquestion[jIndex].question ==
            questions.question) {
          mQuestionMaster[index].allquestion[jIndex].files = path;
        }
      }
    }
  }

  @override
  void onStart() {
    Utility.showLoaderDialog(context);
  }

  @override
  void onUploadError(value) {
    Navigator.of(context).pop();
  }

  @override
  void onUploadProgress(int value) {
    print(value);
  }

  @override
  void onUploadSuccess(value) {
    Navigator.of(context).pop();
    if(value is Allquestion){
      Allquestion question= value;
      updateImage(question, question.files);
    }
  }

  @override
  void onError(value) {
    Navigator.of(context).pop();
  }

  @override
  void onSuccess(value) {
    Navigator.of(context).pop();
    if (value is UpdateCVFStatusResponse) {
      UpdateCVFStatusResponse response = value;
      loadData();
    }
  }

  @override
  void onClick(int action, value) {
    print('onclick called ${action}');
    if(action == ACTION_ADD_NEW_IMAGE){
      pickImage(value);
    }else if(action == ACTION_DELETE_IMAGE){

    }
  }
}

class MyBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            TextField(
              autofocus: true,
            ),
            TextButton(
              child: Text('Next'),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}


class DetailScreen extends StatelessWidget {
  late String imageUrl;
  late Allquestion question;
  late onClickListener listener;

  DetailScreen({Key? key, required this.imageUrl,required this.question,required this.listener}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryLightColor,
        centerTitle: true,
        title:  Text(
          'Intranet',
          style:
          TextStyle(fontSize: 17, color: Colors.white, letterSpacing: 0.53),
        ),
        actions: [
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
              listener.onClick(ACTION_ADD_NEW_IMAGE, question);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.add,
                size: 20,
              ),
            ),
          ),
          /*InkWell(
            onTap: () {
              listener.onClick(ACTION_DELETE_IMAGE, question);
              *//*Navigator.push(
                context, MaterialPageRoute(builder: (context) => UserNotification()));*//*
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.delete,
                size: 20,
              ),
            ),
          ),*/
        ],
      ),
      body: GestureDetector(
        child: Center(
          child: Hero(
            tag: 'imageHero',
            child: Image.network(
              imageUrl,
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}

