import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intranet/api/request/cvf/questions_request.dart';
import 'package:intranet/api/request/cvf/save_cvfquestions_request.dart';
import 'package:intranet/pages/firebase/storageutil.dart';
import 'package:intranet/pages/helper/DatabaseHelper.dart';
import 'package:intranet/pages/helper/LightColor.dart';
import 'package:intranet/pages/helper/LocalConstant.dart';
import 'package:intranet/pages/iface/onResponse.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:url_launcher/url_launcher.dart';

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
import '../../widget/MyWebSiteView.dart';
import '../../widget/pdfviewer.dart';

class QuestionListScreen extends StatefulWidget {
  GetDetailedPJP cvfView;
  String mCategory;
  String mCategoryId;
  int PJPCVF_Id = 0;
  int employeeId;
  bool isViewOnly;

  QuestionListScreen({Key? key,
    required this.PJPCVF_Id,
    required this.employeeId,
    required this.cvfView,
    required this.mCategory,
    required this.mCategoryId,
    required this.isViewOnly})
      : super(key: key);

  @override
  State<QuestionListScreen> createState() => _QuestionListScreenState();
}

class _QuestionListScreenState extends State<QuestionListScreen>
    implements onUploadResponse, onResponse, onClickListener {
  List<QuestionMaster> mQuestionMaster = [];
  bool isLoading = true;
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFileList;
  Map<String, String> userAnswerMap = Map();
  String _Status = '';

  TextEditingController _textEditingController = TextEditingController();

  late QuestionResponse questionResponse;

  var hiveBox;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
// your code goes here
    print('mCategory Id ${widget.mCategoryId}');
    print('mCategory Id ${widget.mCategory}');
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
    hiveBox = Hive.box(LocalConstant.KidzeeDB);
    await Hive.openBox(LocalConstant.KidzeeDB);
    //print('in pref questions');
    try {
      var cvfQuestions = hiveBox.get(widget.PJPCVF_Id.toString() +
          categoryid +
          LocalConstant.KEY_CVF_QUESTIONS);
      if (false && cvfQuestions is QuestionResponse) {
        QuestionResponse response = cvfQuestions as QuestionResponse;
      } else if (true || cvfQuestions
          .toString()
          .isEmpty) {
        //print('empty');
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
    hiveBox.put(
        widget.PJPCVF_Id.toString() +
            categoryid +
            LocalConstant.KEY_CVF_QUESTIONS,
        data);
  }

  updateImageOffline(Allquestion question, String path) async {
    hiveBox.put('img_' + widget.PJPCVF_Id.toString() + question.Question_Id,
        path);
  }

  String getImagePath(Allquestion question) {
    String? path = hiveBox.get('img_' + widget.PJPCVF_Id.toString() + question.Question_Id);
    return path == null ? '' : path.toString();
  }

  loadData() async {
    DBHelper helper = DBHelper();
    questionResponse = await helper.getQuestionsList(widget.PJPCVF_Id.toString());
    bool isInternet = await Utility.isInternet();
    if (!isInternet && (questionResponse != null && questionResponse.responseData.length > 0)) {
      isLoading = true;
      mQuestionMaster.clear();
      for(int index=0;index<questionResponse.responseData.length;index++) {
        if(questionResponse.responseData[index].categoryId == widget.mCategoryId)
          mQuestionMaster.add(questionResponse.responseData[index]);
      }
      isLoading = false;
      setState(() {});
    } else {
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
            questionResponse = value;

            if (questionResponse != null &&
                questionResponse.responseData != null) {
              saveCvfQuestionsPref(
                  widget.mCategoryId, json.encode(questionResponse.toJson()));
              mQuestionMaster.addAll(questionResponse.responseData);
              DBHelper dbHelper = DBHelper();
              dbHelper.insertCVFQuestions(widget.cvfView.PJPCVF_Id,
                  json.encode(questionResponse.toJson()), 0);
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

  String getAnswerId(List<Answers> answerList, String answerType,
      String answer) {
    print('answerType  ${answerType}');
    String answerId = answer;
    if (answerType == 'YesNo') {
      for (int index = 0; index < answerList.length; index++) {
        print('Answer ${answer} AnswerName ${answerList[index].answerName}');
        if (answer == answerList[index].answerName) {
          print('------');
          answerId = answerList[index].answerId;
        }
      }
    } else {
      answerId = answerList[0].answerId;
    }
    print('Answer Id is ${answerId} for ${answer}');
    return answerId;
  }

  saveAnswers(String cvfId) async {
    bool isInternet = await Utility.isInternet();
    if (isInternet) {
      Utility.showLoaderDialog(context);

      String docXml = '<root>';
      for (int index = 0; index < mQuestionMaster.length; index++) {
        for (int jIndex = 0; jIndex <
            mQuestionMaster[index].allquestion.length; jIndex++) {
          if (mQuestionMaster[index].allquestion[jIndex].userAnswers
              .isNotEmpty) {
            print(' 1  ' +
                mQuestionMaster[index].allquestion[jIndex].Question_Id + '  ' +
                mQuestionMaster[index].allquestion[jIndex].question + '  :  ' +
                mQuestionMaster[index].allquestion[jIndex].userAnswers);
            print(' 100  ' +
                mQuestionMaster[index].allquestion[jIndex].userAnswers
                    .toString());
            docXml = '${docXml}<tblPJPCVF_Answer><SubmissionDate>${Utility
                .convertShortDate(DateTime
                .now())}</SubmissionDate><Question_Id>${mQuestionMaster[index]
                .allquestion[jIndex]
                .Question_Id}</Question_Id><AnswerId>${
                getAnswerId(mQuestionMaster[index].allquestion[jIndex].answers,
                    mQuestionMaster[index].allquestion[jIndex].answers[0]
                        .answerType,
                    mQuestionMaster[index].allquestion[jIndex].userAnswers)
            /* mQuestionMaster[index].allquestion[jIndex].answers[0].answerType == 'YesNo' ?
                  mQuestionMaster[index].allquestion[jIndex].userAnswers : ''*/
            }</AnswerId>'
                '<Files>${decodeFile(mQuestionMaster[index]
                .allquestion[jIndex]
                .files)}</Files><Remarks>${mQuestionMaster[index]
                .allquestion[jIndex].answers[0].answerType == 'YesNo'
                ? ''
                : mQuestionMaster[index].allquestion[jIndex].userAnswers
                .isNotEmpty ? mQuestionMaster[index].allquestion[jIndex]
                .userAnswers : '' }</Remarks></tblPJPCVF_Answer>';
          } else if (userAnswerMap[mQuestionMaster[index].allquestion[jIndex]
              .Question_Id] != null &&
              userAnswerMap[mQuestionMaster[index].allquestion[jIndex]
                  .Question_Id]
                  .toString()
                  .isNotEmpty) {
            print(' 2  ' +
                mQuestionMaster[index].allquestion[jIndex].Question_Id + '  ' +
                mQuestionMaster[index].allquestion[jIndex].question + '  :  ' +
                userAnswerMap[mQuestionMaster[index].allquestion[jIndex]
                    .Question_Id].toString());
            print('UserAnswer : ' +
                userAnswerMap[mQuestionMaster[index].allquestion[jIndex]
                    .Question_Id].toString());
            docXml =
            '${docXml}<tblPJPCVF_Answer><SubmissionDate>${Utility
                .convertShortDate(DateTime
                .now())}</SubmissionDate><Question_Id>${mQuestionMaster[index]
                .allquestion[jIndex]
                .Question_Id}</Question_Id><Files>${decodeFile(mQuestionMaster[index]
                .allquestion[jIndex]
                .files)}</Files><AnswerId>${
                getAnswerId(mQuestionMaster[index].allquestion[jIndex].answers,
                    mQuestionMaster[index].allquestion[jIndex].answers[0]
                        .answerType, userAnswerMap[mQuestionMaster[index]
                        .allquestion[jIndex].Question_Id].toString())
            /*mQuestionMaster[index]
                .allquestion[jIndex].answers[0].answerType == 'YesNo' ? userAnswerMap[mQuestionMaster[index]
                .allquestion[jIndex].Question_Id].toString() : ''*/
            }</AnswerId>'
                '<Remarks>${mQuestionMaster[index]
                .allquestion[jIndex].answers[0].answerType == 'YesNo'
                ? ''
                : userAnswerMap[mQuestionMaster[index]
                .allquestion[jIndex].Question_Id]
                .toString()} </Remarks></tblPJPCVF_Answer>';
          }
        }
      }
      docXml = '${docXml} </root>';
      //print(docXml);
      SaveCVFAnswers request = SaveCVFAnswers(
          PJPCVF_Id: widget.PJPCVF_Id,
          DocXml: docXml,
          UserId: widget.employeeId);
      print(request.toJson());
      APIService apiService = APIService();
      apiService.saveCVFAnswers(request).then((value) {
        print(value.toString());
        if (value != null) {
          Navigator.of(context).pop();
          if (value == null || value.responseData == null) {
            Utility.showMessage(context, 'data not found');
          } else if (value is CVFAnswersResponse) {
            CVFAnswersResponse response = value;
            if (cvfId.isNotEmpty) {
              IntranetServiceHandler.updateCVFStatus(widget.employeeId, cvfId,
                  Utility.getDateTime(), 'Completed', this);
            } else {
              if (cvfId.isEmpty) {
                Utility.showMessage(context, 'CVF Answers saved Successfully');
              }
              if (response != null) {}
              setState(() {});
            }
          } else {
            Utility.showMessage(context, 'data not found');
          }
        }

        setState(() {});
      });
    } else {
      Utility.noInternetConnection(context);
    }
  }

  decodeFile(String url){
    return url.replaceAll('&', '&amp;');
  }
  encodeFile(String url){
    return Uri.decodeFull(url.replaceAll('&amp;', '&'));
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAnalyticsUtils().sendAnalyticsEvent('CVFQuestions');
    return Scaffold(
        appBar: AppBar(
          title: const Text('Questions'),
          actions: !widget.isViewOnly ? [
            IconButton(
              icon: const Icon(Icons.done),
              tooltip: 'Filter',
              onPressed: () {
                saveAnswers('');
              },
            ),
          ] : null,
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
      return Utility.emptyDataSet(context, "CVF Questions are not avaliable");
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
                            Utility.shortDate(
                                Utility.convertServerDate(cvfView.visitDate)),
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.black,
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                  fontSize: 11.0,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          )
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

  getCvfInfo(GetDetailedPJP cvfView) {
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
                  Utility.shortTime(Utility.convertTime(cvfView.visitTime)),
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  Utility.shortTimeAMPM(Utility.convertTime(cvfView.visitTime)),
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
                    ? getTextCategory(cvfView, cvfView.purpose![0].categoryName,
                    cvfView.purpose![0].categoryId)
                    : Text(''),
                cvfView.purpose!.length > 1
                    ? getTextCategory(cvfView, cvfView.purpose![1].categoryName,
                    cvfView.purpose![1].categoryId)
                    : Text(''),
                cvfView.purpose!.length > 2
                    ? getTextCategory(cvfView, cvfView.purpose![2].categoryName,
                    cvfView.purpose![2].categoryId)
                    : Text(''),
                cvfView.purpose!.length > 3
                    ? getTextCategory(cvfView, cvfView.purpose![3].categoryName,
                    cvfView.purpose![3].categoryId)
                    : Text(''),
                cvfView.purpose!.length > 4
                    ? getTextCategory(cvfView, cvfView.purpose![4].categoryName,
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
            Expanded(flex: 1, child: getTextRounded(cvfView, 'Mark Completed')),
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
    if (cvfView.Status == 'FILL CVF') {
      cvfView.Status = 'Check Out';
    }
    _Status = cvfView.Status;
    return GestureDetector(
      onTap: () {
        if (widget.isViewOnly) {

        } else if (cvfView.Status == 'Completed') {
          Utility.showMessages(
              context, 'CVF Already submitted and not able to update');
        } else if (isComplete()) {
          saveAnswers(cvfView.PJPCVF_Id);
        } else {
          if (pendingQuestion == '') {
            Utility.showMessage(
                context, 'Please Fill all questions/feedback and try again');
          } else {
            Utility.showMessage(
                context,
                'Please Fill all questions / feedback \n\n'
                    'Incomplete Questions Categoty are - \n ${pendingQuestion}');
          }
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
          child: Text(cvfView.Status,
              textAlign: TextAlign.center,
              style: TextStyle(
                  background: Paint()
                    ..color = LightColors.kLightBlue
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

  getTextCategory(GetDetailedPJP cvfView, String categoryname,
      String categoryId) {
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

  int mQuestionId = 0;

  Widget showQuestions(QuestionMaster questionMaster) {
    mQuestionId = 1;
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
          .map<Widget>((player) => showPlayers(player, mQuestionId++))
          .toList(),
    );
  }

  updateAnswers(Allquestion questions, String answers) {
    print('updateAnswers ${questions.Question_Id} ${answers}');
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
        if (mQuestionMaster[index].allquestion[jIndex].Question_Id ==
            questions.Question_Id) {
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
    DBHelper helper = DBHelper();
    helper.updateCVFQuestions(
        widget.PJPCVF_Id.toString(), json.encode(questionResponse.toJson()), 0);
    setState(() {});
  }

  Widget showPlayers(Allquestion player, int index) {
    //print(player.toJson().toString());
    return Padding(
        padding: EdgeInsets.only(left: 20, right: 25),
        child: Column(
          children: [
            Divider(
              height: 2,
            ),
            Padding(padding: EdgeInsets.only(left: 10,right: 10,top: 3,bottom: 3),
            child:
            Align(
              alignment: Alignment.centerLeft,
              child: Text(player.isCompulsory == '1'
                  ? '* ${index}. ${player.question}'
                  : '${index}. ${player.question}', style: Theme
                  .of(context)
                  .textTheme
                  .bodyMedium,),
            ),),
            _getAnswerWidget(player)
          ],
        ));
  }

  _getAnswerWidget(Allquestion questions) {
    if (questions.answers[0].answerType == 'YesNo') {
      String path = getImagePath(questions);
      if (path.isNotEmpty) {
        questions.files = path;
        updateImage(questions, path);
      }
      //print('${questions.Question_Id}  : SelectedAnswer ${questions.SelectedAnswer} map ${userAnswerMap[questions.Question_Id]}');
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            flex: 1,
            child: CheckboxListTile(
              value: (!userAnswerMap.containsKey(questions.Question_Id) &&
                  questions.SelectedAnswer == '1') ||
                  (userAnswerMap.containsKey(questions.Question_Id) &&
                      userAnswerMap[questions.Question_Id] == '1')
                  ? true
                  : false,
              title: const Text(
                'Yes',
                style: TextStyle(fontSize: 12),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (checked) {
                if (widget.isViewOnly) {

                } else if (_Status == 'Completed') {
                  Utility.showMessages(
                      context, 'CVF Already submitted and not able to update');
                } else {
                  //ischeck[getCheckboxIndex(player.question)] = false;
                  questions.SelectedAnswer = '1';
                  setState(() {
                    updateAnswers(questions, '1');
                  });
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: CheckboxListTile(
              value: (!userAnswerMap.containsKey(questions.Question_Id) &&
                  questions.SelectedAnswer == '2') ||
                  (userAnswerMap.containsKey(questions.Question_Id) &&
                      userAnswerMap[questions.Question_Id] == '2')
                  ? true
                  : false,
              title: const Text(
                'No',
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.left,
              ),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (checked) {
                if (widget.isViewOnly) {

                } else if (_Status == 'Completed') {
                  Utility.showMessages(
                      context, 'CVF Already submitted and not able to update');
                } else {
                  questions.SelectedAnswer = '2';
                  updateAnswers(questions, '2');
                  setState(() {});
                }
              },
            ),
          ),
          GestureDetector(
            onTap: () {
              if (widget.isViewOnly) {
                if (questions.files.isNotEmpty) {
                  if (questions.files.contains('.png') ||
                      questions.files.contains('.jpg') ||
                      questions.files.contains('.jpeg')) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                      return DetailScreen(
                          imageUrl: getImageUrl(questions.files),
                          question: questions,
                          listener: this,
                          isViewOnly: widget.isViewOnly
                      );
                    }));
                  } else {
                    openFile(questions);
                  }
                }
              } else if (_Status == 'Completed') {
                Utility.showMessages(
                    context, 'CVF Already submitted and not able to update');
              } else if (questions.files.isNotEmpty) {
                if (questions.files.contains('.png') ||
                    questions.files.contains('.jpg') ||
                    questions.files.contains('.jpeg')) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return DetailScreen(
                        imageUrl: getImageUrl(questions.files),
                        question: questions,
                        listener: this,
                        isViewOnly: widget.isViewOnly
                    );
                  }));
                } else {
                  openFile(questions);
                }
              } else {
                showImageOption(questions);
              }
            },

            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: widget.isViewOnly && questions.files.isNotEmpty &&
                  questions.files != null ? isImage(questions.files) ? getIcon(
                  questions.files) : getIcon(questions.files)
                  : (getImagePath(questions)).isNotEmpty ?
              !isImage(questions.files) ? getIcon(questions.files) : Image
                  .network(getImageUrl((getImagePath(questions))),
                  // width: 300,
                  height: 80,
                  fit: BoxFit.fill)
                  : questions.files.isEmpty
                  ? Icon(
                Icons.photo,
                size: 20,
              )
                  : Image.network(getImageUrl(questions.files),
                  // width: 300,
                  height: 80,
                  fit: BoxFit.fill),
            ),
          )
        ],
      );
    } else {
      return Column(
        children:  getDescriptionWidget(questions),
      );
    }
  }

  isImage(String file) {
    bool isImage = false;
    if (file.contains('.png') || file.contains('.jpg') ||
        file.contains('.jpeg')) {
      isImage = true;
    }
    return isImage;
  }

  getIcon(String file) {
    if (file.contains('.xls') || file.contains('.xlsx')) {
      return Image.asset('assets/icons/sheet.png', width: 24,);
    } else if (file.contains('.pdf')) {
      return Image.asset('assets/icons/pdf.png', width: 24,);
    }
    return Image.asset('assets/icons/file.png', width: 24,);;
  }

  getDescriptionWidget(Allquestion questions) {
    String path = getImagePath(questions);
    if (path.isNotEmpty) {
      questions.files = path;
      updateImage(questions, path);
    }
    //print(getImageUrl(questions.files));
    final size = MediaQuery
        .of(context)
        .size;
    List<Widget> _rowWidget = [];
    for (int index = 0; index < questions.answers.length; index++) {
      _rowWidget.add(ListTile(
        title: GestureDetector(
          onTap: () {
            if (_Status == 'Completed') {
              Utility.showMessages(
                  context, 'CVF Already submitted and not able to update');
            } else if(widget.isViewOnly){
              Utility.showMessages(
                  context, 'Manager cannot update the CVF answers');
            }else
              showBottomSheet(questions, questions.answers[index].answerName);
          },
          child: Container(
            margin: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
            height: 45,
            width: size.width / 1.3,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey),
            ),
            child: Center(
                child: Text(questions.Remarks.isNotEmpty
                    ? questions.Remarks
                    : (userAnswerMap.containsKey(questions.Question_Id) &&
                    userAnswerMap[questions.Question_Id]
                        .toString()
                        .isNotEmpty)
                    ? userAnswerMap[questions.Question_Id].toString()
                    : questions.Remarks)),
          ),
        ),
        trailing: GestureDetector(
          onTap: () {
            if (widget.isViewOnly) {
              if (questions.files.isNotEmpty) {
                if (questions.files.contains('.jpg') ||
                    questions.files.contains('png')) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return DetailScreen(
                        imageUrl: getImageUrl(questions.files),
                        question: questions,
                        listener: this,
                        isViewOnly: widget.isViewOnly
                    );
                  }));
                } else {
                  openFile(questions);
                }
              }
            } /*else if (_Status == 'Completed') {
              Utility.showMessages(
                  context, 'CVF Already submitted and not able to update');
            } */else if (questions.files.isNotEmpty) {
              if (questions.files.contains('.jpg') ||
                  questions.files.contains('png')) {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return DetailScreen(
                    imageUrl: getImageUrl(questions.files),
                    question: questions,
                    listener: this,
                    isViewOnly: _Status == 'Completed' ? true : widget.isViewOnly,
                  );
                }));
              } else if (_Status != 'Completed') {
                openFile(questions);
              }
            } else
              showImageOption(questions);
          },
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: (getImagePath(questions)).isNotEmpty ?
            !isImage(questions.files) ? getIcon(questions.files) : Image
                .network(getImageUrl((getImagePath(questions))),
                // width: 300,
                height: 80,
                fit: BoxFit.fill)
                : questions.files.isEmpty
                ? Icon(
              Icons.photo,
              size: 20,
            )
                : Image.network(getImageUrl(questions.files),
                // width: 300,
                height: 80,
                fit: BoxFit.fill),
          ),
        ),
      ));
    }
    return _rowWidget;
  }

  getImageUrl(String url) {
    String weburl = url.replaceAll('___', '&');
    weburl = Uri.decodeFull(weburl);
    //print(weburl);
    return weburl;
  }

  showBottomSheet(Allquestion question, String hint) {
    _textEditingController.text =
    question.userAnswers.isNotEmpty ? question.userAnswers : '';
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
                padding: EdgeInsets.only(left: 15, right: 15, bottom: 25),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _textEditingController,
                      cursorColor: Theme
                          .of(context)
                          .primaryColor,
                      minLines: 3,
                      maxLines: 7,
                      maxLength: 600,
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
                            if (_textEditingController.text
                                .toString()
                                .isNotEmpty) {
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
              if (!widget.isViewOnly) {
                question.userAnswers = 'Yes';
                updateAnswers(question, 'Yes');
                setState(() {});
              }
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
              if (!widget.isViewOnly) {
                question.userAnswers = 'No';
                updateAnswers(question, 'No');
                setState(() {});
              }
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

  late String pendingQuestion = '';

  isComplete() {
    bool isCompleted = true;
    String inCompleteQuestions = '';
    String token = '';
    int inCompleteCounts = 0;
    pendingQuestion = '';
    for (int index = 0; index < mQuestionMaster.length; index++) {
      for (int jIndex = 0;
      jIndex < mQuestionMaster[index].allquestion.length;
      jIndex++) {
        String userAnswer = mQuestionMaster[index]
            .allquestion[jIndex]
            .SelectedAnswer
            .isNotEmpty
            ? mQuestionMaster[index].allquestion[jIndex].SelectedAnswer
            : (userAnswerMap.containsKey(mQuestionMaster[index]
            .allquestion[jIndex]
            .Question_Id) &&
            userAnswerMap[mQuestionMaster[index]
                .allquestion[jIndex]
                .Question_Id]
                .toString()
                .isNotEmpty)
            ? userAnswerMap[
        mQuestionMaster[index].allquestion[jIndex].Question_Id]
            .toString()
            : '';
        if (mQuestionMaster[index].allquestion[jIndex].isCompulsory == '1' &&
            (userAnswer.isEmpty || userAnswer == 'null')) {
          inCompleteQuestions =
          'Please complete all Required answers, Questions in Category ${mQuestionMaster[index]
              .allquestion[jIndex].categoryName} is pending';
          if (pendingQuestion.isEmpty) {
            pendingQuestion =
                ' - ' + mQuestionMaster[index].allquestion[jIndex].categoryName;
          } else {
            pendingQuestion = pendingQuestion + ' \n - ' +
                mQuestionMaster[index].allquestion[jIndex].categoryName;
          }
          print(pendingQuestion);
          token = ',';
          inCompleteCounts = inCompleteCounts + 1;
          isCompleted = false;
          break;
        } /*else {
          print(mQuestionMaster[index].allquestion[jIndex].Question_Id +
              ' NC ' +
              mQuestionMaster[index].allquestion[jIndex].SelectedAnswer);
        }*/
      }
    }
    if (inCompleteCounts < 10) {
      //pendingQuestion = inCompleteQuestions;
    } else {
      //pendingQuestion = '';
    }
    //print(pendingQuestion);
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

  showImageOption(Allquestion question) {
    //Navigator.pop(context);
    List<String> options = ['Gallery', 'Camera', 'File Upload'];
    if (question.files.isNotEmpty) {
      options.add('View');
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Select'),
            content: Container(
              width: double.minPositive,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(options[index]),
                    leading: Icon(
                      index == 0
                          ? Icons.image
                          : index == 1
                          ? Icons.camera
                          : Icons.image_search,
                      size: 25,
                    ),
                    onTap: () {
                      //Navigator.pop(context, options[index]);
                      Navigator.of(context, rootNavigator: true).pop('dialog');
                      if (options[index] == 'Gallery')
                        showImagePicker(0, question);
                      else if (options[index] == 'Camera') {
                        showImagePicker(1, question);
                      } else if (options[index] == 'File Upload') {
                        showImagePicker(2, question);
                      } else {
                        showImagePicker(3, question);
                      }
                    },
                  );
                },
              ),
            ),
          );
        });
  }

  showImagePicker(int action, Allquestion question) async {
    print('image action ${action}');
    if (action != 3) {
      if (action == 0) {
        pickImage(question, ImageSource.gallery);
      } else if (action == 1) {
        pickImage(question, ImageSource.camera);
      } else if (action == 2) {
        pickFile(question);
      }
    } else {
      if (question.files.contains('.jpg') || question.files.contains('png')) {
        Navigator.push(context, MaterialPageRoute(builder: (_) {
          return DetailScreen(
            imageUrl: getImageUrl(question.files),
            question: question,
            listener: this,
            isViewOnly: widget.isViewOnly,
          );
        }));
      } else {
        openFile(question);
      }
    }
  }

  openFile(Allquestion question) async {
    if (question.files.contains('.pdf')) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              MyPdfApp(worksheetUrl: Uri.decodeFull(question.files),
                title: question.files,
                filename: '${widget.PJPCVF_Id}_${question.Question_Id}.pdf',
                module: 'CVF',),
        ),
      );
    } else {
      //print(Uri.decodeFull(question.files));
      File file = File(Uri.decodeFull(question.files));
      var filePath =Uri.decodeFull(file.path).split('?');
      //print('FilePath : ${filePath[0]}');
      var fileExt = filePath[0].split('/');
      String fileName = fileExt[fileExt.length-1].toString();
      //print('fileExt : ${fileName}');

      (await Utility.isFileExists(fileName)) ? Utility.shareFile(fileName) :
      setState(() {
        isLoading = true;
      });
      Utility.downloadFile(Uri.decodeFull(question.files), fileName).then((
          value) {
        isLoading = false;
        setState(() {

        });
      });
    }
  }

  launchMyUrl(String weburl) async{
    final Uri url = Uri.parse(weburl);
    if (!await launchUrl(url)) {
    throw Exception('Could not launch $weburl');
    }
  }

    void pickImage(Allquestion player, ImageSource source) async {
      try {
        final XFile? pickedFileList = await _picker.pickImage(
            source: source, maxHeight: 800, imageQuality: 100);
        setState(() {
          _imageFileList = pickedFileList;
          print(_imageFileList!.path);
          //player.files = pickedFileList![0].path;
          updateImage(player, player.files);
          String name = widget.employeeId.toString() +
              '_c' +
              widget.PJPCVF_Id.toString() +
              '_q' +
              player.Question_Id;
          FirebaseStorageUtil()
              .uploadFile(player, _imageFileList!.path, name, this);
        });
      } catch (e) {
        /*setState(() {
        _pickImageError = e;
      });*/
      }
    }

    void pickFile(Allquestion player) async {
      try {
        FilePickerResult? result = await FilePicker.platform.pickFiles();

        if (result != null) {
          File file = File(result.files.single.path!);
          var fileExt = file.path.split('/');
          print('File path ${fileExt[fileExt.length - 1]}');
          setState(() {
            updateImage(player, player.files);
            String name = widget.employeeId.toString() +
                '_c' +
                widget.PJPCVF_Id.toString() +
                '_q' +
                player.Question_Id;
            FirebaseStorageUtil()
                .uploadAnyFile(
                player, file!.path, fileExt[fileExt.length - 1], this);
          });
        } else {
          // User canceled the picker

        }
      } catch (e) {
        print(e);
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
          if (mQuestionMaster[index].allquestion[jIndex].Question_Id ==
              questions.Question_Id) {
            mQuestionMaster[index].allquestion[jIndex].files = path;
            updateImageOffline(questions, path);
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
      if (value is Allquestion) {
        Allquestion question = value;
        updateImage(question, question.files);
      }
      setState(() {});
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
        Utility.showMessageSingleButton(
            context, 'Thank you for submitting the CVF', this);
      }
    }

    @override
    void onClick(int action, value) {
      //print('onclick called ${action}');
      if (action == ACTION_ADD_NEW_IMAGE) {
        showImageOption(value);
      } else if (action == ACTION_DELETE_IMAGE) {} else
      if (action == Utility.ACTION_OK) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
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
  bool isViewOnly;

  DetailScreen(
  {Key? key,
  required this.imageUrl,
  required this.question,
  required this.listener,
  required this.isViewOnly})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
  return Scaffold(
  appBar: AppBar(
  backgroundColor: kPrimaryLightColor,
  centerTitle: true,
  title: Text(
  'Intranet',
  style:
  TextStyle(fontSize: 17, color: Colors.white, letterSpacing: 0.53),
  ),
  actions: !isViewOnly ? [
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
              */ /*Navigator.push(
                context, MaterialPageRoute(builder: (context) => UserNotification()));*/ /*
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.delete,
                size: 20,
              ),
            ),
          ),*/
  ] : null,
  ),
  body: GestureDetector(
  child: PinchZoom(
  child: Image.network(imageUrl),
  resetDuration: const Duration(milliseconds: 100),
  maxScale: 2.5,
  onZoomStart: (){print('Start zooming');},
  onZoomEnd: (){print('Stop zooming');},
  ),
  /*Center(
          child: Hero(
            tag: 'imageHero',
            child: Image.network(
              imageUrl,
            ),
          ),
        ),*/
  onTap: () {
  Navigator.pop(context);
  },
  ),
  );
  }
  }
