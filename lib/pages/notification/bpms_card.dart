import 'package:Intranet/pages/bpms/auth/ui/ChatPage.dart';
import 'package:Intranet/pages/theme/extention.dart';
import 'package:Intranet/pages/utils/theme/colors/light_colors.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

import '../model/bpms_notification_model.dart';

class BPMSNotification extends StatefulWidget {
  BPMSNotification({super.key,required this.bpmsList,required this.title,required this.time});
  BpmsNotificationModelList bpmsList;
  String title;
  String time;

  @override
  State<BPMSNotification> createState() => _BPMSNotificationState();
}

class _BPMSNotificationState extends State<BPMSNotification> {
  bool _customTileExpanded = false;

  _generateList(BuildContext context) {
    List<Widget> list=[];
    for(int index=0;index<widget.bpmsList.data!.length;index++) {
      list.add(_categoryCard(context,widget.bpmsList.data![index]));
    }
    return list;
  }

  Widget _categoryCard(BuildContext context,BpmsNotificationModel model) {
    return Padding(padding: EdgeInsets.only(left: 15,right: 15,bottom: 0),
    child: Card(
      elevation: 4,
      shadowColor: LightColors.kRed,
      child: GestureDetector(
        onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatPage(taskModel: model.getModel(),isEdit: true,franchiseeName:model.dName! )),
          );
        },
        child: ListTile(
          title: Text(model.title!,style: LightColors.titleRedTextStyle,),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(model.dName!,style: LightColors.smallTextStyle,),
            Text('Due Date : ${model.due!}',style: LightColors.subtitleRedTextStyle,)
          ],),
          trailing: TextButton(child: Text('View',style: LightColors.titleRedTextStyle,),onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatPage(taskModel: model.getModel(),isEdit: true,franchiseeName:model.dName!)),
            );
          }),
        ),
      ),
    ),
    ) ;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 15,right: 15,bottom: 10),
      child: Card(
        color: Colors.white,
        shadowColor: LightColors.kLightRedMaterial,
        elevation: 4,
        child: Padding(padding: EdgeInsets.only(bottom: 15),child: ExpansionTile(
          collapsedIconColor: Colors.black45,
          iconColor: Colors.black45,

          initiallyExpanded: true,
          title: Text(widget.title,style: LightColors.titleTextStyle,),
          subtitle: Text(widget.time,style:LightColors.smallTextStyle),
          children: _generateList(context),
        ),) ,
      ),
    );
  }
}

class BPMSNotificationCard extends StatelessWidget {

  BPMSNotificationCard({Key? key,required  this.bpmsList,required this.title,required this.time}) : super(key: key);
  BpmsNotificationModelList bpmsList;
  String title;
  String time;

  _generateList(BuildContext context) {
    List<Widget> list=[];
    for(int index=0;index<bpmsList.data!.length;index++) {
      list.add(_categoryCard(context,bpmsList.data![index]));
    }
    return list;
  }

  Widget _categoryCard(BuildContext context,BpmsNotificationModel model) {
    return Card(
      elevation: 4,
      child: GestureDetector(
        onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatPage(taskModel: model.getModel(),isEdit: true,franchiseeName:model.dName!)),
          );
        },
        child: ListTile(
          title: Text(model.title!,style: LightColors.smallTextStyle,),
          subtitle: Text(model.dName!,style: LightColors.smallTextStyle,),
          trailing: TextButton(child: Text('Fill'),onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatPage(taskModel: model.getModel(),isEdit: true,franchiseeName:model.dName!)),
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(color: Colors.white,
        margin: EdgeInsets.only(left: 15,right: 15,bottom: 10),
        child: Card(
          color: Colors.white,
          child: Padding(padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,style: LightColors.titleTextStyle,),
              Column(
                children: _generateList(context),
              ),
              SizedBox(height: 10,),
              Align(
                alignment: Alignment.centerRight,
                child: Text(time,style: LightColors.smallTextStyle,),
              )
            ],
          ),) ,
        )
    );
  }
}

