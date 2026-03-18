import 'dart:math' as math;
import 'package:Intranet/api/request/zoho_request_model.dart';
import 'package:Intranet/pages/legal_mis/document_provider.dart';
import 'package:Intranet/pages/legal_mis/document_status.dart';
import 'package:Intranet/pages/legal_mis/responsive_layout.dart';
import 'package:Intranet/pages/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DocumentStatusScreen extends ConsumerWidget {
  final Requests requests;
  const DocumentStatusScreen({super.key, required this.requests});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentStatusAsync =
        ref.watch(documentStatusProvider(requests.requestId ?? '0'));

    return Scaffold(
      appBar: AppBar(
        title: Text(requests.requestName ?? 'Document Status'),
      ),
      body: documentStatusAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${err.toString().replaceAll('Exception: ', '')}',
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(
                      documentStatusProvider(requests.requestId ?? '0')),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (DocumentStatus status) => ResponsiveLayout(
          mobileBody: _buildMobileLayout(context, status),
          desktopBody: _buildDesktopLayout(context, status),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, DocumentStatus status) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildHeaderSection(context, status, isMobile: true),
        const SizedBox(height: 24),
        const Text(
          'Recipient status',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...status.recipientList.asMap().entries.map((entry) =>
            _buildRecipientCardMobile(context, entry.value, entry.key + 1)),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, DocumentStatus status) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(context, status, isMobile: false),
              const SizedBox(height: 32),
              const Text(
                'Recipient status',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.shade200)),
                child: Column(
                  children: status.recipientList
                      .asMap()
                      .entries
                      .map((entry) => _buildRecipientRowDesktop(
                          context, entry.value, entry.key + 1,
                          isLast: entry.key == status.recipientList.length - 1))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, DocumentStatus status,
      {required bool isMobile}) {
    // Parse percentage
    double percent = 0;
    try {
      percent =
          double.parse(status.signPercentage.replaceAll('%', '').trim()) / 100;
    } catch (_) {}

    /*  Widget imageBlock = Container(
      width: 70,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // const Icon(Icons.description, color: Colors.white54, size: 30),
          const Spacer(),
          /*   Container(
            width: double.infinity,
            color: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.visibility, color: Colors.white, size: 12),
                SizedBox(width: 4),
                Text("View",
                    style: TextStyle(color: Colors.white, fontSize: 10)),
              ],
            ),
          ) */
        ],
      ),
    ); */

    Widget infoBlock =
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(status.reqId, // Assuming ID as Title
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 4),
      Text("Status: ${Util.getDisplayTitle(status.reqStatus)}",
          style: TextStyle(color: Colors.grey[700], fontSize: 14)),
      const SizedBox(height: 4),
      Text(
          "Submitted on ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.fromMillisecondsSinceEpoch(requests.createdTime!.toInt()))}",
          style: TextStyle(color: Colors.grey[600], fontSize: 13)),
      const SizedBox(height: 4),
      Text(
          "Last updated on ${DateFormat('MMM dd, yyyy HH:mm').format(DateFormat('dd-MMM-yyyy HH:mm:ss').parse(status.actionTime!))}",
          style: TextStyle(color: Colors.grey[600], fontSize: 13)),
    ]);

    Widget chartBlock;
    if (percent >= 1.0) {
      chartBlock = SizedBox(
        width: 100,
        height: 100,
        child: Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: Color(0xFF2E8B57), // Sea Green
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 50,
          ),
        ),
      );
    } else if (requests.requestStatus?.toLowerCase() == 'declined') {
      chartBlock = SizedBox(
        width: 100,
        height: 100,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.redAccent,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.clear,
            color: Colors.white,
            size: 40,
          ),
        ),
      );
    } else {
      chartBlock = SizedBox(
        width: 100,
        height: 100,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CustomPaint(
                painter: _CircularArrowProgressPainter(
                  percentage: percent,
                  backgroundColor: Colors.grey[100] ?? Colors.grey,
                  color: Colors.lightBlueAccent,
                  strokeWidth: 8,
                ),
              ),
            ),
            Text(status.signPercentage,
                style: const TextStyle(
                    color: Colors.lightBlueAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    if (isMobile) {
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // imageBlock,
              // const SizedBox(width: 16),
              if (percent >= 1.0 ||
                  requests.requestStatus?.toLowerCase() == 'declined') ...[
                chartBlock,
                const SizedBox(height: 16),
              ],
              Expanded(child: infoBlock),
            ],
          ),
          if (!(percent >= 1.0 ||
              requests.requestStatus?.toLowerCase() == 'declined')) ...[
            const SizedBox(height: 16),
            chartBlock,
          ]
        ],
      );
    }

    return Row(
      children: [
        // imageBlock,
        // const SizedBox(width: 24),
        if (percent >= 1.0 ||
            requests.requestStatus?.toLowerCase() == 'declined') ...[
          chartBlock,
          const SizedBox(width: 16),
        ],
        Expanded(child: infoBlock),
        if (!(percent >= 1.0 ||
            requests.requestStatus?.toLowerCase() == 'declined')) ...[
          const SizedBox(width: 24),
          chartBlock,
        ],
      ],
    );
  }

  Widget _buildRecipientCardMobile(
      BuildContext context, Recipient recipient, int index) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$index',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black54)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(recipient.recipientName,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(recipient.recipientEmail,
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 13)),
                      const SizedBox(height: 4),
                      Text("Action: ${recipient.actionType}",
                          style:
                              TextStyle(color: Colors.grey[500], fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _TimelineStatus(
                status: recipient.actionStatus,
                actionType: recipient.actionType),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipientRowDesktop(
      BuildContext context, Recipient recipient, int index,
      {bool isLast = false}) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text('$index',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black54)),
          ),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(recipient.recipientName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                Text(recipient.recipientEmail,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                const SizedBox(height: 4),
                Text("Action: ${recipient.actionType}",
                    style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: _TimelineStatus(
                status: recipient.actionStatus,
                actionType: recipient.actionType),
          ),
        ],
      ),
    );
  }
}

class _CircularArrowProgressPainter extends CustomPainter {
  final double percentage;
  final Color backgroundColor;
  final Color color;
  final double strokeWidth;

  _CircularArrowProgressPainter({
    required this.percentage,
    required this.backgroundColor,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, bgPaint);

    final activePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;

    final startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * percentage;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      activePaint,
    );

    if (percentage > 0) {
      final endAngle = startAngle + sweepAngle;
      final dx = center.dx + radius * math.cos(endAngle);
      final dy = center.dy + radius * math.sin(endAngle);

      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(endAngle + math.pi / 2);

      final path = Path();
      final arrowSize = strokeWidth * 2;
      // Draw arrow head
      path.moveTo(-arrowSize / 2, -arrowSize / 2);
      path.lineTo(arrowSize / 2, 0);
      path.lineTo(-arrowSize / 2, arrowSize / 2);
      path.close();

      canvas.drawPath(
          path,
          Paint()
            ..color = color
            ..style = PaintingStyle.fill);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _CircularArrowProgressPainter oldDelegate) {
    return percentage != oldDelegate.percentage ||
        color != oldDelegate.color ||
        backgroundColor != oldDelegate.backgroundColor ||
        strokeWidth != oldDelegate.strokeWidth;
  }
}

class _TimelineStatus extends StatelessWidget {
  final String status;
  final String actionType;
  const _TimelineStatus({required this.status, required this.actionType});

  @override
  Widget build(BuildContext context) {
    int currentStep = 1; // Default Mailed
    String s = status.toUpperCase();
    String type = actionType.toUpperCase();
    if (s == 'VIEWED') currentStep = 2;
    if (s == 'APPROVED' || s == 'SIGNED' || s == 'DECLINED') currentStep = 3;

    const Color activeColor = Color(0xFF2E8B57); // Sea Green
    final Color inactiveColor = Colors.grey[300]!;

    if (type == 'VIEW') {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStep(activeColor, inactiveColor, "Mailed", 1 <= currentStep),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Container(
                height: 2,
                color: 2 <= currentStep ? activeColor : inactiveColor),
          )),
          _buildStep(activeColor, inactiveColor, "Viewed", 2 <= currentStep),
        ],
      );
    }

    String lastStepLabel = type == 'SIGN' ? "Signed" : "Approved";

    if (s == 'DECLINED') {
      lastStepLabel = "Declined";
    } else if (s == 'SIGNED') {
      lastStepLabel = "Signed";
    } else if (s == 'APPROVED') {
      lastStepLabel = "Approved";
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStep(activeColor, inactiveColor, "Mailed", 1 <= currentStep),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Container(
              height: 2, color: 2 <= currentStep ? activeColor : inactiveColor),
        )),
        _buildStep(activeColor, inactiveColor, "Viewed", 2 <= currentStep),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Container(
              height: 2,
              color: 3 <= currentStep
                  ? s == 'DECLINED'
                      ? Colors.redAccent
                      : activeColor
                  : inactiveColor),
        )),
        _buildStep(s == 'DECLINED' ? Colors.redAccent : activeColor,
            inactiveColor, lastStepLabel, 3 <= currentStep),
      ],
    );
  }

  Widget _buildStep(Color active, Color inactive, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, color: isActive ? active : inactive, size: 18),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                fontSize: 12, color: isActive ? Colors.black87 : Colors.grey)),
      ],
    );
  }
}
