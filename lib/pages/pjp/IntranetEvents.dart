import 'package:flutter/material.dart';
import 'package:intranet/pages/helper/DatabaseHelper.dart';
import 'package:intranet/pages/helper/utils.dart';
import 'package:intranet/pages/utils/theme/colors/light_colors.dart';

import '../helper/DBConstant.dart';
import '../helper/LocalConstant.dart';
import 'cvf/cvf_category.dart';
import 'models/PjpModel.dart';

class IntranetEventContainer extends StatelessWidget {
  PJPModel event;

  IntranetEventContainer({
    required this.event,
  });

  late List<PJPModel> pjpList = [];

  addDummeyPJPData() async {
    DBHelper helper = DBHelper();
    List<PJPModel> pjpListModels = await helper.getPjpList();
    pjpList.clear();
    if (pjpListModels != null) {
      pjpList.addAll(pjpListModels);
    }
  }

  Widget getEvent(BuildContext context, double width) {
    print(event.toString());
    if (event is PJPModel) {
      print('in event');
      PJPModel mEvent = event;
      return generatePJPRow(context,mEvent,width);
    } else {
      print('in else ');
      return Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(vertical: 15.0),
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
                color: LightColors.kLavender,
                borderRadius: BorderRadius.circular(30.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Employee Training',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    'Training Scheduled at Mumbai Center ',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.black54,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    textAlign: TextAlign.right,
                    'Today',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.black54,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Align(
              alignment: Alignment.topRight,
              child: Image.asset('assets/icons/training.png'),
            ),
          ),
        ],
      );
    }
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
                  child: Container(
                    height: 30,
                    padding: const EdgeInsets.all(5),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: LightColors.kDarkOrange, // Set border width
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: GestureDetector(
                      onTap: (){
                        updateCVFAction(context,model);
                      },
                      child: Text(
                        !model.isCheckIn ? 'Check In' : model.isCVFCompleted ? 'Check Out' : 'CVF',
                        style: TextStyle(color: Colors.black,fontSize: 11.0),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      )
    );
  }

  void updateCVFAction(BuildContext context,PJPModel model) {
    Utility.showMessage(context,'action captured');

    if(!model.isCheckIn){
      DBHelper dbHelper = DBHelper();
      Map<String, Object> data = {
        DBConstant.IS_CHECK_IN  : 1,
      };
      List<int> whereArugs = [model.pjpId,0];
      //dbHelper.updateData(LocalConstant.TABLE_PJP_INFO, data,DBConstant.ID,whereArugs);
      dbHelper.updateCheckIn(LocalConstant.TABLE_PJP_INFO, 1, model.pjpId);
      event.isCheckIn = true;

    }else{
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CVfCategotyScreen(mPjpModel: model,header: generatePJPRow(context, model, MediaQuery.of(context).size.width),)),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    addDummeyPJPData();
    double width = MediaQuery.of(context).size.width;
    return getEvent(context, width);
  }
}
