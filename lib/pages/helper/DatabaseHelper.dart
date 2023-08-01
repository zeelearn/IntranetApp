import 'dart:async';
import 'dart:convert';
import 'package:intranet/pages/helper/utils.dart';
import 'package:intranet/pages/model/NotificationDataModel.dart';
import 'package:intranet/pages/pjp/models/PJPCenterDetails.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqflite.dart';

import '../../api/request/leave/leave_approve_request.dart';
import '../../api/response/cvf/QuestionResponse.dart';
import '../../api/response/cvf/centers_respinse.dart';
import '../../api/response/pjp/pjplistresponse.dart';
import '../pjp/cvf/CheckInModel.dart';
import '../pjp/models/PjpModel.dart';
import 'DBConstant.dart';
import 'DatabaseHelper.dart';
import 'LocalConstant.dart';


/*
 * Created by AbedElaziz Shehadeh on 1st March, 2020
 * elaziz.shehadeh@gmail.com
 */
class DBHelper {
  static final DBHelper _instance = DBHelper._internal();

  factory DBHelper() => _instance;

  var _db;

  static String CREATE_TABLE_NOTIFICATION = 'CREATE TABLE IF NOT EXISTS  ${LocalConstant.TABLE_NOTIFICATION}'
      '(notification_id TEXT PRIMARY KEY, '
      'title TEXT, '
      'type TEXT, '
      'notification TEXT, '
      'data TEXT, '
      'isseen int, '
      'imageurl TEXT, '
      'date TEXT)';

  static String CREATE_TABLE_CHECKIN = 'CREATE TABLE IF NOT EXISTS  ${LocalConstant.TABLE_CHECKIN}'
      '(${DBConstant.ID} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      '${DBConstant.CVF_ID} TEXT, '
      '${DBConstant.STATE} TEXT, '
      'body TEXT, '
      '${DBConstant.IS_SYNC} int, '
      'date TEXT)';

  static String CREATE_TABLE_PJP_MASTER = 'CREATE TABLE IF NOT EXISTS  ${LocalConstant.TABLE_PJP_INFO}'
      '(${DBConstant.ID} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      '${DBConstant.DATE} TEXT, '
      '${DBConstant.FROM_DATE} TEXT, '
      '${DBConstant.TO_DATE} TEXT, '
      '${DBConstant.REMARK} TEXT, '
      '${DBConstant.VISIT_TYPE} TEXT, '
      '${DBConstant.IS_SYNC} INT, '
      '${DBConstant.IS_DELETE} INT, '
      '${DBConstant.IS_ACTIVE} INT, '
      '${DBConstant.IS_CHECK_IN} INT, '
      '${DBConstant.IS_CHECK_OUT} INT, '
      '${DBConstant.IS_CVF_COMPLETED} INT, '
      '${DBConstant.EMP_CODE} TEXT, '
      '${DBConstant.MODIFIED_DATE} TEXT, '
      '${DBConstant.CREATED_DATE} TEXT)';



  static String CREATE_TABLE_PJP_CENTER_DETAILS = 'CREATE TABLE IF NOT EXISTS  ${LocalConstant.TABLE_PJP_CENTERS_DETAILS}'
      '(${DBConstant.ID} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      '${DBConstant.PJP_ID} INT, '
      '${DBConstant.CENTRE_CODE} TEXT, '
      '${DBConstant.CENTRE_NAME} TEXT, '
      '${DBConstant.PURPOSE} TEXT, '
      '${DBConstant.DATE} TEXT, '
      '${DBConstant.IS_ACTIVE} INT, '
      '${DBConstant.IS_NOTIFY} INT, '
      '${DBConstant.IS_CHECK_IN} INT, '
      '${DBConstant.IS_CHECK_OUT} INT, '
      '${DBConstant.IS_CVF_COMPLETED} INT, '
      '${DBConstant.MODIFIED_DATE} TEXT, '
      '${DBConstant.CREATED_DATE} TEXT)';

  static String CREATE_TABLE_ALL_EMPLOYEE = 'CREATE TABLE IF NOT EXISTS  ${LocalConstant.TABLE_EMPLOYEES}'
      '(notification_id TEXT PRIMARY KEY, '
      '${DBConstant.EMP_FULLNAME} TEXT, '
      '${DBConstant.EMP_CONTACT} TEXT, '
      '${DBConstant.EMP_EMAIL} TEXT, '
      '${DBConstant.EMP_CODE} TEXT, '
      '${DBConstant.EMP_DESG} TEXT, '
      '${DBConstant.EMP_APP_STATUS} TEXT, '
      '${DBConstant.EMP_DISPLAY} TEXT)';

  static String CREATE_TABLE_PARENT_INFO = 'CREATE TABLE IF NOT EXISTS  ${LocalConstant.TABLE_PARENT_INFO}'
      '(_id TEXT PRIMARY KEY, '
      '${DBConstant.FRANCHISEE_ID} INT, '
      '${DBConstant.STUDENT_PROGRAM_ID} INT, '
      '${DBConstant.STUDENT_ID} INT, '
      '${DBConstant.CLASS_ID} INT, '
      '${DBConstant.PARENT_ID} INT, '
      '${DBConstant.PARENT_NAME} TEXT, '
      '${DBConstant.CLASS_NAME} TEXT, '
      '${DBConstant.STUDENT_DOB} TEXT, '
      '${DBConstant.IS_PARENT_VERIFY} TEXT, '
      '${DBConstant.ADDRESS} TEXT, '
      '${DBConstant.ADDRESS_ALT} TEXT, '
      '${DBConstant.PHONE_NUMBER} TEXT, '
      '${DBConstant.MOBILE_NUMBER} TEXT, '
      '${DBConstant.MAIL_ADDRESS} TEXT, '
      '${DBConstant.STATE} TEXT, '
      '${DBConstant.CITY} TEXT, '
      '${DBConstant.PLACE} TEXT, '
      '${DBConstant.STUDENT_NAME} TEXT, '
      '${DBConstant.STUDENT_GENDER} TEXT, '
      '${DBConstant.SCHOOL_NAME} TEXT, '
      '${DBConstant.PROGRAM_NAME} TEXT, '
      '${DBConstant.ADMISSION_DATE} TEXT, '
      '${DBConstant.FRANS_TYPE} TEXT, '
      '${DBConstant.STUDENT_AVTAR} TEXT, '
      '${DBConstant.DATE} TEXT)';



  static String CREATE_TABLE_CVF_CATEGOTY = 'CREATE TABLE IF NOT EXISTS  ${LocalConstant.TABLE_CVF_CATEGORY}'
      '(${DBConstant.ID} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      '${DBConstant.CATEGORY_ID} INT, '
      '${DBConstant.CATEGORY_NAME} TEXT)';

  static String CREATE_TABLE_CVF_QUESTIONS = 'CREATE TABLE IF NOT EXISTS ${LocalConstant.TABLE_CVF_QUESTIONS}'
      '(${DBConstant.ID} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      '${DBConstant.QUESTION_ID} INT, '
      '${DBConstant.QUESTION} TEXT, '
      '${DBConstant.CATEGORY_ID} INT, '
      '${DBConstant.IS_COMPULSARY} INT, '
      '${DBConstant.CATEGORY_NAME} TEXT)';

  static String CREATE_TABLE_QUESTIONS_JSON = 'CREATE TABLE IF NOT EXISTS ${LocalConstant.TABLE_CVF_QUESTION_JSON}'
      '(${DBConstant.ID} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      '${DBConstant.CVF_ID} INT, '
      '${DBConstant.QUESTION} TEXT, '
      '${DBConstant.IS_SYNC} INT, '
      '${DBConstant.MODIFIED_DATE} INT, '
      '${DBConstant.CREATED_DATE} TEXT)';

  static String CREATE_TABLE_CVF_ANSERR_MASTER = 'CREATE TABLE IF NOT EXISTS  ${LocalConstant.TABLE_CVF_ANSWER_MASTER}'
      '(${DBConstant.ID} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      '${DBConstant.QUESTION_ID} INT, '
      '${DBConstant.CATEGORY_ID} INT, '
      '${DBConstant.QUESTION} TEXT, '
      '${DBConstant.ANSWER_NAME} TEXT, '
      '${DBConstant.ANSWER_TYPE} TEXT, '
      '${DBConstant.IS_COMPULSARY} INT)';

  static String CREATE_TABLE_CVF_USER_ANSERR = 'CREATE TABLE IF NOT EXISTS  ${LocalConstant.TABLE_CVF_USER_ANSWERAS}'
      '(${DBConstant.ID} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      '${DBConstant.CVF_ID} INT, '
      '${DBConstant.PJP_ID} INT, '
      '${DBConstant.CATEGORY_NAME} INT, '
      '${DBConstant.QUESTION_ID} INT, '
      '${DBConstant.USER_ANSWER} TEXT, '
      '${DBConstant.IS_SYNC} INT, '
      '${DBConstant.CREATED_DATE} TEXT)';

  static String CREATE_TABLE_CVF_FRANCHISEE = 'CREATE TABLE IF NOT EXISTS  ${LocalConstant.TABLE_CVF_FRANCHISEE}'
      '(${DBConstant.ID} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      '${DBConstant.FRANCHISEE_ID} INT, '
      '${DBConstant.BUSINESS_ID} INT, '
      '${DBConstant.FRANCHISEE_NAME} TEXT, '
      '${DBConstant.FRANCHISEE_CODE} TEXT, '
      '${DBConstant.ZONE} TEXT, '
      '${DBConstant.STATE} TEXT, '
      '${DBConstant.CITY} TEXT)';

  static String CREATE_TABLE_BACKGROUND_SYNC = 'CREATE TABLE IF NOT EXISTS  ${LocalConstant.TABLE_DATA_SYNC}'
      '(${DBConstant.ID} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      '${DBConstant.JSON_MODEL} INT, '
      '${DBConstant.ACTION_TYPE} TEXT, '
      '${DBConstant.IS_SYNC} int, '
      '${DBConstant.USER_ID} TEXT, '
      '${DBConstant.DATE} TEXT)';

  Future<sql.Database> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  DBHelper._internal();


  static initDb() async {
    final dbPath = await sql.getDatabasesPath();
    // open if found, create if not found for db
    return sql.openDatabase(path.join(dbPath, 'intranet.db'),
        onCreate: (db, version) {
          db.execute(CREATE_TABLE_ALL_EMPLOYEE);
          db.execute(CREATE_TABLE_NOTIFICATION);
          db.execute(CREATE_TABLE_PJP_MASTER);
          db.execute(CREATE_TABLE_PJP_CENTER_DETAILS);
          db.execute(CREATE_TABLE_CVF_CATEGOTY);
          db.execute(CREATE_TABLE_CVF_QUESTIONS);
          db.execute(CREATE_TABLE_CVF_ANSERR_MASTER);
          db.execute(CREATE_TABLE_CVF_USER_ANSERR);
          db.execute(CREATE_TABLE_CVF_FRANCHISEE);
          db.execute(CREATE_TABLE_QUESTIONS_JSON);
          db.execute(CREATE_TABLE_CHECKIN);
          db.execute(CREATE_TABLE_BACKGROUND_SYNC);
        },
        onUpgrade: (db,old,newversion){
            print('Database Upgrade-------------------');
            if(old<=3)
              db.execute(CREATE_TABLE_NOTIFICATION);
            if(old==4){
              db.execute(CREATE_TABLE_QUESTIONS_JSON);
            }
            if(old==5){
              db.execute(CREATE_TABLE_CHECKIN);
            }else if(old<=6){
              db.execute(CREATE_TABLE_BACKGROUND_SYNC);
            }
            if(old<=7){
              //db.execute(CREATE_TABLE_CVF_FRANCHISEE);
              db.execute("ALTER TABLE ${LocalConstant.TABLE_CVF_FRANCHISEE} ADD COLUMN ${DBConstant.BUSINESS_ID} int;");
            }
        }, version: 8);
  }

  /// insert data to db
  /// @param table: the name of the table to insert to
  /// @param data: data map to be inserted
  Future<void> insert(String table, Map<String, Object> data) async {
    final dbClient = await db;
    dbClient.insert(table, data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  Future<void> deleteCategory(int categotyId)
  async {
    final dbClient = await db;
    dbClient.delete(LocalConstant.TABLE_CVF_QUESTIONS, where: '${DBConstant.CATEGORY_ID} = ?', whereArgs: [categotyId]);
    dbClient.delete(LocalConstant.TABLE_CVF_ANSWER_MASTER, where: '${DBConstant.CATEGORY_ID} = ?', whereArgs: [categotyId]);

  }


  /// delete data to db
  /// @param table: the name of the table to delete from
  /// @param id: product id to be deleted
  Future<void> delete(String table, String id) async {
    final dbClient = await db;
    dbClient.delete(table, where: '${DBConstant.ID} = ?', whereArgs: [id]);
  }

  Future<void> deleteAllData() async {
    final dbClient = await db;
    dbClient.delete(LocalConstant.TABLE_CVF_QUESTION_JSON, where: null, whereArgs: []);
    dbClient.delete(LocalConstant.TABLE_CVF_ANSWER_MASTER, where: null, whereArgs: []);
    dbClient.delete(LocalConstant.TABLE_CVF_FRANCHISEE, where: null, whereArgs: []);
    dbClient.delete(LocalConstant.TABLE_CVF_QUESTION_JSON, where: null, whereArgs: []);
    dbClient.delete(LocalConstant.TABLE_CVF_QUESTIONS, where: null, whereArgs: []);
    dbClient.delete(LocalConstant.TABLE_CVF_CATEGORY, where: null, whereArgs: []);

  }

  /// delete data to db
  /// @param table: the name of the table to delete from
  /// @param id: product id to be deleted
  Future<void> deleteData(String table) async {
    final dbClient = await db;
    dbClient.delete(table, where: null, whereArgs: []);
  }

  /// update data in db
  /// @param table: the name of the table to be updated
  /// @param data: data map to be updated
  Future<void> update(String table, Map<String, Object> data) async {
    final dbClient = await db;
    dbClient.update(table, data);
  }

  /// select data from db
  /// @param table: the name of the table to fetch data from
  /// @return Future of the list of products data
  Future<List<Map<String, dynamic>>> getData(String table) async {
    final dbClient = await db;
    return await dbClient.query(table);
  }

  Future<List<Map<String, dynamic>>> getOrderedData(String table,String ordebytable,String orderby) async {
    final dbClient = await db;
    return await dbClient.query(table,orderBy: ordebytable+' '+orderby);
  }

  //Update Data
  Future<int> updateData(String table,Map<String, Object> data,String condition,List<Object?>? whereArgs) async {
    final dbClient = await db;
    print(condition + whereArgs.toString());
    return dbClient.update(table, data,where: condition,whereArgs: whereArgs);

  }
  Future<int> updateCheckIn(String table,int checkin,int pjpId) async {
    final dbClient = await db;
    return dbClient.rawUpdate('update ${table} set ${DBConstant.IS_CHECK_IN} = ${checkin} where ${DBConstant.ID}=${pjpId}');

  }
  Future<int> updatePJP(int isSync,int pjpId,int checkin,int checkout,int newPjp) async {
    final dbClient = await db;

    dbClient.rawUpdate('update ${LocalConstant.TABLE_PJP_CENTERS_DETAILS} set ${DBConstant.PJP_ID} = ${newPjp}  where ${DBConstant.PJP_ID}=${pjpId}');

    return dbClient.rawUpdate('update ${LocalConstant.TABLE_PJP_INFO} set ${DBConstant.IS_SYNC} = ${isSync} , ${DBConstant.ID} = ${newPjp} , ${DBConstant.IS_CHECK_IN} = ${checkin},${DBConstant.IS_CHECK_OUT} = ${checkout} where ${DBConstant.ID}=${pjpId}');

  }

  /// clear database
  Future clear() async {
    final dbPath = await sql.getDatabasesPath();
    await sql.deleteDatabase(dbPath);
  }

  Future<void> insertNotification(String id,String title,String type,String notification,String dataNotification,int isseen,String imageurl) async{
    var dbclient = await db;
    Map<String, Object> data = {

      'title': title,
      'type': type,
      'notification': notification,
      'data': dataNotification,
      'isseen': isseen,
      'imageurl': imageurl,
      'date': Utility.parseDate(DateTime.now()),
    };
    await dbclient.insert(LocalConstant.TABLE_NOTIFICATION, data);
  }



  Future<void> insertCheckIn(String cvfId,String body,String status,int isSync) async{
    var dbclient = await db;
    Map<String, Object> data = {
      'body': body,
      '${DBConstant.CVF_ID}': cvfId,
      '${DBConstant.STATE}': status,
      'body': body,
      DBConstant.IS_SYNC: isSync,
      'date': Utility.parseDate(DateTime.now()),
    };
    print(data.toString());
    await dbclient.insert(LocalConstant.TABLE_CHECKIN, data);
  }

  Future<void> insertSyncData(String json,String action,int userid) async{
    var dbclient = await db;
    Map<String, Object> data = {
      '${DBConstant.JSON_MODEL}': json,
      '${DBConstant.ACTION_TYPE}': action,
      DBConstant.IS_SYNC: 0,
      DBConstant.USER_ID: userid,
      DBConstant.DATE: Utility.parseDate(DateTime.now()),
    };
    await dbclient.insert(LocalConstant.TABLE_DATA_SYNC, data);
  }


  Future<void> insertCVFQuestions(String cvfid,String json,int isSync) async{
    var dbclient = await db;
    Map<String, Object> data = {
      '${DBConstant.CVF_ID}': cvfid,
      '${DBConstant.QUESTION}': json,
      '${DBConstant.IS_SYNC}': isSync,
      '${DBConstant.MODIFIED_DATE}': Utility.parseDate(DateTime.now()),
      '${DBConstant.CREATED_DATE}': Utility.parseDate(DateTime.now()),
    };
    await dbclient.insert(LocalConstant.TABLE_CVF_QUESTION_JSON, data);
  }

  Future<void> updateCVFQuestions(String cvfId,String json,int isSync) async{
    var dbclient = await db;
    try {
      await dbclient.rawUpdate('update ${LocalConstant
          .TABLE_CVF_QUESTION_JSON} set is_sync = \'${json}\' ,${DBConstant
          .IS_SYNC} = \'${isSync}\' ,${DBConstant.MODIFIED_DATE} = \'${Utility
          .parseDate(DateTime.now())}\'   where ${DBConstant.CVF_ID}=${cvfId}');
    }catch(e){
      print(e.toString());
    }
  }

  Future<void> updateCheckInStatus(int id,int isSync) async{
    var dbclient = await db;
    await dbclient.rawUpdate('update ${LocalConstant.TABLE_CHECKIN} set ${DBConstant.IS_SYNC} = \'${isSync}\'  where id=${id}');
  }

  Future<QuestionResponse> getQuestionsList(String cvfId) async {
    QuestionResponse response = QuestionResponse(responseMessage: '', statusCode: 200, responseData: []);
    List<Map<String, dynamic>> list = await  DBHelper().getData(LocalConstant.TABLE_CVF_QUESTION_JSON);
    if(list !=null){
      for(int index=0;index<list.length;index++) {
        Map<String, dynamic> map = list[index];
        if(cvfId==map[DBConstant.CVF_ID].toString().trim()){
          //print('trying to decode');
          response = QuestionResponse.fromJson(
            json.decode(map[DBConstant.QUESTION]),
          );

          //print('decode ${response.toJson()}');
          //notificaitonList.add(NotificationDataModel(message: map['data'], title: map['title'], image: map['imageurl'], URL: '', type: map['type'],time:time));
        }else{
          print('not match');
        }

      }
    }else{
      print('getQuestionsList list is null');
    }
    return response;
  }

  Future<List<ApproveLeaveRequestManager>> getUnSyncData(String userId) async {
    QuestionResponse response = QuestionResponse(responseMessage: '', statusCode: 200, responseData: []);
    List<ApproveLeaveRequestManager> unSyncList =[];
    List<Map<String, dynamic>> list = await  DBHelper().getData(LocalConstant.TABLE_DATA_SYNC);
    if(list !=null){
      print('getQuestionsList list is not empty ${list.length}');
      for(int index=0;index<list.length;index++) {
        Map<String, dynamic> map = list[index];
        if(map[DBConstant.IS_SYNC]==0) {
          unSyncList.add(ApproveLeaveRequestManager(
            xml: map[DBConstant.JSON_MODEL], userId: userId, index: map[DBConstant.ID],actionType: map[DBConstant.ACTION_TYPE]));
        }
      }
    }else{
      print('getQuestionsList list is null');
    }
    return unSyncList;
  }

  Future<Map<String,String>> getCheckInStatus() async {
    Map<String,String> mMap = Map();

    List<Map<String, dynamic>> list = await  DBHelper().getOrderedData(LocalConstant.TABLE_CHECKIN,'id','desc');
    if(list !=null){
      for(int index=0;index<list.length;index++) {
        Map<String, dynamic> map = list[index];
        mMap.putIfAbsent(map[DBConstant.CVF_ID].toString(), () => map[DBConstant.STATE]);
        print('${map[DBConstant.CVF_ID]} '+map[DBConstant.STATE]);
      }
    }else{
      print('offline status not found');
    }
    return mMap;
  }

  Future<List<CheckInModel>> getOfflineCheckInStatus() async {
    List<CheckInModel> modelList = [];

    List<Map<String, dynamic>> list = await  DBHelper().getOrderedData(LocalConstant.TABLE_CHECKIN,DBConstant.CVF_ID,"desc");
    if(list !=null){
      for(int index=0;index<list.length;index++) {
        Map<String, dynamic> map = list[index];
        print(map[DBConstant.CVF_ID].toString()+'  '+map[DBConstant.IS_SYNC].toString());
        if(map[DBConstant.IS_SYNC]==0) {
          modelList.add(CheckInModel(id : map['id'],cvfId: map[DBConstant.CVF_ID].toString(),
              body: map['body'].toString(),
              state: map[DBConstant.STATE].toString(),
              isSync: map[DBConstant.IS_SYNC].toString() == 1 ? true : false));
        }

      }
    }
    return modelList;
  }

  Future<List<NotificationDataModel>> getNotificationList() async {
    List<NotificationDataModel> notificaitonList = [];

    List<Map<String, dynamic>> list = await  DBHelper().getData(LocalConstant.TABLE_NOTIFICATION);
    if(list !=null){
      //print('----${list.length}');
      for(int index=0;index<list.length;index++) {
        Map<String, dynamic> map = list[index];
        //print('date is  ${map['date']}');
        String time = '';
        if(map['date'] != null){
          time = map['date'];
        }

        notificaitonList.add(NotificationDataModel(message: map['data']!=null && map['data']!='' ?  map['data'] : map['notification'], title: map['title'], image: map['imageurl'], URL: '', type: map['type'],time:time));
      }
    }
    return notificaitonList;
  }

  Future<void> updateUserAnswer(cvfid,pjpid,quid,cat_name,useranswer) async {
    var dbclient = await db;
    int? count = Sqflite.firstIntValue(
        await dbclient.rawQuery("SELECT COUNT(*) FROM ${LocalConstant.TABLE_CVF_USER_ANSWERAS} WHERE ${DBConstant.CVF_ID}=$cvfid and ${DBConstant.QUESTION_ID}=${quid}"));
    if(count!>0){
      //update
      print('update');
      await dbclient.rawUpdate('update ${LocalConstant.TABLE_CVF_USER_ANSWERAS} set ${DBConstant.USER_ANSWER} = \'${useranswer}\'  where ${DBConstant.CVF_ID}=${cvfid} and ${DBConstant.QUESTION_ID}=${quid}');
    }else{
      print('insert');
      //insert
      Map<String, Object> data = {
        DBConstant.CREATED_DATE: Utility.parseDate(DateTime.now()),
        DBConstant.CVF_ID: cvfid,
        DBConstant.PJP_ID: pjpid,
        DBConstant.CATEGORY_NAME: cat_name,
        DBConstant.QUESTION_ID: quid,
        DBConstant.USER_ANSWER: useranswer,
        DBConstant.IS_SYNC: 0,
      };
      await dbclient.insert(LocalConstant.TABLE_CVF_USER_ANSWERAS, data);
    }
  }

  Future<List<PJPModel>> getPjpList() async {
    List<PJPModel> pjpList = [];

    List<Map<String, dynamic>> list = await  DBHelper().getData(LocalConstant.TABLE_PJP_INFO);
    if(list !=null){
      print('----${list.length}');
      for(int index=0;index<list.length;index++) {
        Map<String, dynamic> map = list[index];
        pjpList.add(PJPModel(pjpId: map[DBConstant.ID],
            dateTime: Utility.convertDate(map[DBConstant.DATE]),
            fromDate: Utility.convertDate(map[DBConstant.TO_DATE]),
            toDate: Utility.convertDate(map[DBConstant.TO_DATE]),
            remark: map[DBConstant.REMARK],
            isSync: map[DBConstant.IS_SYNC]==0 ? false : true,
            employeeId: map[DBConstant.EMP_CODE],
            centerList: [],
            isDelete: map[DBConstant.IS_DELETE]==0 ? false : true,
            isActive: map[DBConstant.IS_ACTIVE]==0 ? false : true,
            isCheckIn: map[DBConstant.IS_CHECK_IN]==0 ? false : true,
            isCheckOut: map[DBConstant.IS_CHECK_OUT]==0 ? false : true,
            isCVFCompleted: map[DBConstant.IS_CVF_COMPLETED]==0 ? false : true,
            isEdit: false,
            createdDate: Utility.convertDate(map[DBConstant.CREATED_DATE]),
            modifiedDate: Utility.convertDate(map[DBConstant.MODIFIED_DATE])));
      }
    }
    return pjpList;
  }

  Future<Map<String,String>> getUsersAnswerList(int cvfId) async {
    Map<String,String> mMap = Map();

    List<Map<String, dynamic>> list = await  DBHelper().getData(LocalConstant.TABLE_CVF_USER_ANSWERAS);
    if(list !=null){
      print('----${list.length}');
      for(int index=0;index<list.length;index++) {
        Map<String, dynamic> map = list[index];
        if(map[DBConstant.CVF_ID] == cvfId)
          mMap.putIfAbsent(map[DBConstant.QUESTION_ID].toString(), () => map[DBConstant.USER_ANSWER]);
      }
    }
    return mMap;
  }

  Future<List<GetDetailedPJP>> getCVFList() async {
    List<GetDetailedPJP> cvfList = [];

    List<Map<String, dynamic>> list = await  DBHelper().getData(LocalConstant.TABLE_PJP_CENTERS_DETAILS);
    if(list !=null){
      for(int index=0;index<list.length;index++) {
        Map<String, dynamic> map = list[index];
        //cvfList.add(value)
        
        /*cvfList.add(PJPCentersInfo(pjpId: map[DBConstant.PJP_ID],
            centerCode: map[DBConstant.CENTRE_CODE],
            centerName: map[DBConstant.CENTRE_NAME],
            purpose: map[DBConstant.PURPOSE],
            dateTime: Utility.convertDate(map[DBConstant.DATE]),
            isSync: false*//*map[DBConstant.IS_SYNC]*//*,
            isCheckIn: map[DBConstant.IS_CHECK_IN] ==1 ? true : false,
            isCheckOut: map[DBConstant.IS_CHECK_OUT] ==1 ? true : false,
            isActive: map[DBConstant.IS_ACTIVE] ==1 ? true : false,
            isNotify: map[DBConstant.IS_NOTIFY] ==1 ? true : false,
            isCompleted: map[DBConstant.IS_CVF_COMPLETED] ==1 ? true : false,
            createdDate: Utility.convertDate(map[DBConstant.CREATED_DATE]), modifiedDate: Utility.convertDate(map[DBConstant.MODIFIED_DATE])));*/
        print(map.toString());
      }

    }
    return cvfList;
  }

  Future<List<FranchiseeInfo>> getFranchiseeList(int businessId) async {
    List<FranchiseeInfo> frichiseeList = [];

    List<Map<String, dynamic>> list = await  DBHelper().getData(LocalConstant.TABLE_CVF_FRANCHISEE);
    print('list franchisee ${list}');
    if(list !=null){
      for(int index=0;index<list.length;index++) {
        Map<String, dynamic> map = list[index];
        print(' NAME ${map[DBConstant.FRANCHISEE_NAME]} business ${map[DBConstant.BUSINESS_ID]}  ${businessId}');
        if(map[DBConstant.BUSINESS_ID] == businessId) {
          frichiseeList.add(FranchiseeInfo(franchiseeId: double.parse(
              map[DBConstant.FRANCHISEE_ID].toString()),
              franchiseeCode: map[DBConstant.FRANCHISEE_CODE],
              franchiseeName: map[DBConstant.FRANCHISEE_NAME],
              franchiseeZone: map[DBConstant.ZONE],
              franchiseeState: map[DBConstant.STATE],
              franchiseeCity: map[DBConstant.CITY]));
        }
        if(index>50){
          break;
        }
      }
    }
    return frichiseeList;
  }
}