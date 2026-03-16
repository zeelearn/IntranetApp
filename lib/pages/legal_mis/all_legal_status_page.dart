import 'package:Intranet/api/APIService.dart';
import 'package:Intranet/pages/utils/theme/colors/light_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:saathi/core/utility/toastUtility.dart';
import 'package:saathi/service/networking/apiService.dart';

// import '../../api/request/zoho_request_model.dart';
import '../../api/request/zoho_request_model.dart' as zohoaction;

import '../helper/constants.dart';

class AllLegalStatusPage extends StatefulWidget {
  const AllLegalStatusPage({required this.email, super.key});
  final String email;

  @override
  State<AllLegalStatusPage> createState() => _AllLegalStatusPageState();
}

class _AllLegalStatusPageState extends State<AllLegalStatusPage> {
  bool isLoading = true;
  zohoaction.ZohoRequestModel? zohoRequestModel;

  List<String> statusOrder = ['All', 'pending'];

  String getDisplayTitle(String status) {
    switch (status) {
      case 'All':
        return 'All';
      case 'pending':
        return 'Pending';
      case 'inprogress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'draft':
        return 'Draft';
      default:
        return status.isNotEmpty
            ? '${status[0].toUpperCase()}${status.substring(1)}'
            : status;
    }
  }

  @override
  void initState() {
    getAllRequest();
    super.initState();
  }

  getAllRequest() async {
    zohoRequestModel = await APIService().getRecipientList(widget.email);
    if (zohoRequestModel?.requests != null) {
      Set<String> statuses = {};
      for (var request in zohoRequestModel!.requests!) {
        if (request.requestStatus?.isNotEmpty == true) {
          statuses.add(request.requestStatus!.toLowerCase());
        }
      }
      statuses.remove('pending');
      statusOrder = ['All', 'pending', ...statuses.toList()];
    }
    setState(() {
      isLoading = false;
    });
  }

  List<zohoaction.Requests> getFilteredRequests(String status) {
    if (zohoRequestModel?.requests == null) return [];
    if (status == 'All') return zohoRequestModel!.requests!;
    return zohoRequestModel!.requests!
        .where((r) =>
            (r.requestStatus?.toLowerCase() ?? '') == status.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: statusOrder.length,
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6F8),
        appBar: AppBar(
          title: const Text('Legal MIS'),
          elevation: 0,
          bottom: (isLoading || (zohoRequestModel?.error != null))
              ? null
              : PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: Container(
                    margin:
                        const EdgeInsets.only(bottom: 12, left: 8, right: 8),
                    child: TabBar(
                      isScrollable: true,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                      ),
                      labelColor: kPrimaryLightColor,
                      unselectedLabelColor: Colors.white,
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                      tabs: statusOrder
                          .map((status) => Tab(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Text(
                                      '${getDisplayTitle(status)} (${getFilteredRequests(status).length})'),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
        ),
        body: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : zohoRequestModel?.error != null
                  ? Center(child: Text(zohoRequestModel!.error!))
                  : TabBarView(
                      children: statusOrder
                          .map((status) => _buildRequestList(status))
                          .toList(),
                    ),
        ),
      ),
    );
  }

  Widget _buildRequestList(String status) {
    final requests = getFilteredRequests(status);
    if (requests.isEmpty) {
      return Center(
        child: Text(
          'No ${getDisplayTitle(status)} agreements found',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        return AgreementCard(
          request: requests[index],
          email: widget.email,
        );
      },
    );
  }
}

class AgreementCard extends StatelessWidget {
  final zohoaction.Requests request;
  final String email;

  const AgreementCard({required this.request, required this.email, super.key});

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      ToastUtility.showSuccess(msg: "$label copied to clipboard");
    });
  }

  @override
  Widget build(BuildContext context) {
    String createdDate = request.createdTime == null
        ? ''
        : DateFormat('dd MMM yy').format(
            DateTime.fromMillisecondsSinceEpoch(request.createdTime!.toInt()));
    String expiryDate = request.expireBy == null
        ? ''
        : DateFormat('dd MMM yy').format(
            DateTime.fromMillisecondsSinceEpoch(request.expireBy!.toInt()));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          request.requestName ?? 'Agreement',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF212121),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _copyToClipboard(
                            context, request.requestName ?? '', "Name"),
                        child: const Icon(Icons.copy,
                            size: 18, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        _getStatusColor(request.requestStatus).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                        color: _getStatusColor(request.requestStatus)
                            .withOpacity(0.2)),
                  ),
                  child: Text(
                    (request.requestStatus ?? 'Unknown').toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(request.requestStatus),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _buildInfoItem(Icons.calendar_today_outlined,
                        'Created On', createdDate)),
                Expanded(
                    child: _buildInfoItem(
                        Icons.event_busy_outlined, 'Expires On', expiryDate)),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'ID: ',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Expanded(
                  child: Text(
                    request.requestId ?? 'N/A',
                    style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                InkWell(
                  onTap: () =>
                      _copyToClipboard(context, request.requestId ?? '', "ID"),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.copy, size: 14, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.black87)),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'inprogress':
        return Colors.blue;
      case 'draft':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }
}
