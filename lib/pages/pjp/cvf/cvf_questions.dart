import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intranet/api/request/cvf/questions_request.dart';
import 'package:intranet/api/request/cvf/save_cvfquestions_request.dart';
import 'package:intranet/pages/helper/DatabaseHelper.dart';
import 'package:intranet/pages/helper/LocalConstant.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../api/APIService.dart';
import '../../../api/response/cvf/QuestionResponse.dart';
import '../../../api/response/cvf/cvfanswers_response.dart';
import '../../../api/response/pjp/pjplistresponse.dart';
import '../../helper/DBConstant.dart';
import '../../helper/utils.dart';
import '../../utils/theme/colors/light_colors.dart';

class QuestionListScreen extends StatefulWidget {
  GetDetailedPJP cvfView;
  String mCategory;
  String mCategoryId;
  int PJPCVF_Id=0;
  int employeeId;

  QuestionListScreen({Key? key,required this.PJPCVF_Id,required this.employeeId, required this.cvfView, required this.mCategory,required this.mCategoryId})
      : super(key: key);

  @override
  State<QuestionListScreen> createState() => _QuestionListScreenState();
}

class _QuestionListScreenState extends State<QuestionListScreen> {
  List<QuestionMaster> mQuestionMaster = [];
  bool isLoading = true;
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _imageFileList;
  Map<String,String> userAnswerMap=Map();

  TextEditingController _textEditingController= TextEditingController();

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

  getUsersAnswers() async{
    DBHelper helper = DBHelper();
    userAnswerMap = await helper.getUsersAnswerList(widget.PJPCVF_Id);

  }

  List<bool> ischeck = [];

  getPrefQuestions(String categoryid)async{
    final prefs = await SharedPreferences.getInstance();
    print('in pref questions');
    try {
      var cvfQuestions = prefs.getString(widget.PJPCVF_Id.toString()+categoryid+LocalConstant.KEY_CVF_QUESTIONS);
      print('in pref questions :   ${jsonDecode(cvfQuestions.toString())}');

      if(cvfQuestions is QuestionResponse){
        QuestionResponse response = cvfQuestions as QuestionResponse;
        print('data found');
      }else if (cvfQuestions
          .toString()
          .isEmpty) {
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
          isLoading=false;
          setState(() {});
        } catch (e) {

          loadData();
        }
      }
    }catch(e){

      loadData();
    }
  }

  saveCvfQuestionsPref(String categoryid,String data) async{
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(widget.PJPCVF_Id.toString()+categoryid+LocalConstant.KEY_CVF_QUESTIONS,data);

  }

  loadData() {
    isLoading = true;
    mQuestionMaster.clear();
    DateTime time = DateTime.now();
    QuestionsRequest request =
        QuestionsRequest(Category_Id: '1', Business_id: '1',PJPCVF_Id: widget.cvfView.PJPCVF_Id);
    APIService apiService = APIService();
    apiService.getCVFQuestions(request).then((value) {
      isLoading = false;
      if (value != null) {
        if (value == null || value.responseData == null) {
          Utility.showMessage(context, 'data not found');
        } else if (value is QuestionResponse) {
          QuestionResponse response = value;

          if (response != null && response.responseData != null) {
            saveCvfQuestionsPref(widget.mCategoryId, json.encode(response.toJson()));
            mQuestionMaster.addAll(response.responseData);
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
      HashMap<String,String> map = HashMap();
      for(int index=0;index<mQuestionMaster.length;index++) {
        for(int jIndex=0;jIndex<mQuestionMaster[index].allquestion.length;jIndex++) {
          if(!map.containsKey(mQuestionMaster[index].categoryId)){
            dbHelper.deleteCategory(int.parse(mQuestionMaster[index].categoryId));
            map.putIfAbsent(mQuestionMaster[index].categoryId, () => mQuestionMaster[index].categoryId);
          }

          Map<String, Object> data = {
            DBConstant.QUESTION_ID: mQuestionMaster[index].allquestion[jIndex]
                .Question_Id,
            DBConstant.QUESTION: mQuestionMaster[index].allquestion[jIndex]
                .question,
            DBConstant.CATEGORY_ID: mQuestionMaster[index].categoryId,
            DBConstant.CATEGORY_NAME: mQuestionMaster[index].categoryName,
            DBConstant.IS_COMPULSARY: mQuestionMaster[index].allquestion[jIndex].isCompulsory,
          };
          dbHelper.insert(LocalConstant.TABLE_CVF_QUESTIONS, data);
          for(int kIndex=0;kIndex<mQuestionMaster[index].allquestion[jIndex].answers.length;kIndex++) {
            Map<String, Object> data = {
              DBConstant.QUESTION_ID: mQuestionMaster[index].allquestion[jIndex].Question_Id,
              DBConstant.QUESTION: mQuestionMaster[index].allquestion[jIndex].question,
              DBConstant.ANSWER_NAME: mQuestionMaster[index].allquestion[jIndex].answers[kIndex].answerName,
              DBConstant.ANSWER_TYPE:mQuestionMaster[index].allquestion[jIndex].answers[kIndex].answerType,
            };
            dbHelper.insert(LocalConstant.TABLE_CVF_ANSWER_MASTER, data);
          }
        }
      }

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
    //print(request.toJson());
    APIService apiService = APIService();
    apiService.saveCVFAnswers(request).then((value) {
      //print(value.toString());
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
              margin: const EdgeInsets.only(top: 100, left: 0, right: 0, bottom: 0),
              child: SingleChildScrollView(
                child: getWidget(),
              ),
            )
          ],
        ));
  }

  getWidget() {
    if(isLoading){
      return Center(child: Image.asset(
        "assets/images/loading.gif",
      ),);
    }else {
      /*return getCVFQuestions(); */
      return Column(
        children:
        mQuestionMaster.map<Widget>((club) => showQuestions(club)).toList(),
      );
    }
  }

  getCVFQuestions() {
    if(isLoading){
      return Center(child: Image.asset(
        "assets/images/loading.gif",
      ),);
    }else  if (mQuestionMaster.isEmpty) {
      //print('List not avaliable');
      return Utility.emptyDataSet(context);
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
                            return generateQuestionView(mQuestionMaster[index].allquestion[jindex]);
                          }),
                    ],
                  ),
                ),
              );
            },
          ));
    }
  }

  generateQuestionView(Allquestion question){
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

  getAnswerView(Allquestion question){

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
                          '${cvfView.franchiseeName}',
                          style: TextStyle(
                            fontFamily: 'Lexend Deca',
                            color: Color(0xFF090F13),
                            fontSize: 16,
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
                ],
              ),
            )),
      ],
    );
  }

  getTextRounded(GetDetailedPJP cvfView, String name) {
    return GestureDetector(
      onTap: () {
        /*if(cvfView.Status =='FILL CVF'){
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => QuestionListScreen(
                  cvfView: cvfView,
                  PJPCVF_Id: int.parse(cvfView.PJPCVF_Id),
                  employeeId: widget.employeeId,
                  mCategory: 'All',
                )),
          );
        }else {
          IntranetServiceHandler.updateCVFStatus(
              employeeId, cvfView.PJPCVF_Id, Utility.getDateTime(),
              getNextStatus(cvfView.Status), this);
          Utility.showMessage(context, '${cvfView.Status} clicked');
        }*/
      },
      child: Container(
        margin: EdgeInsets.only(right: 2),
        decoration: BoxDecoration(
            shape: BoxShape.rectangle, // BoxShape.circle or BoxShape.retangle
            /*color: Colors.red,*/
            boxShadow: [BoxShadow(
              color: Colors.grey,
              blurRadius: 10.0,
            ),]
        ),
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
                  fontSize: 12
              )),
        ),
      ),
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
    if(userAnswerMap.containsKey(questions.Question_Id.toString())){
      userAnswerMap.update(questions.Question_Id.toString(), (value) => answers);
    }else{
      userAnswerMap.putIfAbsent(questions.Question_Id.toString(), () => answers);
    }
    for(int index=0;index<mQuestionMaster.length;index++){
      for(int jIndex=0;jIndex<mQuestionMaster[index].allquestion.length;jIndex++){
          if(mQuestionMaster[index].allquestion[jIndex].question == questions.question){
            mQuestionMaster[index].allquestion[jIndex].userAnswers = answers;
            DBHelper helper = DBHelper();
            //print('update ansert');
            helper.updateUserAnswer(widget.PJPCVF_Id,
                widget.PJPCVF_Id,
                mQuestionMaster[index].allquestion[jIndex].Question_Id,
                mQuestionMaster[index].allquestion[jIndex].categoryName,
                answers);
            break;
          }
      }
    }
  }

  Widget showPlayers(Allquestion player) {
    return ListTile(
      title: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(children: [
            const Divider(
              height: 2,
              color: Colors.blue,
            ),
            const SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Text(player.question,
                  style: const TextStyle(color: Colors.black, fontSize: 14)),
            ),
            //player.answers!=null && player.answers.length>0 && player.answers[0].answerType=='YesNo' ?
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  flex: 1,
                  child: CheckboxListTile(
                    value: player.SelectedAnswer == 'Yes' || (userAnswerMap.containsKey(player.Question_Id) && userAnswerMap[player.Question_Id]=='Yes' ) ? true : false,
                    title: const Text(
                      'Yes',
                      style: TextStyle(fontSize: 12),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (checked) {
                      //ischeck[getCheckboxIndex(player.question)] = false;
                      player.SelectedAnswer = 'Yes';
                      setState(() {
                        updateAnswers(player, 'Yes');
                      });
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: CheckboxListTile(
                    value: player.SelectedAnswer == 'No' || (userAnswerMap.containsKey(player.Question_Id) && userAnswerMap[player.Question_Id]=='No' ) ? true : false,
                    title: const Text(
                      'No',
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.left,
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (checked) {
                      player.SelectedAnswer = 'No';
                      updateAnswers(player, 'No');
                      setState(() {});
                    },
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    pickImage(player);
                  },
                  child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: player.files.isEmpty ? Icon(
                          Icons.photo,
                          size: 20,
                        ) : Image.file(
                            File(player.files),
                        ),
                      ),
                )
              ],
            ),
          ])),
    );
  }

  _getYesNo(Allquestion question){
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
    List<Widget> _rowWidget = []; // this will hold Rows according to available lines
    for(int index=0;index<question.answers.length;index++){
      bool answers = (question.userAnswers == question.answers[index].answerName || question.SelectedAnswer == question.answers[index].answerName) ? true : false;
      _rowWidget.add(_generateYesNoAnswers(question,question.answers[index].answerName,answers));
    }
    return  Row(children: _rowWidget);
  }

  _generateYesNoAnswers(Allquestion question,String Answer_Name, bool value){
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
      final List<XFile>? pickedFileList = await _picker.pickMultiImage(
        maxWidth: 50,
        maxHeight: 50,
        imageQuality: 72,
      );
      setState(() {
        _imageFileList = pickedFileList;
        player.files = pickedFileList![0].path;
        updateImage(player, player.files);
      });
    } catch (e) {
      /*setState(() {
        _pickImageError = e;
      });*/
    }
  }
  updateImage(Allquestion questions,String path){
    for(int index=0;index<mQuestionMaster.length;index++){
      for(int jIndex=0;jIndex<mQuestionMaster[index].allquestion.length;jIndex++){
        if(mQuestionMaster[index].allquestion[jIndex].question == questions.question){
          mQuestionMaster[index].allquestion[jIndex].files = path;

        }
      }
    }
  }
}
