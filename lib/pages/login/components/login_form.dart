import 'dart:convert';

import 'package:Intranet/pages/home/IntranetHomePage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../../api/APIService.dart';
import '../../../api/request/login_request.dart';
import '../../../api/response/login_response.dart';
import '../../helper/LocalConstant.dart';
import '../../helper/constants.dart';
import '../../helper/utils.dart';
import '../PrivacyPolicyScreen.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm>
    implements changePasswordInterface {
  //_LoginFormState({Key? key}) : super(key: key);

  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _repeatPasswordController;

  bool isChecked = false;
  bool isApiCallProcess = false;
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController userPasswordController = TextEditingController();

  bool passwordVisible = false;

  @override
  void initState() {
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _repeatPasswordController = TextEditingController();
    super.initState();
    passwordVisible = true;
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
                padding: EdgeInsets.zero,
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
              decoration: InputDecoration(
                hintText: "Your password",
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.lock),
                ),
                suffixIcon: IconButton(
                  icon: Icon(passwordVisible
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () {
                    setState(
                      () {
                        passwordVisible = !passwordVisible;
                      },
                    );
                  },
                ),
                alignLabelWithHint: false,
                filled: true,
              ),
              keyboardType: TextInputType.visiblePassword,
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
                ),
                GestureDetector(
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
    var hiveBox = await Utility.openBox();
    await Hive.openBox(LocalConstant.KidzeeDB);

    if (!isChecked) {
      Utility.showMessage(context, "Please accept the Terms and Conditions");
    } else if (userNameController.text.toString() != "" &&
        userPasswordController.text.toString() != "") {
      //Utility.showLoaderDialog(context);
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
          if (value == null || value.responseData == null) {
            Utility.showMessage(context, 'Invalid UserName/Password');
          } else if (value is LoginResponseInvalid) {
            LoginResponseInvalid responseInvalid = value;
            Utility.showMessage(context, responseInvalid.responseData);
          } else {
            List<EmployeeDetails> infoList = value.responseData.employeeDetails;

            if (infoList.isEmpty) {
              Utility.showMessage(context, 'Invalid UserName/Password');
            } else {
              EmployeeDetails info = value.responseData.employeeDetails[0];

              //// Save an integer value to 'counter' key.
              hiveBox.put(
                  LocalConstant.KEY_EMPLOYEE_ID, info.employeeId as String);
              hiveBox.put(LocalConstant.KEY_EMPLOYEE_CODE, info.employeeCode);
              hiveBox.put(LocalConstant.KEY_FIRST_NAME, info.employeeFirstName);
              hiveBox.put(LocalConstant.KEY_LAST_NAME, info.employeeLastName);
              hiveBox.put(LocalConstant.KEY_DOJ, info.employeeDateOfJoining);
              hiveBox.put(LocalConstant.KEY_EMP_SUPERIOR_ID,
                  info.employeeSuperiorId as String);
              hiveBox.put(
                  LocalConstant.KEY_DEPARTMENT, info.employeeDepartmentName);
              hiveBox.put(
                  LocalConstant.KEY_DESIGNATION, info.employeeDesignation);
              hiveBox.put(LocalConstant.KEY_EMAIL, info.employeeEmailId);
              hiveBox.put(
                  LocalConstant.KEY_CONTACT, info.employeeContactNumber);
              hiveBox.put(LocalConstant.KEY_IS_ACTIVE, info.isActive);
              hiveBox.put(LocalConstant.KEY_ISCEO, info.isCEO);
              hiveBox.put(
                  LocalConstant.KEY_IS_BUSINESS_HEAD, info.isBusinessHead);
              hiveBox.put(LocalConstant.KEY_USER_NAME, info.userName);
              hiveBox.put(LocalConstant.KEY_USER_PASSWORD, info.userPassword);
              hiveBox.put(LocalConstant.KEY_DOB, info.employeeDateOfBirth);
              hiveBox.put(LocalConstant.KEY_GRADE, info.employeeGrade);
              hiveBox.put(LocalConstant.KEY_DATE_OF_MARRAGE,
                  info.employeeDateOfMarriage);
              hiveBox.put(LocalConstant.KEY_LOCATION, info.employeeLocation);

              hiveBox.put(LocalConstant.KEY_LOGIN_RESPONSE,
                  jsonEncode(value.responseData));

              List<BusinessApplications> businessapplications =
                  value.responseData.businessApplications;
              if (businessapplications.isNotEmpty) {
                hiveBox.put(LocalConstant.KEY_BUSINESS_USERID,
                    businessapplications[0] as String);
              }
              debugPrint('-------------------------LOGINFORM');
              debugPrint(jsonEncode(value.responseData));
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
          Utility.showMessage(context, "Invalid User Name and Password 235");
          debugPrint("null value");
        }
      });
    } else {
      userNameController.text = '';
      userPasswordController.text = '';
      Utility.showMessage(context, "Invalid User Name and Password 243");
    }
  }

  void changePassword(BuildContext context) async {}

  Future<void> _showAlertDialog(
      BuildContext context, String title, String content) {
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
              child: const Text('Ok'),
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
  onChangePassword() {}
  //String flag_image_url(){}
}
