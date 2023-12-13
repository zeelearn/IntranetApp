import 'package:Intranet/api/request/bpms/deletetask.dart';
import 'package:Intranet/pages/bpms/auth/ui/ChatPage.dart';
import 'package:Intranet/pages/bpms/update_task.dart';
import 'package:Intranet/pages/helper/math_utils.dart';
import 'package:Intranet/pages/iface/onClick.dart';
import 'package:Intranet/pages/utils/theme/colors/light_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../api/APIService.dart';
import '../../api/request/bpms/projects.dart';
import '../../api/response/bpms/bpms_stats.dart';
import '../../api/response/bpms/project_task.dart';
import '../../api/response/bpms/send_cred.dart';
import '../helper/LocalConstant.dart';
import '../helper/constants.dart';
import '../helper/utils.dart';
import '../widget/path_bar.dart';
import 'auth/data/providers/auth_provider.dart';
import 'bpms_projects.dart';
import 'new_task.dart';

class BPMSProjectTask extends ConsumerStatefulWidget {

  ProjectModel project;
  int status;
  BPMSProjectTask({Key? key,required this.project,required this.status}) : super(key: key);

  @override
  _BPMSProjectTask createState() => _BPMSProjectTask();
}

class _BPMSProjectTask extends  ConsumerState<BPMSProjectTask> with WidgetsBindingObserver implements onClickListener{

  bool isDataFound=false;
  bool isAddButton=false;
  final focusNode = FocusNode();

  String displayName='';
  int _currentIndex=0;
  Map<int,ProjectTaskModel> mMap = Map();
  int frichiseeId=0;

  String supportPath="";
  String path = 'HOME';
  List<ProjectTaskModel> paths = [];

  ProjectTaskModel? currentTask;
  void pop(){
    print('pop');
    paths.removeLast();
    supportPath = paths.last.path;
    path =supportPath;
    print(paths.length);
    if(paths.length<=1){
      isAddButton=false;
    }
    print('supportPath ${supportPath}');
    getSortedData();
  }

  void push(ProjectTaskModel data,String supportName){
    //String path  = data.title;
    //print('------ ${data.taskcreateduser} ${frichiseeId}');
    if(data.taskcreateduser ==frichiseeId.toString()){
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChatPage(taskModel: data, isEdit: data.taskcreateduser ==frichiseeId.toString() ? true : false,)));
    }else {
      if (supportPath.isEmpty) {
        supportPath = data.title;
      } else {
        supportPath = "$supportPath/${data.title}";
      }
      path = supportPath;
      //print(path);
      data.path = supportPath;
      paths.add(data);
      if(paths.length>=2){
        isAddButton=true;
      }
      getSortedData();
    }
    //historyList.add(ECampusHistoryModel(index: historyList.length + 1, currentPath: path, previousPath: supportName, content: data.ContentDescription));
    //loadDigitalResource();
  }
    @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    var hive = Hive.box(LocalConstant.KidzeeDB);
    displayName  = '${hive.get(LocalConstant.KEY_FIRST_NAME)} ${hive.get(LocalConstant.KEY_LAST_NAME)} - ${hive.get(LocalConstant.KEY_DESIGNATION)}' ;
    paths.clear();
    paths.add(ProjectTaskModel(projectId: '', title: 'HOME', id: 'id', note: 'note', img: '', priority: '', startDate: '', endDate: '', pStartDate: '', dueDate: '', responsiblePerson: '', status: 0, statusname: '', parentTaskId: '', dependentTaskId: 0, taskcount: '', isImageUpload: 0, done: false, mtaskId: '', taskcreateduser: '', latestComment: '', files: '', manager: '', treeStatus: '', datumClass: '', parantDate: '', parantPlandate: 'parantPlandate', path: 'HOME'));
    loadProjectTask();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('loading on resume');
        loadProjectTask();
    }
  }

  loadProjectTask() async{
    var box = await Utility.openBox();
    if(box.get(LocalConstant.KEY_EMPLOYEE_ID)!=null) {
      String uid = box.get(LocalConstant.KEY_EMPLOYEE_ID) as String;
      frichiseeId = box.get(LocalConstant.KEY_FRANCHISEE_ID) as int;
      await ref.read(authNotifierProvider.notifier).getAllTask(frichiseeId.toString(),widget.project.CRMId);
    }
  }

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();


  refreshTask(int franchiseeId){
    ref.read(authNotifierProvider.notifier).refreshProjectTask(franchiseeId.toString(),widget.project.CRMId);
  }
  List<ProjectTaskModel> mSortedProjectList = [];
  getSortedData(){
    final auth = ref.watch(authNotifierProvider);
    mSortedProjectList.clear();
    isDataFound=false;
    if (auth.projectTask!=null && auth.projectTask!.data[0]!.length>0) {
      for (int index = 0; index < auth.projectTask!.data[0]!.length; index++) {
        if (path == 'HOME') {
          if (auth.projectTask!.data[0]![index].parentTaskId == '0') {
            mSortedProjectList.add(auth.projectTask!.data[0][index]);
            isDataFound=true;
          }
        } else if (paths.length > 0) {
          if (auth.projectTask!.data[0]![index].parentTaskId == paths[paths.length - 1].id) {
            mSortedProjectList.add(auth.projectTask!.data[0][index]);
            isDataFound=true;
          }
        }
        //}
      }
    }else{
      print('getSorting no list');
    }
    setState(() {
      //isLoading=false;
    });
  return mSortedProjectList;
  }



  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    getSortedData();
    return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.project.FranchiseeName== null ? displayName : widget.project.FranchiseeName!,style: LightColors.textHeaderStyle13Selected,),
              Text(widget.project.FranchiseeCode==null ? '' : widget.project.FranchiseeCode!,style: LightColors.textHeaderStyle13Selected,),
            ],
          ),
          actions:  <Widget>[
            !isAddButton ?  SizedBox(height: 0,) :
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'addNewTask',
              onPressed: () async {
                if(paths.length>0) {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>InsertNewTask(taskModel: paths[paths.length - 1],)),
                  );
                  loadProjectTask();
                }
              },
            ), //IconButton
          ],
          //<Widget>[]
          backgroundColor: kPrimaryLightColor,
          elevation: 50.0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Menu Icon',
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BPMSProjects(status: widget.status,)));
            },
          ),
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        body: PopScope(
          canPop: false,
          onPopInvoked: (value){
            if(paths.length>1){
              print('if pop ${paths.length}');
              pop();
              print('if pop ${paths.length}');
            }else{
              print('else print ${paths.length}');
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BPMSProjects(status: widget.status)));
            }
          },
          child: SafeArea(
            child: RefreshIndicator(
              key: _refreshIndicatorKey,
              color: Colors.white,
              backgroundColor: Colors.blue,
              strokeWidth: 4.0,
              onRefresh: () async {
                // Replace this delay with the code to be executed during refresh
                // and return a Future when code finishs execution.
                //IntranetServiceHandler.loadPjpSummery(employeeId, 0,businessId, this);
                refreshTask(frichiseeId);
                return Future<void>.delayed(const Duration(seconds: 3));
              },
              // Pull from top to show refresh indicator.
              child: auth.projectTask ==null || auth.loading ? Utility.showLoader() :  Column(
                children: [
                  Container(
                    child: PathBar(
                      paths: paths,
                      icon: Icons.sd_card,
                      onChanged: (index) {
                        print('index ${index} - ${paths.length} ${path}');
                        if(index == paths.length-1){

                        }else if(index==0){
                          paths.clear();
                          path = "HOME";
                          paths.add(ProjectTaskModel(projectId: '', title: 'HOME', id: 'id', note: 'note', img: '', priority: '', startDate: '', endDate: '', pStartDate: '', dueDate: '', responsiblePerson: '', status: 0, statusname: '', parentTaskId: '', dependentTaskId: 0, taskcount: '', isImageUpload: 0, done: false, mtaskId: '', taskcreateduser: '', latestComment: '', files: '', manager: '', treeStatus: '', datumClass: '', parantDate: '', parantPlandate: 'parantPlandate', path: 'HOME'));
                          supportPath="";
                          isAddButton = false;
                          //historyList.clear();
                          //loadDigitalResource();
                          getSortedData();
                        }else {
                          //path = paths[index].path;

                          // for(int j=index+1;j<historyList.length;j++){
                          //   historyList.removeAt(index);
                          // }
                          //paths.removeRange(index + 1, paths.length);
                          pop();
                          //getSortedData();
                        }
                        print('Path is ${path}');
                        setState(() {});
                      },
                    ),
                  ),
                  Flexible(
                    child: Container(
                        padding: EdgeInsets.only(left: 10,right: 10,top: 10),
                        child: isDataFound==false ? Utility.emptyDataSet(context, 'Project task are not found') : ListView.builder(
                          itemCount: getSortedData().length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            bool isLastElement = mSortedProjectList.length + 1 == index;
                            return GestureDetector(
                              onTap: (){
                                push(mSortedProjectList[index], supportPath);
                                //paths.add(mSortedProjectList[index]);
                              },
                              child: getView(mSortedProjectList![index],isLastElement),
                            );
                          },
                        )
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }

  showImageOption(ProjectModel model) {
    List<String> options = ['Project Details', 'Task Chart','Send Credential'];

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(model.FranchiseeName.toString()),
            content: SizedBox(
              width: double.minPositive,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(options[index]),
                    onTap: () {
                      Navigator.of(context).pop();
                      if (index==0) {
                        //showImagePicker(0);
                      } else if (index==1) {
                        //showImagePicker(1);
                      } else {
                        //showImagePicker(3);
                      }
                    },
                  );
                },
              ),
            ),
          );
        });
  }

  getAssetName(String status){
    if(status == 'Pending'){
      return "pendingtasks";
    }else if(status == 'In Progress'){
      return "inprogress";
    }else if(status.toLowerCase().contains('completed')){
      return "task_completed";
    }
    return "pendingtasks";
  }

  getActions(ProjectTaskModel model){
    List<Widget> list = [];
    if(paths.length > 1){
      list.add(IconButton(
        icon: const Icon(Icons.message_outlined),
        color: kPrimaryLightColor,
        tooltip: 'message',
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatPage(taskModel: model,isEdit: model.taskcreateduser ==frichiseeId.toString() ? true : false)),
          );
          loadProjectTask();
          //showImageOption(model);
        },
      ));
    }else if(model.taskcreateduser.isNotEmpty) {
      list.add(IconButton(
        icon: const Icon(Icons.message_outlined),
        color: kPrimaryLightColor,
        tooltip: 'message',
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatPage(taskModel: model,isEdit: model.taskcreateduser ==frichiseeId.toString() ? true : false)),
          );
          loadProjectTask();
          //showImageOption(model);
        },
      ));
    }
    if(model.taskcreateduser == frichiseeId.toString()){
      if(model.statusname=='Completed'){
        list.add(IconButton(
          icon: const Icon(Icons.done_outline),
          color: LightColors.kGreen,
          tooltip: 'edit',
          onPressed: () async {
            Utility.showMessage(context, 'The task has been completed...');
            //showImageOption(model);
          },
        ));
      }else {
        list.add(IconButton(
          icon: const Icon(Icons.edit),
          color: kPrimaryLightColor,
          tooltip: 'edit',
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => UpdateBPMSTask(taskModel: model,)),
            );
            loadProjectTask();
            //showImageOption(model);
          },
        ));
        print('${model.title} ${model.mtaskId}');
        if(model.mtaskId=='0')
        list.add(IconButton(
          icon: const Icon(Icons.delete),
          color: LightColors.kRed,
          tooltip: 'Filter',
          onPressed: () async {
            currentTask = model;
            Utility.onApproveConfirmation(context, 'Delete task', 'Are you sure to delete the ${model.title} task', this);
            //showImageOption(model);
          },
        ));
      }

    }
    return list;
  }

  getListofImages(ProjectTaskModel model){
    if(model.files.isNotEmpty && model.files.contains(',')) {
      List<String> imageList = model.files.split(',');
      return Column(
        children: <Widget>[
          new Container(
            child: Expanded(
              child: new ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: imageList.length,
                itemBuilder: (context, index) =>
                new Container(
                  alignment: Alignment.topCenter,
                  child: new Stack(
                    alignment: Alignment.topCenter,
                    children: <Widget>[
                      new Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: new Container(
                          width: 60.0,
                          height: 60.0,
                          decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                            image: new DecorationImage(
                                fit: BoxFit.fill,
                                image: new NetworkImage(
                                    imageList[index])),
                          ),
                          //margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        ),
                      ),
                    ],
                  ),
                ),

              ),
            ),
          ),
        ],
      );
    }else{
      return SizedBox(height: 0,);
    }
  }

  getView(ProjectTaskModel model,bool isLastElement){
    return Card(
      color: model.statusname=='Pending' ?  LightColors.kYallow : model.statusname=='Completed' ?  kPrimaryLightColor : LightColors.kRed,
      elevation: 5,
      margin: !isLastElement
          ? EdgeInsets.only(bottom: 10)
          : EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
            color: Color(0xFFFFFFFF),
            border: Border.all(
              color: model.statusname=='Pending' ?  LightColors.kYallow : model.statusname=='Completed' ?  kPrimaryLightColor : LightColors.kRed,
            ),
            borderRadius: BorderRadius.all(Radius.circular(5))
        ),
        margin: EdgeInsets.only(right: 5,bottom: 4),
        padding: EdgeInsets.only(left: 10,top: 10,bottom: 10,right:10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: model.taskcreateduser == frichiseeId.toString() && model.statusname=='Completed' ? size.width *  0.56 : model.taskcreateduser.isEmpty || model.taskcreateduser != frichiseeId.toString()  ? size.width *  0.72 : model.mtaskId=='0' ? size.width * 0.45 : size.width * 0.58,
                      child: Text(
                        '${model.title}',
                        style: TextStyle(
                          color: Color(0xff151a56),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 1,
                    ),
                    Text(
                      '${model.statusname}',
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                SizedBox(
                  width: 5,
                ),
                model.taskcreateduser.isEmpty  ? SizedBox(width: 0,) : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: getActions(model),
                ),
              ],
            ),
            model.taskcount.isEmpty && model.responsiblePerson.isEmpty && model.latestComment.isEmpty ? SizedBox(height: 0,) :
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*getListofImages(model),*/
                model.responsiblePerson.isEmpty ? SizedBox(height: 0,) :
                Text(
                  'Responsible Person   : ${model.responsiblePerson}',
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                model.latestComment!=null && model.latestComment.isNotEmpty ?
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Last Comments         : ${model.latestComment}',
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ) : SizedBox(height: 0,),
                Text(
                  'Total Task        : ${model.taskcount}',
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            SizedBox(
              height: 15,
            ),
            model.parantPlandate.isNotEmpty || model.startDate.isNotEmpty || model.parantPlandate.isNotEmpty || model.pStartDate.isNotEmpty ?
            DateTimeCard(model) : SizedBox(height: 0,)
            ,
          ],
        ),
      ),
    );
  }

getView12(ProjectTaskModel model,bool isLastElement){
    return Card(
      elevation: 5,
      margin: !isLastElement
          ? EdgeInsets.only(bottom: 20)
          : EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.only(left: 10,top: 10,bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage('assets/images/task-list.png'),
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: size.width * 0.5,
                      child: Text(
                        '${model.title}',
                        style: TextStyle(
                          color: Color(0xff151a56),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      '${model.statusname}',
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 10,
                ),
                SizedBox(width: 70,
                child: Text(
                  '${model.taskcount.toString()}',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),),

              ],
            ),

            SizedBox(
              height: 15,
            ),
            /*Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Task Id   : ${model.mtaskId}',
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Last Comments : ${model.latestComment}',
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'count : ${model.taskcount}',
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),*/
            SizedBox(
              height: 15,
            ),
            //DateTimeCard(model),
            /*Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: OutlinedButton(
                    child: Text('Cancel'),
                    onPressed: () {},
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: ElevatedButton(
                    child: Text('Reschedule'),
                    onPressed: () => {},
                  ),
                )
              ],
            )*/
          ],
        ),
      ),
    );
}
    getView1(ProjectModel model) {
      return GestureDetector(
        onTap: () {
          /*if(model.ApprovalStatus =='Approved') {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CVFListScreen(mPjpInfo: pjpInfo)));
          }else if(pjpInfo.isSelfPJP=='1' && pjpInfo.ApprovalStatus=='Rejected'){
            Utility.showMessageSingleButton(context, 'The PJP is Rejected by Manager', this);
          }else if (pjpInfo.isSelfPJP=='1'){
            Utility.showMessageSingleButton(context, 'This pjp is not approved yet, Please connect with your manager', this);
          }*/
        },
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(1, 10, 1, 1),
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
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(12, 4, 12, 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                        child: Text(
                          'Created By : ${model.CreatedBy}',
                          style: TextStyle(
                            fontFamily: 'Lexend Deca',
                            color: Color(0xFF4B39EF),
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                        child: Text(
                          'CRM Id : P-${model.CRMId}',
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
                ListTile(
                  title: Padding(
                    padding: EdgeInsetsDirectional.all(0),
                    child: Text(
                      '${model.FranchiseeName}',
                      style: LightColors.textHeaderStyle16,
                    ),
                  ),
                  subtitle: /*Expanded(
                  flex: 1,
                  child:*/ Text(
                    '${model.FranchiseeCode}',
                    style: LightColors.textSmallStyle,
                  ),
                  //),
                  /*trailing:  Text(
                    pjpInfo.ApprovalStatus,
                    style: TextStyle(
                      fontFamily: 'Lexend Deca',
                      color: LightColors.kRed,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),*/
                ),
              ],
            ),
          ),
        ),
      );
    }

    DateTimeCard(ProjectTaskModel model){
    //print(model.toJson());
      return Container(
        decoration: BoxDecoration(
          color: Color(0xffe8eafe),
          borderRadius: BorderRadius.circular(10),
        ),
        width: double.infinity,
        padding: EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                model.pStartDate.isEmpty && model.parantPlandate.isEmpty ? SizedBox(height: 0,) :
                Text(
                  'Plan StartDate : ${model.pStartDate.isEmpty ? model.parantPlandate.isEmpty ? '' : parsePlanDate(model.parantPlandate,0) :  Utility.parseShortDate(model.pStartDate)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: kPrimaryLightColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                model.startDate != null && model.startDate.isNotEmpty || model.parantDate!=null && model.parantDate.isNotEmpty   ?
                Text(
                  'Actual Date : ${model.startDate.isNotEmpty ?  Utility.parseShortDate(model.startDate) : parsePlanDate(model.parantDate, 0)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: kPrimaryLightColor,
                    fontWeight: FontWeight.bold,
                  ),
                ) : SizedBox(height: 0,),

              ],
            ),
            /*Text(
              Utility.parseShortDate(model.taskcount),
              style: TextStyle(
                fontSize: 10,
                color: kPrimaryLightColor,
                fontWeight: FontWeight.bold,
              ),
            ),*/
            Column(
              children: [
                /*Icon(
                  Icons.access_alarm,
                  color: Color(0xff575de3),
                  size: 17,
                ),*/

                model.dueDate.isEmpty && model.parantPlandate.isEmpty ? SizedBox(height: 0,) :
                Text(
                  'Plan EndDate : ${model.dueDate.isEmpty ? model.parantPlandate.isEmpty ? '' : parsePlanDate(model.parantPlandate,1) : Utility.parseShortDate(model.dueDate)}' ,
                  style: TextStyle(
                    fontSize: 10,
                    color: kPrimaryLightColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                model.endDate != null && model.endDate.isNotEmpty || model.parantDate!=null && model.parantDate.isNotEmpty   ?
                Text(
                  'Actual End : ${model.endDate.isNotEmpty ? Utility.parseShortDate(model.endDate) : parsePlanDate(model.parantDate, 1)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: LightColors.kRed,
                    fontWeight: FontWeight.bold,
                  ),
                )  : SizedBox(height: 0,),
              ],
            )
          ],
        ),
      );
    }
    String parsePlanDate(String date,int index){
      String newDate = date;
      try{
        var d = date.split(',');
        return d[index];
      }catch(e){}
      return newDate;
    }

  deleteTask(ProjectTaskModel? currentTask){
    APIService apiService = APIService();
    Utility.showLoaderDialog(context);
    apiService.deleteTask(DeleteTaskRequest(taskId: currentTask!.id)).then((value) {
      Navigator.of(context).pop();
      print('response ---');
      print(value);
      if (value != null) {
        if (value == null ) {
          Utility.showMessage(context, 'data not found');
        } else if (value is CommonResponse) {
          CommonResponse response = value;
          print(response.toJson());
          if(response.data[0].msg.toLowerCase().contains('sucess')){
            Utility.getConfirmationDialog(context, 'Task Deleted Successfully', response.data[0].msg,this);
          }else
            Utility.showMessage(context, response.data[0].msg);
        } else {
          Utility.showMessage(context, 'Unable to delete task');
        }
      }
      //Navigator.of(context).pop();
      setState(() {});
    });
  }
  
  @override
  void onClick(int action, value) {
    if(action == Utility.ACTION_CONFIRM){
      deleteTask(currentTask);
    }
  }
}
