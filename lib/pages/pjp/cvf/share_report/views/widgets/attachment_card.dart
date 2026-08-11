import 'package:Intranet/pages/helper/constants.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/controllers/share_report_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AttachmentCard extends StatelessWidget {
  const AttachmentCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ShareReportController>();
    return Obx(() {
      final ok = c.pdfAvailable.value;
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: ok ? Colors.grey.shade300 : Colors.red.shade200,
          ),
        ),
        child: ListTile(
          dense: true,
          leading: CircleAvatar(
            backgroundColor: ok
                ? kPrimaryLightColor.withValues(alpha: 0.12)
                : Colors.red.shade50,
            child: Icon(
              Icons.picture_as_pdf,
              color: ok ? kPrimaryLightColor : Colors.red,
            ),
          ),
          title: Text(
            c.pdfFileName,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          subtitle: Text(
            ok
                ? 'Automatically attached'
                : 'CVF report attachment is not available. Please try again.',
            style: TextStyle(
              fontSize: 12,
              color: ok ? Colors.grey.shade700 : Colors.red.shade700,
            ),
          ),
          trailing: Icon(
            ok ? Icons.check_circle : Icons.error_outline,
            color: ok ? Colors.green : Colors.red,
          ),
        ),
      );
    });
  }
}
