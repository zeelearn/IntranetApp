import 'dart:ui';

import 'package:flutter/material.dart';

class LocalConstant {

  static const kDefaultSpacing = 20.0;

  static const String ACTION_PDF = 'pdf';
  static const String NOTIFICATION_CHANNEL = 'Intranet';
  static const String ACTION_GALLERY = 'Gallery';
  static const String ACTION_CAMERA = 'Camera';
  static const String ACTION_UPDATE_STATUS = 'Update Status';
  static const int ACTION_USER_EVENT = 100;

  static const String KidzeeDB = "kidzeepref";
  static const String DEF_AVTAR = 'https://cdn-icons-png.flaticon.com/128/847/847969.png';

  static const String KEY_COUNTER = "counter";
  static const String KEY_ISLOGGEDIN = "islogin";
  static const String KEY_UID = "uid";
  static const String KEY_FRANCHISEE_ID = "franid";
  static const String KEY_IS_OTP_VERIFIED = "isotpverified";
  static const String KEY_USER_NAME = "uname";
  static const String KEY_USER_PASSWORD = "password";
  static const String KEY_EMPLOYEE_ID = "empid";
  static const String KEY_EMPLOYEE_AVTAR = "empavtar";
  static const String KEY_EMPLOYEE_AVTAR_LIST = "empavtar_list";
  static const String KEY_FCM_ID = "fcmid";
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
  static const String KEY_LOGIN_RESPONSE ="loginresponse";
  static const String KEY_BUSINESS_ID ="bid";
  static const String KEY_BUSINESS_NAME ="bname";
  static const String KEY_SYNC_INTERVAL = "syncinterval";

  static const String KEY_CVF_QUESTIONS = "_cvfques";
  static const String KEY_MY_ATTENDANCE = "attend";
  static const String KEY_MY_LEAVE = "leave";
  static const String KEY_MY_OUTDOOR = "od";
  static const String KEY_MY_PJP = "mypjp";
  static const String KEY_MY_CVF = "mycvf";


  static const String KEY_AUTH_TOKEN = "authtoken";


  static const int ACTION_BACK = 999;

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


  static String TABLE_NOTIFICATION ="usernotification";
  static String TABLE_CHECKIN ="checkin";
  static String TABLE_EMPLOYEES ="emp_info";
  static String TABLE_PARENT_INFO ="parent_info";
  static String TABLE_PJP_INFO ="pjp_info";
  static String TABLE_PJP_CENTERS_DETAILS ="pjp_center_details";

  static String TABLE_CVF_CATEGORY ="cvf_category";
  static String TABLE_PJP_PURPOSE ="pjp_purpose";

  static String TABLE_CVF_QUESTIONS ="cvf_questions";
  static String TABLE_CVF_QUESTION_JSON ="cvfquestion";

  static String TABLE_CVF_ANSWER_MASTER ="cvf_answermaster";
  static String TABLE_CVF_USER_ANSWERAS ="cvf_user_answers";
  static String TABLE_CVF_FRANCHISEE ="cvf_centers";
  static String TABLE_DATA_SYNC ="data_sync";


  // storage keys
  static const authStorageKey = 'auth';
  static const communicationKey = 'commu';
  static const taskKey = 'task';
  static const indent = 'indent';
  static const projects = 'projects';
  static const projectbystatus = 'projectbystatus';
  static const projecttask = 'projectstask';


  static const int ALL_PROJECT = 100;
  static const int MY_PROJECT = 0;
  static const int PENDING_PROJECT = 1;
  static const int INPROGRESS_PROJECT = 2;
  static const int COMPLETED_PROJECT = 4;

}
