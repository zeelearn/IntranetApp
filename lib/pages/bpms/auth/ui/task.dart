import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../api/response/bpms/getTaskDetailsResponseModel.dart';
import '../../../../api/response/bpms/project_task.dart';
import '../../../helper/LightColor.dart';
import '../../../helper/utils.dart';
import '../../../utils/theme/colors/light_colors.dart';
import '../../Filters.dart';
import '../data/providers/auth_provider.dart';
import 'ChatPage.dart';

class Tasks extends StatelessWidget {
  List<ProjectTaskModel> taskModelList = [];
  WidgetRef ref;


  List<Filters> _chipsList = [Filters('All', 0, LightColors.kLightBlueMaterial,false),
    Filters('Pending', 1, LightColor.grey,false),
    Filters('Completed', 2, LightColor.grey,false),
    Filters('Completed', 3, LightColor.grey,false)];

  Tasks(this.ref,this.taskModelList);


  @override
  Widget build(BuildContext context) {
    return taskModelList.length==0 ? Utility.emptyDataSet(context,'') :Flexible(
            child: ListView.builder(
              itemCount: taskModelList.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                if(taskModelList[index].statusname=='Pending')
                  return getPendingView(context,taskModelList[index]);
                else
                  return getView(context,taskModelList[index]);
              },
            )
        );
  }

  showChatScreen(BuildContext context, ProjectTaskModel taskModel) async {
    var result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ChatPage(taskModel: taskModel, isEdit: true,);
    }));
    print('showChatScreen ------notifier-----------${result}');
    ref.read(authNotifierProvider.notifier).refreshTask();
    print('showChatScreen ------notifier---END--------');

  }
  Widget getView(BuildContext context, ProjectTaskModel taskModel){
    return GestureDetector(
              onTap: () {
                showChatScreen(context, taskModel);
              },
              child: Container(
                margin: EdgeInsets.only(left: 15,right: 15,top: 15),
                decoration: BoxDecoration(
                    color: taskModel.statusname.toLowerCase().contains('completed') ? Colors.white : taskModel.statusname.toLowerCase().contains('completed') ?  Colors.white : taskModel.statusname.toLowerCase().contains('progress') ? LightColors.kLightYellow : LightColors.kLightGray1,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [BoxShadow(
                        color: Colors.black26.withOpacity(0.05),
                        offset: Offset(0.0,6.0),
                        blurRadius: 10.0,
                        spreadRadius: 0.10
                    )]
                ),
                child: Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                FadeInImage(
                                  width: 24,
                                  placeholder: AssetImage('assets/icons/ic_pending.png'),
                                  image: AssetImage('assets/icons/${taskModel.statusname.toLowerCase().contains('completed') ? 'ic_task_comp' : taskModel.statusname=='In Progress' ? 'ic_task_inprogress' : 'ic_pending'}.png'),
                                  imageErrorBuilder: (context, error, stackTrace) {
                                    return Image.asset('assets/icons/ic_pending.png',fit: BoxFit.fitWidth);
                                  },
                                  fit: BoxFit.cover,
                                ),
                               /* CircleAvatar(
                                  backgroundImage: AssetImage('assets/icons/${taskModel.statusname.toLowerCase()=='completed' ? 'ic_task_comp' : taskModel.statusname=='In Progress' ? 'ic_task_inprogress' : 'ic_pending'}.png') *//*AssetImage(question.author.imageUrl)*//*,
                                  radius: 22,
                                ),*/
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        width: MediaQuery.of(context).size.width * 0.5,
                                        child: Text(
                                          taskModel.title,
                                          style: GoogleFonts.roboto(
                                            fontSize: 16.0,
                                            color: Colors.black87,
                                            height: 1,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 5,),
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.56,
                                        child: Text(
                                          "Last Comment : ${taskModel.latestComment}",
                                          style: GoogleFonts.roboto(
                                            fontSize: 12.0,
                                            color: Colors.black87,
                                            height: 1,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Text(
                                "${taskModel.statusname}",
                              style: GoogleFonts.roboto(
                                background: Paint()
                                  ..color = taskModel.statusname.toLowerCase().contains('completed') ? LightColors.kLightGreenMaterial : taskModel.statusname.toLowerCase().contains('completed') ? LightColors.kGreen : taskModel.statusname.toLowerCase().contains('progress') ? LightColors.kLightYellow2 : LightColors.kLightGray1
                                  ..strokeWidth = 18
                                  ..strokeJoin = StrokeJoin.round
                                  ..strokeCap = StrokeCap.round
                                  ..style = PaintingStyle.stroke,
                                fontSize: 12.0,
                                color: taskModel.statusname.toLowerCase()=='completed' ? Colors.white : taskModel.statusname.toLowerCase().contains('completed') ? Colors.black : Colors.black87,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5),
                      Divider(color: LightColor.lightGrey,),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.calendar_today,
                                color: LightColors.kLightGray1,
                                size: 12,
                              ),
                              SizedBox(width: 4.0),
                              Text(
                                "Start At : ${Utility.parseShortDate(taskModel.startDate)}",
                                style: GoogleFonts.roboto(
                                  fontSize: 12.0,
                                  color: Colors.black87,
                                  height: 1,
                                ),
                              )
                            ],
                          ),
                          taskModel.statusname.toLowerCase().contains('completed') ?
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.calendar_today,
                                color: LightColors.kLightGray1,
                                size: 12,
                              ),
                              SizedBox(width: 4.0),
                              Text(
                                "Completed At : ${Utility.parseShortDate(taskModel.endDate)}",
                                style: GoogleFonts.roboto(
                                  fontSize: 12.0,
                                  color: Colors.black87,
                                  height: 1,
                                ),
                              )
                            ],
                          ) : SizedBox(width: 0,),
                        ],
                      )
                    ],
                  ),
                ),
              ),
    );
  }

  getTaskImage(ProjectTaskModel taskModel){
    return FadeInImage(
      width: 24,
      placeholder: AssetImage('assets/icons/ic_pending.png'),
      image: AssetImage('assets/icons/${taskModel.statusname.toLowerCase()=='completed' ? 'ic_task_comp' : taskModel.statusname=='In Progress' ? 'ic_task_inprogress' : 'ic_pending'}.png'),
      imageErrorBuilder: (context, error, stackTrace) {
        return Image.asset('assets/icons/ic_pending.png',fit: BoxFit.fitWidth);
      },
      fit: BoxFit.cover,
    );
  }
  Widget getPendingView(BuildContext context, ProjectTaskModel taskModel){
    return GestureDetector(
      onTap: () {
        showChatScreen(context, taskModel);
      },
      child: Container(
        margin: EdgeInsets.only(left: 10,right: 10,top: 10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [BoxShadow(
                color: Colors.black26.withOpacity(0.05),
                offset: Offset(0.0,6.0),
                blurRadius: 10.0,
                spreadRadius: 0.10
            )]
        ),
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        getTaskImage(taskModel),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Text(
                                  taskModel.title,
                                  style: GoogleFonts.roboto(
                                    fontSize: 16.0,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    height: 1,
                                  ),
                                ),
                              ),

                            ],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "${taskModel.statusname}",
                      style: GoogleFonts.roboto(
                        background: Paint()
                          ..color = LightColors.kLightGray1
                          ..strokeWidth = 18
                          ..strokeJoin = StrokeJoin.round
                          ..strokeCap = StrokeCap.round
                          ..style = PaintingStyle.stroke,
                        fontSize: 12.0,
                        color: taskModel.statusname.toLowerCase().contains('completed') ? Colors.white : Colors.black87,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
