import 'package:Intranet/pages/bpms/bpms_task.dart';
import 'package:Intranet/pages/helper/math_utils.dart';
import 'package:Intranet/pages/utils/theme/colors/light_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/request/bpms/projects.dart';
import '../../api/response/bpms/bpms_stats.dart';
import '../helper/LocalConstant.dart';
import '../helper/constants.dart';
import '../helper/utils.dart';
import 'auth/data/providers/auth_provider.dart';

class BPMSProjects extends ConsumerStatefulWidget {

  BPMSProjects({Key? key,}) : super(key: key);

  @override
  _BPMSProjects createState() => _BPMSProjects();
}

class _BPMSProjects extends  ConsumerState<BPMSProjects> with WidgetsBindingObserver{

  bool isSearch=false;
  TextEditingController _searchController = TextEditingController();
  final focusNode = FocusNode();

    @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    loadProjects();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
      print('didChangeAppLifecycleState');
    if (state == AppLifecycleState.resumed) {
      //print('resume');
      loadProjects();
    }
  }

  loadProjects() async{
    var box = await Utility.openBox();
    if(box.get(LocalConstant.KEY_EMPLOYEE_ID)!=null) {
      print('in if emoloyee found');
      String uid = box.get(LocalConstant.KEY_EMPLOYEE_ID) as String;
      int frid = box.get(LocalConstant.KEY_FRANCHISEE_ID) as int;
      print('in if emoloyee found ${uid}');
      await ref.read(authNotifierProvider.notifier).getAllProjects(frid.toString());
    }
  }

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  resetSearch(){
    isSearch=false;
    _searchController.text='';
  }
  List<ProjectModel> mSortedProjectList = [];
  getSortedData(){
    print('Sorted list');
    final auth = ref.watch(authNotifierProvider);
    mSortedProjectList.clear();
    if (auth.projectList!=null && auth.projectList!.length>0)
      for (int index = 0; index <auth.projectList!.length; index++) {
        if (_searchController.text.toString().isEmpty || auth.projectList![index].isContains(_searchController.text.toString().toLowerCase())) {
          mSortedProjectList.add(auth.projectList![index]);
        }
      }
    print('Sorted list ${mSortedProjectList.length}');
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
        backgroundColor: Color(0xffe9ebf0),
        appBar: AppBar(
          centerTitle: false,
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
                        color: Colors.blue,
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
              Text('All Projects',style: LightColors.textHeaderStyle13Selected,),
              Text('Manish Sharma - SAT Operation Head',style: LightColors.textHeaderStyle13Selected,),
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
          backgroundColor: kPrimaryLightColor,
          elevation: 50.0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Menu Icon',
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
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
                              print(crmId);
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BPMSProjectTask(projectId: crmId,)));
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

getView(ProjectModel model,bool isLastElement){
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
                      '${model.FranchiseeCode}',
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
                  color: Color(0xff575de3),
                  tooltip: 'Filter',
                  onPressed: () {
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

    DateTimeCard(ProjectModel model){
      return Container(
        decoration: BoxDecoration(
          color: Color(0xffe8eafe),
          borderRadius: BorderRadius.circular(10),
        ),
        width: double.infinity,
        padding: EdgeInsets.only(left: 20,right: 20,top: 10,bottom: 10),
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
                  Utility.parseShortDate(model.approvedDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xff575de3),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Approved Date',
                  style: TextStyle(
                    fontSize: 8,
                    color: Color(0xff575de3),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              model.taskcount.replaceAll(',', ', '),
              style: TextStyle(
                fontSize: 14,
                color: Color(0xff575de3),
                fontWeight: FontWeight.bold,
              ),
            ),
            Column(
              children: [
                /*Icon(
                  Icons.access_alarm,
                  color: Color(0xff575de3),
                  size: 17,
                ),*/
                Text(
                  Utility.parseShortDate(model.deadline),
                  style: TextStyle(
                    color: LightColors.kRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Deadline',
                  style: TextStyle(
                    fontSize: 10,
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
}
