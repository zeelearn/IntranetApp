import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../api/request/zoho_request_model.dart';
import '../utils/theme/colors/light_colors.dart';

class AllLegalListPage extends StatelessWidget {
  const AllLegalListPage(
      {required this.title, required this.requestList, super.key});
  final String title;
  final List<Requests> requestList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: requestList.length,
              itemBuilder: (context, i) {
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Agreement Date: ${requestList[i].createdTime == null ? '' : DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(requestList[i].createdTime!.toInt()))}',
                          style: LightColors.textHeaderStyle13,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Agreement Id: ${requestList[i].requestId == null ? '' : requestList[i].requestId!}',
                          style: LightColors.textHeaderStyle13,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          requestList[i].requestName ?? '',
                          style: LightColors.textbigStyle,
                        ),
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
                            'Expire on : ${requestList[i].expireBy == null ? '' : DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(requestList[i].expireBy!.toInt()))}',
                            style: LightColors.textHeaderStyle13,
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
