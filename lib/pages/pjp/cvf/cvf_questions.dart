import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Intranet/api/request/cvf/questions_request.dart';
import 'package:Intranet/api/request/cvf/save_cvfquestions_request.dart';
import 'package:Intranet/pages/firebase/storageutil.dart';
import 'package:Intranet/pages/helper/DatabaseHelper.dart';
import 'package:Intranet/pages/helper/LocalConstant.dart';
import 'package:Intranet/pages/iface/onResponse.dart';
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
import '../../helper/LightColor.dart';
import '../../helper/constants.dart';
import '../../helper/utils.dart';
import '../../iface/onClick.dart';
import '../../iface/onUploadResponse.dart';
import '../../utils/theme/colors/light_colors.dart';
import '../../widget/pdfviewer.dart';

class QuestionListScreen extends StatefulWidget {
  GetDetailedPJP cvfView;
  String mCategory;
  String mCategoryId;
  int PJPCVF_Id = 0;
  int employeeId;
  bool isViewOnly;

  QuestionListScreen(
      {Key? key,
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

  late QuestionResponse? questionResponse = null;

  var hiveBox;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getPrefQuestions(widget.mCategoryId);
      getUsersAnswers();
    });
  }

  getUsersAnswers() async {
    DBHelper helper = DBHelper();
    userAnswerMap = await helper.getUsersAnswerList(widget.PJPCVF_Id);
  }

  List<bool> ischeck = [];

  int businessId = 1;

  bool isAllCategoryQuestionsCompleted() {
    bool isCompleted = true;
    int inCompleteCounts = 0;
    for (int jkIndex = 0; jkIndex < widget.cvfView.purpose!.length; jkIndex++) {
      var cvfQuestions = hiveBox.get(widget.PJPCVF_Id.toString() +
          widget.cvfView.purpose![jkIndex].categoryId.trim() +
          LocalConstant.KEY_CVF_QUESTIONS);
      if (cvfQuestions == null || cvfQuestions.toString().isEmpty) {
        isCompleted = false;
        pendingQuestion =
            " Questions in ${widget.cvfView.purpose![jkIndex].categoryName} are incomplete, please complete all questions / feedback";
      } else {
        try {
          QuestionResponse cvfQuestionsModel = QuestionResponse(
              responseMessage: '', statusCode: 100, responseData: []);
          if (cvfQuestions is QuestionResponse) {
            cvfQuestionsModel = cvfQuestionsModel;
          } else {
            try {
              cvfQuestionsModel = QuestionResponse.fromJson(
                json.decode(cvfQuestions),
              );
            } catch (e) {
              cvfQuestionsModel = QuestionResponse.fromJson(
                cvfQuestions,
              );
            }
          }
          if (cvfQuestionsModel != null &&
              cvfQuestionsModel.responseData != null &&
              cvfQuestionsModel.responseData.length > 0) {
            for (int index = 0;
                index < cvfQuestionsModel.responseData.length;
                index++) {
              for (int jIndex = 0;
                  jIndex <
                      cvfQuestionsModel.responseData[index].allquestion.length;
                  jIndex++) {
                List<QuestionMaster> mQuestionMaster =
                    cvfQuestionsModel.responseData;
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
                        ? userAnswerMap[mQuestionMaster[index]
                                .allquestion[jIndex]
                                .Question_Id]
                            .toString()
                        : '';
                if (mQuestionMaster[index].allquestion[jIndex].isCompulsory ==
                        '1' &&
                    (userAnswer.isEmpty || userAnswer == 'null')) {
                  if (pendingQuestion.isEmpty) {
                    pendingQuestion =
                        'Please submit the below observation \n\n - ' +
                            mQuestionMaster[index]
                                .allquestion[jIndex]
                                .categoryName;
                  } else {
                    pendingQuestion = pendingQuestion +
                        ' \n' +
                        widget.cvfView.purpose![jkIndex].categoryName;
                  }
                  inCompleteCounts = inCompleteCounts + 1;
                  isCompleted = false;
                  break;
                }
              }
            }
          } else {
            pendingQuestion =
                " Please Fill ${widget.cvfView.purpose![jkIndex].categoryName} and try again";
          }
        } catch (e) {
          debugPrint(e.toString());
        }
      }
    }
    return isCompleted;
  }

  getPrefQuestions(String categoryid) async {
    hiveBox = Hive.box(LocalConstant.KidzeeDB);
    businessId = hiveBox.get(LocalConstant.KEY_BUSINESS_ID);
    await Hive.openBox(LocalConstant.KidzeeDB);

    //debugPrint('in pref questions');
    try {
      var cvfQuestions = hiveBox.get(widget.PJPCVF_Id.toString() +
          categoryid +
          LocalConstant.KEY_CVF_QUESTIONS);
      //debugPrint('cvfQES --- ${widget.PJPCVF_Id.toString() + categoryid + LocalConstant.KEY_CVF_QUESTIONS}');
      /*if (cvfQuestions is QuestionResponse) {
        debugPrint('localdata');
        QuestionResponse response = cvfQuestions as QuestionResponse;
        loadData();
      } else */
      if (cvfQuestions.toString().isEmpty) {
        //debugPrint('empty');
        loadData();
      } else {
        debugPrint('in else');
        try {
          QuestionResponse cvfQuestionsModel = QuestionResponse.fromJson(
            json.decode(cvfQuestions.toString()),
          );
          debugPrint('Data from the Preference ${cvfQuestionsModel}');
          mQuestionMaster.addAll(cvfQuestionsModel.responseData);
          questionResponse = QuestionResponse(responseMessage: '', statusCode: 200, responseData: cvfQuestionsModel.responseData);
          isLoading = false;
          setState(() {});
        } catch (e) {
          debugPrint('captured in catch $e');
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
    hiveBox.put(
        'img_' + widget.PJPCVF_Id.toString() + question.Question_Id, path);
  }

  String getImagePath(Allquestion question) {
    String? path = hiveBox
        .get('img_' + widget.PJPCVF_Id.toString() + question.Question_Id);
    return path == null ? '' : path.toString();
  }

  loadData() async {
    DBHelper helper = DBHelper();
    questionResponse = await helper.getQuestions(widget.PJPCVF_Id.toString(), widget.mCategory, widget.mCategoryId);

    //print('offline ${questionResponse!.toJson()}');

    bool isInternet = await Utility.isInternet();

    if (!isInternet && (questionResponse != null && questionResponse!.responseData.length > 0)) {
      isLoading = true;
      mQuestionMaster.clear();
      for (int index = 0; index < questionResponse!.responseData.length;index++) {
        mQuestionMaster.add(questionResponse!.responseData[index]);
      }
      isLoading = false;
      setState(() {});
    } else {
      setState(() {
        isLoading = true;
      });
      mQuestionMaster.clear();
      QuestionsRequest request = QuestionsRequest(
          Category_Id: widget.mCategoryId,
          Business_id: businessId.toString(),
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
                questionResponse!.responseData != null) {
              saveCvfQuestionsPref(widget.mCategoryId, questionResponse!.toJson());
              mQuestionMaster.addAll(questionResponse!.responseData);
              DBHelper dbHelper = DBHelper();
              dbHelper.insertCVFQuestions(
                  widget.cvfView.PJPCVF_Id,
                  widget.mCategoryId,
                  json.encode(questionResponse!.toJson()),
                  0);
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

  String getAnswerId(List<Answers> answerList, String answerType, String answer) {
    String answerId = answer;
    if (answerType == 'YesNo') {
      //print('Answer YesNo...${answer}');
      for (int index = 0; index < answerList.length; index++) {
        if (answer == answerList[index].answerName) {
          answerId = answerList[index].answerId;
      //    print('Answer AnswerId...${answerId}');
        }
      }
    } else {
      answerId = answerList[0].answerId;
      //print('Answer AnswerId...else');
    }
    //print('Answer is ${answerId}');
    return answerId;
  }

  String getRating(List<Answers> answerList, String answerType, String answer) {
    String rating = '';
    if (answerType == 'YesNo') {
      //print('Answer YesNo...${answer}');
      for (int index = 0; index < answerList.length; index++) {
        if (answer == answerList[index].answerId) {
          rating = answerList[index].rating;
        //  print('Answer AnswerId...${rating}');
        }
      }
    }
    //print('Answer is ${rating}');
    return rating;
  }
bool isOffline=false;
  isFileUpload() {
    isOffline=false;
    for (int index = 0; index < mQuestionMaster.length; index++) {
      for (int jIndex = 0;jIndex < mQuestionMaster[index].allquestion.length;jIndex++) {
        if(mQuestionMaster[index].allquestion[jIndex].files.isNotEmpty && mQuestionMaster[index].allquestion[jIndex].files.contains('data/user')){
          String name = widget.employeeId.toString() +'_c' +widget.PJPCVF_Id.toString() +'_q' +mQuestionMaster[index].allquestion[jIndex].Question_Id;
          FirebaseStorageUtil().uploadFile(mQuestionMaster[index].allquestion[jIndex], mQuestionMaster[index].allquestion[jIndex].files, name, this);
          return true;
        }
      }
    }
    //isOffline=false;
    return isOffline;
  }

  saveAnswers(String cvfId) async {
    bool isInternet = await Utility.isInternet();
    if(isFileUpload()){
      debugPrint('isFile upload');
    }else if (isInternet) {
      debugPrint('saving data');
      Utility.showLoaderDialog(context);
      isOffline=false;
      String docXml = '<root>';
      for (int index = 0; index < mQuestionMaster.length; index++) {
        for (int jIndex = 0;
            jIndex < mQuestionMaster[index].allquestion.length;
            jIndex++) {
          if (mQuestionMaster[index].allquestion[jIndex].endDate!='NA' || mQuestionMaster[index].allquestion[jIndex].startDate!='NA' || mQuestionMaster[index].allquestion[jIndex].Remarks.isNotEmpty || mQuestionMaster[index]
                      .allquestion[jIndex]
                      .answers[0]
                      .answerType ==
                  'YesNo' &&
              (mQuestionMaster[index]
                      .allquestion[jIndex]
                      .userAnswers
                      .isNotEmpty ||
                  mQuestionMaster[index]
                      .allquestion[jIndex]
                      .files
                      .isNotEmpty)) {
            //print('===========IF YESNO ${mQuestionMaster[index].allquestion[jIndex].Question_Id} uid-${mQuestionMaster[index].allquestion[jIndex].userAnswers},${userAnswerMap[mQuestionMaster[index].allquestion[jIndex].Question_Id]}');
            docXml =
                '${docXml}<tblPJPCVF_Answer><SubmissionDate>${Utility.convertShortDate(DateTime.now())}</SubmissionDate><Question_Id>${mQuestionMaster[index].allquestion[jIndex].Question_Id}</Question_Id><AnswerId>${getAnswerId(mQuestionMaster[index].allquestion[jIndex].answers, mQuestionMaster[index].allquestion[jIndex].answers[0].answerType, mQuestionMaster[index].allquestion[jIndex].userAnswers.isNotEmpty ? mQuestionMaster[index].allquestion[jIndex].userAnswers : userAnswerMap[mQuestionMaster[index].allquestion[jIndex].Question_Id].toString() )
                /* mQuestionMaster[index].allquestion[jIndex].answers[0].answerType == 'YesNo' ?
                  mQuestionMaster[index].allquestion[jIndex].userAnswers : ''*/
                }</AnswerId>'
                '${mQuestionMaster[index].allquestion[jIndex].toStartDateXml()}${mQuestionMaster[index].allquestion[jIndex].toEndDateXml()}<Rating>${getRating(mQuestionMaster[index].allquestion[jIndex].answers, mQuestionMaster[index].allquestion[jIndex].answers[0].answerType, mQuestionMaster[index].allquestion[jIndex].SelectedAnswer.isNotEmpty ? mQuestionMaster[index].allquestion[jIndex].SelectedAnswer : userAnswerMap[mQuestionMaster[index].allquestion[jIndex].Question_Id].toString())}</Rating><Files>${encodeFile(mQuestionMaster[index].allquestion[jIndex].files)}</Files><Remarks>${mQuestionMaster[index].allquestion[jIndex].Remarks.isNotEmpty ? mQuestionMaster[index].allquestion[jIndex].Remarks : mQuestionMaster[index].allquestion[jIndex].answers[0].answerType == 'YesNo' ? '' : mQuestionMaster[index].allquestion[jIndex].userAnswers.isNotEmpty ? mQuestionMaster[index].allquestion[jIndex].userAnswers : ''}</Remarks></tblPJPCVF_Answer>';
            print(docXml);
          } else if (/*mQuestionMaster[index]
                      .allquestion[jIndex]
                      .answers[0]
                      .answerType !=
                  'YesNo' &&*/
              (userAnswerMap[mQuestionMaster[index]
                              .allquestion[jIndex]
                              .Question_Id] !=
                          null &&
                      userAnswerMap[mQuestionMaster[index]
                              .allquestion[jIndex]
                              .Question_Id]
                          .toString()
                          .isNotEmpty ||
                  mQuestionMaster[index]
                      .allquestion[jIndex]
                      .files
                      .isNotEmpty)) {
            //print('===========ELSE YESNO  ${mQuestionMaster[index].allquestion[jIndex].userAnswers},${userAnswerMap[mQuestionMaster[index].allquestion[jIndex].Question_Id]},${getAnswerId(mQuestionMaster[index].allquestion[jIndex].answers, mQuestionMaster[index].allquestion[jIndex].answers[0].answerType, userAnswerMap[mQuestionMaster[index].allquestion[jIndex].Question_Id].toString().isNotEmpty  ? userAnswerMap[mQuestionMaster[index].allquestion[jIndex].Question_Id].toString() : mQuestionMaster[index].allquestion[jIndex].SelectedAnswer)}');
            docXml =
                '${docXml}<tblPJPCVF_Answer><SubmissionDate>${Utility.convertShortDate(DateTime.now())}</SubmissionDate><Question_Id>${mQuestionMaster[index].allquestion[jIndex].Question_Id}</Question_Id><Files>${encodeFile(mQuestionMaster[index].allquestion[jIndex].files)}</Files><AnswerId>${getAnswerId(mQuestionMaster[index].allquestion[jIndex].answers, mQuestionMaster[index].allquestion[jIndex].answers[0].answerType, userAnswerMap[mQuestionMaster[index].allquestion[jIndex].Question_Id].toString().isNotEmpty  ? userAnswerMap[mQuestionMaster[index].allquestion[jIndex].Question_Id].toString() : userAnswerMap[mQuestionMaster[index].allquestion[jIndex].Question_Id].toString())
                }</AnswerId>'
                '<Remarks>${ mQuestionMaster[index].allquestion[jIndex].answers[0].answerType == 'YesNo' ? '' : userAnswerMap[mQuestionMaster[index].allquestion[jIndex].Question_Id].toString().isEmpty || userAnswerMap[mQuestionMaster[index].allquestion[jIndex].Question_Id].toString() == 'null' ? mQuestionMaster[index].allquestion[jIndex].Remarks : userAnswerMap[mQuestionMaster[index].allquestion[jIndex].Question_Id].toString()}</Remarks></tblPJPCVF_Answer>';
          }
        }
      }
      docXml = '${docXml} </root>';
      print(docXml);
      debugPrint('API Is Calling....');
      SaveCVFAnswers request = SaveCVFAnswers(
          PJPCVF_Id: widget.PJPCVF_Id,
          DocXml: docXml,
          UserId: widget.employeeId);
      APIService apiService = APIService();
      apiService.saveCVFAnswers(request).then((value) {
        if (value != null) {
          Navigator.of(context).pop();
          if (value == null || value.responseData == null) {
            Utility.showMessage(context, 'data not found');
          } else if (value is CVFAnswersResponse) {
            CVFAnswersResponse response = value;
            if (cvfId.isNotEmpty) {
              IntranetServiceHandler.updateCVFStatus(widget.employeeId,
                  widget.cvfView, Utility.getDateTime(), 'Completed', this);
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

  decodeFile(String url) {
    return url.replaceAll('&amp;', '&');
  }

  encodeFile(String url) {
    String link = url.replaceAll('___', '&');
    link = link.replaceAll('&', '&amp;');
    return link;
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAnalyticsUtils().sendAnalyticsEvent('CVFQuestions');
    return Scaffold(
        appBar: AppBar(
          title: const Text('Questions'),
          actions: !widget.isViewOnly
              ? [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh',
                    onPressed: () {
                      loadData();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.done),
                    tooltip: 'Filter',
                    onPressed: () {
                      saveAnswers('');
                    },
                  ),
                ]
              : null,
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

  List<Widget> getCategoryList(GetDetailedPJP cvfView) {
    List<Widget> list = [];
    for (int index = 0; index < widget.cvfView.purpose!.length; index++) {
      list.add(getTextCategory(cvfView, cvfView.purpose![index].categoryName,
          cvfView.purpose![index].categoryId));
    }
    return list;
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
          padding: EdgeInsetsDirectional.fromSTEB(5, 4, 20, 4),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: getCategoryList(cvfView),
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
                children: getCategoryList(cvfView),
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
          Utility.showMessages(context, 'CVF Already submitted and not able to update');
        } else if (isComplete() && isAllCategoryQuestionsCompleted()) {
          saveAnswers(cvfView.PJPCVF_Id);
        } else {
          if (pendingQuestion == '') {
            Utility.showMessage(
                context, 'Please Fill all questions/feedback and try again');
          } else {
            Utility.showMessage(
                context,
                /*'Please Fill all questions / feedback \n\n'
                    'Incomplete Questions Categoty are - \n */
                '${pendingQuestion}');
          }
        }
      },
      child: Container(
        margin: EdgeInsets.only(right: 2),
        decoration: BoxDecoration(
            shape: BoxShape.rectangle, // BoxShape.circle or BoxShape.retangle
            /*color: Colors.red,*/
            color: LightColors.kLightBlue,
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 5.0,
              ),
            ]),
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Text(cvfView.Status,
              textAlign: TextAlign.center,
              style: TextStyle(
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
    //mQuestionMaster[index].allquestion[jIndex].answers
    if (userAnswerMap.containsKey(questions.Question_Id.toString())) {
      userAnswerMap.update(questions.Question_Id.toString(), (value) => answers);
    } else {
      userAnswerMap.putIfAbsent(questions.Question_Id.toString(), () => answers);
    }
    for (int index = 0; index < mQuestionMaster.length; index++) {
      for (int jIndex = 0;jIndex < mQuestionMaster[index].allquestion.length;jIndex++) {
        if (mQuestionMaster[index].allquestion[jIndex].Question_Id ==questions.Question_Id) {
          mQuestionMaster[index].allquestion[jIndex].SelectedAnswer = answers;
          mQuestionMaster[index].allquestion[jIndex].userAnswers = answers;
          //debugPrint('Answer updated for ${questions.Question_Id} ${answers}');
          DBHelper helper = DBHelper();
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
    saveCvfQuestionsPref(widget.mCategoryId, questionResponse!.toJson());
    /*DBHelper helper = DBHelper();
    helper.updateCVFQuestions(
        widget.PJPCVF_Id.toString(), questionResponse.toJson(), 0);*/
    setState(() {});
  }

  Widget showPlayers(Allquestion player, int index) {
    return Padding(
        padding: EdgeInsets.only(left: 20, right: 25),
        child: Column(
          children: [
            Divider(
              height: 2,
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, right: 10, top: 3, bottom: 3),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  player.isCompulsory == '1'
                      ? '* ${index}. ${player.question}'
                      : '${index}. ${player.question}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            _getAnswerWidget(player)
          ],
        ));
  }

  _getAnswerWidget(Allquestion questions){
    if (questions.answers[0].answerType == 'YesNo') {
      String path = getImagePath(questions);
      if (path.isNotEmpty) {
        questions.files = path;
        updateImage(questions, path);
      }

      return Padding(padding: EdgeInsets.only(bottom: 15),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 10),
                constraints: BoxConstraints.tightFor(width: MediaQuery.of(context).size.width * 0.7, height: questions.IsProgressive=='1' ? questions.answers.length * 50 : 120),
                child: Column(
                  children: _generateDynamicYesNo(questions),
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
                              isViewOnly: widget.isViewOnly);
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
                            isViewOnly: widget.isViewOnly);
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
                  child: questions.files.isNotEmpty && questions.files != null
                      ? isImage(questions.files) && questions.files.contains('data/user')
                      ? Image.file(File(questions.files),height: 30,width: 30,) : isImage(questions.files)
                      ? getIcon(questions.files)
                      : getIcon(questions.files)
                      : (getImagePath(questions)).isNotEmpty
                      ? !isImage(questions.files)
                      ? getIcon(questions.files)
                      : Image.network(
                      getImageUrl((getImagePath(questions))),
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
              // More rows
            ],
          ),
          questions.IsProgressive=='1' ? getDateLatyout(questions) : Container()
        ],
      ),);
    }else {
      return Column(
        children: getDescriptionWidget(questions),
      );
    }
  }

  getDateLatyout(Allquestion questions) {
    return Container(
      color: LightColors.kLightGrayM,
      child: Row(
        children: [
          Expanded(child: datePicker(context,questions.Question_Id,'Start',questions.startDate,questions.startDate)),
          questions.startDate.isNotEmpty ?
          Expanded(child: datePicker(context,questions.Question_Id,'End',questions.endDate,questions.startDate)) : Container()
        ],
      ),
    );
  }

  getRemark(Allquestion questions) {
    //print(questions.toJson());
    return Container(
      color: LightColors.kLightGrayM,
      width: MediaQuery.of(context).size.width,
      height: 35,
      child: Row(
        children: [
          Expanded(child: InkWell(onTap:() => showRemarkDialog(questions),child: Text(maxLines: 2,
              overflow: TextOverflow.ellipsis, questions.Remarks.isEmpty ? 'Remark' : questions.Remarks),))
        ],
      ),
    );
  }
  _getAnswerWidget1(Allquestion questions) {
    if (questions.answers[0].answerType == 'YesNo') {
      String path = getImagePath(questions);
      if (path.isNotEmpty) {
        questions.files = path;
        updateImage(questions, path);
      }
      //debugPrint('${questions.Question_Id}  : SelectedAnswer ${questions.SelectedAnswer} map ${userAnswerMap[questions.Question_Id]}');
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(child: Row(
            children: _generateDynamicYesNo(questions),
          ),),
          /*Expanded(
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
          ),*/
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
                          isViewOnly: widget.isViewOnly);
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
                        isViewOnly: widget.isViewOnly);
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
              child: questions.files.isNotEmpty && questions.files != null
                  ? isImage(questions.files) && questions.files.contains('data/user')
                  ? Image.file(File(questions.files),height: 30,width: 30,) : isImage(questions.files)
                      ? getIcon(questions.files)
                      : getIcon(questions.files)
                  : (getImagePath(questions)).isNotEmpty
                      ? !isImage(questions.files)
                          ? getIcon(questions.files)
                          : Image.network(
                              getImageUrl((getImagePath(questions))),
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
        children: getDescriptionWidget(questions),
      );
    }
  }

  isImage(String file) {
    bool isImage = false;
    if (file.contains('.png') ||
        file.contains('.jpg') ||
        file.contains('.jpeg')) {
      isImage = true;
    }
    return isImage;
  }

  getIcon(String file) {
    //debugPrint('file is ${file}');
    if (file.contains('.xls') || file.contains('.xlsx')) {
      return Image.asset(
        'assets/icons/sheets.png',
        width: 24,
      );
    } else if (file.contains('.pdf')) {
      return Image.asset(
        'assets/icons/pdf.png',
        width: 24,
      );
    }
    return Image.asset(
      'assets/icons/file.png',
      width: 24,
    );
    ;
  }

  getDescriptionWidget(Allquestion questions) {
    String path = getImagePath(questions);
    if (path.isNotEmpty) {
      questions.files = path;
      updateImage(questions, path);
    }
    //debugPrint(getImageUrl(questions.files));
    final size = MediaQuery.of(context).size;
    List<Widget> _rowWidget = [];
    for (int index = 0; index < questions.answers.length; index++) {
      _rowWidget.add(ListTile(
        title: GestureDetector(
          onTap: () {
            if (_Status == 'Completed') {
              Utility.showMessages(
                  context, 'CVF Already submitted and not able to update');
            } else if (widget.isViewOnly) {
              Utility.showMessages(
                  context, 'Manager cannot update the CVF answers');
            } else
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
                child: Text((userAnswerMap.containsKey(questions.Question_Id) &&
                        userAnswerMap[questions.Question_Id]
                            .toString()
                            .isNotEmpty &&
                        userAnswerMap[questions.Question_Id].toString() != null)
                    ? userAnswerMap[questions.Question_Id].toString()
                    : questions.Remarks.isNotEmpty &&
                            questions.Remarks != 'null'
                        ? questions.Remarks
                        : '')),
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
                        isViewOnly: widget.isViewOnly);
                  }));
                } else {
                  openFile(questions);
                }
              }
            }
            /*else if (_Status == 'Completed') {
              Utility.showMessages(
                  context, 'CVF Already submitted and not able to update');
            } */
            else if (questions.files.isNotEmpty) {
              if (questions.files.contains('.jpg') ||
                  questions.files.contains('png')) {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return DetailScreen(
                    imageUrl: getImageUrl(questions.files),
                    question: questions,
                    listener: this,
                    isViewOnly:
                        _Status == 'Completed' ? true : widget.isViewOnly,
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
            child: isImage(questions.files) && questions.files.contains('data/user') ? Image.file(File(questions.files)) : questions.files.isNotEmpty
                ? !isImage(questions.files)
                    ?  getIcon(questions.files)
                    : Image.network(getImageUrl(decodeFile(questions.files)),
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
    String weburl = url /*.replaceAll('___', '&')*/;
    weburl = weburl;
    if (weburl.contains('%')) weburl = weburl;
    debugPrint('ImageUrl ' + weburl);
    return weburl;
  }

  showBottomSheet(Allquestion question, String hint) {
    _textEditingController.text = question.userAnswers.isNotEmpty
        ? question.userAnswers
        : question.Remarks.isNotEmpty && question.Remarks != 'null'
            ? question.Remarks
            : '';
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
                      cursorColor: Theme.of(context).primaryColor,
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
                              updateAnswers(question,_textEditingController.text.toString());
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

  _generateDynamicYesNo(Allquestion questions){
    //print('_generate yesno=====================');
    List<Widget> list = [];
    for(int index=0;index<questions.answers.length;index++){
      list.add(Expanded(
        child: CheckboxListTile(
          value: (!userAnswerMap.containsKey(questions.Question_Id) &&
              questions.SelectedAnswer == questions.answers[index].answerId) ||
              (userAnswerMap.containsKey(questions.Question_Id) &&
                  userAnswerMap[questions.Question_Id] == questions.answers[index].answerId)
              ? true
              : false,
          title:  Text(
            questions.answers[index].answerName,
            style: TextStyle(fontSize: 12),
          ),
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (checked) {
            if (widget.isViewOnly) {
              Utility.showMessages(context, 'Unable to Edit ${widget.isViewOnly}');
            } else if (_Status == 'Completed') {
              Utility.showMessages(
                  context, 'CVF Already submitted and not able to update');
            } else {
              //ischeck[getCheckboxIndex(player.question)] = false;
              questions.SelectedAnswer = questions.answers[index].answerId;
              setState(() {
                updateAnswers(questions, questions.answers[index].answerId);
              });
            }
          },
        ),
      ));
    }
    list.add(getRemark(questions));
    return list;
  }

  updateRemark(Allquestion questions,String remark) async{

    for (int index = 0; index < mQuestionMaster.length; index++) {
      for (int jIndex = 0;jIndex < mQuestionMaster[index].allquestion.length;jIndex++) {
        if (mQuestionMaster[index].allquestion[jIndex].Question_Id ==questions.Question_Id) {
          mQuestionMaster[index].allquestion[jIndex].Remarks = remark;
          break;
        }
      }
    }
    questionResponse!.responseData.clear();
    questionResponse!.responseData.addAll(mQuestionMaster);
    //print(questionResponse!.toJson());
    saveCvfQuestionsPref(widget.mCategoryId, questionResponse!.toJson());
    DBHelper dbHelper = DBHelper();
    await dbHelper.updateCVFQuestions(widget.PJPCVF_Id.toString(), widget.mCategory,json.encode(questionResponse!.toJson()),0);
  }

  showRemarkDialog(Allquestion questions){
    if (widget.isViewOnly) {
    } else if (widget.cvfView.Status == 'Completed') {
      Utility.showMessages(context, 'CVF Already submitted and not able to update');
    }else {
      TextEditingController _controlelr = TextEditingController();
      _controlelr.text = questions.Remarks;
      showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) =>
              Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery
                        .of(context)
                        .viewInsets
                        .bottom),
                child: Container(
                  margin: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(onPressed: () {
                            updateRemark(questions, _controlelr.text
                                .toString());
                            //questions.Remarks=_controlelr.text.toString();
                            Navigator.of(context).pop();
                          }, child: Text('Submit'))
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text('Enter Remark',
                            style: LightColors.subTextStyle),
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      TextField(
                        controller: _controlelr,
                        maxLines: 3,
                        maxLength: 100,
                        decoration: InputDecoration(
                            hintText: 'Remark'
                        ),
                        autofocus: true,
                      ),
                    ],
                  ),
                ),
              ));
    }
  }
  var _dateController = TextEditingController();
  Widget datePicker(BuildContext context,String Question_Id,String label,String text,String start) {
    return Container(
      margin: EdgeInsets.all(5),
      height: 35,
      child: InkWell(
        onTap: (){
          if (widget.isViewOnly) {
          } else if (widget.cvfView.Status == 'Completed') {
            Utility.showMessages(context, 'CVF Already submitted and not able to update');
          }else {
            DateTime startDate = label == 'Start' ? DateTime(DateTime
                .now()
                .year, DateTime
                .now()
                .month - 1, DateTime
                .now()
                .day) : Utility.parseDateTime(start);
            DateTime endDate = DateTime(DateTime
                .now()
                .year, DateTime
                .now()
                .month + 1, DateTime
                .now()
                .day);
            _showDatePicker(
                context, Question_Id, label, text, startDate, endDate);
          }
        },
        child: Row(
          children: [
            Icon(Icons.date_range,size: 14,),
            SizedBox(width: 10,),
            Text(text.isEmpty || text=='NA' ? 'Timeline ${label} Date' : Utility.parseSimpleDate(text),style: TextStyle(fontSize: text.isEmpty ? 10 :12, color: text.isEmpty ? Colors.grey : Colors.black87),),
          ],
        ),
      ),
    );
  }

  updateDate(String questionId,String label,String date) async{
    for (int index = 0; index < mQuestionMaster.length; index++) {
      for (int jIndex = 0; jIndex <
          mQuestionMaster[index].allquestion.length; jIndex++) {
          if(mQuestionMaster[index].allquestion[jIndex].Question_Id==questionId){
            if(label=='Start') {
              mQuestionMaster[index].allquestion[jIndex].startDate = date;
              if(mQuestionMaster[index].allquestion[jIndex].endDate.isNotEmpty) {
                DateTime startDate = Utility.parseDateTime(date);
                DateTime endDate = Utility.parseDateTime(mQuestionMaster[index].allquestion[jIndex].endDate);
                if(startDate.isAfter(endDate)){
                  mQuestionMaster[index].allquestion[jIndex].endDate ='';
                }
              }
            }else {
              mQuestionMaster[index].allquestion[jIndex].endDate = date;
            }
          }
      }
    }
    //print(questionResponse);
    questionResponse!.responseData.clear();
    questionResponse!.responseData.addAll(mQuestionMaster);
    saveCvfQuestionsPref(widget.mCategoryId, questionResponse!.toJson());
    //print('save -- ${questionResponse!.toJson()}');
  }

  _showDatePicker(BuildContext context,String questionId,String label,String text,DateTime start,DateTime lastDate) async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: start.isAfter(DateTime.now()) ? start : DateTime.now(),
        firstDate: start /*DateTime(DateTime.now().year - 1, 5)*/,
        //DateTime.now() - not to allow to choose before today.
        lastDate: lastDate /*DateTime(DateTime.now().year + 1, 9)*/);

    if (pickedDate != null) {
      setState(() {
        updateDate(questionId,label,Utility.getDate(pickedDate));
      });
    } else {}
  }

  _getYesNo(Allquestion question) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            Expanded(
              flex: 4,
              child: Column(
                children: _generateDynamicYesNo(question),
              ),
            ),
            question.IsProgressive=='1' ? Container(color: Colors.lightBlue, child: Text('Date'),) : Container()
          ],
        )
          ,
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
    //debugPrint('counter is ${counter}');
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

        if(mQuestionMaster[index].allquestion[jIndex].IsProgressive=='1' && mQuestionMaster[index].allquestion[jIndex].SelectedAnswer.trim()!='1' &&  (mQuestionMaster[index].allquestion[jIndex].Remarks.isEmpty || mQuestionMaster[index].allquestion[jIndex].startDate=='NA' || mQuestionMaster[index].allquestion[jIndex].endDate=='NA')){
          //print('${mQuestionMaster[index].allquestion[jIndex].Question_Id} ${mQuestionMaster[index].allquestion[jIndex].SelectedAnswer} ${mQuestionMaster[index].allquestion[jIndex].Remarks} ${mQuestionMaster[index].allquestion[jIndex].startDate} ${mQuestionMaster[index].allquestion[jIndex].endDate}');
          pendingQuestion = 'Please submit the below observation \n\n - ' +
              mQuestionMaster[index].allquestion[jIndex].categoryName +
              ',  Ques No : ' +
              mQuestionMaster[index].allquestion[jIndex].question;
          //debugPrint('isComplete ${pendingQuestion}');
          token = ',';
          inCompleteCounts = inCompleteCounts + 1;
          isCompleted = false;
          break;
          //break;
        }
        
        if (mQuestionMaster[index].allquestion[jIndex].isCompulsory == '1' && (userAnswer.isEmpty || userAnswer == 'null')) {
          inCompleteQuestions = 'Please complete all Required answers, Questions in Category ${mQuestionMaster[index].allquestion[jIndex].categoryName} is pending';

          if (pendingQuestion.isEmpty) {
            pendingQuestion = 'Please submit the below observation \n\n - ' +
                mQuestionMaster[index].allquestion[jIndex].categoryName;
          } else {
            pendingQuestion = pendingQuestion +
                ' \n - ' +
                mQuestionMaster[index].allquestion[jIndex].categoryName;
          }
          //debugPrint(pendingQuestion);
          token = ',';
          inCompleteCounts = inCompleteCounts + 1;
          isCompleted = false;
          break;
        } /*else {
          debugPrint(mQuestionMaster[index].allquestion[jIndex].Question_Id +
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
  }

  void onItemChanged(bool? checked) {
    //ischeck[getCheckboxIndex(player.question)] = false;
    //player.userAnswers = '1';
    setState() {
      //debugPrint('data updated');
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
    debugPrint('image action ${action}');
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
      File file = File(decodeUrl(question.files));
      var filePath = file.path.split('?');
      //debugPrint('FilePath : ${filePath[0]}');
      var fileExt = filePath[0].split('/');
      String title = fileExt[fileExt.length - 1].toString();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MyPdfApp(
            worksheetUrl: question.files,
            title: title,
            filename: title,
            module: '',
          ),
        ),
      );
    } else {
      File file = File(decodeUrl(question.files));
      var filePath = file.path.split('?');
      //debugPrint('FilePath : ${filePath[0]}');
      var fileExt = filePath[0].split('/');
      String fileName = fileExt[fileExt.length - 1].toString();
      debugPrint('fileExt : ${fileName}');

      (await Utility.isFileExists(fileName))
          ? Utility.shareFile(fileName)
          : setState(() {
              isLoading = true;
            });
      Utility.downloadFile(question.files, fileName).then((value) {
        isLoading = false;
        setState(() {});
      });
    }
  }

  decodeUrl(String url) {
    url = Uri.decodeFull(url);
    if (url.contains('%2F')) {
      url = Uri.decodeFull(url);
    }
    if (url.contains('%2F')) {
      url = Uri.decodeFull(url);
    }
    debugPrint('decoe file ${url}');
    return url;
  }

  launchMyUrl(String weburl) async {
    final Uri url = Uri.parse(weburl);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $weburl');
    }
  }

  void pickImage(Allquestion player, ImageSource source) async {
    try {
      final XFile? pickedFileList = await _picker.pickImage(
          source: source, maxHeight: 800, imageQuality: 100);
      debugPrint('File upload gallery');
      setState(() async {
        _imageFileList = pickedFileList;
        updateImage(player, player.files);
        String name = widget.employeeId.toString() +'_c' +widget.PJPCVF_Id.toString() +'_q' +player.Question_Id;
        if (await Utility.isInternet())
          FirebaseStorageUtil().uploadFile(player, _imageFileList!.path, name, this);
        else {
          updateImage(player, _imageFileList!.path);
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void pickFile(Allquestion player) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        File file = File(result.files.single.path!);
        var fileExt = file.path.split('/');
        debugPrint('File path ${fileExt[fileExt.length - 1]}');
        setState(() async {
          updateImage(player, player.files);
          if (await Utility.isInternet()){
            FirebaseStorageUtil().uploadAnyFile(player, file!.path, fileExt[fileExt.length - 1], this);
          }else{
            debugPrint(file!.path);
            updateImage(player, file!.path);
          }
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  updateImage(Allquestion questions, String path) {
    for (int index = 0; index < mQuestionMaster.length; index++) {
      for (int jIndex = 0;
          jIndex < mQuestionMaster[index].allquestion.length;
          jIndex++) {
        if (mQuestionMaster[index].allquestion[jIndex].Question_Id == questions.Question_Id) {
          mQuestionMaster[index].allquestion[jIndex].files = path;
          updateImageOffline(questions, path);
        }
      }
    }
    setState(() {

    });
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
    debugPrint(value.toString());
  }

  @override
  void onUploadSuccess(value) {
    if(!isOffline)
      Navigator.of(context).pop();
    if (value is Allquestion) {
      Allquestion question = value;
      updateImage(question, question.files);
      //if(isOffline){
        //saveAnswers('');
      //}
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
      Utility.showMessageSingleButton(context, 'Thank you for submitting the CVF', this);
    }
  }

  @override
  void onClick(int action, value) {
    //debugPrint('onclick called ${action}');
    if (action == ACTION_ADD_NEW_IMAGE) {
      showImageOption(value);
    } else if (action == ACTION_DELETE_IMAGE) {
    } else if (action == Utility.ACTION_OK) {
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
    debugPrint(imageUrl);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Intranet',
          style:
              TextStyle(fontSize: 17, color: Colors.white, letterSpacing: 0.53),
        ),
        actions: !isViewOnly
            ? [
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
              ]
            : null,
      ),
      body: GestureDetector(
        child: PinchZoom(
          child:  imageUrl.contains('data/user') ? Image.file(File(imageUrl)) : Image.network(imageUrl),
          //resetDuration: const Duration(milliseconds: 100),
          maxScale: 2.5,
          onZoomStart: () {
            debugPrint('Start zooming');
          },
          onZoomEnd: () {
            debugPrint('Stop zooming');
          },
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
