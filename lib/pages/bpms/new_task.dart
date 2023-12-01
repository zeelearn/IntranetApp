import 'package:Intranet/api/request/bpms/newtask.dart';
import 'package:Intranet/api/response/bpms/bpms_status.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/APIService.dart';
import '../../api/response/bpms/newtask.dart';
import '../../api/response/bpms/project_task.dart';
import '../helper/LocalConstant.dart';
import '../helper/constants.dart';
import '../helper/utils.dart';
import '../iface/onClick.dart';
import '../utils/theme/colors/light_colors.dart';
import '../widget/button_widget.dart';
import '../widget/date_time/date_picker.dart';
import '../widget/form/form.dart';
import '../widget/form/form_section.dart';
import '../widget/form/options/dropdown.dart';
import '../widget/form/text/text_field.dart';
import '../widget/form/validators.dart';
import 'auth/data/providers/auth_provider.dart';
import 'bpms_projects.dart';

class InsertNewTask extends ConsumerStatefulWidget {
  ProjectTaskModel taskModel;
  InsertNewTask({Key? key,required this.taskModel}) : super(key: key);

  @override
  _NewTaskState createState() => _NewTaskState();
}

class _NewTaskState extends ConsumerState<InsertNewTask> implements onClickListener {

  bool isLoader =false;
  final formKey = GlobalKey<FormState>();
  String _status='Pending';
  String _title='';
  String _startDate='';
  String _endDate='';
  String _comments='';
  List<String> statusList=[];

  @override
  void initState() {
    super.initState();
    loadData();
    _startDate = Utility.convertShortDate(DateTime.now());
    _endDate = Utility.convertShortDate(DateTime.now());
  }

  loadData()async{
    await ref.read(authNotifierProvider.notifier).getStatus();
    final auth = ref.watch(authNotifierProvider);
    statusList.clear();
    statusList.addAll(getStatusNames(auth.statusList));
  }

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Color(0xffe9ebf0),
      appBar: AppBar(
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add New Task',style: LightColors.textHeaderStyle13Selected,),
            Text(widget.taskModel.path,style: LightColors.textHeaderStyle13Selected,),
          ],
        ),
        //<Widget>[]
        backgroundColor: kPrimaryLightColor,
        elevation: 50.0,

        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Center(
        child: isLoader ? Utility.showLoader() : Container(
          height: size.height,
          width: size.height,
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xff151f2c) : Colors.white,
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child:  FastForm(
                formKey: formKey,
                inputDecorationTheme: InputDecorationTheme(
                  disabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                    BorderSide(color: Colors.grey[700]!, width: 1),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(width: 2),
                  ),
                  errorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide:
                    BorderSide(color: Colors.red[500]!, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                children: _buildForm(context),
                /*onChanged: (value) {
                  // ignore: avoid_print
                  print('Form changed: ${value.toString()}');
                },*/
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<String> getStatusNames(List<ProjectStatusModel>? statusList){
    List<String> list = [];
    list.add('Select Status');
    if(_status.isEmpty)
      _status = 'Select Status';
    if(statusList!=null)
      for (int index = 0; index < statusList!.length; index++) {
        list.add(statusList![index].Status);
      }
    return list;
  }

  getStatus(List<ProjectStatusModel>? statusList){
    int status=0;
    for(int index=0;index<statusList!.length;index++){
      if(_status == statusList[index].Status){
        status = statusList[index].TaskStatusId;
        break;
      }
    }
    return status;
  }

  List<Widget> _buildForm(BuildContext context,) {
    final auth = ref.watch(authNotifierProvider);
    Size size = MediaQuery.of(context).size;
    return [
      FastFormSection(
        padding: const EdgeInsets.all(16.0),
        header: const Padding(
          padding: EdgeInsets.all(12.0),
          child: Text(
            'Add New Task',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
        ),
        children: [
          buildTextField('Enter Title', Icons.title, false, size, (value) => null, false,
            onChanged: (value){
              _title = value!;
              print('title changed ${value}');
            },),

          getStatusNames(auth.statusList).length>0 ? FastDropdown<String>(
            name: 'Status',
            labelText: 'Status',
            dropdownColor: Color(0xffF7F8F8),
            decoration: new InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding:
              EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
              hintText: "Hint here",
              fillColor: Color(0xffF7F8F8)
            ),
            items: statusList /*['Norway', 'Sweden', 'Finland', 'Denmark', 'Iceland']*/,
            initialValue: _status,
            onChanged: (value){
              _status = value!;
              print('status changed ${value}');
            },
          ) : SizedBox(height: 0,),
          FastDatePicker(
            name: 'date_picker',
            labelText: 'Start Date',
            firstDate: DateTime(1970),
            lastDate: DateTime(2040),
            backgroundColor: Color(0xffF7F8F8),
            decoration: new InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding:
                EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                hintText: "Hint here",
                fillColor: Color(0xffF7F8F8)
            ),
            onChanged: (value){
              print('date changed ${value}');
              _startDate = Utility.convertShortDate(value!);
            },
          ),
          SizedBox(height: 15,),
          FastDatePicker(
            name: 'date_picker',
            labelText: 'end Date',
            firstDate: DateTime(1970),
            lastDate: DateTime(2040),
            backgroundColor: Color(0xffF7F8F8),
            decoration: new InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding:
                EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                hintText: "Hint here",
                fillColor: Color(0xffF7F8F8)
            ),
            onChanged: (value){
              print('date changed ${value}');
              _endDate = Utility.convertShortDate(value!);
            },
          ),
          FastTextField(
            name: 'comments',
            labelText: 'Comments',
            placeholder: 'Comments',
            minLines: 1,
            maxLines: 5,
            keyboardType: TextInputType.text,
            maxLength: 200,
            prefix: const Icon(Icons.message),
            buildCounter: inputCounterWidgetBuilder,
            inputFormatters: const [],
            validator: Validators.compose([
              Validators.required((value) => 'Field is required'),
              Validators.minLength(
                  2,
                      (value, minLength) =>
                  'Field must contain at least $minLength characters')
            ]),
            onChanged: (value){
              print('comments changed ${value}');
              _comments = value!;
            },
          ),
        ],
      ),
      Padding(
        padding: EdgeInsets.only(top: size.height * 0.025),
        child: ButtonWidget(
            text: 'Add New Task',
            backColor: const [Color(0xff92A3FD), Color(0xff9DCEFF)],
            textColor: const [
              Colors.white,
              Colors.white,
            ],
            onPressed: () async {
              print('Status Name ${_status}');
              if(_title.isEmpty){
                Utility.showMessage(context, 'Please Select the Title');
              }else if(_status.isEmpty || _status=='Select Status'){
                Utility.showMessage(context, 'Please Select the Task Status');
              }else if(_startDate.isEmpty){
                Utility.showMessage(context, 'Please Select the Task Start Date');
              }else if(_endDate.isEmpty){
                Utility.showMessage(context, 'Please Select the Task End Date');
              }/*else if(true){
                onClick(1, 'value');
              }*/else{
                var box = await Utility.openBox();
                int userId = box.get(LocalConstant.KEY_FRANCHISEE_ID) as int;
                NewTaskRequest request = NewTaskRequest(taskid: 0,
                    mtaskId: 0,
                    projectId: widget.taskModel.projectId,
                    title: _title,
                    note: _comments,
                    startDate: _startDate.isEmpty
                        ? Utility.getServerDate()
                        : _startDate,
                    endDate: _endDate.isEmpty
                        ? Utility.getServerDate()
                        : _endDate,
                    pStartDate: _startDate.isEmpty
                        ? Utility.getServerDate()
                        : _startDate,
                    pEndDate: _endDate.isEmpty
                        ? Utility.getServerDate()
                        : _endDate,
                    status:  getStatus(auth.statusList),
                    formurl: '',
                    parentTaskId: widget.taskModel.id,
                    dependentTaskId: 0, contributionId: 3,
                    UserId: userId);
                //await ref.read(authNotifierProvider.notifier).addNewTask(request);
                addNewTask(request);

              }
            }),
      ),
    ];
  }

  addNewTask(NewTaskRequest request) {
    Utility.showLoaderDialog(context);
    APIService apiService = APIService();
    apiService.addNewTask(request).then((value) {
      debugPrint(value.toString());
      Navigator.of(context).pop();
      if (value != null) {
        if (value == null) {
          Utility.showMessage(context, 'data not found');
        } else if (value is AddNewTaskResponse) {
          AddNewTaskResponse response = value;
          if (response != null) {
            Utility.showMessageSingleButton(context, 'Task has been added successfully', this);
          }
          setState(() {});
        } else {
          Utility.showMessage(context, 'Unable to upload the Task, Please try again');
        }
      }

      setState(() {});
    });
  }

  bool pwVisible = false;
  Widget buildTextField(
      String hintText,
      IconData icon,
      bool password,
      size,
      FormFieldValidator validator,
      bool isDarkMode, {required Function(dynamic value) onChanged}
      ) {
    return Padding(
      padding: EdgeInsets.only(top: size.height * 0.025),
      child: Container(
        width: size.width * 0.91,
        height: size.height * 0.06,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.black : const Color(0xffF7F8F8),
          borderRadius: const BorderRadius.all(Radius.circular(0)),
        ),
        child: TextFormField(
            style: TextStyle(
                color: isDarkMode ? const Color(0xffADA4A5) : Colors.black),
            onChanged: onChanged,
            validator: validator,
            textInputAction: TextInputAction.next,
            obscureText: password ? !pwVisible : false,
            decoration: InputDecoration(
              errorStyle: const TextStyle(height: 0),
              hintStyle: const TextStyle(
                color: Color(0xffADA4A5),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(
                top: size.height * 0.02,
              ),
              hintText: hintText,
              prefixIcon: Padding(
                padding: EdgeInsets.only(
                  top: size.height * 0.005,
                ),
                child: Icon(
                  icon,
                  color: const Color(0xff7B6F72),
                ),
              ),
              suffixIcon: password
                  ? Padding(
                padding: EdgeInsets.only(
                  top: size.height * 0.005,
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      pwVisible = !pwVisible;
                    });
                  },
                  child: pwVisible
                      ? const Icon(
                    Icons.visibility_off_outlined,
                    color: Color(0xff7B6F72),
                  )
                      : const Icon(
                    Icons.visibility_outlined,
                    color: Color(0xff7B6F72),
                  ),
                ),
              )
                  : null,
            ),
          ),
      ),
    );
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> buildSnackError(
      String error, context, size) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.black,
        content: SizedBox(
          height: size.height * 0.02,
          child: Center(
            child: Text(error),
          ),
        ),
      ),
    );
  }

  @override
  void onClick(int action, value) {
    Navigator.of(context).pop();
    /*Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => BPMSProjects()));*/
  }
}
