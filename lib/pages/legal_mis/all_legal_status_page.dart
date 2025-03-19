import 'package:Intranet/api/APIService.dart';
import 'package:Intranet/pages/utils/theme/colors/light_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saathi/service/networking/apiService.dart';

import '../../api/request/zoho_request_model.dart';
import '../../api/request/zoho_request_model.dart' as zohoaction;
import '../helper/LightColor.dart';
import '../helper/constants.dart';
import '../utils/toastmsg.dart';
import '../widget/MyWebSiteView.dart';
import 'all_legal_list_page.dart';
import 'request_status_model.dart';

class AllLegalStatusPage extends StatefulWidget {
  const AllLegalStatusPage({required this.email, super.key});
  final String email;

  @override
  State<AllLegalStatusPage> createState() => _AllLegalStatusPageState();
}

class _AllLegalStatusPageState extends State<AllLegalStatusPage> {
  bool isLoading = true;

  ZohoRequestModel? zohoRequestModel;

  List<RequestStatusModel> requestStatusList = [];

  @override
  void initState() {
    getAllRequest();
    super.initState();
  }

  getAllRequest() async {
    zohoRequestModel = await APIService().getRecipientList(widget.email);
    requestStatusList.addAll(getStatusCounts(zohoRequestModel?.requests ?? []));
    setState(() {
      isLoading = false;
    });
  }

  List<RequestStatusModel> getStatusCounts(List<Requests> requestsList) {
    Map<String, int> statusCount = {};

    for (var request in requestsList) {
      if (request.requestStatus != null) {
        statusCount[request.requestStatus!] =
            (statusCount[request.requestStatus!] ?? 0) + 1;
      }
    }

    String getDisplayName(String status) {
      if (status == 'draft') {
        return 'All Drafts';
      } else if (status == 'inprogress') {
        return 'In - Progress Agreements';
      } else if (status == 'pending') {
        return 'Pending Agreements';
      } else if (status == 'completed') {
        return 'Completed Agreements';
      } else {
        return status;
      }
    }

    List<RequestStatusModel> result = statusCount.entries
        .map((entry) => RequestStatusModel(
            status: entry.key,
            displayName: getDisplayName(entry.key),
            count: entry.value))
        .toList();

    result.insert(
        0,
        RequestStatusModel(
            status: 'All',
            displayName: 'All Agreements',
            count: requestsList.length));

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Legal MIS'),
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
                      : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // Number of columns
                            crossAxisSpacing: 8.0, // Spacing between columns
                            mainAxisSpacing: 8.0, // Spacing between rows
                            childAspectRatio: 1, // Adjust the aspect ratio
                          ),
                          itemBuilder: (context, i) {
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AllLegalListPage(
                                        title: requestStatusList[i].status,
                                        requestList: requestStatusList[i]
                                                    .status ==
                                                'All'
                                            ? (zohoRequestModel?.requests ?? [])
                                            : zohoRequestModel?.requests
                                                    ?.where(
                                                      (element) => (element
                                                              .requestStatus
                                                              ?.contains(
                                                                  requestStatusList[
                                                                          i]
                                                                      .status) ??
                                                          false),
                                                    )
                                                    .toList() ??
                                                [],
                                      ),
                                    ));
                              },
                              child: Card(
                                elevation: 5,
                                color: kPrimaryLightColor,
                                margin: const EdgeInsets.all(10),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        requestStatusList[i].count.toString(),
                                        style: LightColors.textHeaderStyle16
                                            .copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        requestStatusList[i].displayName,
                                        textAlign: TextAlign.center,
                                        style: LightColors.textbigStyle
                                            .copyWith(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          itemCount: requestStatusList.length,
                        ))
        ],
      ),
    );
  }
}
