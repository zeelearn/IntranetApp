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
      print('in if emoloyee found ${frid}');
      ProjectStatsModel response = await ref.read(authNotifierProvider.notifier).getStats(frid.toString());
      print('in if response ${response}');
      mMenus.addAll([
        CourseCard(
            level: response.TotalProject.toString(),
            title: "My Projects",
            duration: "7-30 Days",
            color: Color(0xff8E97FD),
            textColor: Color(0xffFFECCC),
            image: Image(
              image: AssetImage('assets/images/project.png'),
            )
        ),CourseCard(
            level: response.pendingtask.toString(),
            title: "Pending Task",
            duration: "12-35 Days",
            color: Color(0xffFA6E5A),
            textColor: Color(0xffFFECCC),

            image: Image(
              image: AssetImage('assets/images/pending-tasks.png'),
            )
        ),
        CourseCard(
            level: response.InprogressTask.toString(),
            title: "In Progress",
            duration: "7-27 Days",
            color: Color(0xffFFC97E),
            textColor: Color(0xff3F414E),
            image: Image(
              image: AssetImage('assets/images/work-in-progress.png'),
            )
        ),
        CourseCard(
            level: response.completedTask.toString(),
            title: "Completed",
            duration: "1 Day",
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
    return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('BPMS Dashboard',style: LightColors.textHeaderStyle13Selected,),
              Text('Manish Sharma - SAT Operation Head',style: LightColors.textHeaderStyle13Selected,),
            ],
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.filter_list),
              tooltip: 'Filter',
              onPressed: () {
                //openFilters();
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
            child: auth.loading ? Utility.showLoader() : Column(
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
      return Flexible(
          child: Container(
              padding: EdgeInsets.all(12.0),
              child: GridView.builder(
                itemCount: mMenus.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0
                ),
                itemBuilder: (BuildContext context, int index){
                  return mMenus[index];
                },
              )
          ),
      );
  }

  @override
  Widget build123(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'MontserratRegular'),
      home: Scaffold(
        body: ListView(
          children: <Widget>[
            IntrinsicHeight(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      child: Text(
                        "Coding step by step",
                        style: TextStyle(
                            fontSize: 28,
                            color: Colors.blueGrey[800],
                            fontFamily: 'MontserratBold'),
                      ),
                      padding: EdgeInsets.fromLTRB(10, 40, 0, 0),
                    ),
                    Padding(
                      child: Text(
                        "Programming is fun when it's learnt right",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.blueGrey[400],
                            fontFamily: 'MontserratRegular'),
                      ),
                      padding: EdgeInsets.fromLTRB(10, 8, 0, 30),
                    ),
                  ]),
            ),
            IntrinsicHeight(
              child: Row(children: [
                Flexible(
                  flex: 1,
                  child: CourseCard(
                      level: "All Projects",
                      title: "My Projects",
                      duration: "7-30 Days",
                      color: Color(0xff8E97FD),
                      textColor: Color(0xffFFECCC),
                      image: Image(
                        image: AssetImage('assets/icons/python.png'),
                      )),
                ),
                Flexible(
                  flex: 1,
                  child: CourseCard(
                      level: "BASIC",
                      title: "JavaScript",
                      duration: "12-35 Days",
                      color: Color(0xffFFC97E),
                      textColor: Color(0xff3F414E),
                      image: Image(
                        image: AssetImage('assets/icons/js.png'),
                      )),
                ),
              ]),
            ),
            IntrinsicHeight(
              child: Row(children: [
                Flexible(
                  flex: 1,
                  child: CourseCard(
                      level: "BASIC",
                      title: "CSS",
                      duration: "7-27 Days",
                      color: Color(0xffFA6E5A),
                      textColor: Color(0xffFFECCC),
                      image: Image(
                        image: AssetImage('assets/icons/css.png'),
                      )),
                ),
                Flexible(
                  flex: 1,
                  child: CourseCard(
                      level: "Crash Course",
                      title: "HTML",
                      duration: "1 Day",
                      color: Color(0xff6CB28E),
                      textColor: Color(0xffFFECCC),
                      image: Image(
                        image: AssetImage('assets/icons/html.png'),
                      )),
                ),
              ]),
            ),
            IntrinsicHeight(
              child: Row(children: [
                Flexible(
                  flex: 1,
                  child: HorizontalCard(
                      level: "BASIC",
                      title: "CSS",
                      color: Color(0xff3B3A55),
                      textColor: Color(0xffFFECCC),
                      image: Image(
                        image: AssetImage('assets/icons/bottom-cloud.png'),
                      ), duration: '',),
                ),
              ]),
            ),
            ListTile(
              leading: Icon(Icons.map),
              title: Text('Map'),
            ),
            ListTile(
              leading: Icon(Icons.map),
              title: Text('Map'),
            ),
            ListTile(
              leading: Icon(Icons.map),
              title: Text('Map'),
            ),
            ListTile(
              leading: Icon(Icons.map),
              title: Text('Map'),
            ),
            ListTile(
              leading: Icon(Icons.map),
              title: Text('Map'),
            ),
            ListTile(
              leading: Icon(Icons.map),
              title: Text('Map'),
            ),
            ListTile(
              leading: Icon(Icons.map),
              title: Text('Map'),
            ),
            ListTile(
              leading: Icon(Icons.map),
              title: Text('Map'),
            ),
            ListTile(
              leading: Icon(Icons.map),
              title: Text('Map'),
            ),
            ListTile(
              leading: Icon(Icons.map),
              title: Text('Map'),
            ),
            ListTile(
              leading: Icon(Icons.map),
              title: Text('Map'),
            ),
            ListTile(
              leading: Icon(Icons.map),
              title: Text('Map'),
            ),
            ListTile(
              leading: Icon(Icons.map),
              title: Text('Map'),
            ),
            ListTile(
              leading: Icon(Icons.map),
              title: Text('Map'),
            ),
            ListTile(
              leading: Icon(Icons.map),
              title: Text('Map'),
            ),
            ListTile(
              leading: Icon(Icons.map),
              title: Text('Map'),
            ),
            ListTile(
              leading: Icon(Icons.map),
              title: Text('Map'),
            ),
            ListTile(
              leading: Icon(Icons.map),
              title: Text('Map'),
            ),
          ],
        ),
        //body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        //   Padding(
        //     child: Text(
        //       "Coding step by step",
        //       style: TextStyle(
        //           fontSize: 28,
        //           color: Colors.blueGrey[800],
        //           fontFamily: 'MontserratBold'),
        //     ),
        //     padding: EdgeInsets.fromLTRB(10, 80, 0, 0),
        //   ),
        //   Padding(
        //     child: Text(
        //       "Programming is fun when it's learnt right",
        //       style: TextStyle(
        //           fontSize: 16,
        //           color: Colors.blueGrey[400],
        //           fontFamily: 'MontserratRegular'),
        //     ),
        //     padding: EdgeInsets.fromLTRB(10, 8, 0, 0),
        //   ),
        // ]

        //GridView.count(
        //    crossAxisCount: 2, children: [Text("Hi"), Text("Hello")])
        //]),
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  const CourseCard(
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
    return GestureDetector(
      onTap: (){
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => BPMSProjects()));
      },
      child: Container(
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
                    Padding(
                      child: Text(
                        level,
                        style: TextStyle(
                            fontSize: 28,
                            color: textColor,
                            fontFamily: 'MontserratBold'),
                      ),
                      padding: EdgeInsets.fromLTRB(18, 70, 0, 0),
                    ),
                    Padding(
                      child: Text(
                        title,
                        style: TextStyle(
                            fontSize: 18,
                            color: textColor,
                            fontFamily: 'MontserratLight'),
                      ),
                      padding: EdgeInsets.fromLTRB(15, 110, 0, 0),
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