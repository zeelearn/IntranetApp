import 'package:Intranet/api/request/bpms/send_cred.dart';
import 'package:Intranet/api/response/bpms/send_cred.dart';
import 'package:Intranet/pages/bpms/bpms_dashboard.dart';
import 'package:Intranet/pages/bpms/bpms_task.dart';
import 'package:Intranet/pages/bpms/update_task.dart';
import 'package:Intranet/pages/helper/math_utils.dart';
import 'package:Intranet/pages/utils/theme/colors/light_colors.dart';
import 'package:Intranet/pages/widget/MyWebSiteView.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/APIService.dart';
import '../../api/request/bpms/deletetask.dart';
import '../../api/request/bpms/projects.dart';
import '../../api/response/bpms/project_task.dart';
import '../helper/LocalConstant.dart';
import '../helper/constants.dart';
import '../helper/utils.dart';
import '../home/IntranetHomePage.dart';
import '../iface/onClick.dart';
import 'auth/data/providers/auth_provider.dart';
import 'auth/ui/ChatPage.dart';

class BPMSProjects extends ConsumerStatefulWidget {
  int status;
  BPMSProjects({Key? key,required this.status}) : super(key: key);
  //BPMSProjects({Key? key}) : super(key: key);

  @override
  _BPMSProjects createState() => _BPMSProjects();
}

class _BPMSProjects extends  ConsumerState<BPMSProjects> with WidgetsBindingObserver implements onClickListener{

  bool isSearch=false;
  TextEditingController _searchController = TextEditingController();
  final focusNode = FocusNode();
  int frichiseeId=0;
  String displayName='';
  String userId='';
  ProjectTaskModel? currentTask;

    @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    loadProjects();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      //print('resume');
      loadProjects();
    }
  }

  loadProjects() async{
    var box = await Utility.openBox();
    if(box.get(LocalConstant.KEY_EMPLOYEE_ID)!=null) {
      String uid = box.get(LocalConstant.KEY_EMPLOYEE_ID) as String;
      frichiseeId = box.get(LocalConstant.KEY_FRANCHISEE_ID) as int;
      displayName = '${box.get(LocalConstant.KEY_FIRST_NAME) as String} ${box.get(LocalConstant.KEY_LAST_NAME) as String}';
      print('last sync');
      String lastSync = box.containsKey(LocalConstant.PROJ_LAST_SYNC+'${widget.status}') ?  box.get(LocalConstant.PROJ_LAST_SYNC+'${widget.status}') as String : '';
      print(lastSync);
      if(widget.status==100 || widget.status==0) {
        await ref.read(authNotifierProvider.notifier).getAllProjects(frichiseeId.toString(),lastSync);
      }else{
        await ref.read(authNotifierProvider.notifier).getProjectByStatus(frichiseeId.toString(),widget.status,lastSync);
      }
    }
  }

  refreshProjects() async{
    var box = await Utility.openBox();
    if(box.get(LocalConstant.KEY_EMPLOYEE_ID)!=null) {
      print('in if emoloyee found');
      String uid = box.get(LocalConstant.KEY_EMPLOYEE_ID) as String;
      int frid = box.get(LocalConstant.KEY_FRANCHISEE_ID) as int;
      print('in if emoloyee found ${uid}');
      await ref.read(authNotifierProvider.notifier).refreshProjectList(frid.toString(),widget.status);
    }
  }

  void sendCredentials(String crmId) {
    APIService apiService = APIService();
    Utility.showLoaderDialog(context);
    apiService.sendCredentials(SendCredentialsRequest(crmId: crmId)).then((value) {
      if (value != null) {
        Navigator.of(context).pop();
        CommonResponse responseModel;
        if (value != null) {
          responseModel = value;
          Utility.showMessage(context,responseModel.data[0].msg );
        } else {
          Utility.showMessage(context,'Unable to send Credentials Please try again later');
        }
      } else {
        Utility.showMessage(context,'Unable to send Credentials Please try again later');
      }
    });
  }

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  resetSearch(){
    isSearch=false;
    _searchController.text='';
  }
  List<ProjectModel> mSortedProjectList = [];
  getSortedData(){
    final auth = ref.watch(authNotifierProvider);
    mSortedProjectList.clear();
    if (auth.projectList!=null && auth.projectList!.length>0)
      for (int index = 0; index <auth.projectList!.length; index++) {
        if (_searchController.text.toString().isEmpty || auth.projectList![index].isContains(_searchController.text.toString().toLowerCase())) {
          if(widget.status==0){
           //if(auth.projectList![index].FranchiseeId == frichiseeId)
             mSortedProjectList.add(auth.projectList![index]);
          } else{
            mSortedProjectList.add(auth.projectList![index]);
          }
        }
      }
    //print('Sorted list ${mSortedProjectList.length}');
    setState(() {
      //isLoading=false;
    });
  return mSortedProjectList;
  }

  getTitle(){
    String title ='All Projects';
    switch(widget.status){
      case LocalConstant.MY_PROJECT:
          title = 'My Projects';
        break;
        case LocalConstant.PENDING_PROJECT:
          title = 'Pending Task';
        break;
        case LocalConstant.COMPLETED_PROJECT:
          title = 'Completed Task';
        break;
        case LocalConstant.INPROGRESS_PROJECT:
          title = 'In-Progress Task';
        break;
    }
    return title;
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    getSortedData();
    return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Color(0xffe9ebf0),
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: kPrimaryLightColor,
          leading: InkWell(
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          BPMSDashboard(userId: '',)));
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.arrow_back,
                  size: 24,
                ),
              ],
            ),
          ),
          title: isSearch ? Card(
            margin: EdgeInsets.all(5),
            color: Colors.white,
            child: Container(
              child: SizedBox(
                height: 45,
                width: MediaQuery.of(context).size.width / 0.7,
                child: TextFormField(
                  controller: _searchController,
                  textInputAction: TextInputAction.done,
                  style: LightColors.textHeaderStyle13,
                  focusNode: focusNode,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'search here..',
                    counterText: "",
                    fillColor: Colors.white60,
                    suffixIcon: InkWell(
                      onTap: (){
                        resetSearch();
                        getSortedData();
                      },
                      child: !isSearch ?  Icon(Icons.search) : Icon(Icons.clear),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2.0),
                      borderSide: BorderSide(
                        color: kPrimaryLightColor,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2.0),
                      borderSide: BorderSide(
                        color: LightColors.kLightGray,
                        width: 1.0,
                      ),
                    ),
                  ),
                  //initialValue: _dayController.text.toString(),
                  onChanged: (val){

                    //if(val.length>1)
                    setState(() {
                      _searchController.text = val.toString();
                      getSortedData();
                    });
                  },
                  onFieldSubmitted: (val) {

                    setState(() {
                      _searchController.text = val.toString();
                      getSortedData();
                      resetSearch();
                    });
                  },
                ),
              ),
            ),
          ) : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(displayName,style: LightColors.textHeaderStyle13Selected,),
              Text(getTitle(),style: LightColors.textHeaderStyle13Selected,),
            ],
          ),
          actions: isSearch ? null : <Widget>[
            /*IconButton(
              icon: const Icon(Icons.filter_list),
              tooltip: 'Filter',
              onPressed: () {

              },
            ),*/IconButton(
              icon: !isSearch ?  Icon(Icons.search) : Icon(Icons.clear),
              tooltip: 'Search',
              onPressed: () {
                setState(() {
                  _searchController.text ='';
                  isSearch = true;
                });
              },
            ), //IconButton
          ],
          //<Widget>[]

          elevation: 50.0,

          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        body: SafeArea(
          child: RefreshIndicator(
            key: _refreshIndicatorKey,
            color: Colors.white,
            backgroundColor: Colors.blue,
            strokeWidth: 4.0,
            onRefresh: () async {
              // Replace this delay with the code to be executed during refresh
              // and return a Future when code finishs execution.
              //IntranetServiceHandler.loadPjpSummery(employeeId, 0,businessId, this);
              refreshProjects();
              return Future<void>.delayed(const Duration(seconds: 3));
            },
            // Pull from top to show refresh indicator.
            child: auth.projectList ==null || auth.loading ? Utility.showLoader() : Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 10,
                ),
                Flexible(
                  child: Container(
                      padding: EdgeInsets.all(12.0),
                      child: ListView.builder(
                        itemCount: getSortedData().length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          bool isLastElement = mSortedProjectList.length + 1 == index;
                          String crmId = mSortedProjectList[index].CRMId;
                          return GestureDetector(
                            onTap: (){
                              if(widget.status !=0 && widget.status !=100){
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ChatPage(taskModel: mSortedProjectList![index].getModel(), isEdit: true,franchiseeName: mSortedProjectList![index].FranchiseeName!)));
                              }else if(mSortedProjectList!=null && mSortedProjectList.length>index) {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            BPMSProjectTask(
                                              project: mSortedProjectList[index], status: widget.status,)));
                              }else{
                                print('list not found....');
                              }
                            },
                            child: widget.status ==100 || widget.status ==0 ? getView(mSortedProjectList![index],isLastElement) :  getTaskView(mSortedProjectList![index],isLastElement),
                          );
                        },
                      )
                  ),
                )
              ],
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
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) => MyWebsiteView(
                              title: model.FranchiseeName!,
                              url: 'https://project.zeelearn.com/#/admin/projects/projectDetails/${model.FranchiseeId!}&${model.CRMId}&mobile&${frichiseeId}',
                            )));
                      } else if (index==1) {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) => MyWebsiteView(
                              title: model.FranchiseeName!,
                              url: 'https://chart.zeelearn.com/chart.html?pid=${model.CRMId}',
                            )));
                        //MyWebsiteView(title: model.FranchiseeName!, url: 'https://chart.zeelearn.com/chart.html?pid=${model.CRMId}',);
                      } else {
                        sendCredentials(model.CRMId);
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

getView(ProjectModel model,bool isLastElement){
    return Card(
      color: LightColors.kLightGrayM,
      elevation: 5,
      margin: !isLastElement
          ? EdgeInsets.only(bottom: 20)
          : EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
            color: Color(0xFFFFFFFF),
            border: Border.all(
              color: LightColors.kLightGray1,
            ),
            borderRadius: BorderRadius.all(Radius.circular(5))
        ),
        padding: EdgeInsets.only(left: 10,top: 10,bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage('assets/icons/ic_pending.png'),
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: size.width * 0.6,
                      child: Text(
                        '${model.FranchiseeName}',
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
                      '${model.Title}  ${model.FranchiseeCode==null  || model.FranchiseeCode=='null' ? model.Title!.isNotEmpty ? model.Title : model.FranchiseeCode : ''}',
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

                IconButton(
                  icon: const Icon(Icons.more_outlined),
                  color: kPrimaryLightColor,
                  tooltip: 'Options',
                  onPressed: () async {
                    showImageOption(model);
                  },
                )
              ],
            ),

            SizedBox(
              height: 15,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CRM ID   : ${model.CRMId}',
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                model.TierName!=null ?
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Tier         : ${model.TierName}',
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 50,),
                    Text(
                      'Fee Type : ${model.FeeType}',
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ) : SizedBox(height: 0,),
                Text(
                  'RSM        : ${model.CreatedBy}',
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Location : ${model.CatchmentArea}',
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
            widget.status == 100 || widget.status == 0 ? DateTimeCardMyProject(model) :
            DateTimeCard(model),
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

  getTaskView(ProjectModel model,bool isLastElement){
    return Card(
      color: widget.status == LocalConstant.PENDING_PROJECT ?  LightColors.kYallow : widget.status == LocalConstant.COMPLETED_PROJECT ?  kPrimaryLightColor : LightColors.kRed,
      elevation: 5,
      margin: !isLastElement
          ? EdgeInsets.only(bottom: 10)
          : EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
            color: Color(0xFFFFFFFF),
            border: Border.all(
              color: widget.status == LocalConstant.PENDING_PROJECT ?  LightColors.kYallow : widget.status == LocalConstant.COMPLETED_PROJECT ?  kPrimaryLightColor : LightColors.kRed,
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
                      width: model.taskcreateduser == frichiseeId.toString() && model.statusname=='Completed' ? size.width *  0.45 : model.taskcreateduser!.isEmpty || model.taskcreateduser != frichiseeId.toString()  ? size.width *  0.44 : model.mtaskId=='0' ? size.width * 0.43 : size.width * 0.4,
                      child: Text(
                        '${model.Title}',
                        style: TextStyle(
                          color: Color(0xff151a56),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 1,
                    ),
                    SizedBox(
                      width: model.taskcreateduser == frichiseeId.toString() && model.statusname=='Completed' ? size.width *  0.52 : model.taskcreateduser!.isEmpty || model.taskcreateduser != frichiseeId.toString()  ? size.width *  0.44 : model.mtaskId=='0' ? size.width * 0.43 : size.width * 0.4,
                      child: Text(
                        '${model.FranchiseeName} ${model.FranchiseeCode!.isNotEmpty ? ' - ${model.FranchiseeCode}' : ''}',
                        style: TextStyle(
                          color: Colors.black45,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  ],
                ),

                SizedBox(
                  width: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: getActions(model),
                ),
              ],
            ),
            model.taskcount.isEmpty && model.responsiblePerson!.isEmpty && model.Remark!.isEmpty ? SizedBox(height: 0,) :
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*getListofImages(model),*/
                model.responsiblePerson==null || model.responsiblePerson.isEmpty ? SizedBox(height: 0,) :
                Text(
                  'Responsible Person   : ${model.responsiblePerson}',
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                model!.Remark!=null && model.Remark!.isNotEmpty ?
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: size.width * 0.7,
                      child: Text(
                        'Last Comments         : ${model.Remark}',
                        style: TextStyle(
                          color: Colors.black45,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                    ,
                  ],
                ) : SizedBox(height: 0,),
              ],
            ),

            SizedBox(
              height: 10,
            ),
            model.p_start_date!.isNotEmpty || model.StartDate!.isNotEmpty || model.due_date!.isNotEmpty || model.End_date!.isNotEmpty ?
            DateTimeCard(model) : SizedBox(height: 0,)
            ,
          ],
        ),
      ),
    );
  }


  getActions(ProjectModel model){
    List<Widget> list = [];
    list.add(IconButton(
      icon: const Icon(Icons.message_outlined),
      color: kPrimaryLightColor,
      tooltip: 'message',
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChatPage(taskModel: model.getModel(),isEdit: model.taskcreateduser ==frichiseeId.toString() ? true : false,franchiseeName: model.FranchiseeName!,)),
        );
        refreshProjects();
        //showImageOption(model);
      },
    ));
    list.add(IconButton(
      icon: const Icon(Icons.edit),
      color: kPrimaryLightColor,
      tooltip: 'edit',
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => UpdateBPMSTask(taskModel: model.getModel(),)),
        );
        refreshProjects();
        //showImageOption(model);
      },
    ));
    if(model.mtaskId=='0')
      list.add(IconButton(
        icon: const Icon(Icons.delete),
        color: LightColors.kRed,
        tooltip: 'Filter',
        onPressed: () async {
          currentTask = model.getModel();
          Utility.onApproveConfirmation(context, 'Delete task', 'Are you sure to delete the ${model.Title} task', this);
          //showImageOption(model);
        },
      ));
    return list;
  }

  DateTimeCardMyProject(ProjectModel model){
    return Container(
      decoration: BoxDecoration(
        color: Color(0xffe8eafe),
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.infinity,
      margin: EdgeInsets.only(right:10),
      padding: EdgeInsets.only(left: 20,right: 20,top: 10,bottom: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Text(
                widget.status==100 || widget.status == 0 ? 'Approved Date' : 'Plan Start Date',
                style: TextStyle(
                  fontSize: 8,
                  color: Color(0xff575de3),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.status==100 || widget.status == 0 ?  Utility.parseShortDate(model.approvedDate) : Utility.parseShortDate(model.p_start_date!),
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xff575de3),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(
            width: size.width *  0.3,
            child: Center(
              child: Text(
                model.taskcount.replaceAll(',', ', '),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xff575de3),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Column(
            children: [
              Text(
                widget.status==100 || widget.status == 0 ? 'Deadline' : 'Plan End Date',
                style: TextStyle(
                  fontSize: 8,
                  color: LightColors.kRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.status==100 || widget.status == 0 ? Utility.parseShortDate(model.deadline) : Utility.parseShortDate(model.due_date!),
                style: TextStyle(
                  fontSize: 12,
                  color: LightColors.kRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
    DateTimeCard(ProjectModel model){
      return Container(
        decoration: BoxDecoration(
          color: Color(0xffe8eafe),
          borderRadius: BorderRadius.circular(10),
        ),
        width: double.infinity,
        margin: EdgeInsets.only(right:10),
        padding: EdgeInsets.only(left: 20,right: 20,top: 10,bottom: 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                /*
                SizedBox(
                  width: 5,
                ),*/
                Text(
                  widget.status==100 || widget.status == 0 ? 'Approved Date' : 'Plan Start Date',
                  style: TextStyle(
                    fontSize: 8,
                    color: Color(0xff575de3),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.status==100 || widget.status == 0 ?  Utility.parseShortDate(model.approvedDate) : Utility.parseShortDate(model.p_start_date!),
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xff575de3),
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  widget.status==100 || widget.status == 0 ? 'Deadline' : 'Actual Start Date',
                  style: TextStyle(
                    fontSize: 8,
                    color: Color(0xff575de3),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  Utility.parseShortDate(model.StartDate!),
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xff575de3),
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ],
            ),
            SizedBox(
              width: size.width *  0.3,
              child: Center(
              child: Text(
                  model.taskcount.replaceAll(',', ', '),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xff575de3),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Column(
              children: [
                Text(
                  widget.status==100 || widget.status == 0 ? 'Deadline' : 'Plan End Date',
                  style: TextStyle(
                    fontSize: 8,
                    color: LightColors.kRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.status==100 || widget.status == 0 ? Utility.parseShortDate(model.deadline) : Utility.parseShortDate(model.due_date!),
                  style: TextStyle(
                    fontSize: 12,
                    color: LightColors.kRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Divider(height: 1,),
                Text(
                  'Actual End Date',
                  style: TextStyle(
                    fontSize: 8,
                    color: Color(0xff575de3),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  Utility.parseShortDate(model.End_date!),
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xff575de3),
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ],
            )
          ],
        ),
      );
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
          //print(response.toJson());
          if(response.data[0].msg.toLowerCase().contains('sucess')){
            Utility.getConfirmationDialog(context, 'Task Deleted Successfully', response.data[0].msg,this);
          }else
            Utility.showMessage(context, response.data[0].msg);
        } else {
          Utility.showMessage(context, 'Unable to delete task');
        }
        refreshProjects();
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
