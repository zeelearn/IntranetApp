import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intranet/pages/home/IntranetHomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../api/APIService.dart';
import '../../../api/request/login_request.dart';
import '../../../api/response/login_response.dart';
import '../../helper/LocalConstant.dart';
import '../../helper/constants.dart';
import '../../helper/utils.dart';
import '../PrivacyPolicyScreen.dart';

class LoginForm extends StatefulWidget  {

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> implements changePasswordInterface{
  //_LoginFormState({Key? key}) : super(key: key);

  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _repeatPasswordController;


  bool isChecked = false;
  bool isApiCallProcess = false;
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController userPasswordController = TextEditingController();

  @override
  void initState() {
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _repeatPasswordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  // void setState(Null Function() param0) {}

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            onSaved: (email) {},
            controller: userNameController,
            decoration: const InputDecoration(
              hintText: "Your User Name",
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.person),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            child: TextFormField(
              textInputAction: TextInputAction.done,
              obscureText: true,
              cursorColor: kPrimaryColor,
              controller: userPasswordController,
              decoration: const InputDecoration(
                hintText: "Your password",
                prefixIcon: Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.lock),
                ),
              ),
            ),
          ),
          Hero(
            tag: "login_btn",
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Material(
                  child: Checkbox(
                    value: isChecked,
                    onChanged: (value) {
                      //isChecked = value!;
                      setState(() {
                        isChecked = value!;
                      });
                    },
                  ),
                ),GestureDetector(
                  onTap: () {
                    if (kIsWeb) {
                      _launchURL();
                    } else {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) =>
                              PrivacyPolicyScreen()));
                    }
                  },
                  child: const Text(
                    'I have read and accept terms \nand conditions',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: defaultPadding),
          Hero(
            tag: "login_btn",
            child: ElevatedButton(
              onPressed: () {
                validate(context);
              },
              child: Text(
                "Login".toUpperCase(),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
        ],
      ),
    );
  }

  _launchURL() async {
    /*const url = 'https://www.kidzee.com/Home/PrivacyPolicy';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }*/
  }

  void validate(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    if(!isChecked){
      Utility.showMessage(context, "Please accept the Terms and Conditions");
    }else if (userNameController.text.toString() != "" &&
        userPasswordController.text.toString() != "") {
      Utility.showLoaderDialog(context);
      LoginRequestModel loginRequestModel = LoginRequestModel(
        userName: userNameController.text.toString(),
        password: userPasswordController.text.toString(),
      );
      //loginRequestModel.User_Name = 'F2354';
      //loginRequestModel.User_Password = 'Niharika#123';
      APIService apiService = APIService();
      apiService.login(loginRequestModel).then((value) {
        if (value != null) {
          setState(() {
            isApiCallProcess = false;
          });
          if(value==null || value.responseData==null){
            Utility.showMessage(context,'Invalid UserName/Password');
          }else if(value is LoginResponseInvalid){
            LoginResponseInvalid responseInvalid = value;
            Utility.showMessage(context, responseInvalid.responseData);
          }else {
            List<EmployeeDetails> infoList = value.responseData.employeeDetails;
            if (infoList == null || infoList.length <= 0) {
              Utility.showMessage(context, 'Invalid UserName/Password');
            } else {
              EmployeeDetails info = value.responseData.employeeDetails[0];
              // // Save an integer value to 'counter' key.
              prefs.setString(
                  LocalConstant.KEY_EMPLOYEE_ID, info.employeeId as String);
              prefs.setString(
                  LocalConstant.KEY_EMPLOYEE_CODE, info.employeeCode as String);
              prefs.setString(
                  LocalConstant.KEY_FIRST_NAME,
                  info.employeeFirstName as String);
              prefs.setString(
                  LocalConstant.KEY_LAST_NAME, info.employeeLastName as String);
              prefs.setString(
                  LocalConstant.KEY_DOJ, info.employeeDateOfJoining as String);
              prefs.setString(LocalConstant.KEY_EMP_SUPERIOR_ID,
                  info.employeeSuperiorId as String);
              prefs.setString(LocalConstant.KEY_DEPARTMENT,
                  info.employeeDepartmentName as String);
              prefs.setString(LocalConstant.KEY_DESIGNATION,
                  info.employeeDesignation as String);
              prefs.setString(
                  LocalConstant.KEY_EMAIL, info.employeeEmailId as String);
              prefs.setString(LocalConstant.KEY_CONTACT,
                  info.employeeContactNumber as String);
              prefs.setBool(LocalConstant.KEY_IS_ACTIVE, info.isActive);
              prefs.setBool(LocalConstant.KEY_ISCEO, info.isCEO);
              prefs.setBool(
                  LocalConstant.KEY_IS_BUSINESS_HEAD, info.isBusinessHead);
              prefs.setString(
                  LocalConstant.KEY_USER_NAME, info.userName as String);
              prefs.setString(
                  LocalConstant.KEY_USER_PASSWORD, info.userPassword as String);
              prefs.setString(
                  LocalConstant.KEY_DOB, info.employeeDateOfBirth as String);
              prefs.setString(
                  LocalConstant.KEY_GRADE, info.employeeGrade as String);
              prefs.setString(LocalConstant.KEY_DATE_OF_MARRAGE,
                  info.employeeDateOfMarriage as String);
              prefs.setString(
                  LocalConstant.KEY_LOCATION, info.employeeLocation as String);

              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        IntranetHomePage(userId: info.employeeId as String)),
              );
            }

          }

        } else {
          Navigator.pop(context);
          Utility.showMessage(context, "Invalid User Name and Password");
          print("null value");
        }
      });

    } else {
      userNameController.text='';
      userPasswordController.text='';
      Utility.showMessage(context, "Invalid User Name and Password");
    }
  }



  void changePassword(BuildContext context) async {

  }

  Future<void> _showAlertDialog(BuildContext context, String title, String content) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(content),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
                //Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void clearPasswordFields() {
    _currentPasswordController.text = '';
    _newPasswordController.text = '';
    _repeatPasswordController.text = '';
  }

  @override
  onChangePassword() {
    changePassword(context);
  }
}

class changePasswordInterface {
  onChangePassword(){}
  //String flag_image_url(){}
}
