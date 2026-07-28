import 'package:Intranet/pages/home/v2/profile/profile_controller_v2.dart';
import 'package:Intranet/pages/home/v2/widgets/dash_v2_tokens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// View-only employee profile screen backed by Hive login response.
class ProfileScreenV2 extends StatefulWidget {
  const ProfileScreenV2({super.key});

  @override
  State<ProfileScreenV2> createState() => _ProfileScreenV2State();
}

class _ProfileScreenV2State extends State<ProfileScreenV2> {
  late final ProfileControllerV2 controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ProfileControllerV2());
  }

  @override
  void dispose() {
    if (Get.isRegistered<ProfileControllerV2>()) {
      Get.delete<ProfileControllerV2>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DashV2Colors.scaffold,
      appBar: AppBar(
        backgroundColor: DashV2Colors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('My Profile', style: DashV2Text.appBarTitle),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: controller.loadProfile,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.loadProfile,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              if (controller.errorMessage.value != null) ...[
                _ErrorBanner(message: controller.errorMessage.value!),
                const SizedBox(height: 12),
              ],
              _ProfileHeader(controller: controller),
              const SizedBox(height: 16),
              if (controller.contactRows.isNotEmpty)
                _InfoSection(
                  title: 'Contact',
                  icon: Icons.contact_mail_outlined,
                  rows: controller.contactRows.toList(),
                ),
              if (controller.workRows.isNotEmpty) ...[
                const SizedBox(height: 12),
                _InfoSection(
                  title: 'Work',
                  icon: Icons.work_outline_rounded,
                  rows: controller.workRows.toList(),
                ),
              ],
              if (controller.personalRows.isNotEmpty) ...[
                const SizedBox(height: 12),
                _InfoSection(
                  title: 'Personal',
                  icon: Icons.person_outline_rounded,
                  rows: controller.personalRows.toList(),
                ),
              ],
              // if (controller.roles.isNotEmpty) ...[
              //   const SizedBox(height: 12),
              //   _RolesSection(controller: controller),
              // ],
              if (controller.businesses.isNotEmpty) ...[
                const SizedBox(height: 12),
                _BusinessSection(controller: controller),
              ],
              if (controller.otherRows.isNotEmpty) ...[
                const SizedBox(height: 12),
                _InfoSection(
                  title: 'Other',
                  icon: Icons.info_outline_rounded,
                  rows: controller.otherRows.toList(),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.controller});

  final ProfileControllerV2 controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DashV2Colors.card,
        borderRadius: BorderRadius.circular(DashV2Colors.cardRadius),
        boxShadow: DashV2Colors.cardShadow,
      ),
      child: Row(
        children: [
          _Avatar(controller: controller),
          const SizedBox(width: 14),
          Expanded(
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.fullName.value.isEmpty
                        ? 'Employee'
                        : controller.fullName.value,
                    style: DashV2Text.sectionTitle.copyWith(fontSize: 17),
                  ),
                  if (controller.designation.value.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      controller.designation.value,
                      style: DashV2Text.subtitle,
                    ),
                  ],
                  if (controller.employeeCode.value.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: DashV2Colors.tint(DashV2Colors.primary),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Code: ${controller.employeeCode.value}',
                        style: DashV2Text.caption.copyWith(
                          color: DashV2Colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.controller});

  final ProfileControllerV2 controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bytes = controller.profileAvatarBytes.value;
      final url = controller.profileImageUrl.value;
      ImageProvider? image;
      if (bytes != null) {
        image = MemoryImage(bytes);
      } else if (url.isNotEmpty) {
        image = NetworkImage(url);
      }

      return Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: DashV2Colors.tint(DashV2Colors.primary),
          border: Border.all(color: DashV2Colors.border, width: 2),
          image: image == null
              ? null
              : DecorationImage(image: image, fit: BoxFit.cover),
        ),
        child: image == null
            ? const Icon(
                Icons.person_rounded,
                color: DashV2Colors.primary,
                size: 36,
              )
            : null,
      );
    });
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.title,
    required this.icon,
    required this.rows,
  });

  final String title;
  final IconData icon;
  final List<ProfileInfoRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DashV2Colors.card,
        borderRadius: BorderRadius.circular(DashV2Colors.cardRadius),
        boxShadow: DashV2Colors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Icon(icon, size: 18, color: DashV2Colors.primary),
                const SizedBox(width: 8),
                Text(title, style: DashV2Text.sectionTitle),
              ],
            ),
          ),
          const Divider(height: 1, color: DashV2Colors.border),
          for (var i = 0; i < rows.length; i++) ...[
            _InfoTile(label: rows[i].label, value: rows[i].value),
            if (i != rows.length - 1)
              const Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: DashV2Colors.border,
              ),
          ],
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: DashV2Text.caption),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: DashV2Text.cardTitle.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _RolesSection extends StatelessWidget {
  const _RolesSection({required this.controller});

  final ProfileControllerV2 controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: DashV2Colors.card,
        borderRadius: BorderRadius.circular(DashV2Colors.cardRadius),
        boxShadow: DashV2Colors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.badge_outlined,
                size: 18,
                color: DashV2Colors.primary,
              ),
              const SizedBox(width: 8),
              Text('Special Roles', style: DashV2Text.sectionTitle),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.roles
                .map(
                  (role) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: DashV2Colors.tint(DashV2Colors.purple),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      role.splRole,
                      style: DashV2Text.caption.copyWith(
                        color: DashV2Colors.purple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _BusinessSection extends StatelessWidget {
  const _BusinessSection({required this.controller});

  final ProfileControllerV2 controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
        color: DashV2Colors.card,
        borderRadius: BorderRadius.circular(DashV2Colors.cardRadius),
        boxShadow: DashV2Colors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.business_outlined,
                size: 18,
                color: DashV2Colors.primary,
              ),
              const SizedBox(width: 8),
              Text('Business Applications', style: DashV2Text.sectionTitle),
            ],
          ),
          const SizedBox(height: 8),
          ...controller.businesses.map(
            (b) => ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: CircleAvatar(
                radius: 16,
                backgroundColor: DashV2Colors.tint(DashV2Colors.blue),
                child: Text(
                  b.businessName.isNotEmpty
                      ? b.businessName.characters.first.toUpperCase()
                      : 'B',
                  style: DashV2Text.caption.copyWith(
                    color: DashV2Colors.blue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              title: Text(b.businessName, style: DashV2Text.cardTitle),
              // subtitle: Text(
              //   'ID: ${b.businessID}',
              //   style: DashV2Text.caption,
              // ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DashV2Colors.tint(DashV2Colors.red),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DashV2Colors.red.withValues(alpha: 0.3)),
      ),
      child: Text(
        message,
        style: DashV2Text.caption.copyWith(color: DashV2Colors.red),
      ),
    );
  }
}
