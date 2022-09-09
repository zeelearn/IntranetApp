import 'dart:ui';

import 'package:flutter/material.dart';

class LocalConstant {

  static const kDefaultSpacing = 20.0;

  static const String KidzeeDB = "kidzeepref";
  static const String DEF_AVTAR = 'https://cdn-icons-png.flaticon.com/128/847/847969.png';

  static const String KEY_ISLOGGEDIN = "islogin";
  static const String KEY_IS_OTP_VERIFIED = "isotpverified";
  static const String KEY_USER_NAME = "uname";
  static const String KEY_USER_PASSWORD = "password";
  static const String KEY_EMPLOYEE_ID = "empid";
  static const String KEY_EMPLOYEE_CODE = "employee_Code";
  static const String KEY_FIRST_NAME = "employee_FirstName";
  static const String KEY_LAST_NAME = "employee_LastName";
  static const String KEY_DOJ = "employee_doj";
  static const String KEY_DOB = "employee_dob";
  static const String KEY_EMP_SUPERIOR_ID = "employee_SuperiorId";
  static const String KEY_DEPARTMENT = "employee_DepartmentName";
  static const String KEY_DESIGNATION = "desg";
  static const String KEY_EMAIL = "email";
  static const String KEY_GENDER = "gender";
  static const String KEY_CONTACT = "contact";
  static const String KEY_IS_ACTIVE = "isactive";
  static const String KEY_ISCEO = "isceo";
  static const String KEY_IS_BUSINESS_HEAD = "business_head";
  static const String KEY_GRADE = "grade";
  static const String KEY_ZONE = "zone";
  static const String KEY_DATE_OF_MARRAGE= "marrage_date";
  static const String KEY_LOCATION = "location";


  static const String KEY_AUTH_TOKEN = "authtoken";

  static const kPrimaryColor = Color(0xFFE57373);
  static const kBackgroundColor = Color(0xFFFFCDD2);
  static const kTopBackgroundColor = Color(0XFFFCE4EC);

  static const FB_ACTIVITY_PLANNER = "tActivity";
  static const FB_ACTIVITY_RHYMES = "klt_db";

  //Colors for theme
  static Color lightPrimary = Color(0xfffcfcff);
  static Color darkPrimary = Colors.black;
  static Color lightAccent = Color(0xff5563ff);
  static Color darkAccent = Color(0xff5563ff);
  static Color lightBG = Color(0xfffcfcff);
  static Color darkBG = Colors.black;
  static Color? ratingBG = Colors.yellow[600];


  static String TABLE_NOTIFICATION ="notification";
  static String TABLE_EMPLOYEES ="emp_info";
  static String TABLE_PARENT_INFO ="parent_info";
  static String TABLE_PJP_INFO ="pjp_info";
  static String TABLE_PJP_CENTERS_DETAILS ="pjp_center_details";

  static String TABLE_CVF_CATEGORY ="cvf_category";
  static String TABLE_PJP_PURPOSE ="pjp_purpose";
  static String TABLE_CVF_QUESTIONS ="cvf_questions";
  static String TABLE_CVF_ANSWER_MASTER ="cvf_answermaster";
  static String TABLE_CVF_FRANCHISEE ="cvf_centers";



}
