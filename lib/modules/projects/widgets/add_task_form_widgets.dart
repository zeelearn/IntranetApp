import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/modules/projects/models/add_task_request.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';
import 'package:Intranet/modules/projects/utils/project_date_utils.dart';

class TaskSectionLabel extends StatelessWidget {
  const TaskSectionLabel(
    this.text, {
    super.key,
    this.required = false,
  });

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          text: text,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: DashboardColors.textDark,
          ),
          children: [
            if (required)
              TextSpan(
                text: ' *',
                style: GoogleFonts.poppins(
                  color: DashboardColors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class TaskTextField extends StatelessWidget {
  const TaskTextField({
    super.key,
    required this.controller,
    this.hint,
    this.maxLines = 1,
    this.maxLength,
    this.errorText,
    this.suffix,
    this.onChanged,
    this.enabled = true,
    this.readOnly = false,
  });

  final TextEditingController controller;
  final String? hint;
  final int maxLines;
  final int? maxLength;
  final String? errorText;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final editable = enabled && !readOnly;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          onChanged: editable ? onChanged : null,
          enabled: enabled,
          readOnly: readOnly,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: editable
                ? DashboardColors.textDark
                : DashboardColors.textMuted,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              fontSize: 13,
              color: DashboardColors.textMuted,
            ),
            filled: true,
            fillColor: editable ? Colors.white : const Color(0xFFF0F2F5),
            suffixIcon: suffix,
            counterText: maxLength == null ? '' : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: DashboardColors.primary,
                width: 1.4,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: DashboardColors.error),
            ),
          ),
        ),
        if (errorText != null && errorText!.isNotEmpty)
          ValidationMessage(errorText!),
      ],
    );
  }
}

class ValidationMessage extends StatelessWidget {
  const ValidationMessage(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        message,
        style: GoogleFonts.poppins(
          fontSize: 11,
          color: DashboardColors.error,
        ),
      ),
    );
  }
}

class TaskSelectorCard extends StatelessWidget {
  const TaskSelectorCard({
    super.key,
    required this.label,
    required this.value,
    required this.placeholder,
    required this.leading,
    required this.onTap,
  });

  final String label;
  final String value;
  final String placeholder;
  final Widget leading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasValue = value.trim().isNotEmpty;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 1,
      shadowColor: const Color(0x14000000),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: DashboardColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasValue ? value : placeholder,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: hasValue
                            ? DashboardColors.textDark
                            : DashboardColors.textMuted,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: DashboardColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TaskDateField extends StatelessWidget {
  const TaskDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.enabled = true,
    this.required = true,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final bool enabled;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TaskSectionLabel(label, required: required),
        Material(
          color: enabled ? Colors.white : const Color(0xFFF0F2F5),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: enabled ? onTap : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value == null
                          ? 'Select date'
                          : ProjectDateUtils.formatForm(value),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: value == null
                            ? DashboardColors.textMuted
                            : (enabled
                                ? DashboardColors.textDark
                                : DashboardColors.textMuted),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: enabled
                        ? DashboardColors.primary
                        : DashboardColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TaskStatusChips extends StatelessWidget {
  const TaskStatusChips({
    super.key,
    required this.selectedId,
    required this.onSelected,
  });

  final int selectedId;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: TaskFormStatusOption.all.map((opt) {
        final selected = opt.id == selectedId;
        final color = _colorFor(opt.code);
        return InkWell(
          onTap: () => onSelected(opt.id),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? DashboardColors.primaryLight
                  : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected
                    ? DashboardColors.primary
                    : Colors.grey.shade300,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  opt.code,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: DashboardColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(growable: false),
    );
  }

  Color _colorFor(String code) {
    switch (code) {
      case 'IP':
        return DashboardColors.purple;
      case 'C':
        return DashboardColors.success;
      case 'BPC':
        return DashboardColors.primary;
      default:
        return DashboardColors.warning;
    }
  }
}

class TaskPriorityChips extends StatelessWidget {
  const TaskPriorityChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: TaskFormPriority.all.map((p) {
        final isSelected = p == selected;
        final color = p == TaskFormPriority.high
            ? DashboardColors.error
            : p == TaskFormPriority.medium
                ? DashboardColors.warning
                : DashboardColors.primary;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => onSelected(p),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? DashboardColors.primaryLight
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? DashboardColors.primary
                        : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.circle, size: 8, color: color),
                    const SizedBox(width: 6),
                    Text(
                      p,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(growable: false),
    );
  }
}

class TaskSubtaskStepper extends StatelessWidget {
  const TaskSubtaskStepper({
    super.key,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onDecrement,
            icon: const Icon(Icons.remove_rounded),
          ),
          Expanded(
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            onPressed: onIncrement,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}

class TaskAttachmentBox extends StatelessWidget {
  const TaskAttachmentBox({
    super.key,
    required this.files,
    required this.onBrowse,
    required this.onRemove,
    this.errorText,
    this.busy = false,
  });

  final List<TaskAttachmentFile> files;
  final VoidCallback onBrowse;
  final ValueChanged<int> onRemove;
  final String? errorText;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (files.isEmpty)
          InkWell(
            onTap: busy ? null : onBrowse,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.grey.shade300,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  if (busy)
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    )
                  else
                    const Icon(
                      Icons.cloud_upload_outlined,
                      size: 36,
                      color: DashboardColors.primary,
                    ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to upload from camera, gallery or files',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: DashboardColors.textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'PDF, DOC, DOCX, JPG, PNG · Max 10MB',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: DashboardColors.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else ...[
          for (var i = 0; i < files.length; i++)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(
                    files[i].isImage
                        ? Icons.image_outlined
                        : (files[i].isPdf
                            ? Icons.picture_as_pdf
                            : Icons.insert_drive_file_outlined),
                    color: files[i].isPdf
                        ? DashboardColors.error
                        : DashboardColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          files[i].name,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          files[i].sizeLabel,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: DashboardColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => onRemove(i),
                    icon: const Icon(Icons.close_rounded, size: 18),
                  ),
                ],
              ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: busy ? null : onBrowse,
              icon: busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add),
              label: const Text('Add more files'),
            ),
          ),
        ],
        if (errorText != null && errorText!.isNotEmpty)
          ValidationMessage(errorText!),
      ],
    );
  }
}

class TaskBottomActionBar extends StatelessWidget {
  const TaskBottomActionBar({
    super.key,
    required this.primaryLabel,
    required this.onPrimary,
    required this.onCancel,
    this.busy = false,
  });

  final String primaryLabel;
  final VoidCallback? onPrimary;
  final VoidCallback onCancel;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: busy ? null : onPrimary,
                style: DashboardColors.primaryFilledButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: busy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        primaryLabel,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: busy ? null : onCancel,
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
