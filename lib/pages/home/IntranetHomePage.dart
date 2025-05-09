import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:Intranet/api/response/login_response.dart';
import 'package:Intranet/firebase_options.dart';
import 'package:Intranet/main.dart';
import 'package:Intranet/pages/helper/LocalConstant.dart';
import 'package:Intranet/pages/helper/utils.dart';
import 'package:Intranet/pages/leave/leave_list.dart';
import 'package:Intranet/pages/notification/UserNotification.dart';
import 'package:Intranet/pages/outdoor/outdoor_list.dart';
import 'package:Intranet/pages/pjp/models/PjpModel.dart';
import 'package:Intranet/pages/pjp/mypjp.dart';
import 'package:Intranet/pages/userinfo/employee_list.dart';
import 'package:app_version_update/app_version_update.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:saathi/zllsaathi.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uni_links5/uni_links.dart';

import '../../api/APIService.dart';
import '../../api/request/login_request.dart';
import '../attendance/attendance_list.dart';
import '../attendance/attendance_marking.dart';
import '../attendance/manager_screen.dart';
import '../firebase/anylatics.dart';
import '../firebase/notification.dart';
import '../firebase/notification_service.dart';
import '../firebase/storageutil.dart';
import '../helper/DatabaseHelper.dart';
import '../helper/constants.dart';
import '../iface/onClick.dart';
import '../iface/onUploadResponse.dart';
import '../intro/intro.dart';
import '../leave/leave_list_manager.dart';
import '../model/filter.dart';
import '../outdoor/outdoor_requisition_manager.dart';
import '../pjp/IntranetEvents.dart';
import '../pjp/cvf/mycvf.dart';
import '../pjp/pjp_list_manager.dart';
import '../utils/theme/colors/light_colors.dart';
import 'home_page_menus.dart';

class IntranetHomePage extends StatefulWidget {
  String userId;
  FilterSelection mPjpFilters =
      FilterSelection(filters: [], type: FILTERStatus.MYSELF);
  int _selectedDestination = 1;

  IntranetHomePage({super.key, required this.userId});

  @override
  _IntranetHomePageState createState() => _IntranetHomePageState();
}

bool initialURILinkHandled = false;

class _IntranetHomePageState extends State<IntranetHomePage>
    with WidgetsBindingObserver
    implements onUploadResponse, onClickListener {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Uri? _initialURI;
  Uri? _currentURI;
  Object? _err;

  StreamSubscription? _streamSubscription;

  static const int MENU_HOME = 1;
  static const int MENU_ATTENDANCE = 2;
  static const int MENU_ATTENDANCE_MARKING = 10;
  static const int MENU_OUTDOOR = 3;
  static const int MENU_LEAVE = 4;
  static const int MENU_LEAVE_APPROVAL = 5;
  static const int MENU_ATTENDANCE_MARKING_APPROVAL = 6;
  static const int MENU_OUTDOOR_APPROVAL = 7;
  static const int MENU_PROFILE = 8;
  static const int MENU_PJP = 9;
  static const int MENU_CVF = 11;

  final ImagePicker _picker = ImagePicker();
  XFile? _imageFileList;
  bool isBpms = false;

  late final ValueNotifier<List<PJPModel>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.twoWeeks;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOff; // Can be toggled on/off by longpressing a date
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  Map<DateTime, List<PJPModel>> attendanceEvent = {};
  int employeeId = 0;
  int businessId = 0;
  String _currentBusinessName = '';
  String mUserName = '';
  String mDesignation = '';
  String email = '';
  String _profileImage =
      'https://cdn-icons-png.flaticon.com/128/149/149071.png';
  Uint8List? _profileAvtar;
  List<PJPModel> mPjpList = [];
  late String mTitle = "";
  var hiveBox;

  final bool _flexibleUpdateAvailable = false;
  AppUpdateInfo? _updateInfo;

  /*FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  FirebaseMessaging messaging = FirebaseMessaging.instance;*/
  String appVersion = '';
  List<BusinessApplications> businessApplications = [];

  updateCurrentBusiness(int bid, String name, int uid) async {
    hiveBox = await Utility.openBox();
    await Hive.openBox(LocalConstant.KidzeeDB);
    hiveBox.put(LocalConstant.KEY_BUSINESS_ID, bid);
    hiveBox.put(LocalConstant.KEY_BUSINESS_NAME, name);
    hiveBox.put(LocalConstant.KEY_BUSINESS_USERID, uid);
    //hiveBox.put(LocalConstant.KEY_FRANCHISEE_ID,uid);
    setState(() {
      _currentBusinessName = name;
    });
  }

  void validate(BuildContext context) async {
    hiveBox = await Utility.openBox();
    await Hive.openBox(LocalConstant.KidzeeDB);
    mUserName = hiveBox.get(LocalConstant.KEY_USER_NAME);
    String userPassword = hiveBox.get(LocalConstant.KEY_USER_PASSWORD);
    String loginResponse = hiveBox.get(LocalConstant.KEY_LOGIN_RESPONSE);
    if (loginResponse.isEmpty ||
        mUserName.isNotEmpty && userPassword.isNotEmpty) {
      Utility.showLoaderDialog(context);
      LoginRequestModel loginRequestModel = LoginRequestModel(
        userName: mUserName,
        password: userPassword,
      );
      APIService apiService = APIService();
      apiService.login(loginRequestModel).then((value) {
        debugPrint(value.toString());
        if (value != null) {
          setState(() {
            //isApiCallProcess = false;
          });
          if (value == null || value.responseData == null) {
            //Utility.showMessage(context,'Invalid UserName/Password');
          } else if (value is LoginResponseInvalid) {
            LoginResponseInvalid responseInvalid = value;
            //Utility.showMessage(context, responseInvalid.responseData);
          } else {
            List<EmployeeDetails> infoList = value.responseData.employeeDetails;
            if (infoList.isEmpty) {
              //Utility.showMessage(context, 'Invalid UserName/Password');
            } else {
              EmployeeDetails info = value.responseData.employeeDetails[0];
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
              try {
                hive.put(LocalConstant.KEY_BUSINESS_ID,
                    value.responseData.businessApplications[0].businessID);
                List<BusinessApplications> businessApplications =
                    value.responseData.businessApplications;
                for (int index = 0;
                    index < businessApplications.length;
                    index++) {
                  //BP Management
                  if (businessApplications[index].businessName ==
                      'BP Management') {
                    isBpms = true;
                    hive.put(
                        LocalConstant.KEY_FRANCHISEE_ID,
                        value.responseData.businessApplications[index]
                            .business_UserID);
                  }
                }
              } catch (e) {}
              debugPrint('========Login Form ====== ${jsonEncode(value)}');
              getLoginResponse();
            }
          }
          Navigator.of(context).pop();
          setState(() {});
        } else {
          Navigator.pop(context);
          //Utility.showMessage(context, "Invalid User Name and Password");
          debugPrint("null value");
        }
      });
    } else {}
  }

  getLoginResponse() async {
    debugPrint('in Login Response ================');
    businessApplications.clear();
    hiveBox = await Utility.openBox();
    await Hive.openBox(LocalConstant.KidzeeDB);
    var loginresponse = hiveBox.get(LocalConstant.KEY_LOGIN_RESPONSE);
    debugPrint('login Response is : ' + loginresponse);
    try {
      LoginResponseModel response = LoginResponseModel.fromJson(
        json.decode(loginresponse),
      );
      debugPrint('response received.....');
      businessApplications.addAll(response.responseData.businessApplications);
      if (_currentBusinessName.isNotEmpty && businessApplications.isNotEmpty) {
        _currentBusinessName = businessApplications[0].businessName;
        updateCurrentBusiness(
            businessApplications[0].businessID,
            businessApplications[0].businessName,
            businessApplications[0].business_UserID);
      }
      setState(() {});
    } catch (e) {
      debugPrint('Error in getting login response');
      debugPrint(e.toString());
      //IntranetServiceHandler.loadPjpSummery(employeeId, 0, this);
    }
  }

  Future<void> showBusinessListDialog(isFromDrawar) {
    if (businessApplications.isEmpty) {
      return showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              title: Text("Alert"),
              content: Text(
                  'Business not assigned in your account, please connect with your manager'),
            );
          });
    } else
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Select Business"),
              content: SizedBox(
                width: 300.0,
                child: ListView.builder(
                  itemCount: businessApplications.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Container(
                        child: Card(
                            color: businessId ==
                                    businessApplications[index].businessID
                                ? Colors.white54
                                : Colors.white,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                if (isFromDrawar) Navigator.pop(context);
                                updateCurrentBusiness(
                                    businessApplications[index].businessID,
                                    businessApplications[index].businessName,
                                    businessApplications[index]
                                        .business_UserID);
                              },
                              child: ListTile(
                                title: Text(
                                    businessApplications[index].businessName),
                              ),
                            )));
                  },
                ),
              ),
            );
          });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    debugPrint('initstate ======================');
    _selectedDay = _focusedDay;
    //_selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    //addEvent();
    getUserInfo();
    //_listenForMessages();

    initNotification();

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published123!');
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const UserNotification()));
    });
    //_listenForMessages();
    if (!kIsWeb) if (Platform.isAndroid) {
      checkForUpdate();
    } else if (Platform.isIOS) {
      _verifyVersion();
    }

    getLoginResponse();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _initURIHandler();
      _incomingLinkHandler();
      //showBusinessListDialog(false);
    });
  }

  Future<void> _initURIHandler() async {
    if (!initialURILinkHandled) {
      initialURILinkHandled = true;

      try {
        final initialURI = await getInitialUri();
        // Use the initialURI and warn the user if it is not correct,
        // but keep in mind it could be `null`.
        if (initialURI != null) {
          debugPrint("Initial URI on home screen received $initialURI");

          _initialURI = initialURI;

          // SharedPreferences prefs = await SharedPreferences.getInstance();
          // String uid = prefs.getString(LocalConstant.KEY_UID) as String;
          deepLinkCommonFunction(_initialURI);
        } else {
          getLoginResponse();
          validate(context);
          // navigate();
          debugPrint("Null Initial URI received");
        }
      } on PlatformException {
        // Platform messages may fail, so we use a try/catch PlatformException.
        // Handle exception by warning the user their action did not succeed
        debugPrint("Failed to receive initial uri");
        getLoginResponse();
        validate(context);
      } on FormatException catch (err) {
        getLoginResponse();
        validate(context);
        if (!mounted) {
          return;
        }
        debugPrint('Malformed Initial URI received');
        setState(() => _err = err);
      }
    }
  }

  /// Handle incoming links - the ones that the app will receive from the OS
  /// while already started.
  void _incomingLinkHandler() {
    if (!kIsWeb) {
      // It will handle app links while the app is already started - be it in
      // the foreground or in the background.
      _streamSubscription = uriLinkStream.listen((Uri? uri) async {
        if (!mounted) {
          return;
        }
        debugPrint('Received URI: $uri');

        // SharedPreferences prefs = await SharedPreferences.getInstance();
        // String uid = prefs.getString(LocalConstant.KEY_UID) as String;
        deepLinkCommonFunction(uri);
      }, onError: (Object err) {
        if (!mounted) {
          return;
        }
        debugPrint('Error occurred: $err');
      });
    }
  }

  void deepLinkCommonFunction(Uri? initialURI) async {
    debugPrint(
        'udid from deep linkk is - ${initialURI!.path.split('/').elementAt(1)}');
    debugPrint('udid $initialURI');
    debugPrint('udid ${initialURI.queryParameters['id']}');
    if (initialURI.toString().contains('zllsaathi.zeelearn.com/ticketDetail')) {
      //Saathi Ticket Details
      print('ticket ID ${initialURI.queryParameters['id']!}');
      print('BID ${initialURI.queryParameters['b_id']!}');
      print('BUID ${initialURI.queryParameters['bu_id']!}');

      ZllTicket(
          context,
          initialURI.queryParameters['id']!,
          initialURI.queryParameters['b_id']!,
          initialURI.queryParameters['bu_id']!,
          initialURI.queryParameters['u_id']!.replaceAll('.', ''),
          kPrimaryLightColor);
    }
  }

  // @pragma('vm:entry-point')
  // Future<void> _firebaseMessagingBackgroundHandler(
  //     RemoteMessage message) async {
  //   print('A new onMessageOpenedApp event was published! main 437');
  //   NotificationService().parseNotification(message);
  // }

  initNotification() async {
    await initFirebase();
    await NotificationController.initializeLocalNotifications();
    await NotificationController.initializeIsolateReceivePort();
    // Set the background messaging handler early on, as a named top-level function
    //FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  Future<void> initFirebase() async {
    //await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    if (!kIsWeb && !Platform.isAndroid)
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
    else
      await Firebase.initializeApp();
    messaging = FirebaseMessaging.instance;
    // Set the background messaging handler early on, as a named top-level function
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    if (kDebugMode) {
      // Force disable Crashlytics collection while doing every day development.
      // Temporarily toggle this to true if you want to test crash reporting in your app.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    } else {
      // Handle Crashlytics enabled status when not in Debug,
      FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    }

    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    NotificationSettings settings = await firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    //FirebaseMessaging.instance.getInitialMessage();
    print('User granted permission: ${settings.authorizationStatus}');
    if (!kIsWeb) {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

// Declaration of variables

      if (Platform.isIOS) {
        await firebaseMessaging.setForegroundNotificationPresentationOptions(
          alert: true, // Required to display a heads up notification
          badge: true,
          sound: true,
        );
      }
    }

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    getPermission();
    getToken();

    //runApp(MyApp());
  }

  Future<void> getPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    FirebaseMessaging.instance.requestPermission();
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
  }

  late String token;
  getToken() async {
    print('app token is ');
    token = (await FirebaseMessaging.instance.getToken())!;
    print('Notification Token..$token');
    print(token);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!kDebugMode) {
        if (Platform.isAndroid) {
          checkForUpdate();
        } else if (Platform.isIOS) {
          _verifyVersion();
        }
      }
    }
  }

  void _verifyVersion() async {
    await AppVersionUpdate.checkForUpdates(
      appleId: '6443464060',
      playStoreId: 'com.zeelearn.intranet',
    ).then((result) async {
      if (result.canUpdate!) {
        await AppVersionUpdate.showBottomSheetUpdate(
            context: context,
            appVersionResult: result,
            mandatory: true,
            title: 'App Update Avaliable',
            content: const Text(
                'New version of our Intranet application is now available, and we highly recommend that you install it to benefit from its enhanced features and improved security.'));
      }
    });
    // TODO: implement initState
  }

  // It is assumed that all messages contain a data field with the key 'type'
  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    if (!kIsWeb) {
      RemoteMessage? initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();

      // If the message also contains a data property with a "type" of "chat",
      // navigate to a chat screen
      if (initialMessage != null) {
        _handleMessage(initialMessage);
      }

      // Also handle any interaction when the app is in the background via a
      // Stream listener
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
    }
  }

  void _handleMessage(RemoteMessage message) {
    debugPrint('Handle Notification $message');
    if (message.data['type'] == 'chat') {
      debugPrint('Handle Notification');
      /*Navigator.pushNamed(
        context,
        '/chat',
        arguments: message,
      );*/
    }
  }

  /*void _listenForMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground! asd');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint('Message also contained a notification: ${message.notification}');
        setState(() {
          String? body = message.notification?.body;
          if (body != null) {
            //this._receivedPushMessage = body;
          } else {
            //this._receivedPushMessage = "message boy was null";
          }
        });
      }
    });
  }*/

  decodeJsonValue() {
    String message =
        "{type: ATNDC, title: ATNDC, message: Sudhir Patil has sent a new ATNDC requisition - 1103397 for approval.}";
    message = message.replaceAll("{", "{\"");
    message = message.replaceAll("}", "\"}");
    message = message.replaceAll(":", "\":\"");
    message = message.replaceAll(", ", "\",\"");
    debugPrint(message);
    var json = jsonDecode(message);
    debugPrint(json);
  }

  updateProfileImage() async {
    var hiveBox = await Utility.openBox();
    await Hive.openBox(LocalConstant.KidzeeDB);
    if (_profileImage.isNotEmpty)
      hiveBox.put(LocalConstant.KEY_EMPLOYEE_AVTAR, _profileImage);
  }

  Future<void> getUserInfo() async {
    var hiveBox = await Utility.openBox();
    await Hive.openBox(LocalConstant.KidzeeDB);
    employeeId =
        int.parse(hiveBox.get(LocalConstant.KEY_EMPLOYEE_ID) as String);
    mDesignation = hiveBox.get(LocalConstant.KEY_DESIGNATION) as String;
    email = hiveBox.get(LocalConstant.KEY_EMAIL) as String;
    var imageUrl = hiveBox.get(LocalConstant.KEY_EMPLOYEE_AVTAR);
    if (hiveBox.containsKey(LocalConstant.KEY_FRANCHISEE_ID)) {
      isBpms = true;
    }
    mTitle =
        "${hiveBox.get(LocalConstant.KEY_FIRST_NAME)} ${hiveBox.get(LocalConstant.KEY_LAST_NAME)}";
    _currentBusinessName =
        hiveBox.get(LocalConstant.KEY_BUSINESS_NAME).toString();
    _profileImage = 'https://cdn-icons-png.flaticon.com/128/149/149071.png';
    String sex = hiveBox.get(LocalConstant.KEY_GENDER) as String;
    if (imageUrl != null) {
      _profileImage = imageUrl;
    } else if (sex == 'Male') {
      _profileImage = 'https://cdn-icons-png.flaticon.com/128/149/149071.png';
    } else {
      _profileImage = 'https://cdn-icons-png.flaticon.com/128/727/727393.png';
    }
    _getId(employeeId.toString());

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      String appName = packageInfo.appName;
      String packageName = packageInfo.packageName;
      String version = packageInfo.version;
      String buildNumber = packageInfo.buildNumber;
      appVersion = version;
    });
    getProfileImage();
    //decodeJsonValue();
    setState(() {});
  }

  getProfileImage() async {
    try {
      var hiveBox = await Utility.openBox();
      await Hive.openBox(LocalConstant.KidzeeDB);
      debugPrint('Avtar getProfileImaage-----');
      var avtar = hiveBox.get(LocalConstant.KEY_EMPLOYEE_AVTAR_LIST);
      debugPrint('Avtar $avtar');
      if (avtar != null && avtar != '') {
        debugPrint('getProfile pic decode');
        _profileAvtar = base64.decode(avtar);
      } else {
        debugPrint('getProfile pic in else');
        FirebaseStorageUtil().getProfileImage(employeeId.toString(), this);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  uploadProfilePicture() async {
    try {
      final XFile? pickedFileList = await _picker.pickImage(
          source: ImageSource.camera, maxHeight: 800, imageQuality: 100);
      setState(() {
        _imageFileList = pickedFileList;
        FirebaseStorageUtil()
            .uploadAvtar(_imageFileList!.path, employeeId.toString(), this);
      });
    } catch (e) {
      /*setState(() {
        _pickImageError = e;
      });*/
    }
  }

  Future<String?> _getId(String employeeId) async {
    var deviceInfo = DeviceInfoPlugin();
    String? id;
    String useragent = 'Android';
    if (Platform.isIOS) {
      // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      id = iosDeviceInfo.identifierForVendor; // unique ID on iOS
      useragent = 'IOS_${iosDeviceInfo.model}_$appVersion';
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      id = androidDeviceInfo.id; // unique ID on Android
      useragent =
          'Android_${androidDeviceInfo.brand}_${androidDeviceInfo.model}';
    }
    if (!kIsWeb) {
      final firebaseMessaging = FCM();
      //useragent= Platform.isIOS ? 'IOS' : 'Android';
      firebaseMessaging.setNotifications(
          employeeId.toString(), id ?? '0', useragent);
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        NotificationService().parseNotification(message);
      });
    }
    return null;
  }

  getCurrentEvents(DateTime date, List<PJPModel> pjpListModels) {
    List<PJPModel> list = [];
    debugPrint('getEvent----${pjpListModels.length}');
    for (int index = 0; index < pjpListModels.length; index++) {
      debugPrint(
          '${Utility.shortDate(date)}  -- ${Utility.shortDate(pjpListModels[index].fromDate)}');
      if (Utility.shortDate(date) ==
          Utility.shortDate(pjpListModels[index].fromDate)) {
        list.add(pjpListModels[index]);
      }
    }
    return list;
  }

  syncPjpList() async {
    DBHelper helper = DBHelper();
    DateTime today = DateTime.now();
    List<PJPModel> pjpListModels = await helper.getPjpList();
    DateTime start = DateTime(1, today.month - 1, today.year);
    DateTime end = DateTime(today.day, today.month + 1, today.year);
    kEvents.clear();
    mPjpList.clear();
    mPjpList.addAll(pjpListModels);
    debugPrint('data inserted');
    /*if(pjpListModels!=null){
      Map<DateTime,List<PJPModel>> data = {};
      if(start.isBefore(end)) {
        try {
          data.putIfAbsent(pjpListModels[0].fromDate, () =>
              getCurrentEvents(start, pjpListModels));
          // data.putIfAbsent(pjpListModels[0].fromDate, getCurrentEvents(start,pjpListModels));
          start.add(Duration(days: 1, hours: 23));
        }catch(e){}
      }
      kEvents.addAll(data);
    }*/
  }

  void addEvent() {
    debugPrint('add event');
    //kEvents.addAll(_kEventSource);
    syncPjpList();
    debugPrint('addEvent ');
    setState(() {});
  }

  List<PJPModel> _getEventsForDay(DateTime day) {
    // Implementation example
    debugPrint('add _getEventsForDay');
    if (mPjpList.isEmpty) {
      syncPjpList();
    }
    debugPrint('day is ${day.day}');
    return getCurrentEvents(day, mPjpList); //kEvents[day] ?? [];
  }

  BoxDecoration _getEventDecoration(DateTime day) {
    // Implementation example
    //return kEvents[day] ?? [];
    BoxDecoration decoration = const BoxDecoration(
      color: Colors.indigo,
      shape: BoxShape.circle,
    );
    String todaysDate = DateFormat('dd MMM yyyy').format(day);
    /*if(attendanceEvent.containsKey(todaysDate)){
      var list = attendanceEvent[todaysDate]?.toList();
      if(list?[0].title=='Present'){
        decoration = BoxDecoration(
          color: Colors.red,
          shape: BoxShape.rectangle,
        );
      }else if(list?[0].title=='Holiday'){
        decoration = BoxDecoration(
          color: Colors.red,
          shape: BoxShape.rectangle,
        );
      }
    }*/
    return decoration;
  }

  List<PJPModel> _getEventsForRange(DateTime start, DateTime end) {
    // Implementation example
    final days = daysInRange(start, end);
    debugPrint('_getEventsForRange');
    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });
      debugPrint('_onDaySelected');
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });
    debugPrint('_onRangeSelected');
    // `start` or `end` could be null
    if (start != null && end != null) {
      _selectedEvents.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents.value = _getEventsForDay(start);
    } else if (end != null) {
      _selectedEvents.value = _getEventsForDay(end);
    }
  }

  void onBackClickListener() {
    if (widget._selectedDestination == MENU_HOME) {
      // set up the buttons
      Widget cancelButton = TextButton(
        child: const Text("Cancel"),
        onPressed: () {
          Navigator.of(context).pop(true);
        },
      );
      Widget continueButton = TextButton(
        child: const Text("Exit"),
        onPressed: () {
          Navigator.of(context).pop(true);
          if (Platform.isAndroid) {
            Future.delayed(const Duration(milliseconds: 100), () {
              SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            });
          } else if (Platform.isIOS) {
            exit(0);
          }
        },
      );

      // set up the AlertDialog
      AlertDialog alert = AlertDialog(
        title: const Text("Alert"),
        content: const Text("Would you like to Exit?"),
        actions: [
          cancelButton,
          continueButton,
        ],
      );

      // show the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    } else {
      setState(() {
        widget._selectedDestination = 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    EasyLoading.init();
    FirebaseAnalyticsUtils().enableAnytics();
    FirebaseAnalyticsUtils().sendAnalyticsEvent('HomeScreen');
    //analytics.logAppOpen();
    return WillPopScope(
      onWillPop: () async {
        onBackClickListener();
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        // appBar: AppBar(
        //   title: KidzeeWidget().getAppBarUI(context),
        // ),
        appBar: getAppbar(),
        drawer: getNavigationalDrawar(),
        body: getScreen(),
        bottomNavigationBar: Utility.footer(appVersion),
        /*floatingActionButton:_selectedDestination==MENU_HOME ? FloatingActionButton.extended(
          onPressed: () {
            // Add your onPressed code here!
           */ /* Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => AddNewPjp()));*/ /*
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => AddNewPjp()));

          },
          label: const Text('New PJP'),
          icon: const Icon(Icons.thumb_up),
          backgroundColor: Colors.pink,
        ) : null,*/
      ),
    );
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> checkForUpdate() async {
    InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        _updateInfo = info;
        if (_updateInfo?.updateAvailability ==
            UpdateAvailability.updateAvailable) {
          InAppUpdate.performImmediateUpdate()
              .catchError((e) => showSnack(e.toString()));
        }
      });
    }).catchError((e) {
      //showSnack(e.toString());
    });
  }

  void showSnack(String text) {
    if (_scaffoldKey.currentContext != null) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext!)
          .showSnackBar(SnackBar(content: Text(text)));
    }
  }

  AppBar getAppbar() {
    return AppBar(
      backgroundColor: kPrimaryLightColor,
      centerTitle: false,
      title: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mTitle,
            style: const TextStyle(
                fontSize: 17, color: Colors.white, letterSpacing: 0.53),
          ),
          _currentBusinessName == 'null'
              ? const SizedBox(
                  width: 0,
                )
              : InkWell(
                  onTap: () {
                    showBusinessListDialog(false);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(0),
                    child: Text(_currentBusinessName,
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            letterSpacing: 0.53)),
                  ),
                ),
        ],
      ),
      /*shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),*/
      /*leading: InkWell(
        onTap: () {
          _scaffoldKey.currentState?.openDrawer();
        },
        child: const Icon(
          Icons.subject,
          color: Colors.white,
        ),
      ),*/
      actions: [
        InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EmployeeListScreen(displayName: '')));
          },
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.search,
              size: 20,
            ),
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const UserNotification()));
          },
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.notifications,
              size: 20,
            ),
          ),
        ),
      ],
      /*bottom: PreferredSize(
          child: getAppBottomView(),
          preferredSize: Size.fromHeight(80.0)),*/
    );
  }

  Widget getScreen() {
    debugPrint('getscreen-------- ');
    switch (widget._selectedDestination) {
      case MENU_HOME:
        debugPrint('getscreen-------- $mUserName');
        return HomePageMenu(isBpms, mUserName, email, _profileAvtar);
        break;
      case MENU_ATTENDANCE:
        return AttendanceSummeryScreen(
          displayName: mTitle,
        );
        break;
      case MENU_ATTENDANCE_MARKING:
        return AttendanceMarkingScreen(
            isManager: false, employeeId: employeeId, displayName: '--');
        break;
      case MENU_OUTDOOR:
        return OutdoorScreen(
          displayName: mTitle,
          businessId: businessId,
        );
        break;
      case MENU_LEAVE:
        return LeaveSummeryScreen(
          displayName: mTitle,
        );
        break;
      case MENU_ATTENDANCE_MARKING_APPROVAL:
        return AttendanceManagerScreen(
          employeeId: employeeId,
          listener: this,
        );
        break;
      case MENU_LEAVE_APPROVAL:
        return LeaveManagerScreen(
          employeeId: employeeId,
        );
        break;
      case MENU_OUTDOOR_APPROVAL:
        return OutdoorReqManagerScreen(
          employeeId: employeeId,
        );
        break;
      case MENU_PJP:
        return MyPjpListScreen(mFilterSelection: widget.mPjpFilters);
      case MENU_CVF:
        return MyCVFListScreen();
        break;
      default:
        return _homeScreen(context);
    }
  }

  Widget getHomeScreen() {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 12),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () => selectDestination(MENU_PJP),
            child: /*Expanded(
                  child:*/
                Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.4,
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFF4B39EF),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 3,
                      color: Color(0x39000000),
                      offset: Offset(0, 1),
                    )
                  ],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                      child: Icon(
                        Icons.electric_car,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                      child: Text(
                        'My PJP',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Lexend Deca',
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            /*),*/
          ),
          GestureDetector(
            onTap: () {
              debugPrint('CVF CLICKED');
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MyCVFListScreen()));
            },
            child: /*Expanded(
                  child:*/
                Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.4,
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFF4B39EF),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 3,
                      color: Color(0x39000000),
                      offset: Offset(0, 1),
                    )
                  ],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                      child: Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                      child: Text(
                        'My CVF',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Lexend Deca',
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              /* ),*/
            ),
          ),
        ],
      ),
    );
  }

  Widget getNavigationalDrawar() {
    //debugPrint(_profileImage);
    return Drawer(
      child: getMenu(),
    );
  }

  getImageUrl(String url) {
    String weburl = url.replaceAll('___', '&');
    weburl = Uri.decodeFull(weburl);
    debugPrint(weburl);
    return weburl;
  }

  getMenu() {
    return ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: <Widget>[
        UserAccountsDrawerHeader(
          decoration: BoxDecoration(
              color: kPrimaryLightColor,
              border: Border.all(
                color: LightColors.kYallow,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(5))),
          onDetailsPressed: () {
//            uploadProfilePicture();
            showBusinessListDialog(true);
          },
          accountEmail: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(mDesignation, style: LightColors.subWhiteTextStyle),
              Text(
                _currentBusinessName == 'null' ? '' : _currentBusinessName,
                style: LightColors.subWhiteTextStyle,
              ),
            ],
          ),
          accountName: Text(mTitle, style: LightColors.titleWhiteTextStyle),
          currentAccountPictureSize: const Size.square(60.0),
          currentAccountPicture: GestureDetector(
            onTap: () {
              if (_profileImage.isNotEmpty) {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return DetailScreen(
                      imageUrl: _profileImage,
                      imageList: _profileAvtar,
                      userName: mTitle,
                      listener: this,
                      isViewOnly: false);
                }));
              } else {
                uploadProfilePicture();
              }
            },
            child: Container(
              width: 60.0,
              height: 60.0,
              decoration: BoxDecoration(
                color: kPrimaryLightColor /*const Color(0xff7c94b6)*/,
                image: DecorationImage(
                  image: _profileAvtar != null
                      ? Image.memory(_profileAvtar!).image
                      : NetworkImage(_profileImage),
                  fit: BoxFit.cover,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(50.0)),
                border: Border.all(
                  color: Colors.green,
                  width: 1.0,
                ),
              ),
            ),
          ),
        ),
        Ink(
          color: widget._selectedDestination == MENU_HOME
              ? LightColors.kLightBlue
              : Colors.white,
          child: ListTile(
            leading: SizedBox(
                height: 32.0,
                width: 32.0,
                child: Image.asset('assets/icons/ic_home.png')),
            trailing: widget._selectedDestination == MENU_HOME
                ? const Icon(
                    Icons.bookmark,
                    color: kPrimaryLightColor,
                  )
                : null,
            title: Text(
              'Home',
              style: widget._selectedDestination == MENU_HOME
                  ? LightColors.headerTitleSelected
                  : LightColors.headerTilte,
            ),
            selected: widget._selectedDestination == MENU_HOME,
            onTap: () => selectDestination(MENU_HOME),
          ),
        ),
        const Divider(),
        Ink(
          color: widget._selectedDestination == MENU_LEAVE
              ? LightColors.kLightBlue
              : Colors.white,
          child: ListTile(
            leading: SizedBox(
                height: 32.0,
                width: 32.0,
                child: Image.asset('assets/icons/ic_leave.png')),
            title: Text(
              'Leave',
              style: widget._selectedDestination == MENU_LEAVE
                  ? LightColors.headerTitleSelected
                  : LightColors.headerTilte,
            ),
            trailing: widget._selectedDestination == MENU_LEAVE
                ? const Icon(Icons.bookmark)
                : null,
            selected: widget._selectedDestination == MENU_LEAVE,
            onTap: () => selectDestination(MENU_LEAVE),
          ),
        ),
        Ink(
          color: widget._selectedDestination == MENU_OUTDOOR
              ? LightColors.kLightBlue
              : Colors.white,
          child: ListTile(
            leading: SizedBox(
                height: 32.0,
                width: 32.0,
                child: Image.asset('assets/icons/ic_outdoor.png')),
            title: Text(
              'Outdoor Duty',
              style: widget._selectedDestination == MENU_OUTDOOR
                  ? LightColors.headerTitleSelected
                  : LightColors.headerTilte,
            ),
            trailing: widget._selectedDestination == MENU_OUTDOOR
                ? const Icon(Icons.bookmark)
                : null,
            selected: widget._selectedDestination == MENU_OUTDOOR,
            onTap: () => selectDestination(MENU_OUTDOOR),
          ),
        ),
        Ink(
          color: widget._selectedDestination == MENU_ATTENDANCE
              ? LightColors.kLightBlue
              : Colors.white,
          child: ListTile(
            leading: SizedBox(
                height: 32.0,
                width: 32.0,
                child: Image.asset('assets/icons/ic_attendance.png')),
            title: Text(
              'Attendance Summary',
              style: widget._selectedDestination == MENU_ATTENDANCE
                  ? LightColors.headerTitleSelected
                  : LightColors.headerTilte,
            ),
            trailing: widget._selectedDestination == MENU_ATTENDANCE
                ? const Icon(Icons.bookmark)
                : null,
            selected: widget._selectedDestination == MENU_ATTENDANCE,
            onTap: () => selectDestination(MENU_ATTENDANCE),
          ),
        ),
        Ink(
          color: Colors.white,
          child: ListTile(
            leading: SizedBox(
                height: 32.0,
                width: 32.0,
                child: Image.asset('assets/icons/ic_journey.png')),
            title: const Text('PJP'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyPjpListScreen(
                            mFilterSelection: FilterSelection(
                                filters: [], type: FILTERStatus.MYSELF),
                          )));
            },
          ),
        ),
        Ink(
          color: Colors.white,
          child: ListTile(
            leading: SizedBox(
                height: 32.0,
                width: 32.0,
                child: Image.asset('assets/icons/ic_checklist.png')),
            title: const Text('CVF'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MyCVFListScreen()));
            },
          ),
        ),
        Ink(
          color: widget._selectedDestination == MENU_ATTENDANCE_MARKING
              ? LightColors.kLightBlue
              : Colors.white,
          child: ListTile(
            leading: SizedBox(
                height: 32.0,
                width: 32.0,
                child: Image.asset('assets/icons/ic_attendance_marking.png')),
            title: Text(
              'Attendance Marking',
              style: widget._selectedDestination == MENU_ATTENDANCE_MARKING
                  ? LightColors.headerTitleSelected
                  : LightColors.headerTilte,
            ),
            trailing: widget._selectedDestination == MENU_ATTENDANCE_MARKING
                ? const Icon(Icons.bookmark)
                : null,
            selected: widget._selectedDestination == MENU_ATTENDANCE_MARKING,
            onTap: () => selectDestination(MENU_ATTENDANCE_MARKING),
          ),
        ),
        Container(
          color: LightColors.kLightGray,
          child: const Padding(
            padding: EdgeInsets.only(left: 16, top: 10, bottom: 10),
            child: Text(
              'Approvals',
              style: TextStyle(
                  backgroundColor: LightColors.kLightGray,
                  color: Colors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Ink(
          color: widget._selectedDestination == MENU_LEAVE_APPROVAL
              ? LightColors.kLightBlue
              : Colors.white,
          child: ListTile(
            leading: SizedBox(
                height: 32.0,
                width: 32.0,
                child: Image.asset('assets/icons/ic_leave.png')),
            title: Text(
              'Leave',
              style: widget._selectedDestination == MENU_LEAVE_APPROVAL
                  ? LightColors.headerTitleSelected
                  : LightColors.headerTilte,
            ),
            trailing: widget._selectedDestination == MENU_LEAVE_APPROVAL
                ? const Icon(Icons.bookmark)
                : null,
            selected: widget._selectedDestination == MENU_LEAVE_APPROVAL,
            onTap: () => selectDestination(MENU_LEAVE_APPROVAL),
          ),
        ),
        Ink(
          color: widget._selectedDestination == MENU_OUTDOOR_APPROVAL
              ? LightColors.kLightBlue
              : Colors.white,
          child: ListTile(
            leading: SizedBox(
                height: 32.0,
                width: 32.0,
                child: Image.asset('assets/icons/ic_outdoor.png')),
            title: Text(
              'Outdoor Duty',
              style: widget._selectedDestination == MENU_OUTDOOR_APPROVAL
                  ? LightColors.headerTitleSelected
                  : LightColors.headerTilte,
            ),
            trailing: widget._selectedDestination == MENU_OUTDOOR_APPROVAL
                ? const Icon(Icons.bookmark)
                : null,
            selected: widget._selectedDestination == MENU_OUTDOOR_APPROVAL,
            onTap: () => selectDestination(MENU_OUTDOOR_APPROVAL),
          ),
        ),
        Ink(
          color: widget._selectedDestination == MENU_ATTENDANCE_MARKING_APPROVAL
              ? LightColors.kLightBlue
              : Colors.white,
          child: ListTile(
            leading: SizedBox(
                height: 32.0,
                width: 32.0,
                child: Image.asset('assets/icons/ic_attendance.png')),
            tileColor:
                widget._selectedDestination == MENU_ATTENDANCE_MARKING_APPROVAL
                    ? LightColors.kLightBlue
                    : Colors.white,
            title: Text(
              'Attendance Marking',
              style: widget._selectedDestination ==
                      MENU_ATTENDANCE_MARKING_APPROVAL
                  ? LightColors.headerTitleSelected
                  : LightColors.headerTilte,
            ),
            trailing:
                widget._selectedDestination == MENU_ATTENDANCE_MARKING_APPROVAL
                    ? const Icon(Icons.bookmark)
                    : null,
            selected:
                widget._selectedDestination == MENU_ATTENDANCE_MARKING_APPROVAL,
            onTap: () => selectDestination(MENU_ATTENDANCE_MARKING_APPROVAL),
          ),
        ),
        Ink(
          color: Colors.white,
          child: ListTile(
            leading: SizedBox(
                height: 32.0,
                width: 32.0,
                child: Image.asset('assets/icons/ic_journey.png')),
            title: const Text('PJP'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PJPManagerScreen(
                          employeeId:
                              employeeId) /*MyPjpListScreen(
                          mFilterSelection: FilterSelection(
                              filters: [], type: FILTERStatus.NONE),
                        )*/
                      ));
            },
          ),
        ),
        const Divider(),
        ListTile(
          leading: SizedBox(
              height: 32.0,
              width: 32.0,
              child: Image.asset('assets/icons/ic_logout.png')),
          title: const Text('Log Out'),
          selected: widget._selectedDestination == 0,
          onTap: () => signOut(),
        ),
      ],
    );
  }

  void selectDestination(int index) {
    Navigator.of(context).pop();
    if (false && index == 10) {
    } else {
      setState(() {
        widget._selectedDestination = index;
      });
    }
  }

  signOut() async {
    var hiveBox = await Utility.openBox();
    await Hive.openBox(LocalConstant.KidzeeDB);
    hiveBox.clear();
    hiveBox.close();
    DBHelper helper = DBHelper();
    helper.deleteAllData();
    await Future.delayed(const Duration(seconds: 1));
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => IntroPage(),
        ),
        (route) => false);
    /* if (Platform.isAndroid) {
      Future.delayed(const Duration(milliseconds: 100), () {
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      });
    } else if (Platform.isIOS) {
      exit(0);
    } */
  }

  Widget _homeScreen(BuildContext context) {
    debugPrint('home screen');
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: LightColors.kLightYellow,
        body: SafeArea(
            child: Column(children: <Widget>[
          TableCalendar<PJPModel>(
            firstDay: kFirstDay,
            lastDay: kLastDay,
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            rangeStartDay: _rangeStart,
            rangeEndDay: _rangeEnd,
            calendarFormat: _calendarFormat,
            rangeSelectionMode: _rangeSelectionMode,
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonDecoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(20.0),
              ),
              formatButtonTextStyle: const TextStyle(color: Colors.white),
              formatButtonShowsNext: false,
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              // Weekend days color (Sat,Sun)
              weekendStyle: TextStyle(color: Colors.deepOrangeAccent),
            ),
            // Calendar Dates styling
            calendarStyle: CalendarStyle(
              // Weekend dates color (Sat & Sun Column)
              weekendTextStyle: const TextStyle(color: Colors.red),
              // highlighted color for today
              todayDecoration: const BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.rectangle,
              ),
              // highlighted color for selected day
              selectedDecoration: const BoxDecoration(
                color: Colors.black26,
                shape: BoxShape.rectangle,
              ),
              markerDecoration: _getEventDecoration(_focusedDay),
            ),

            onDaySelected: _onDaySelected,
            onRangeSelected: _onRangeSelected,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
              debugPrint('page changes');
            },
          ),
          const SizedBox(height: 8.0),
          /*Expanded(
            child:*/
          ValueListenableBuilder<List<PJPModel>>(
            valueListenable: _selectedEvents,
            builder: (context, value, _) {
              return ListView.builder(
                itemCount: value.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 4.0,
                    ),
                    child: IntranetEventContainer(
                      event: value[index],
                    ),
                  );
                },
              );
            },
          ),
          //),
        ])));
  }

  @override
  void onStart() {
    Utility.showLoaderDialog(context);
  }

  @override
  void onUploadError(value) {
    Navigator.of(context).pop();
  }

  @override
  void onUploadProgress(int value) {}

  @override
  void onUploadSuccess(value) async {
    if (value is String) {
      Navigator.of(context).pop();
      _profileImage = getImageUrl(value.toString());
      updateProfileImage();
      FirebaseStorageUtil().getProfileImage(employeeId.toString(), this);
    } else if (value is Uint8List) {
      var hiveBox = await Utility.openBox();
      await Hive.openBox(LocalConstant.KidzeeDB);
      var profileImage = base64.encode(value);
      _profileAvtar = base64.decode(profileImage);
      hiveBox.put(LocalConstant.KEY_EMPLOYEE_AVTAR_LIST, profileImage);
    }
    setState(() {});
  }

  @override
  void onClick(int action, value) {
    if (action == LocalConstant.ACTION_BACK) {
      onBackClickListener();
    } else if (action == ACTION_ADD_NEW_IMAGE) {
      uploadProfilePicture();
    }
  }
}

class DetailScreen extends StatelessWidget {
  late String imageUrl;
  late Uint8List? imageList;
  late String userName;
  late onClickListener listener;
  bool isViewOnly;

  DetailScreen(
      {super.key,
      required this.imageUrl,
      required this.imageList,
      required this.userName,
      required this.listener,
      required this.isViewOnly});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryLightColor,
        centerTitle: true,
        title: const Text(
          'Intranet',
          style:
              TextStyle(fontSize: 17, color: Colors.white, letterSpacing: 0.53),
        ),
        actions: !isViewOnly
            ? [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    listener.onClick(ACTION_ADD_NEW_IMAGE, userName);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.add,
                      size: 20,
                    ),
                  ),
                ),
              ]
            : null,
      ),
      body: imageList != null
          ? Image.memory(imageList!)
          : Image.network(imageUrl),
    );
  }
}

/*class Event {

  final String title;
  dynamic mEvent;
  Event(this.title,this.mEvent);


 */ /* final String title;
  final String subtitle;
  final String fromDate;
  final String toDate;


  const Event(this.title,this.subtitle,this.toDate,this.fromDate);

  @override
  String toString() => title;*/ /*
}*/

/*var pjpModel = PJPEventModel(title: 'Employee Training', subtitle: 'Employee Training at CWP-XXX', visitType: 'Training',
    purposeOfVisit: 'Training',
    businessType: 'kidzee', fromDate: '15 Aug', toDate: '18 Aug', boxColor: LightColors.kDarkYellow,icons: 'assets/icons/meeting.png',
    checkInTime: '10:00',isCheckin: true,ampm:'AM');*/

/// Example events.
///
/// Using a [LinkedHashMap] is highly recommended if you decide to use a map.
final kEvents = LinkedHashMap<DateTime, List<PJPModel>>(
  equals: isSameDay,
  hashCode: getHashCode,
);
/*final _kEventSource = Map.fromIterable(List.generate(50, (index) => index),
    key: (item) => DateTime.utc(kFirstDay.year, kFirstDay.month, item * 5),
    value: (item) => List.generate(
        item % 4 + 1, (index) => Event('',pjpModel)))
  ..addAll({
    kToday: [
      Event('',PJPEventModel(title: 'Kidzee Varsova', subtitle: 'Scheduled Center Visit at CWP-XXX', visitType: 'Center Visit',
          purposeOfVisit: 'Center Visit',
          businessType: 'kidzee', fromDate: '23 Aug', toDate: '25 Aug', boxColor: LightColors.kLightGreen,icons: 'assets/icons/visitor.png',
      checkInTime: '10:00',isCheckin: true,ampm:'AM')),
      Event('',PJPEventModel(title: 'Kidzee Banashankari', subtitle: 'Employee Training at CWP-XXX', visitType: 'Training',
          purposeOfVisit: 'Training',
          businessType: 'kidzee', fromDate: '25 Aug', toDate: '28 Aug', boxColor: LightColors.kDarkYellow,icons: 'assets/icons/training.png',
          checkInTime: '12:30',isCheckin: false,ampm:'PM')),
      Event('',PJPEventModel(title: 'Kidzee Chembur', subtitle: 'Employee Training at CWP-XXX', visitType: 'Training',
          purposeOfVisit: 'Training',
          businessType: 'kidzee', fromDate: '25 Aug', toDate: '2  8 Aug', boxColor: LightColors.kDarkYellow,icons: 'assets/icons/meeting.png',
          checkInTime: '04:00',isCheckin: true,ampm:'PM')),
    ],
  });*/

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 2, kToday.day);
