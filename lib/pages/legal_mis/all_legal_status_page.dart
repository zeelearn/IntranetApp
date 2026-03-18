import 'package:Intranet/api/APIService.dart';
import 'package:Intranet/pages/legal_mis/document_status_screen.dart';
import 'package:Intranet/pages/utils/theme/colors/light_colors.dart';
import 'package:Intranet/pages/utils/util.dart';
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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<String> statusOrder = [
    'All',
  ];

  String _getEffectiveStatus(zohoaction.Requests request) {
    if (request.actions != null) {
      // Find the action corresponding to the current user.
      for (final action in request.actions!) {
        if (action.recipientEmail == widget.email) {
          final actionStatus = action.actionStatus?.toLowerCase();
          // If we found the user's action and it has a status, use that.
          if (actionStatus != null && actionStatus.isNotEmpty) {
            return actionStatus;
          }
          // Found the user's action, but it has no status.
          // Stop searching and fall back to the main request status.
          break;
        }
      }
    }

    // Fallback to the overall request status if no specific action is found for the user,
    // or if the user's action has no status.
    return request.requestStatus?.toLowerCase() ?? 'unknown';
  }

  String _getRequestStatus(zohoaction.Requests request) {
    return request.requestStatus?.toLowerCase() ?? 'unknown';
  }

  String _getActionStatusOnly(zohoaction.Requests request) {
    if (request.actions != null) {
      for (final action in request.actions!) {
        if (action.recipientEmail == widget.email) {
          return action.actionStatus?.toLowerCase() ?? 'unknown';
        }
      }
    }
    return 'unknown';
  }

  @override
  void initState() {
    getAllRequest();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  getAllRequest() async {
    zohoRequestModel = await APIService().getRecipientList(widget.email);

    if (zohoRequestModel?.requests != null) {
      Set<String> statuses = {};
      for (var request in zohoRequestModel!.requests!) {
        final status = _getRequestStatus(request);
        if (status.isNotEmpty) statuses.add(status);
      }

      List<String> desiredOrder = [
        'inprogress',
        'completed',
        'no action',
        'draft',
        'recalled',
        'expired'
      ];
      List<String> sortedStatuses = statuses.toList();
      sortedStatuses.sort((a, b) {
        int indexA = desiredOrder.indexOf(a);
        int indexB = desiredOrder.indexOf(b);
        if (indexA == -1 && indexB == -1) return a.compareTo(b);
        if (indexA == -1) return 1;
        if (indexB == -1) return -1;
        return indexA.compareTo(indexB);
      });
      statusOrder = ['All', ...sortedStatuses];
    }
    setState(() {
      isLoading = false;
    });
  }

  List<zohoaction.Requests> getFilteredRequests(String status) {
    if (zohoRequestModel?.requests == null) return [];
    if (status == 'All') return zohoRequestModel!.requests!;
    return zohoRequestModel!.requests!
        .where((r) => _getRequestStatus(r) == status.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // Default to 'inprogress' tab if it exists, otherwise 'All'.
    int initialTabIndex = statusOrder.indexOf('inprogress');
    if (initialTabIndex == -1) {
      initialTabIndex = 0;
    }

    final bool hasNoData =
        !isLoading && (zohoRequestModel?.requests?.isEmpty ?? true);

    return DefaultTabController(
      length: statusOrder.length,
      initialIndex: initialTabIndex,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6F8),
        appBar: AppBar(
          title: const Text('Legal MIS'),
          elevation: 0,
          bottom: (isLoading || (zohoRequestModel?.error != null) || hasNoData)
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
                                      '${Util.getDisplayTitle(status)} (${getFilteredRequests(status).length})'),
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
                  : hasNoData
                      ? const Center(child: Text('No agreements found.'))
                      : Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                              child: TextField(
                                controller: _searchController,
                                onChanged: (value) {
                                  setState(() {
                                    _searchQuery = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'Search by Agreement Name or ID',
                                  prefixIcon: const Icon(Icons.search,
                                      color: Colors.grey),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10.0),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide: BorderSide(
                                        color: Colors.grey.withOpacity(0.2)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide: BorderSide(
                                        color: kPrimaryLightColor
                                            .withOpacity(0.5)),
                                  ),
                                  suffixIcon: _searchQuery.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear,
                                              color: Colors.grey),
                                          onPressed: () {
                                            _searchController.clear();
                                            setState(() {
                                              _searchQuery = '';
                                            });
                                          },
                                        )
                                      : null,
                                ),
                              ),
                            ),
                            Expanded(
                              child: TabBarView(
                                children: statusOrder
                                    .map((status) => _buildRequestList(status))
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
        ),
      ),
    );
  }

  Widget _buildRequestList(String status) {
    final initialRequests = getFilteredRequests(status);

    final requests = _searchQuery.isEmpty
        ? initialRequests
        : initialRequests.where((request) {
            final name = request.requestName?.toLowerCase() ?? '';
            final id = request.requestId?.toLowerCase() ?? '';
            final query = _searchQuery.toLowerCase();
            return name.contains(query) || id.contains(query);
          }).toList();

    if (status.toLowerCase() == 'inprogress' && requests.isNotEmpty) {
      return _buildNestedTabs(requests);
    }

    return _buildListView(requests, status);
  }

  Widget _buildNestedTabs(List<zohoaction.Requests> requests) {
    Set<String> actionStatuses = {};
    for (var r in requests) {
      String as = _getActionStatusOnly(r);
      if (as != 'unknown') actionStatuses.add(as);
    }

    if (actionStatuses.isEmpty) {
      return _buildListView(requests, 'inprogress');
    }

    List<String> tabs = ['All', ...actionStatuses.toList()];

    return DefaultTabController(
      length: tabs.length,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            width: double.infinity,
            child: TabBar(
              isScrollable: true,
              labelColor: kPrimaryLightColor,
              unselectedLabelColor: Colors.grey,
              indicatorSize: TabBarIndicatorSize.label,
              tabs:
                  tabs.map((t) => Tab(text: Util.getDisplayTitle(t))).toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: tabs.map((t) {
                List<zohoaction.Requests> filtered;
                if (t == 'All') {
                  filtered = requests;
                } else {
                  filtered = requests
                      .where((r) => _getActionStatusOnly(r) == t)
                      .toList();
                }
                return _buildListView(filtered, t);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<zohoaction.Requests> requests, String status) {
    if (requests.isEmpty) {
      return Center(
        child: Text(
          'No ${Util.getDisplayTitle(status)} agreements found',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return AgreementCard(
          request: request,
          effectiveStatus: _getEffectiveStatus(request),
          email: widget.email,
        );
      },
    );
  }
}

class AgreementCard extends StatelessWidget {
  final zohoaction.Requests request;
  final String email;
  final String effectiveStatus;

  const AgreementCard(
      {required this.request,
      required this.email,
      required this.effectiveStatus,
      super.key});

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

    return InkWell(
      onTap: () {
        if (request.requestStatus?.toLowerCase() == 'draft') {
          ToastUtility.showWarning(
              msg:
                  "This agreement is in Draft stage. Status details are not available.");
          return;
        }
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DocumentStatusScreen(
                requests: request,
              ),
            ));
        ;
      },
      child: Container(
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
                      color: _getStatusColor(effectiveStatus).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: _getStatusColor(effectiveStatus)
                              .withOpacity(0.2)),
                    ),
                    child: Text(
                      (effectiveStatus).toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(effectiveStatus),
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
                    onTap: () => _copyToClipboard(
                        context, request.requestId ?? '', "ID"),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child:
                          const Icon(Icons.copy, size: 14, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
      case 'signed':
      case 'approved':
        return Colors.green;
      case 'pending':
      case 'declined':
        return Colors.orange;
      case 'inprogress':
      case 'viewed':
        return Colors.blue;
      case 'draft':
      case 'recalled':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }
}
