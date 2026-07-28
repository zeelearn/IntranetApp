import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';
import 'package:Intranet/modules/projects/utils/projects_file_opener.dart';

/// Named document (e.g. project Documents tab Name + DocURL).
class NamedAttachment {
  const NamedAttachment({required this.name, required this.url});

  final String name;
  final String url;
}

/// Displays comma-separated / list of attachment paths from Gettaskdata.
class TaskAttachmentList extends StatelessWidget {
  const TaskAttachmentList({
    super.key,
    required this.files,
    this.compact = false,
    this.title = 'Attachments',
    this.namedFiles = const [],
  });

  /// Builds from Name + URL pairs (project documents).
  factory TaskAttachmentList.named({
    Key? key,
    required List<NamedAttachment> documents,
    bool compact = false,
    String title = 'Documents',
  }) {
    return TaskAttachmentList(
      key: key,
      files: documents.map((e) => e.url).toList(growable: false),
      namedFiles: documents,
      compact: compact,
      title: title,
    );
  }

  final List<String> files;
  final bool compact;
  final String title;

  /// When non-empty, display [NamedAttachment.name] instead of URL filename.
  final List<NamedAttachment> namedFiles;

  static String fileName(String path) {
    final cleaned = path.trim();
    if (cleaned.isEmpty) return 'File';
    final slash = cleaned.replaceAll('\\', '/');
    final parts = slash.split('/');
    return parts.isEmpty ? cleaned : parts.last;
  }

  static String extensionOf(String path) {
    final name = fileName(path);
    final dot = name.lastIndexOf('.');
    if (dot < 0 || dot == name.length - 1) return '';
    return name.substring(dot + 1).toLowerCase();
  }

  static (IconData, Color) iconFor(String path) {
    final ext = extensionOf(path);
    switch (ext) {
      case 'pdf':
        return (Icons.picture_as_pdf_rounded, const Color(0xFFD32F2F));
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'gif':
      case 'webp':
      case 'bmp':
        return (Icons.image_rounded, const Color(0xFF43A047));
      case 'xls':
      case 'xlsx':
      case 'csv':
        return (Icons.grid_on_rounded, const Color(0xFF2E7D32));
      case 'doc':
      case 'docx':
        return (Icons.article_rounded, const Color(0xFF1976D2));
      case 'ppt':
      case 'pptx':
        return (Icons.slideshow_rounded, const Color(0xFFE65100));
      case 'zip':
      case 'rar':
      case '7z':
        return (Icons.folder_zip_rounded, const Color(0xFF6D4C41));
      case 'mp4':
      case 'mov':
      case 'avi':
      case 'mkv':
        return (Icons.videocam_rounded, const Color(0xFF5E35B1));
      case 'mp3':
      case 'wav':
      case 'm4a':
        return (Icons.audiotrack_rounded, const Color(0xFF00897B));
      case 'txt':
      case 'log':
        return (Icons.description_rounded, const Color(0xFF546E7A));
      default:
        return (Icons.insert_drive_file_rounded, DashboardColors.primary);
    }
  }

  Future<void> _open(String path) async {
    await ProjectsFileOpener.open(
      url: path,
      title: fileName(path),
    );
  }

  String _labelFor(int index, String file) {
    if (index < namedFiles.length && namedFiles[index].name.trim().isNotEmpty) {
      return namedFiles[index].name.trim();
    }
    return fileName(file);
  }

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) return const SizedBox.shrink();

    if (compact) {
      return Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (var i = 0; i < files.length; i++)
            InkWell(
              onTap: () => _open(files[i]),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      iconFor(files[i]).$1,
                      size: 14,
                      color: iconFor(files[i]).$2,
                    ),
                    const SizedBox(width: 4),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 140),
                      child: Text(
                        _labelFor(i, files[i]),
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: DashboardColors.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < files.length; i++) ...[
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => _open(files[i]),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: iconFor(files[i]).$2.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        iconFor(files[i]).$1,
                        color: iconFor(files[i]).$2,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _labelFor(i, files[i]),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: DashboardColors.textDark,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (extensionOf(files[i]).isNotEmpty)
                            Text(
                              extensionOf(files[i]).toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: DashboardColors.textMuted,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.open_in_new_rounded,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
