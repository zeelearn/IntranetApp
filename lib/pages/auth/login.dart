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
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1100;
    final bool isTablet = width >= 600 && width < 1100;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(children: [
        if (isDesktop || isTablet)
          Expanded(
            flex: isDesktop ? 3 : 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    LightColor.primarydark_color,
                    LightColor.primary_color,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: logo(100, 100),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        "Unified Employee Portal",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: isDesktop ? 40 : 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Access your attendance, leave, and journey planning in one place.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        Expanded(
          flex: 2,
          child: Container(
            color: Colors.white,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!isDesktop && !isTablet) ...[
                        Center(child: logo(80, 80)),
                        const SizedBox(height: 30),
                      ],
                      Text(
                        "Welcome",
                        style: GoogleFonts.inter(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E293B),
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Please enter your details to sign in.",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        "User Name",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _userNameController,
                        hintText: "Enter your username",
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Password",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 8),
                      passwordTextField(
                          MediaQuery.of(context).size, _userPasswordController),
                      const SizedBox(height: 24),
                      _buildTermsAndConditions(),
                      const SizedBox(height: 32),
                      signInButton(MediaQuery.of(context).size),
                      const SizedBox(height: 24),
                      Center(child: footerText()),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
      bottomNavigationBar: Utility.footer(appVersion),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF1E293B)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
        prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: LightColor.primary_color, width: 2),
        ),
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    return Row(
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: isChecked,
            activeColor: LightColor.primary_color,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: (value) {
              setState(() {
                isChecked = value!;
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (kIsWeb) {
                _launchURL();
              } else {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => MyWebsiteView(
                          url: 'https://kidzee.com/PrivacyPolicy',
                          title: 'Privacy Policy',
                        )));
              }
            },
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(
                    fontSize: 14, color: const Color(0xFF64748B)),
                children: [
                  const TextSpan(text: 'I have read and accept '),
                  TextSpan(
                    text: 'terms and conditions',
                    style: TextStyle(
                      color: LightColor.primarydark_color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  _launchForgotPasswordURL() async {
    const url = 'https://intranet.zeelearn.com/ForgotPassword.aspx';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
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
      width: width_,
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
    return TextFormField(
      obscureText: passwordVisible,
      controller: controller,
      style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF1E293B)),
      keyboardType: TextInputType.visiblePassword,
      decoration: InputDecoration(
        hintText: "••••••••",
        hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
        prefixIcon:
            const Icon(Icons.lock_outline, color: Color(0xFF64748B), size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            passwordVisible ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xFF64748B),
            size: 20,
          ),
          onPressed: () => setState(() => passwordVisible = !passwordVisible),
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: LightColor.primary_color, width: 2),
        ),
      ),
    );
  }

  Widget signInButton(Size size) {
    return GestureDetector(
      onTap: () {
        validate(context);
      },
      child: ElevatedButton(
        onPressed: () => validate(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: LightColor.primary_color,
          foregroundColor: LightColor.black,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          'Sign In',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  void validate(BuildContext context) async {
    if (!isChecked) {
      Utility.showMessage(context, "Please accept the Terms and Conditions");
    } else if (!await Utility.isInternet()) {
      Utility.showMessage(context,
          "Internet Connectivity not avaliable, please check internet and try again");
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
        Navigator.pop(context);
        debugPrint(value.toString());
        // if (value != null) {
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
            hive.put(LocalConstant.KEY_DEPARTMENT, info.employeeDepartmentName);
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
            hive.put(
                LocalConstant.KEY_DATE_OF_MARRAGE, info.employeeDateOfMarriage);
            hive.put(LocalConstant.KEY_LOCATION, info.employeeLocation);
            hive.put(LocalConstant.KEY_GENDER, info.gender);
            hive.put(LocalConstant.KEY_MANAGER_NAME, info.managerName);
            hive.put(LocalConstant.KEY_PASSWORD_EXPIRED, info.passwordExpired);
            hive.put(LocalConstant.KEY_EMP_TYPE, info.employeeRoleName);

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
        // } else {
        //   Navigator.pop(context);
        //   Utility.showMessage(context, "Invalid User Name and Password");
        //   debugPrint("null value");
        // }
      });
    } else {
      _userNameController.text = '';
      _userPasswordController.text = '';
      Utility.showMessage(context, "Invalid User Name and Password");
    }
  }

  //sign up text here
  Widget footerText() {
    return GestureDetector(
      onTap: () {
        _launchForgotPasswordURL();
      },
      child: Text(
        'Forgot Password?',
        style: GoogleFonts.inter(
          fontSize: 14.0,
          color: const Color(0xFF21899C),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
