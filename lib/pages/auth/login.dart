import 'dart:convert';

import 'package:Intranet/pages/firebase/anylatics.dart';
import 'package:Intranet/pages/widget/MyWebSiteView.dart';
import 'package:Intranet/pages/widget/MyWidget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../api/APIService.dart';
import '../../api/request/login_request.dart';
import '../../api/response/login_response.dart';
import '../helper/LightColor.dart';
import '../helper/LocalConstant.dart';
import '../helper/utils.dart';
import '../home/IntranetHomePage.dart';
import '../login/PrivacyPolicyScreen.dart';

class LoginPage extends StatefulWidget {
  bool isAutoLogin;
  LoginPage({required this.isAutoLogin, Key? key}) : super(key: key);

  @override
  _LoginPage createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
/*class LoginPage extends StatelessWidget {*/
  //LoginPage({Key? key}) : super(key: key);

  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _userPasswordController = TextEditingController();

  bool isChecked = false;
  bool isApiCallProcess = false;

  String appVersion = '';
  bool passwordVisible = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    passwordVisible = true;
    Future.delayed(Duration.zero, () {
      getDeviceInfo();
      if (widget.isAutoLogin) {
        autoLogin();
      } else {
        setState(() {});
      }
    });
  }

  autoLogin() async {
    var box = await Utility.openBox();
    _userNameController.text = box.get(LocalConstant.KEY_USER_NAME) as String;
    _userPasswordController.text =
        box.get(LocalConstant.KEY_USER_PASSWORD) as String;
    isChecked = true;
    validate(context);
  }

  Future<void> getDeviceInfo() async {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      String appName = packageInfo.appName;
      String packageName = packageInfo.packageName;
      String version = packageInfo.version;
      String buildNumber = packageInfo.buildNumber;
      appVersion = version;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        Container(
          color: Colors.white, // Your screen background color
        ),
        Scaffold(
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 30, right: 30, top: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //logo section
                  logo(50, 50),
                  SizedBox(
                    height: size.height * 0.07,
                  ),
                  richText(20),
                  SizedBox(
                    height: size.height * 0.03,
                  ),

                  //email & password section
                  /*emailTextField(size),*/
                  MyWidget().normalTextField(
                      context, 'UserName', _userNameController),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  passwordTextField(size, _userPasswordController),

                  SizedBox(
                    height: size.height * 0.02,
                  ),

                  Row(
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
                                    MyWebsiteView(
                                      url: 'https://kidzee.com/PrivacyPolicy',
                                      title: 'Privacy Policy',
                                    )));
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

                  //sign in button & sign in with text
                  signInButton(size),

                  //sign up text here
                  Center(
                    child: footerText(),
                  )
                ],
              ),
            ),
          ),
          bottomNavigationBar: Utility.footer(appVersion),
        ),
        Positioned(
          top: 0.0,
          left: 0.0,
          right: 0.0,
          child: AppBar(
            title: const Text(''), // You can add title here
            /*leading: new IconButton(
              icon: new Icon(Icons.arrow_back_ios, color: Colors.grey),
              onPressed: () => Navigator.of(context).pop(),
            ),*/
            backgroundColor: Colors.transparent, //You can make this transparent
            elevation: 0.0, //No shadow
          ),
        ),
      ],
    );
  }

  _launchURL() async {
    const url = 'https://www.kidzee.com/Home/PrivacyPolicy';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget logo(double height_, double width_) {
    return Image.asset(
      'assets/icons/app_logo.png',
      width: 150,
    ); /*SvgPicture.asset(
      'assets/icons/app_logo.png',
      height: height_,
      width: width_,
    );*/
  }

  Widget richText(double fontSize) {
    return Text.rich(
      TextSpan(
        style: GoogleFonts.inter(
          fontSize: fontSize,
          color: LightColor.titleTextColor,
          letterSpacing: 2,
          height: 1.03,
        ),
        children: const [
          TextSpan(
            text: 'INTRA',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(
            text: 'NET',
            style: TextStyle(
              color: LightColor.primarydark_color,
              fontWeight: FontWeight.w800,
            ),
          ),
          /*TextSpan(
            text: 'KIT',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),*/
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget emailTextField(Size size) {
    return Container(
      alignment: Alignment.center,
      height: size.height / 11,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          width: 1.0,
          color: const Color(0xFFEFEFEF),
        ),
      ),
      child: TextField(
        style: GoogleFonts.inter(
          fontSize: 16.0,
          color: const Color(0xFF15224F),
        ),
        maxLines: 1,
        cursorColor: const Color(0xFF15224F),
        decoration: InputDecoration(
            labelText: 'Email/ Phone number',
            labelStyle: GoogleFonts.inter(
              fontSize: 12.0,
              color: const Color(0xFF969AA8),
            ),
            border: InputBorder.none),
      ),
    );
  }

  Widget passwordTextField(Size size, TextEditingController controller) {
    return Container(
      alignment: Alignment.center,
      height: size.height / 14,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          width: 1.0,
          color: LightColor.primary_color,
        ),
      ),
      child: TextField(
        obscureText: passwordVisible,
        controller: controller,
        style: GoogleFonts.inter(
          fontSize: 20.0,
          color: LightColor.primarydark_color,
        ),
        maxLines: 1,
        keyboardType: TextInputType.visiblePassword,
        cursorColor: const Color(0xFF15224F),
        decoration: InputDecoration(
            prefixIcon: const Icon(Icons.password),
            suffixIcon: IconButton(
              icon: Icon(
                  passwordVisible ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(
                  () {
                    debugPrint('password visibility $passwordVisible');
                    passwordVisible = !passwordVisible;
                  },
                );
              },
            ),
            alignLabelWithHint: false,
            filled: true,
            labelText: 'Password',
            labelStyle: GoogleFonts.inter(
              fontSize: 12.0,
              color: LightColor.black,
            ),
            border: InputBorder.none),
      ),
    );
  }

  Widget signInButton(Size size) {
    return GestureDetector(
      onTap: () {
        validate(context);
      },
      child: Container(
        alignment: Alignment.center,
        height: size.height / 14,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50.0),
          color: LightColor.primary_color,
          boxShadow: const [
            BoxShadow(
              color: LightColor.seeBlue,
              offset: Offset(0, 5.0),
              blurRadius: 10.0,
            ),
          ],
        ),
        child: Text(
          'Login',
          style: GoogleFonts.inter(
            fontSize: 16.0,
            color: LightColor.black,
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void validate(BuildContext context) async {
    if (!isChecked) {
      Utility.showMessage(context, "Please accept the Terms and Conditions 1");
    } else if (_userNameController.text.toString() != "" &&
        _userPasswordController.text.toString() != "") {
      Utility.showLoaderDialog(context);
      LoginRequestModel loginRequestModel = LoginRequestModel(
        userName: _userNameController.text.toString(),
        password: _userPasswordController.text.toString(),
      );
      //loginRequestModel.User_Name = 'F2354';
      //loginRequestModel.User_Password = 'Niharika#123';
      APIService apiService = APIService();
      apiService.login(loginRequestModel).then((value) async {
        debugPrint(value.toString());
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
              await Hive.openBox(LocalConstant.KidzeeDB);
              var hive = Hive.box(LocalConstant.KidzeeDB);
              // // Save an integer value to 'counter' key.
              hive.put(LocalConstant.KEY_EMPLOYEE_ID,
                  info.employeeId.toInt().toString());
              hive.put(LocalConstant.KEY_EMPLOYEE_CODE, info.employeeCode);
              hive.put(LocalConstant.KEY_FIRST_NAME, info.employeeFirstName);
              hive.put(LocalConstant.KEY_LAST_NAME, info.employeeLastName);
              hive.put(LocalConstant.KEY_DOJ, info.employeeDateOfJoining);
              hive.put(LocalConstant.KEY_EMP_SUPERIOR_ID,
                  info.employeeSuperiorId.toInt().toString());
              hive.put(
                  LocalConstant.KEY_DEPARTMENT, info.employeeDepartmentName);
              hive.put(LocalConstant.KEY_DESIGNATION, info.employeeDesignation);
              hive.put(LocalConstant.KEY_EMAIL, info.employeeEmailId);
              hive.put(LocalConstant.KEY_CONTACT, info.employeeContactNumber);
              hive.put(LocalConstant.KEY_IS_ACTIVE, info.isActive);
              hive.put(LocalConstant.KEY_ISCEO, info.isCEO);
              hive.put(LocalConstant.KEY_IS_BUSINESS_HEAD, info.isBusinessHead);
              hive.put(LocalConstant.KEY_USER_NAME, info.userName);
              hive.put(LocalConstant.KEY_USER_PASSWORD, info.userPassword);
              hive.put(LocalConstant.KEY_DOB, info.employeeDateOfBirth);
              hive.put(LocalConstant.KEY_GRADE, info.employeeGrade);
              hive.put(LocalConstant.KEY_DATE_OF_MARRAGE,
                  info.employeeDateOfMarriage);
              hive.put(LocalConstant.KEY_LOCATION, info.employeeLocation);
              hive.put(LocalConstant.KEY_GENDER, info.gender);

              FirebaseAnalyticsUtils.sendEvent(info.userName);
              hive.put(LocalConstant.KEY_LOGIN_RESPONSE, jsonEncode(value));
              debugPrint('========Login Form ====== ${jsonEncode(value)}');
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => IntranetHomePage(
                        userId: info.employeeId.toInt().toString())),
              );
            }
          }
        } else {
          Navigator.pop(context);
          Utility.showMessage(context, "Invalid User Name and Password");
          debugPrint("null value");
        }
      });
    } else {
      _userNameController.text = '';
      _userPasswordController.text = '';
      Utility.showMessage(context, "Invalid User Name and Password");
    }
  }

  Widget signInWithText() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: Divider()),
        SizedBox(
          width: 16,
          height: 20,
        ),
        /*Text(
          'Or Sign in with',
          style: GoogleFonts.inter(
            fontSize: 12.0,
            color: LightColor.grey,
          ),
          textAlign: TextAlign.center,
        ),*/
        SizedBox(
          width: 16,
        ),
        Expanded(child: Divider()),
      ],
    );
  }

  //sign up text here
  Widget footerText() {
    return Text.rich(
      TextSpan(
        style: GoogleFonts.inter(
          fontSize: 12.0,
          color: const Color(0xFF3B4C68),
        ),
        children: const [
          TextSpan(
            text: '',
          ),
          TextSpan(
            text: ' ',
            style: TextStyle(
              color: Color(0xFF21899C),
            ),
          ),
          /*TextSpan(
            text: 'Forgot Password',
            style: TextStyle(
              color: Color(0xFF21899C),
              fontWeight: FontWeight.w700,
            ),
          ),*/
        ],
      ),
    );
  }
}
