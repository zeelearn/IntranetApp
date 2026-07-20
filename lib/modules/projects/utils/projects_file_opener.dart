import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';
import 'package:Intranet/modules/projects/models/task_comment.dart';
import 'package:Intranet/modules/projects/widgets/task_attachment_list.dart';

/// Opens PDFs/images in-app; other types fall back to external launcher.
class ProjectsFileOpener {
  ProjectsFileOpener._();

  static bool isImageUrl(String url) {
    final ext = TaskAttachmentList.extensionOf(url);
    return const {'png', 'jpg', 'jpeg', 'gif', 'webp', 'bmp'}.contains(ext);
  }

  static bool isPdfUrl(String url) =>
      TaskAttachmentList.extensionOf(url) == 'pdf';

  static Future<void> open({
    required String url,
    String title = 'Attachment',
  }) async {
    final cleaned = url.trim();
    if (cleaned.isEmpty) return;

    if (isPdfUrl(cleaned) || isImageUrl(cleaned)) {
      await Get.to(
        () => AttachmentViewerScreen(url: cleaned, title: title),
      );
      return;
    }

    final uri = Uri.tryParse(cleaned);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> openAttachment(TaskCommentAttachment attachment) {
    return open(
      url: attachment.openUrl,
      title: attachment.fileName.isEmpty ? 'Attachment' : attachment.fileName,
    );
  }
}

class AttachmentViewerScreen extends StatelessWidget {
  const AttachmentViewerScreen({
    super.key,
    required this.url,
    this.title = 'Attachment',
  });

  final String url;
  final String title;

  @override
  Widget build(BuildContext context) {
    final isPdf = ProjectsFileOpener.isPdfUrl(url);
    final isImage = ProjectsFileOpener.isImageUrl(url);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: DashboardColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: 'Open externally',
            onPressed: () async {
              final uri = Uri.tryParse(url);
              if (uri != null && await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            icon: const Icon(Icons.open_in_new_rounded),
          ),
        ],
      ),
      body: isPdf
          ? PdfViewer.uri(Uri.parse(url))
          : isImage
              ? PhotoView(
                  imageProvider: NetworkImage(url),
                  backgroundDecoration:
                      const BoxDecoration(color: Colors.black),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 3,
                  loadingBuilder: (context, event) => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Text(
                      'Unable to load image',
                      style: GoogleFonts.poppins(color: Colors.white70),
                    ),
                  ),
                )
              : Center(
                  child: TextButton(
                    onPressed: () => ProjectsFileOpener.open(url: url, title: title),
                    child: const Text('Open file'),
                  ),
                ),
    );
  }
}
