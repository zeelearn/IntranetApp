import 'package:Intranet/pages/utils/theme/colors/light_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/response/bpms/bpms_stats.dart';
import '../helper/LocalConstant.dart';
import '../helper/constants.dart';
import '../helper/utils.dart';
import 'auth/data/providers/auth_provider.dart';
import 'bpms_projects.dart';

class BPMSDashboard extends ConsumerStatefulWidget {
  String userId;

  BPMSDashboard({Key? key, required this.userId}) : super(key: key);

  @override
  _BPMSDashboard createState() => _BPMSDashboard();
}

class _BPMSDashboard extends  ConsumerState<BPMSDashboard> {

  bool isLoading = true;
  String displayName='';
    @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadCounts();
  }

  loadCounts() async{
    var box = await Utility.openBox();
    if(box.get(LocalConstant.KEY_EMPLOYEE_ID)!=null) {
      print('in if emoloyee found');
      String uid = box.get(LocalConstant.KEY_EMPLOYEE_ID) as String;
      int frid = box.get(LocalConstant.KEY_FRANCHISEE_ID) as int;
      displayName = '${box.get(LocalConstant.KEY_FIRST_NAME) as String} ${box.get(LocalConstant.KEY_LAST_NAME) as String}';
      print('in if emoloyee found ${frid}');
      ProjectStatsModel response = await ref.read(authNotifierProvider.notifier).getStats(frid.toString());
      print('in if response ${response}');
      setState(() {
        isLoading=false;
      });
      mMenus.addAll([
        CourseCard(
            counts: 0,
            title: "ALL Projects",
            status: LocalConstant.ALL_PROJECT,
            color: Color(0xff8E97FD),
            textColor: Color(0xffFFECCC),
            image: Image(
              image: AssetImage('assets/images/project.png'),
            )
        ),CourseCard(
            counts: response.TotalProject,
            title: "My Projects",
            status: LocalConstant.MY_PROJECT,
            color: Color(0xff8E97FD),
            textColor: Color(0xffFFECCC),
            image: Image(
              image: AssetImage('assets/images/project.png'),
            )
        ),CourseCard(
            counts: response.InprogressTask,
            title: "In Progress Task",
            status: LocalConstant.INPROGRESS_PROJECT,
            color: Color(0xffFFC97E),
            textColor: Color(0xff3F414E),
            image: Image(
              image: AssetImage('assets/images/pending-tasks.png'),
            )
        ),
        CourseCard(
            counts: response.pendingtask,
            title: "Pending Task",
            status: LocalConstant.PENDING_PROJECT,
            color: Color(0xffFA6E5A),
            textColor: Color(0xffFFECCC),

            image: Image(
              image: AssetImage('assets/images/work-in-progress.png'),
            )
        ),
        CourseCard(
            counts: response.completedTask,
            title: "Completed",
            status: LocalConstant.COMPLETED_PROJECT,
            color: Color(0xff6CB28E),
            textColor: Color(0xffFFECCC),
            image: Image(
              image: AssetImage('assets/images/check.png'),
            )
        )
      ]);
    }
  }

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  List<CourseCard> mMenus = [];

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    print('isLoading ${auth.loading}');
    return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('BPMS Dashboard',style: LightColors.textHeaderStyle13Selected,),
              Text(displayName,style: LightColors.textHeaderStyle13Selected,),
            ],
          ),
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
            child: isLoading ? Utility.showLoader() : Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 10,
                ),
                getBPMSMenu(),
              ],
            ),
          ),
        ));
  }

  getBPMSMenu() {
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 4;
    final double itemWidth = size.width / 2;
    return Flexible(
          child: Container(
              padding: EdgeInsets.all(12.0),
              child: GridView.builder(
                itemCount: mMenus.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                  childAspectRatio: (itemWidth / itemHeight),
                ),
                itemBuilder: (BuildContext context, int index){
                  return mMenus[index];
                },
              )
          ),
      );
  }

}

class CourseCard extends StatelessWidget {
  const CourseCard(
      {Key? key,
        required this.counts,
        required this.title,
        required this.status,
        required this.color,
        required this.image,
        required this.textColor})
      : super(key: key);

  final int counts;
  final String title;
  final int status;
  final Color color;
  final Image image;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => new BPMSProjects(status: status)));
      },
      child: Container(
        height: 100,
          child: Padding(
            padding: EdgeInsets.all(5),
            child: Card(
                color: color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        height: 50,
                        child: image,
                      ),
                    ),
                    counts==0 ? SizedBox(height: 0,) :
                    Padding(
                      child: Text(
                        counts.toString(),
                        style: TextStyle(
                            fontSize: 34,
                            color: textColor,
                            fontFamily: 'MontserratBold'),
                      ),
                      padding: EdgeInsets.fromLTRB(18, 30, 0, 0),
                    ),
                    Padding(
                      child: Text(
                        title,
                        style: TextStyle(
                            fontSize: 18,
                            color: textColor,
                            fontFamily: 'MontserratLight'),
                      ),
                      padding: EdgeInsets.fromLTRB(15, 80, 0, 0),
                    ),
                  ],
                )),
          )),
    );
  }
}

class HorizontalCard extends StatelessWidget {
  const HorizontalCard(
      {Key? key,
        required this.level,
        required this.title,
        required this.duration,
        required this.color,
        required this.image,
        required this.textColor})
      : super(key: key);

  final String level;
  final String title;
  final String duration;
  final Color color;
  final Image image;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 120,
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Card(
              color: color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      child: image,
                    ),
                  ),
                  Padding(
                    child: Text(
                      level,
                      style: TextStyle(
                          fontSize: 14,
                          color: textColor,
                          fontFamily: 'MontserratRegular'),
                    ),
                    padding: EdgeInsets.fromLTRB(28, 55, 0, 0),
                  ),
                  Padding(
                    child: Text(
                      title,
                      style: TextStyle(
                          fontSize: 22,
                          color: textColor,
                          fontFamily: 'MontserratBold'),
                    ),
                    padding: EdgeInsets.fromLTRB(25, 24, 0, 0),
                  ),
                  Padding(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xffEBEAEC),
                        elevation: 5,
                        padding: const EdgeInsets.all(12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      onPressed: () {  },/*RaisedButton(
                      color: Color(0xffEBEAEC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),*/
                      child: Text(
                        "Start",
                        style: TextStyle(color: Color(0xffffffff)),
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(275, 26, 0, 0),
                  ),
                ],
              )),
        ));
  }
}