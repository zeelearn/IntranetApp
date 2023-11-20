import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../api/APIService.dart';
import '../../../../api/ServiceHandler.dart';
import '../../../../api/request/bpms/get_task_comments.dart';
import '../../../../api/request/bpms/insert_attachment.dart';
import '../../../../api/request/bpms/update_task.dart';
import '../../../../api/response/bpms/franchisee_details_response.dart';
import '../../../../api/response/bpms/getTaskDetailsResponseModel.dart';
import '../../../../api/response/bpms/get_comments_response.dart';
import '../../../../api/response/bpms/insert_attachment_response.dart';
import '../../../../api/response/bpms/project_task.dart';
import '../../../../api/response/bpms/update_task_response.dart';
import '../../../../api/response/uploadimage.dart';
import '../../../helper/LocalConstant.dart';
import '../../../helper/constants.dart';
import '../../../helper/helpers.dart';
import '../../../helper/math_utils.dart';
import '../../../helper/utils.dart';
import '../../../iface/onClick.dart';
import '../../../iface/onResponse.dart';
import '../../../utils/theme/colors/light_colors.dart';
import '../../../widget/VideoPlayer.dart';
import '../../../widget/button_widget.dart';
import '../../../widget/image_viewer.dart';
import '../data/enums/auth_status.dart';
import '../data/providers/auth_provider.dart';
import 'MessageModel.dart';
import 'OwnMessgaeCrad.dart';
import 'camera/CameraScreen.dart';

/// This class design by Suhhir Patil on behalf of zeelearn
/// on 27th June 2023
/// *

class ChatPage extends ConsumerStatefulWidget {
  ProjectTaskModel taskModel;

  ChatPage({Key? key, required this.taskModel}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage>
    implements onResponse, onClickListener {
  bool show = false;
  static bool isLoading = false;
  FocusNode focusNode = FocusNode();
  bool sendButton = false;
  List<CommentModel> messages = [];
  final TextEditingController _controller = TextEditingController();

  final ScrollController _scrollController = ScrollController();
  String _status = '';
  bool isAnyChange = false;

  String _statusValue = 'Select Status';
  List<String> statusOptions = [
    'Select Status',
    'In Progress',
    'Cancelled',
    'Completed'
  ];

  String lastsync = '';
  static List<String> imgList = [];

  String _menuName = '';

  @override
  void initState() {
    _controller.text = "";
    super.initState();
    loadTaskComments();

  }


  gsOfflineData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isInternet = await Utility.isInternet();
    var chatSummery = prefs.getString(getId());
    bool isOfflineEligble = await Utility.isOfflineEligble(context, prefs.getString('sync_${getId()}') ?? '');
    if (chatSummery == null) {
      isInternet = false;
      isLoading = false;
      loadTaskComments();
    } else if (isOfflineEligble || !isInternet) {
      isInternet = true;
      isLoading = false;
      getLocalData(chatSummery);
    } else {
      loadTaskComments();
    }
  }

  getLocalData(data) {
    bool isLoad = false;
    try {
      messages.clear();
      isLoading = false;
      GetCommentResponse response = GetCommentResponse.fromJson(
        json.decode(data!),
      );
      print(response.toJson());
      messages.addAll(response.commentModelList);
      setState(() {});
      setState(() {});
      isLoad = true;
    } catch (e) {
      print(e);
      isLoad = false;
    }
    return isLoad;
  }

  generateMenu() {
    if (widget.taskModel.statusname == 'Pending') {
      _menuName = 'Mark In Progress';
    } else if (widget.taskModel.statusname == 'In Progress') {
      _menuName = 'Completed';
    }
  }

  initData() async {
    //await getUserInfo();
    imgList.clear();
    print('chat initData-------------------------${widget.taskModel.statusname}');
    if (widget.taskModel.files.isNotEmpty) {
      print('initData---${widget.taskModel.files}');
      imgList.addAll(widget.taskModel.files.split(','));
    }
    await Hive.openBox(LocalConstant.communicationKey); // settings
    Hive.box(LocalConstant.communicationKey).watch(key: 'imageUpload').listen((event) {
      print('Event Captured ${event}');
      setState(() {
        //counter = event.value;
        //FileUploadModel
      });
    });
  }

  String userId = '';
  String francId = '';

  Future<void> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    francId = prefs.getString(LocalConstant.KEY_FRANCHISEE_ID) as String;
    userId = prefs.getString(LocalConstant.KEY_UID) as String;
    loadTaskComments();
  }

  void loadTaskComments() {
    GetTaskCommentRequest request = GetTaskCommentRequest(task_id: widget.taskModel.id);
    IntranetServiceHandler().getTaskComments(request, this);
    initData();
  }

  void sendMessage(String message) {
    CommentModel messageModel = CommentModel(
        comment: message,
        CreatedBy: userId,
        CreatedDate: Utility.parseShortDate(''),
        createdtime: DateTime.now().toString().substring(10, 16),
        ModifiedBy: userId,
        ModifiedDate: Utility.parseShortDate(''),
        createduser: userId);
    //setMessage("source", messageModel);
    updateTaskDetails(widget.taskModel, widget.taskModel.statusname, message);
    /*socket.emit("message",{"message": message, "sourceId": sourceId, "targetId": targetId});*/
  }

  void setMessage(String type, CommentModel messageModel) {
    /*MessageModel messageModel = MessageModel(
        type: type,
        message: message,
        time: DateTime.now().toString().substring(10, 16));
    print(messages);*/
    isAnyChange = true;
    List<CommentModel> temp = [messageModel];
    temp.addAll(messages);
    messages.clear();
    messages.addAll(temp);
    print('length ${messages.length}');
    if (messages.length > 4 && widget.taskModel.statusname != 'Pending') {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
    }
    //messages.reversed;
    /*setState(() {

    });*/
  }

  Widget getImages() {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 150,
              child: ListView.builder(
                itemCount: imgList.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) => Container(
                  margin: const EdgeInsets.all(5),
                  color: Colors.white24,
                  child: InkWell(
                    onTap: () async {
                      await Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return (imgList[index].contains('.mp4') ||
                                imgList[index].contains('.m3u8'))
                            ? VideoPlayer(
                                path: imgList[index],
                                Title: imgList[index],
                              )
                            : ImageViewer(imageUrl: imgList[index].toString());
                      }));
                    },
                    child: Center(
                      child: (imgList[index].contains('.mp4') ||
                              imgList[index].contains('.m3u8'))
                          ? const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.video_camera_back,
                                size: 50,
                              ),
                            ) /* FutureBuilder<ThumbnailResult>(
                              future: GEtThumbNail.genThumbnail(imgList[index]),
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                if (snapshot.hasData) {
                                  final image = snapshot.data.image;
                                  final width = snapshot.data.width;
                                  final height = snapshot.data.height;
                                  final dataSize = snapshot.data.dataSize;
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      image,
                                    ],
                                  );
                                } else if (snapshot.hasError) {
                                  return Container(
                                    padding: const EdgeInsets.all(8.0),
                                    color: Colors.red,
                                    child: Text(
                                      "Error:\n${snapshot.error.toString()}",
                                    ),
                                  );
                                } else {
                                  return const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        CircularProgressIndicator(),
                                      ]);
                                }
                              },
                            ) */
                          /* const SizedBox(
                              height: 50,
                              width: 50,
                              child: Icon(
                                Icons.video_collection,
                              )) */
                          : loadImage(imgList[index], File(imgList[index])),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget loadImage(String networkImage, File imageFile) {
    return Card(
        borderOnForeground: true,
        color: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(2),
          child: networkImage.contains('file')
              ? Image(
                  image: FileImage(imageFile),
                  width: 100,
                  height: 150,
                )
              : FadeInImage(
                  placeholder:
                      const AssetImage('assets/images/placeholder.png'),
                  image: NetworkImage(networkImage),
                  imageErrorBuilder: (context, error, stackTrace) {
                    return Image(image: FileImage(imageFile));
                  },
                  fit: BoxFit.cover,
                ),
        ));
  }

  final List<Widget> imageSliders = imgList
      .map((item) => Container(
            child: Container(
              margin: const EdgeInsets.all(5.0),
              child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                  child: Stack(
                    children: <Widget>[
                      Image.network(
                        item,
                        fit: BoxFit.cover,
                        width: 1000,
                        height: 100,
                      ),
                    ],
                  )),
            ),
          ))
      .toList();

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    print("build isLoading ${auth.loading} ");
    if(auth.loading == AuthStatus.authenticated){
      print('loading status false');
      isLoading = false;
    }
    final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
        GlobalKey<RefreshIndicatorState>();
    final descriptionKey = GlobalKey<FormState>();

    return SafeArea(
      child: RefreshIndicator(
          key: refreshIndicatorKey,
          color: Colors.white,
          backgroundColor: Colors.blue,
          strokeWidth: 4.0,
          onRefresh: () async {
            // Replace this delay with the code to be executed during refresh
            //ref.read(authNotifierProvider.notifier).refreshCommunication();
            ref.read(authNotifierProvider.notifier).checkAuthStatus();
            return Future<void>.delayed(const Duration(seconds: 3));
          },
          // Pull from top to show refresh indicator.
          child: chatView(widget.taskModel)),
    );
  }

  afterFileUploading(UploadImageResponse value) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      insertTaskAttachment(value.imageModel![0].location);
      updateImage(value.imageModel![0].location);
      print('afterFileUploading 384');
      //ref.read(authNotifierProvider.notifier).checkAuthStatus();
      setState(() {
        isLoading = false;
      });
    });
  }

  chatView(ProjectTaskModel model) {
    return Stack(
      children: [
        Image.asset(
          "assets/images/whatsapp_Back.png",
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
              backgroundColor: kPrimaryLightColor,
              leading: InkWell(
                onTap: () {

                  Navigator.of(context).pop();
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_back,
                      size: 24,
                    ),
                  ],
                ),
              ),
              title: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.taskModel.title,
                        style: const TextStyle(
                          fontSize: 14.0,
                        ),
                      ),
                      Text(
                        lastsync,
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      )
                    ],
                  ),
              actions: widget.taskModel.statusname
                      .toLowerCase()
                      .contains('progres')
                  ? [
                      InkWell(
                        onTap: () {
                          _status = 'BP Completed';
                          //Utility.confirmalert(context, 'Are you sure?', 'Are you sure to Complete the Task', this);
                          Utility.getConfirmation(context, 'Are you sure you want to complete the task?', '', this);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            color: Colors.white,
                            child: Center(
                              child: Text('  Mark Completed  ',
                                style: LightColors.textHeaderStyle13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]
                  : null,
          ),
          body: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: isLoading ? Utility.showLoader() : WillPopScope(
              child: widget.taskModel.statusname.isEmpty ||
                    widget.taskModel.statusname == 'Pending'
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        showBottomSheetStartTask1(context, widget.taskModel)
                      ],
                    )
                  : Column(
                      children: [
                        /*StreamBuilder<Map<String, dynamic>?>(
                          stream: FlutterBackgroundService().on('update'),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox.shrink();
                            }

                            final data = snapshot.data!;
                            debugPrint('Response from background is - $data');

                            if (data.containsKey('success')) {
                              UploadImageResponse value =
                                  UploadImageResponse.fromJson(
                                      jsonDecode(jsonEncode(data['success'])));

                              imgList.add(value.imageModel![0].location);

                              afterFileUploading(value);

                              var file = File(data['videoUrl']);

                              debugPrint(
                                  'new video name is - ${value.imageModel![0].location.split('/').last.split('.').first}');

                              var path = file.path;
                              var lastseperator =
                                  path.lastIndexOf(Platform.pathSeparator);
                              var newpath =
                                  '${path.substring(0, lastseperator + 1)}${value.imageModel![0].location.split('/').last.split('.').first}.mp4';
                              file.renameSync(newpath);
                            } else if (data.containsKey('progress')) {
                              debugPrint('data on progress is - $data');
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                    child: Column(
                                  children: [
                                    const Text('Uploading File wait'),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    CircularProgressIndicator(
                                      value: data['progress']['bytes'] /
                                          data['progress']['totalbytes'],
                                      strokeWidth: 5,
                                      color: Colors.red,
                                    ),
                                  ],
                                )),
                              );
                            } else {
                              WidgetsBinding.instance
                                  .addPostFrameCallback((timeStamp) {
                                Utility.showMessageCallback(
                                    context, 'Alert', data['error'], this);
                              });
                            }

                            return const SizedBox.shrink();
                          },
                        ),*/
                        Container(
                          child: imgList.isNotEmpty
                              ? Card(
                                  margin: const EdgeInsets.only(
                                      left: 2, right: 2, bottom: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                  child: getImages())
                              : const Text(''),
                        ),
                        Expanded(
                          // height: MediaQuery.of(context).size.height - 150,
                          child: ListView.builder(
                            shrinkWrap: true,
                            reverse: true,
                            controller: _scrollController,
                            itemCount: messages.length + 1,
                            itemBuilder: (context, index) {
                              if (index == messages.length) {
                                return Container(
                                  height: 70,
                                );
                              }
                              return OwnMessageCard(
                                message: messages[index].comment,
                                time: Utility.parseShortTime(
                                    messages[index].CreatedDate),
                              );
                            },
                          ),
                        ),
                        widget.taskModel.statusname
                                .toLowerCase()
                                .contains('progres')
                            ? Align(
                                alignment: Alignment.bottomCenter,
                                child: SizedBox(
                                  height: 70,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Row(
                                        children: [
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                60,
                                            child: Card(
                                              margin: const EdgeInsets.only(
                                                  left: 2, right: 2, bottom: 8),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10, right: 10),
                                                child: TextFormField(
                                                  key: _descriptionKey,
                                                  controller: _controller,
                                                  focusNode: focusNode,
                                                  textAlignVertical:
                                                      TextAlignVertical.center,
                                                  keyboardType:
                                                      TextInputType.multiline,
                                                  maxLines: 5,
                                                  minLines: 1,
                                                  onChanged: (value) {
                                                    if (value.isNotEmpty) {
                                                      setState(() {
                                                        sendButton = true;
                                                      });
                                                    } else {
                                                      setState(() {
                                                        sendButton = false;
                                                      });
                                                    }
                                                  },
                                                  decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    hintText: "Type a message",
                                                    hintStyle: const TextStyle(color: Colors.grey),
                                                    suffixIcon: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        IconButton(
                                                          icon: const Icon(Icons
                                                              .attach_file),
                                                          onPressed: () {
                                                            showModalBottomSheet(
                                                                backgroundColor:
                                                                    Colors
                                                                        .transparent,
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (builder) =>
                                                                        bottomSheet());
                                                          },
                                                        ),
                                                        IconButton(
                                                          icon: const Icon(
                                                              Icons.camera_alt),
                                                          onPressed: () async {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) =>
                                                                        CameraScreen(
                                                                          taskName: widget
                                                                              .taskModel
                                                                              .title,
                                                                        ))).then(
                                                                (value) async {
                                                              log('Response from CameraScreen is - $value');
                                                              if (value !=null) {
                                                                setState(() {
                                                                  isLoading = true;
                                                                });
                                                                if(value is MessageModel) {
                                                                  MessageModel model = value;
                                                                  //uploadImage(model.path);
                                                                  APIService().uploadImage(userId,model.path!,listener: this);
                                                                }else{

                                                                  APIService().uploadImage(userId,value,isVideoFile:true,listener: this);
                                                                }
                                                              }
                                                            });
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                    contentPadding:
                                                        const EdgeInsets.all(5),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 8,
                                              right: 2,
                                              left: 2,
                                            ),
                                            child: CircleAvatar(
                                              radius: 25,
                                              backgroundColor:
                                                  const Color(0xFF128C7E),
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons.send,
                                                  /*sendButton ? Icons.send : Icons.mic,*/
                                                  color: Colors.white,
                                                ),
                                                onPressed: () {
                                                  if (sendButton) {
                                                    _scrollController.animateTo(
                                                        _scrollController
                                                            .position
                                                            .maxScrollExtent,
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    300),
                                                        curve: Curves.easeOut);
                                                    sendMessage(
                                                        _controller.text);
                                                    _controller.clear();
                                                    setState(() {
                                                      sendButton = false;
                                                    });
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(),
                                    ],
                                  ),
                                ),
                              )
                            : const SizedBox(
                                width: 0,
                              ),
                      ],
                    ),
              onWillPop: () {
                print('back button listener');
                if (show) {
                  setState(() {
                    show = false;
                  });
                } else {
                  if (isAnyChange) {
                    Navigator.pop(context, widget.taskModel);
                  } else {
                    Navigator.of(context).pop();
                  }
                }
                return Future.value(false);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomSheet() {
    return SizedBox(
      height: 200,
      width: MediaQuery.of(context).size.width,
      child: Card(
        margin: const EdgeInsets.all(18.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /*iconCreation(
                      Icons.insert_drive_file, Colors.indigo, LocalConstant.ACTION_PDF),
                  SizedBox(
                    width: 40,
                  ),*/
                  iconCreation(Icons.camera_alt, Colors.pink,
                      LocalConstant.ACTION_CAMERA),
                  const SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.insert_photo, Colors.purple,
                      LocalConstant.ACTION_GALLERY),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget iconCreation(IconData icons, Color color, String text) {
    return InkWell(
      onTap: () {
        onClick(LocalConstant.ACTION_USER_EVENT, text);
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color,
            child: Icon(
              icons,
              // semanticLabel: "Help",
              size: 29,
              color: Colors.white,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              // fontWeight: FontWeight.w100,
            ),
          )
        ],
      ),
    );
  }

  showImagePicker(source) async {
    final ImagePicker picker = ImagePicker();
    if (source == ImageSource.gallery || source == ImageSource.camera) {
      XFile? photo;
      photo = await picker.pickImage(source: source, imageQuality: 72);
      if (photo != null) {
        print('image upload');
        setState(() {
          isLoading=true;
        });
        APIService().uploadImage(userId, photo.path, listener: this);
      }
    } else {
      print('image not found');
    }
  }

  void updateTaskDetails(ProjectTaskModel item, String status, String remark) {
    _status = status;
    isAnyChange = true;
    CommentModel messageModel = CommentModel(
        comment: remark,
        CreatedBy: userId,
        CreatedDate: Utility.getServerDate(),
        createdtime: DateTime.now().toString().substring(10, 16),
        ModifiedBy: userId,
        ModifiedDate: Utility.getServerDate(),
        createduser: userId);
    setMessage("source", messageModel);
    UpdateBpmsTaskRequest request = UpdateBpmsTaskRequest(
        taskid: int.parse(item.id),
        status: status,
        remark: remark,
        startDate: widget.taskModel.pStartDate.isEmpty
            ? Utility.getServerDate()
            : widget.taskModel.startDate,
        endDate: Utility.getServerDate(),
        userId: userId);
    IntranetServiceHandler().updateTaskDetails(request, true, this);
    //Navigator.of(context, rootNavigator: true).pop('dialog');
  }

  void insertTaskAttachment(String filepath) {
    setState(() {
      isLoading = true;
    });
    ProjectTaskModel item = widget.taskModel;
    InsertTaskAttachmentRequest request = InsertTaskAttachmentRequest(
        taskId: item.id, filePath: filepath, userId: userId);
    IntranetServiceHandler().insertTaskAttachment(request, this);
  }

  final _priorityKey = GlobalKey<FormState>();
  final _statusKey = GlobalKey<FormState>();
  final _descriptionKey = GlobalKey<FormState>();
  final TextEditingController _descriptinoController = TextEditingController();

  int ACTION_DROPDOWN_PRIORITY = 1001;
  int ACTION_DROPDOWN_STATUS = 1002;

  Widget showBottomSheetStartTask(BuildContext context, ProjectTaskModel item) {
    return isLoading
        ? Utility.showLoader()
        : SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Card(
              margin: const EdgeInsets.all(18.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: size.width,
                        child: Text(
                          'Update Task ',
                          style: LightColors.textHeaderStyle16,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /*getDropdownField(_priorityKey, 'Select Priority', _priorityValue, priorityOptions,this, size, size.width * 0.4,ACTION_DROPDOWN_PRIORITY),
                  SizedBox(
                    width: 10,
                  ),*/
                        getDropdownField(
                            _statusKey,
                            'Select Status',
                            _statusValue,
                            statusOptions,
                            this,
                            size,
                            size.width * 0.4,
                            ACTION_DROPDOWN_STATUS),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    getTextAreaField(
                        _descriptionKey,
                        _descriptinoController,
                        'Description',
                        Icons.description,
                        size,
                        size.width * 0.83),
                    Padding(
                      padding: const EdgeInsets.all(0),
                      child: ButtonWidget(
                          text: 'Update',
                          backColor: false
                              ? [
                                  Colors.black,
                                  Colors.black,
                                ]
                              : const [Color(0xff92A3FD), Color(0xff9DCEFF)],
                          textColor: const [
                            Colors.white,
                            Colors.white,
                          ],
                          onPressed: () async {
                            print('onPress calleed');
                            //Navigator.of(context).pop();
                            updateTaskDetails(item, _statusValue,
                                _descriptinoController.text.toString());
                            /*if (userName.trim().isEmpty) {
                        buildSnackError('Please Enter your userName',context,size,
                        );
                      }*/
                          }),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  int getStatus(String statusName) {
    int status = 1;
    switch (statusName) {
      case 'Pending':
        status = 1;
        break;
      case 'In Progress':
        status = 2;
        break;
      case 'Cancelled':
        status = 3;
        break;
      case 'Completed':
        status = 4;
        break;
    }
    return status;
  }

  Widget showBottomSheetStartTask1(BuildContext context, ProjectTaskModel item) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 250,
      child: Card(
        margin: const EdgeInsets.all(18.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: size.width,
                  child: Text(
                    item.title,
                    style: LightColors.textHeaderStyle16,
                  ),
                ),
              ),
              const Divider(
                thickness: 1,
              ),
              const SizedBox(
                width: 10,
              ),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: size.width,
                  child: Text(
                    widget.taskModel.statusname == 'Pending'
                        ? '${item.title} Task still not started, Do you want to Start the task'
                        : 'Are you sure to complete the ${item.title}',
                    style: LightColors.textHeaderStyle16,
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              SizedBox(
                width: size.width * 0.7,
                child: Padding(
                  padding: const EdgeInsets.all(0),
                  child: ButtonWidget(
                      text: 'Let\'s Start',
                      backColor: false
                          ? [
                              Colors.black,
                              Colors.black,
                            ]
                          : const [Color(0xff92A3FD), Color(0xff9DCEFF)],
                      textColor: const [
                        Colors.white,
                        Colors.white,
                      ],
                      onPressed: () async {
                        widget.taskModel.statusname = 'In Progress';
                        isAnyChange = true;
                        updateTaskDetails(item, 'In Progress',
                            '${item.title} task has been started');
                      }),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void onError(value) {
    //Navigator.pop(context);
    print('onError');
    setState(() {
      isLoading = false;
    });
  }

  @override
  void onStart() {
    print('onStart');
  }

  getId() {
    return 'task_${widget.taskModel.mtaskId}';
  }

  saveComments(String json) async {
    if (json != 'null' && json.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString(getId(), json);
      prefs.setString('sync_${getId()}', Utility.formatDate());
    }
  }

  @override
  void onSuccess(value) {
    print('onSuccess');
    print('in BP COmpltedadadakldnakldn123 $value $_status');

    setState(() {
      isLoading = false;
    });
    if (value is UpdateBpmsTaskResponse) {
      UpdateBpmsTaskResponse responseModel = value;
      widget.taskModel.statusname = _status;
      print(_status);
      print(responseModel.toJson());
      ref
          .read(authNotifierProvider.notifier)
          .updateMessage(widget.taskModel, _controller.text.toString());
      if (_status == 'In Progress') {

      }else if (_status == 'BP Completed') {
        widget.taskModel.statusname = 'BP Completed';
        widget.taskModel.status = getStatus(_status);
        print('in BP COmpltedadadakldnakldn');
        isAnyChange = true;
        Navigator.of(context).pop();
      }
    } else if (value is GetCommentResponse) {
      GetCommentResponse commentResponse = value;
      messages.clear();
      String json = jsonEncode(commentResponse);
      saveComments(json);
      if (commentResponse.commentModelList.isNotEmpty) {
        messages.addAll(commentResponse.commentModelList);
        //messages.reversed;
        if (messages.isNotEmpty) {
          lastsync =
              'last sync is ${Utility.parseShortTime(messages[0].CreatedDate)}';
        }
      }
       setState(() {});
    } else if (value is InsertTaskAttachmentResponse) {
      isAnyChange = true;
      InsertTaskAttachmentResponse response = value;
      if (response.data.isNotEmpty) {
        Utility.showMessage(context, response.data[0].msg);
      }
    }
  }

  updateImage(String url) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String franchiseeId =
          prefs.getString(LocalConstant.KEY_FRANCHISEE_ID) as String;
      var taskDetails = prefs.getString('synctask_$franchiseeId');
      print('task detasil $taskDetails');
      GetTaskDetailsResponseModel response =
          GetTaskDetailsResponseModel.fromJson(json.decode(taskDetails!));
      for (int index = 0; index < response.taskDetail.length; index++) {
        if (response.taskDetail[index].id == widget.taskModel.id) {
          response.taskDetail[index].files =
              '${response.taskDetail[index].files}, $url';
          print('image update ${response.taskDetail[index].title}');
        }
      }
      String savejson = jsonEncode(response);
      saveTaskDetails(savejson, franchiseeId);
    } catch (e) {
      print(e);
    }
  }

  saveTaskDetails(String json, String franchiseeId) async {
    if (json != 'null' && json.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('synctask_$franchiseeId', json);
      print(json);
    }
  }

  /*uploadImage(value) async {
    print('upload image ${value}');
    DBHelper dbHelper = DBHelper();
    dbHelper.insertSyncData(
        FileUploadModel(mTaskId: widget.taskModel.id, path: value, userId: userId, request: Utility.getFileName(value),).toJson(),
        LocalConstant.ACTION_BACKGROUND_FILE_UPLOAD,
        1);

    final flutterService = FlutterBackgroundService();
    if (!await flutterService.isRunning()) {
      await initializeService();
    }else{
      print('servie is running');
    }
  }*/

  @override
  void onClick(int action, value) {
    print('click listener action $action value $value');
    setState(() {
      isLoading = false;
    });
    if(action == Utility.ACTION_CONFIRM){
      updateTaskDetails(widget.taskModel, 'BP Completed', 'BP Completed');
    }else if (action == 0 && value == 0) {
      //widget.clickListener.onClick(action, value);
    } else if (action == ACTION_DROPDOWN_STATUS) {
      _statusValue = value;
    } else if (action == LocalConstant.ACTION_USER_EVENT) {
      Navigator.of(context).pop();
      switch (value) {
        case LocalConstant.ACTION_UPDATE_STATUS:
          showModalBottomSheet(
              backgroundColor: Colors.transparent,
              context: context,
              builder: (builder) =>
                  showBottomSheetStartTask(context, widget.taskModel));
          break;
        case LocalConstant.ACTION_CAMERA:
          showImagePicker(ImageSource.camera);
          break;
        case LocalConstant.ACTION_GALLERY:
          showImagePicker(ImageSource.gallery);
          break;
      }
    } else if (action == Utility.ACTION_IMAGE_UPLOAD_RESPONSE_ERROR) {
      print('ACTION_IMAGE_UPLOAD_RESPONSE_ERROR');
      setState(() {
        isLoading = false;
      });
    } else if (action == Utility.ACTION_IMAGE_UPLOAD_RESPONSE_OK) {
      print('ACTION_IMAGE_UPLOAD_RESPONSE_OK');
      setState(() {
        isLoading = false;
      });
      if (value is UploadImageResponse) {

        UploadImageResponse response = value;
        if (value.message.contains('Successfully')) {
          imgList.add(value.imageModel![0].location);
          insertTaskAttachment(value.imageModel![0].location);
          updateImage(value.imageModel![0].location);
          setState(() {
            isLoading=false;
          });
          print('1297 image Response');
          //ref.read(authNotifierProvider.notifier).checkAuthStatus();
        } else {
          Utility.showMessageCallback(context, 'Alert', value.message, this);
        }
        //Navigator.of(context, rootNavigator: true).pop('dialog');
      }
    } else if (action == 111) {
      ProjectTaskModel taskModel = value;
      //updateTaskDetails(response);
      //showChatScreen(context, taskModel);
      /*showModalBottomSheet(
          backgroundColor:
          Colors.transparent,
          context: context,
          builder: (builder) =>
              showBottomSheetEditTask(context,model));*/
    }
  }
}
