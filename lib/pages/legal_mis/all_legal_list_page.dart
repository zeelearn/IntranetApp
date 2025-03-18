import 'package:Intranet/api/APIService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saathi/service/networking/apiService.dart';

import '../../api/request/zoho_request_model.dart';
import '../../api/request/zoho_request_model.dart' as zohoaction;
import '../utils/toastmsg.dart';
import '../widget/MyWebSiteView.dart';

class AllLegalListPage extends StatefulWidget {
  const AllLegalListPage({required this.email, super.key});
  final String email;

  @override
  State<AllLegalListPage> createState() => _AllLegalListPageState();
}

class _AllLegalListPageState extends State<AllLegalListPage> {
  bool isLoading = true;

  ZohoRequestModel? zohoRequestModel;

  

  @override
  void initState() {
    getAllRequest();
    super.initState();
  }

  getAllRequest() async {
    APIService apiService = APIService();
    zohoRequestModel = await apiService.getRecipientList(widget.email);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.email),
      ),
      body: Column(
        children: [
          Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : zohoRequestModel?.error != null
                      ? Center(child: Text(zohoRequestModel!.error!))
                      : GridView.builder(gridDelegate: , itemBuilder: itemBuilder) /* ListView.builder(
                          itemCount: zohoRequestModel?.requests?.length ?? 0,
                          itemBuilder: (context, i) {
                            return Card(
                              margin: const EdgeInsets.all(10),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            'Agreement Date: ${zohoRequestModel?.requests?[i].createdTime == null ? '' : DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(zohoRequestModel!.requests![i].createdTime!.toInt()))}'),
                                        Text(
                                            'Request Id: ${zohoRequestModel?.requests?[i].requestId == null ? '' : zohoRequestModel!.requests![i].requestId!}'),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(zohoRequestModel!
                                            .requests![i].requestName ??
                                        ''),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    /*  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        ElevatedButton(
                                            onPressed: () async {
                                              for (zohoaction.Actions act
                                                  in zohoRequestModel!
                                                          .requests![i]
                                                          .actions ??
                                                      []) {
                                                if (act.recipientEmail ==
                                                        widget.email &&
                                                    act.actionStatus !=
                                                        "SIGNED" &&
                                                    act.actionStatus !=
                                                        "APPROVED") {
                                                  var response = await APIService()
                                                      .getViewDocumentURl(
                                                          requestId: zohoRequestModel
                                                                  ?.requests?[i]
                                                                  .requestId ??
                                                              '' /* '57292000000494235' */,
                                                          actionId: act
                                                                  .actionId ??
                                                              '' /* '57292000000494330' */);
                                                  response.either(
                                                    (left) => ToastMessage()
                                                        .showErrorToast(left),
                                                    (right) {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                MyWebsiteView(
                                                              title: 'title',
                                                              url: right,
                                                            ),
                                                          ));
                                                    },
                                                  );
                                                }
                                              }
                                            },
                                            child: const Text('View Details')),
                                        ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        MyWebsiteView(
                                                      title: 'title',
                                                      url:
                                                          'https://sign.zoho.in/zs/60026957733#/request/details/${zohoRequestModel!.requests![i].requestId ?? ''}',
                                                    ),
                                                  ));
                                            },
                                            child: const Text('Track '))
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ), */
                                    Container(
                                      alignment: Alignment.bottomRight,
                                      child: Text(
                                          'Expire on : ${zohoRequestModel?.requests?[i].expireBy == null ? '' : DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(zohoRequestModel!.requests![i].expireBy!.toInt()))}'),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ) */)
        ],
      ),
    );
  }
}
