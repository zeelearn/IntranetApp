import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Intranet/api/request/cvf/category_request.dart';
import 'package:Intranet/pages/pjp/models/PjpModel.dart';
import 'package:Intranet/pages/utils/widgets/back_button.dart';
import 'package:square_percent_indicater/square_percent_indicater.dart';

import '../../../api/APIService.dart';
import '../../../api/response/cvf/category_response.dart';
import '../../helper/DBConstant.dart';
import '../../helper/DatabaseHelper.dart';
import '../../helper/LocalConstant.dart';
import '../../helper/constants.dart';
import '../../helper/utils.dart';
import '../../userinfo/employee_list.dart';
import '../../utils/theme/colors/light_colors.dart';

class CVfCategotyScreen extends StatefulWidget {
  PJPModel mPjpModel;
  Widget header;
  CVfCategotyScreen({ Key? key,required this.mPjpModel,required this.header }) : super(key: key);

  @override
  State<CVfCategotyScreen> createState() => _CategotyScreenState();
}

class _CategotyScreenState extends State<CVfCategotyScreen> {

  late List<CategotyInfo> mCategoryList=[];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCategoryList();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.light;
    return Scaffold(
      appBar: getAppbar(),
      body: Container(
        margin: EdgeInsets.symmetric(vertical: 1.0),
        padding: EdgeInsets.only(left: 5,right:5),
        child: Column(
          children: [

           /* widget.header,*/
            generatePJPRow(context, widget.mPjpModel, size.width),
            categoryListWidget(),
          ],
        ),
      ),
    );
  }

  AppBar getAppbar(){
    return AppBar(
      backgroundColor: kPrimaryLightColor,
      centerTitle: true,
      title:  Text(
        'Title',
        style:
        TextStyle(fontSize: 17, color: Colors.white, letterSpacing: 0.53),
      ),
      /*shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),*/
      /*leading: InkWell(
        onTap: () {
          _scaffoldKey.currentState?.openDrawer();
        },
        child: const Icon(
          Icons.subject,
          color: Colors.white,
        ),
      ),*/
      actions: [
        InkWell(
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => EmployeeListScreen(displayName: '')));
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.search,
              size: 20,
            ),
          ),
        ),
        InkWell(
          onTap: () {
            /*Navigator.push(
                context, MaterialPageRoute(builder: (context) => UserNotification()));*/
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.notifications,
              size: 20,
            ),
          ),
        ),
      ],
      /*bottom: PreferredSize(
          child: getAppBottomView(),
          preferredSize: Size.fromHeight(80.0)),*/
    );
  }


  generatePJPRow(BuildContext context,PJPModel model,double width){
    return Padding(padding: EdgeInsets.all(1),
        child: Container(
          decoration: BoxDecoration(color: Colors.grey,),
          padding: EdgeInsets.all(1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  height: 80,
                  width: MediaQuery.of(context).size.width * 0.10,
                  decoration: BoxDecoration(color: LightColors.kLightGray1,),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        Utility.shortDate(model.fromDate),
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        Utility.shortDate(model.toDate),
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  height: 80,
                  width: MediaQuery.of(context).size.width * 0.30,
                  decoration: BoxDecoration(color: LightColors.kLightGray),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Utility.shortDate(model.fromDate),
                          style: TextStyle(color: Colors.black),
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 5, bottom: 5),
                          child: Text(
                            Utility.shortDate(model.toDate),
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  height: 80,
                  width: MediaQuery.of(context).size.width * 0.12,
                  decoration: BoxDecoration(color: LightColors.kLightGray),
                  child: Center(
                    child: getProgress(50),
                  ),
                ),
              ),
            ],
          ),
        )
    );
  }

  getProgress(int progress){
    return SquarePercentIndicator(
      width: 40,
      height: 40,
      startAngle: StartAngle.bottomRight,
      reverse: true,
      borderRadius: 12,
      shadowWidth: 1.5,
      progressWidth: 5,
      shadowColor: LightColors.kAbsent_BUTTON,
      progressColor: LightColors.kBlue,
      progress: progress/100,
      child: Center(
          child: Text(
            "${progress} %",
            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
          )),
    );
  }

  categoryListWidget() {
    double width = MediaQuery.of(context).size.width;
    if (mCategoryList == null || mCategoryList.length <= 0) {
      //debugPrint('data not found');
      return Utility.emptyDataSet(context,"CVF Categories are not available");
    } else {
      return Flexible(
          child: ListView.builder(
            itemCount: mCategoryList.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(color: Colors.grey,),
                child: Container(
                  margin: EdgeInsets.only(top: 1),
                  /*decoration: BoxDecoration(color: LightColors.kLightGray,borderRadius: BorderRadius.all(Radius.circular(10.0))),*/
                  decoration: BoxDecoration(color: LightColors.kLightGray,),
                  padding: EdgeInsets.all(1),
                  child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                      leading: Container(
                        padding: EdgeInsets.only(right: 12.0),
                        decoration: new BoxDecoration(
                            color: LightColors.kLightBlue,
                            border: new Border(
                                right: new BorderSide(width: 1.0, color: Colors.grey))),
                        child: getProgress(30),
                      ),
                      title: Text(
                        mCategoryList[index].categoryName,
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

                      /*subtitle: Row(
                        children: <Widget>[
                          Icon(Icons.linear_scale, color: Colors.yellowAccent),
                          Text(" Intermediate", style: TextStyle(color: Colors.black))
                        ],
                      ),*/
                      trailing:
                      Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0)),
                ),
              ) ;
            },
          ));
    }
  }

  _headerWidget(double width){
    return Padding(padding: EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              height: 80,
              width: MediaQuery.of(context).size.width * 0.10,
              decoration: BoxDecoration(color: LightColors.kPalePink,),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    Utility.shortDate(widget.mPjpModel.fromDate),
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    Utility.shortDate(widget.mPjpModel.toDate),
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: MyBackButton(),
          ),
          Expanded(
            flex: 1,
            child: Container(
              height: 80,
              width: MediaQuery.of(context).size.width * 0.10,
              decoration: BoxDecoration(color: LightColors.kPalePink,),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    Utility.shortDate(widget.mPjpModel.fromDate),
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    Utility.shortDate(widget.mPjpModel.toDate),
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),);
  }

  getCategoryList() async{
    List<CategotyInfo> list = await getCategoryFromDb();
    if(list==null || list.length==0){
      fetchCategory();
    }else{
      mCategoryList.clear();
      mCategoryList.addAll(list);
    }
  }

  insertCategory() async{
    DBHelper dbHelper = DBHelper();
    for(int index=0;index<mCategoryList.length;index++) {
      Map<String, Object> data = {
        DBConstant.CATEGORY_ID: mCategoryList[index].categoryId,
        DBConstant.CATEGORY_NAME:  mCategoryList[index].categoryName
      };
      dbHelper.insert(LocalConstant.TABLE_CVF_CATEGORY, data);
    }
  }

  Future<List<CategotyInfo>> getCategoryFromDb() async {
    List<CategotyInfo> categoryList = [];

    List<Map<String, dynamic>> list = await  DBHelper().getData(LocalConstant.TABLE_CVF_CATEGORY);
    if(list !=null){
      debugPrint('----${list.length}');
      for(int index=0;index<list.length;index++) {
        Map<String, dynamic> map = list[index];
        categoryList.add(CategotyInfo(categoryId: map[DBConstant.CATEGORY_ID], categoryName: map[DBConstant.CATEGORY_NAME]));
      }
    }
    return categoryList;
  }

  fetchCategory() {
    Utility.showLoaderDialog(context);
    mCategoryList.clear();
    CVFCategoryRequest request = CVFCategoryRequest(Category_Id: "1", Business_id: 0);
    APIService apiService = APIService();
    apiService.getCVFCategoties(request).then((value) {
      debugPrint(value.toString());
      if (value != null) {
        if (value == null || value.responseData == null) {
          Utility.showMessage(context, 'data not found');
        } else if (value is CVFCategoryResponse) {
          CVFCategoryResponse response = value;
          if(response!=null){
            mCategoryList.addAll(response.responseData);
          }
          setState(() {});
          debugPrint('summery list ${response.responseData.length}');
        } else {
          Utility.showMessage(context, 'data not found');
        }
      }
      Navigator.of(context).pop();
      setState(() {});
    });
  }



}