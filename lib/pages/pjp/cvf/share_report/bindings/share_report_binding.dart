import 'package:Intranet/pages/pjp/cvf/share_report/controllers/share_report_controller.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/models/share_report_args.dart';
import 'package:get/get.dart';

class ShareReportBinding extends Bindings {
  ShareReportBinding({required this.args});

  final ShareReportArgs args;

  @override
  void dependencies() {
    if (Get.isRegistered<ShareReportController>()) {
      Get.delete<ShareReportController>(force: true);
    }
    Get.put(ShareReportController(args: args));
  }
}
