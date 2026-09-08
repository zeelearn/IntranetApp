import 'package:Intranet/api/response/pjp/pjplistresponse.dart';
import 'package:Intranet/pages/firebase/anylatics.dart';
import 'package:Intranet/pages/helper/LightColor.dart';
import 'package:Intranet/pages/helper/constants.dart';
import 'package:Intranet/pages/helper/utils.dart';
import 'package:Intranet/pages/pjp/cvf/v2/cvf_controller.dart';
import 'package:Intranet/pages/utils/theme/colors/light_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:order_tracker_zen/order_tracker_zen.dart';
import 'package:Intranet/pages/widget/intranet_order_tracker.dart';

/// CVF v2 accent — date/time, category, ref id.
const Color _cvfAccent = Color(0xFF4B39EF);

// ---------------------------------------------------------------------------
// Entry points
// ---------------------------------------------------------------------------

/// All CVF visits (independent of PJP) — uses `GetAllCVFDetails` API.
class MyCVFListScreenV2 extends StatelessWidget {
  const MyCVFListScreenV2({super.key});

  @override
  Widget build(BuildContext context) {
    return const CVFListScreenV2();
  }
}

/// CVF list for a specific PJP — uses `GetAllVisitDetails` API.
class PJPCVFListScreenV2 extends StatelessWidget {
  const PJPCVFListScreenV2({
    super.key,
    required this.pjpInfo,
    this.isViewOnly = false,
  });

  final PJPInfo pjpInfo;
  final bool isViewOnly;

  @override
  Widget build(BuildContext context) {
    return CVFListScreenV2(pjpInfo: pjpInfo, isViewOnly: isViewOnly);
  }
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class CVFListScreenV2 extends StatefulWidget {
  const CVFListScreenV2({super.key, this.pjpInfo, this.isViewOnly = false});

  final PJPInfo? pjpInfo;
  final bool isViewOnly;

  @override
  State<CVFListScreenV2> createState() => _CVFListScreenV2State();
}

class _CVFListScreenV2State extends State<CVFListScreenV2> {
  late final String _tag;
  late final CVFController controller;

  @override
  void initState() {
    super.initState();
    _tag = widget.pjpInfo?.PJP_Id ?? 'all_cvf';
    controller = Get.put(
      CVFController(pjpInfo: widget.pjpInfo, isViewOnly: widget.isViewOnly),
      tag: _tag,
    );
  }

  @override
  void dispose() {
    Get.delete<CVFController>(tag: _tag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAnalyticsUtils().sendAnalyticsEvent('MyCVF_V2');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(controller.screenTitle),
        centerTitle: false,
        backgroundColor: kPrimaryLightColor,
        foregroundColor: Colors.white,
        elevation: 50.0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
            onPressed: () => controller.showFilterSheet(context),
          ),
          if (widget.pjpInfo != null &&
              widget.isViewOnly != null &&
              controller.showAddCvf &&
              !widget.isViewOnly &&
              widget.pjpInfo!.ApprovalStatus != 'Rejected' &&
              widget.pjpInfo!.ApprovalStatus != 'Canceled')
            IconButton(
              icon: const Icon(Icons.add_box),
              tooltip: 'ADD CVF',
              onPressed: () => controller.navigateToAddCvf(context),
            ),
        ],
      ),
      body: Column(
        children: [
          const _CvfStatusLegend(),
          Expanded(child: _CvfListBody(controller: controller)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status legend
// ---------------------------------------------------------------------------

class _CvfStatusLegend extends StatelessWidget {
  const _CvfStatusLegend();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: kPrimaryTEXTBGColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: const [
            _LegendItem(color: CvfStatusColor.pending, label: 'Pending'),
            SizedBox(width: 12),
            _LegendItem(color: CvfStatusColor.approved, label: 'Approved'),
            SizedBox(width: 12),
            _LegendItem(color: CvfStatusColor.completed, label: 'Completed'),
            SizedBox(width: 12),
            _LegendItem(color: CvfStatusColor.inProgress, label: 'In Progress'),
            SizedBox(width: 12),
            _LegendItem(color: CvfStatusColor.rejected, label: 'Rejected'),
            SizedBox(width: 12),
            _LegendItem(color: CvfStatusColor.cancelled, label: 'Cancelled'),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 4,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(fontSize: 11, color: LightColor.grey)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Reactive list body
// ---------------------------------------------------------------------------

class _CvfListBody extends StatelessWidget {
  const _CvfListBody({required this.controller});

  final CVFController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Obx(() {
          final loading = controller.isLoading.value;
          final _ = controller.cvfList.length;
          final activeFilter = controller.filter.value;
          controller.offlineStatus.length;

          if (loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final error = controller.errorMessage.value;
          if (error != null && error.isNotEmpty) {
            return _CvfErrorState(
              message: error,
              minHeight: constraints.maxHeight,
              onRetry: controller.refresh,
            );
          }

          final items = controller.filteredList;
          if (items.isEmpty) {
            return RefreshIndicator(
              onRefresh: controller.refresh,
              color: Colors.white,
              backgroundColor: kPrimaryLightColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: _CvfEmptyState(
                    message: 'Your CVF list is empty',
                    maxHeight: constraints.maxHeight,
                  ),
                ),
              ),
            );
          }

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
            children: [
              if (activeFilter != CvfFilter.all)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Chip(
                      avatar: Icon(Icons.filter_alt,
                          size: 18, color: kPrimaryLightColor),
                      label: Text('Filter: ${controller.filterLabel}'),
                      deleteIconColor: kPrimaryLightColor,
                      onDeleted: () => controller.filter.value = CvfFilter.all,
                    ),
                  ),
                ),
              ...List.generate(items.length, (index) {
                return _CvfCard(
                  controller: controller,
                  cvf: controller.normalizeCvf(items[index]),
                );
              }),
            ],
          );
        });
      },
    );
  }
}

class _CvfEmptyState extends StatelessWidget {
  const _CvfEmptyState({required this.message, required this.maxHeight});

  final String message;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final animationHeight = (maxHeight * 0.35).clamp(100.0, 180.0);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: animationHeight,
              child: Lottie.asset(
                'assets/json/not_found.json',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: LightColor.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CvfErrorState extends StatelessWidget {
  const _CvfErrorState({
    required this.message,
    required this.onRetry,
    required this.minHeight,
  });

  final String message;
  final Future<void> Function() onRetry;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off, size: 48, color: LightColor.grey),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: LightColor.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryLightColor),
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text('Retry',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card — matches legacy CVF card layout + action row
// ---------------------------------------------------------------------------

class _CvfCard extends StatelessWidget {
  const _CvfCard({required this.controller, required this.cvf});

  final CVFController controller;
  final GetDetailedPJP cvf;

  @override
  Widget build(BuildContext context) {
    final statusColor = controller.statusBarColor(cvf);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 3,
            color: Color(0x430F1113),
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: ClipRect(
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Tooltip(
                message: controller.statusLabel(cvf),
                child: SizedBox(
                  width: 1,
                  child: ColoredBox(color: statusColor),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => controller.onCvfTap(context, cvf),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CvfDateHeader(cvf: cvf),
                        ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          title: Text(
                            _title(cvf),
                            style: const TextStyle(
                              fontFamily: 'Lexend Deca',
                              color: Color(0xFF090F13),
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            _subtitle(cvf),
                            style: const TextStyle(
                              fontFamily: 'Lexend Deca',
                              color: LightColor.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          trailing: _CvfStatusTrailing(
                              controller: controller, cvf: cvf),
                        ),
                        if (cvf.cvfHistory != null &&
                            cvf.cvfHistory!.isNotEmpty)
                          _CvfHistoryBlock(cvf: cvf),
                        _CvfRemarksBlock(controller: controller, cvf: cvf),
                        if (cvf.purpose != null && cvf.purpose!.isNotEmpty)
                          _CvfCategoryStrip(controller: controller, cvf: cvf),
                        _CvfTimeline(cvf: cvf),
                      ],
                    ),
                  ),
                  if (controller.showCardActions(cvf))
                    _CvfCardActions(controller: controller, cvf: cvf),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _title(GetDetailedPJP cvf) {
    if (cvf.ActivityTitle.isNotEmpty && cvf.ActivityTitle != 'NA') {
      return cvf.ActivityTitle;
    }
    return cvf.franchiseeName;
  }

  String _subtitle(GetDetailedPJP cvf) {
    if (cvf.Address == 'Search Location') return cvf.franchiseeCode;
    return cvf.Address.length < 50
        ? cvf.Address
        : '${cvf.Address.substring(0, 50)}..';
  }
}

/// Top row: scheduled date/time on the left, ref id on the right.
class _CvfDateHeader extends StatelessWidget {
  const _CvfDateHeader({required this.cvf});

  final GetDetailedPJP cvf;

  @override
  Widget build(BuildContext context) {
    final dateText =
        Utility.shortDate(Utility.convertServerDate(cvf.visitDate));
    final timeText = '${Utility.shortTime(Utility.convertTime(cvf.visitTime))} '
        '${Utility.shortTimeAMPM(Utility.convertTime(cvf.visitTime))}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Wrap(
            spacing: 4,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Icon(Icons.date_range, color: _cvfAccent, size: 20),
              Text(
                dateText,
                style: const TextStyle(
                  fontFamily: 'Lexend Deca',
                  color: _cvfAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Icon(Icons.access_time, color: _cvfAccent, size: 15),
              Text(
                timeText,
                style: const TextStyle(
                  fontFamily: 'Lexend Deca',
                  color: _cvfAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          cvf.PJP_Id == null
              ? SizedBox.shrink()
              : Text(
                  'PJP Id : ${cvf.PJP_Id ?? ''}',
                  style: const TextStyle(
                    fontFamily: 'Lexend Deca',
                    color: _cvfAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
          Text(
            'Ref Id : ${cvf.PJPCVF_Id}',
            style: const TextStyle(
              fontFamily: 'Lexend Deca',
              color: _cvfAccent,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Status badge on the right of the title row (completed checkmark, etc.).
class _CvfStatusTrailing extends StatelessWidget {
  const _CvfStatusTrailing({required this.controller, required this.cvf});

  final CVFController controller;
  final GetDetailedPJP cvf;

  @override
  Widget build(BuildContext context) {
    if (controller.isViewOnly ||
        (controller.isPjpMode && controller.pjpInfo!.isSelfPJP == '0')) {
      return const SizedBox.shrink();
    }
    if (controller.isCancelled(cvf)) {
      return const Text(
        'Cancelled',
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      );
    }
    if (controller.isRejected(cvf)) {
      return const Text(
        'PJP Rejected',
        style: TextStyle(
          fontFamily: 'Lexend Deca',
          color: kPrimaryLightColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      );
    }
    if (cvf.Status == 'Check Out') {
      return OutlinedButton(
        onPressed: () => controller.selectCategory(context, cvf),
        child: Text(
          cvf.Status,
          style: const TextStyle(
            fontFamily: 'Lexend Deca',
            color: kPrimaryLightColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    if (cvf.Status == 'Completed') {
      return Image.asset('assets/icons/ic_checked.png', height: 50);
    }
    if (cvf.Status == 'Check In' || cvf.Status == 'NA') {
      return const SizedBox.shrink();
    }
    return Text(
      cvf.Status,
      style: const TextStyle(
        fontFamily: 'Lexend Deca',
        color: LightColors.kRed,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

/// Map / Reschedule / Cancel — web: text buttons, mobile: 3-dot bottom sheet.
class _CvfCardActions extends StatelessWidget {
  const _CvfCardActions({required this.controller, required this.cvf});

  final CVFController controller;
  final GetDetailedPJP cvf;

  @override
  Widget build(BuildContext context) {
    if (true || kIsWeb) {
      return WebCardActions(controller: controller, cvf: cvf);
    }
    return Align(
      alignment: Alignment.centerRight,
      child: IconButton(
        icon: const Icon(Icons.more_vert, color: kPrimaryLightColor),
        tooltip: 'Actions',
        onPressed: () => controller.showActionSheet(context, cvf),
      ),
    );
  }
}

class WebCardActions extends StatelessWidget {
  const WebCardActions({required this.controller, required this.cvf, this.onVisitUpdated});

  final CVFController controller;
  final GetDetailedPJP cvf;
  final Function(GetDetailedPJP)? onVisitUpdated;

  @override
  Widget build(BuildContext context) {
    final canRescheduleVisit = controller.canReschedule(cvf);
    final canCancelVisit = controller.canRescheduleOrCancel(cvf);
    final isCompleted = controller.isCompleted(cvf);
    final hasMap = controller.hasLocation(cvf);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Wrap(
        alignment: WrapAlignment.start,
        spacing: 8,
        runSpacing: 4,
        children: [
          if (hasMap)
            TextButton.icon(
              onPressed: () => controller.openLocationMap(context, cvf),
              icon: const Icon(Icons.map, size: 18, color: kPrimaryLightColor),
              label: const Text(
                'Map',
                style: TextStyle(
                    color: kPrimaryLightColor, fontWeight: FontWeight.w600),
              ),
            ),
          if (canRescheduleVisit)
            TextButton.icon(
              onPressed: () => controller.showRescheduleDialog(context, cvf, onVisitUpdated),
              icon: const Icon(Icons.edit_calendar,
                  size: 18, color: kPrimaryLightColor),
              label: const Text(
                'Reschedule',
                style: TextStyle(
                    color: kPrimaryLightColor, fontWeight: FontWeight.w600),
              ),
            ),
          if (canCancelVisit)
            TextButton.icon(
              onPressed: () => controller.showCancelDialog(context, cvf,onVisitUpdated),
              icon: const Icon(Icons.cancel, size: 18, color: Colors.red),
              label: const Text(
                'Cancel CVF',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
              ),
            ),
          if (isCompleted)
            TextButton.icon(
              onPressed: () => controller.openWebsiteReport(context, cvf),
              icon: const Icon(Icons.category,
                  size: 18, color: kPrimaryLightColor),
              label: const Text(
                'Report',
                style: TextStyle(
                    color: kPrimaryLightColor, fontWeight: FontWeight.w600),
              ),
            ),
          // if (isCompleted)
          //   TextButton.icon(
          //     onPressed: () => controller.generateReportEmailBody(context, cvf),
          //     icon: const Icon(Icons.share_outlined,
          //         size: 18, color: kPrimaryLightColor),
          //     label: const Text(
          //       'Share Report',
          //       style: TextStyle(
          //           color: kPrimaryLightColor, fontWeight: FontWeight.w600),
          //     ),
          //   ),
        ],
      ),
    );
  }
}

class _CvfHistoryBlock extends StatelessWidget {
  const _CvfHistoryBlock({required this.cvf});

  final GetDetailedPJP cvf;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: kPrimaryTEXTBGColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: kPrimaryLightColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rescheduled From:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: kPrimaryLightColor,
              ),
            ),
            ...cvf.cvfHistory!.map(
              (history) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${Utility.shortDate(Utility.convertServerDate(history.visitDate))} at '
                  '${Utility.shortTime(Utility.convertTime(history.visitTime))} '
                  '${Utility.shortTimeAMPM(Utility.convertTime(history.visitTime))} : ${history.remarks}',
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CvfRemarksBlock extends StatelessWidget {
  const _CvfRemarksBlock({required this.controller, required this.cvf});

  final CVFController controller;
  final GetDetailedPJP cvf;

  @override
  Widget build(BuildContext context) {
    if (cvf.remarks.isEmpty || cvf.remarks == 'NA')
      return const SizedBox.shrink();

    final isCancel = controller.isCancelled(cvf);
    final isReschedule =
        !isCancel && cvf.cvfHistory != null && cvf.cvfHistory!.isNotEmpty;

    if (!isCancel && !isReschedule) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Text(
        isCancel
            ? 'Cancel Remark: ${cvf.remarks}'
            : 'Reschedule Remark: ${cvf.remarks}',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isCancel ? Colors.red : kPrimaryLightColor,
        ),
      ),
    );
  }
}

class _CvfCategoryStrip extends StatelessWidget {
  const _CvfCategoryStrip({required this.controller, required this.cvf});

  final CVFController controller;
  final GetDetailedPJP cvf;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: LightColors.kLightGray,
      padding: const EdgeInsets.fromLTRB(5, 4, 12, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _categoryWidgets(context),
        ),
      ),
    );
  }

  List<Widget> _categoryWidgets(BuildContext context) {
    final purposes = cvf.purpose!;
    final list = <Widget>[];
    for (var i = 0; i < purposes.length; i++) {
      if (i >= 2) {
        list.add(_categoryText(context, 'more..', i == 0));
        break;
      }
      list.add(_categoryText(context, purposes[i].categoryName, i == 0));
    }
    return list;
  }

  Widget _categoryText(BuildContext context, String name, bool isFirst) {
    return GestureDetector(
      onTap: () => controller.onCategoryTap(context, cvf),
      child: Padding(
        padding: EdgeInsets.only(left: isFirst ? 0 : 10),
        child: Text(name, style: const TextStyle(color: _cvfAccent)),
      ),
    );
  }
}

class _CvfTimeline extends StatelessWidget {
  const _CvfTimeline({required this.cvf});

  final GetDetailedPJP cvf;

  @override
  Widget build(BuildContext context) {
    if (cvf.CheckInAddress.isEmpty || cvf.Status.contains('Check In')) {
      return const SizedBox.shrink();
    }

    final trackerData = <TrackerData>[
      TrackerData(
        title: 'Check In',
        date: Utility.getShortDateTime(cvf.DateTimeIn),
        tracker_details: [
          TrackerDetails(title: cvf.CheckInAddress, datetime: ''),
        ],
      ),
      if (cvf.Status.toLowerCase().contains('comp') &&
          cvf.CheckOutAddress.isNotEmpty)
        TrackerData(
          title: 'Check Out',
          date: Utility.getShortDateTime(cvf.DateTimeOut),
          tracker_details: [
            TrackerDetails(title: cvf.CheckOutAddress, datetime: ''),
          ],
        ),
    ];

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: IntranetOrderTrackerZen(tracker_data: trackerData),
      ),
    );
  }
}
