import 'dart:math' as math;
import 'package:Intranet/api/request/zoho_request_model.dart';
import 'package:Intranet/pages/legal_mis/document_provider.dart';
import 'package:Intranet/pages/legal_mis/document_status.dart';
import 'package:Intranet/pages/legal_mis/responsive_layout.dart';
import 'package:Intranet/pages/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
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
    return Container(
      color: Colors.grey[50],
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildHeaderSection(context, status, isMobile: true),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Recipient Activity',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF333333)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...status.recipientList.asMap().entries.map((entry) =>
              _buildRecipientCardMobile(context, entry.value, entry.key + 1)),
          const SizedBox(height: 40),
        ],
      ),
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

    // Refined Info Block
    Widget infoBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isMobile) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  requests.requestName ?? status.reqId,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy_outlined, size: 20),
                color: Colors.grey.shade600,
                tooltip: 'Copy Request Name',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: requests.requestName ?? ''));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Request Name copied to clipboard')));
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildStatusChip(status.reqStatus),
        ] else ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  requests.requestName ?? status.reqId,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy_outlined, size: 18),
                color: Colors.grey.shade600,
                tooltip: 'Copy Request Name',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: requests.requestName ?? ''));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Request Name copied to clipboard')),
                  );
                },
              ),
              const SizedBox(width: 8),
              _buildStatusChip(status.reqStatus),
            ],
          ),
        ],
        const SizedBox(height: 16),
        /* _buildInfoRow(
          Icons.tag,
          "ReqID",
          status.reqId,
          trailing: InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: status.reqId));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Request ID copied to clipboard')));
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Icon(Icons.copy, size: 16, color: Colors.grey[600]),
            ),
          ),
        ),
        const SizedBox(height: 8), */
        _buildInfoRow(
            Icons.calendar_today_outlined,
            "Submitted",
            DateFormat('MMM dd, yyyy • HH:mm').format(
                DateTime.fromMillisecondsSinceEpoch(
                    requests.createdTime!.toInt()))),
        const SizedBox(height: 8),
        _buildInfoRow(
            Icons.history,
            "Last Updated",
            DateFormat('MMM dd, yyyy • HH:mm').format(
                DateFormat('dd-MMM-yyyy HH:mm:ss').parse(status.actionTime!))),
      ],
    );

    // Chart Block
    Widget chartBlock = _buildChartBlock(
        context, percent, status.signPercentage, requests.requestStatus);

    if (isMobile) {
      return Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              infoBlock,
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Divider(height: 1, thickness: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      const Text(
                        "Completion Status",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      chartBlock,
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
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

  Widget _buildStatusChip(String status) {
    Color color = Colors.blue;
    if (status.toLowerCase().contains('progress'))
      color = Colors.orange.shade700;
    if (status.toLowerCase().contains('complete') ||
        status.toLowerCase().contains('approved') ||
        status.toLowerCase().contains('signed')) color = Colors.green.shade700;
    if (status.toLowerCase().contains('decline')) color = Colors.red.shade700;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        Util.getDisplayTitle(status),
        style:
            TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {Widget? trailing}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
              fontWeight: FontWeight.w500),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
                color: Color(0xFF444444),
                fontSize: 13,
                fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildChartBlock(BuildContext context, double percent,
      String percentText, String? requestStatus) {
    if (percent >= 1.0) {
      return SizedBox(
        width: 100,
        height: 100,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF2E8B57).withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF2E8B57), width: 2),
          ),
          child: const Icon(
            Icons.check,
            color: Color(0xFF2E8B57),
            size: 50,
          ),
        ),
      );
    } else if (requestStatus?.toLowerCase() == 'declined') {
      return SizedBox(
        width: 100,
        height: 100,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.redAccent, width: 2),
          ),
          child: const Icon(
            Icons.clear,
            color: Colors.redAccent,
            size: 40,
          ),
        ),
      );
    } else {
      return SizedBox(
        width: 100,
        height: 100,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: percent),
                duration: const Duration(seconds: 2),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return CustomPaint(
                    painter: _CircularArrowProgressPainter(
                      percentage: value,
                      backgroundColor: Colors.grey[200]!,
                      color: Theme.of(context).primaryColor,
                      strokeWidth: 8,
                    ),
                  );
                },
              ),
            ),
            Text(percentText,
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }
  }

  Widget _buildRecipientCardMobile(
      BuildContext context, Recipient recipient, int index) {
    // Generate initials
    String initials = "";
    if (recipient.recipientName.isNotEmpty) {
      List<String> names = recipient.recipientName.trim().split(" ");
      if (names.isNotEmpty) {
        initials = names[0][0];
        if (names.length > 1) initials += names[names.length - 1][0];
      }
    }
    initials = initials.toUpperCase();

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blueGrey[50],
                  radius: 22,
                  child: Text(
                    initials,
                    style: TextStyle(
                        color: Colors.blueGrey[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(recipient.recipientName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Color(0xFF2C3E50))),
                      const SizedBox(height: 2),
                      Text(recipient.recipientEmail,
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.touch_app_outlined,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text("Action Required: ",
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12)),
                      Text(recipient.actionType,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _TimelineStatus(
                      status: recipient.actionStatus,
                      actionType: recipient.actionType),
                ],
              ),
            )
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
          _buildLine(activeColor, inactiveColor, 2 <= currentStep),
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

    final Color lastStepColor =
        s == 'DECLINED' ? Colors.redAccent : activeColor;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStep(activeColor, inactiveColor, "Mailed", 1 <= currentStep),
        _buildLine(activeColor, inactiveColor, 2 <= currentStep),
        _buildStep(activeColor, inactiveColor, "Viewed", 2 <= currentStep),
        _buildLine(lastStepColor, inactiveColor, 3 <= currentStep),
        _buildStep(
            lastStepColor, inactiveColor, lastStepLabel, 3 <= currentStep),
      ],
    );
  }

  Widget _buildLine(Color activeColor, Color inactiveColor, bool isActive) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Stack(
          children: [
            Container(height: 2, color: inactiveColor),
            if (isActive)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(seconds: 2),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return FractionallySizedBox(
                    widthFactor: value,
                    child: child,
                  );
                },
                child: Container(height: 2, color: activeColor),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(Color active, Color inactive, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(seconds: 1),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: isActive ? value : 1.0,
              child: child,
            );
          },
          child:
              Icon(Icons.circle, color: isActive ? active : inactive, size: 18),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                fontSize: 12, color: isActive ? Colors.black87 : Colors.grey)),
      ],
    );
  }
}
