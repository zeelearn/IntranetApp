import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/pages/helper/LocalConstant.dart';
import 'package:Intranet/api/response/login_response.dart';

/// Singleton class for managing and rendering the active Business across all screens.
class BusinessWidget {
  // Private Constructor for Singleton Pattern
  BusinessWidget._internal() {
    _initFromStorage();
  }

  static final BusinessWidget _instance = BusinessWidget._internal();

  /// Access the Singleton instance: `BusinessWidget.instance`
  static BusinessWidget get instance => _instance;

  /// Reactive Notifiers for instantaneous UI updates across all screens
  final ValueNotifier<String> selectedBusinessName = ValueNotifier<String>('');
  final ValueNotifier<int> selectedBusinessId = ValueNotifier<int>(0);
  final ValueNotifier<int> selectedBusinessUserId = ValueNotifier<int>(0);
  final ValueNotifier<List<BusinessApplications>> availableBusinesses =
      ValueNotifier<List<BusinessApplications>>([]);

  /// Initialize state from Hive Local Storage
  void _initFromStorage() {
    try {
      if (Hive.isBoxOpen(LocalConstant.KidzeeDB)) {
        final box = Hive.box(LocalConstant.KidzeeDB);
        _loadFromBox(box);
      } else {
        Hive.openBox(LocalConstant.KidzeeDB).then((box) {
          _loadFromBox(box);
        });
      }
    } catch (e) {
      debugPrint("Error initializing BusinessWidget: $e");
    }
  }

  void _loadFromBox(Box box) {
    selectedBusinessName.value =
        box.get(LocalConstant.KEY_BUSINESS_NAME, defaultValue: '')?.toString() ?? '';
    selectedBusinessId.value =
        box.get(LocalConstant.KEY_BUSINESS_ID, defaultValue: 0) ?? 0;
    selectedBusinessUserId.value =
        box.get(LocalConstant.KEY_BUSINESS_USERID, defaultValue: 0) ?? 0;

    // Load available business list from login response cache
    final rawLogin = box.get(LocalConstant.KEY_LOGIN_RESPONSE)?.toString();
    if (rawLogin != null && rawLogin.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawLogin);
        final loginResponse = LoginResponseModel.fromJson(decoded);
        if (loginResponse.responseData.businessApplications.isNotEmpty) {
          availableBusinesses.value =
              loginResponse.responseData.businessApplications;

          // Fallback if current business name is empty
          if (selectedBusinessName.value.isEmpty || selectedBusinessName.value == 'null') {
            final first = loginResponse.responseData.businessApplications.first;
            updateBusiness(first);
          }
        }
      } catch (e) {
        debugPrint("Error parsing cached business applications: $e");
      }
    }
  }

  /// Update the active business globally and persist in Hive
  Future<void> updateBusiness(BusinessApplications business) async {
    try {
      Box box;
      if (Hive.isBoxOpen(LocalConstant.KidzeeDB)) {
        box = Hive.box(LocalConstant.KidzeeDB);
      } else {
        box = await Hive.openBox(LocalConstant.KidzeeDB);
      }

      await box.put(LocalConstant.KEY_BUSINESS_ID, business.businessID);
      await box.put(LocalConstant.KEY_BUSINESS_NAME, business.businessName);
      await box.put(LocalConstant.KEY_BUSINESS_USERID, business.business_UserID);

      selectedBusinessName.value = business.businessName;
      selectedBusinessId.value = business.businessID;
      selectedBusinessUserId.value = business.business_UserID;
    } catch (e) {
      debugPrint("Error updating business in BusinessWidget: $e");
    }
  }

  /// Helper to open the business selection bottom sheet picker
  Future<void> openBusinessPicker(BuildContext context, {VoidCallback? onBusinessChanged}) async {
    final list = availableBusinesses.value;
    if (list.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No additional business mapped to your account.")),
      );
      return;
    }

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    const Icon(Icons.apartment_rounded, color: Colors.blueAccent),
                    const SizedBox(width: 8),
                    Text(
                      "Select Active Business",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: list.length,
                  itemBuilder: (ctx, index) {
                    final item = list[index];
                    final isSelected = item.businessID == selectedBusinessId.value;
                    return ListTile(
                      leading: Icon(
                        isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: isSelected ? Colors.blue : Colors.grey.shade400,
                      ),
                      title: Text(
                        item.businessName,
                        style: GoogleFonts.inter(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.blue.shade900 : Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                      trailing: isSelected
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                "ACTIVE",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : null,
                      onTap: () async {
                        await updateBusiness(item);
                        Navigator.pop(ctx);
                        onBusinessChanged?.call();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // WIDGET BUILDER FUNCTIONS (CALLABLE ANYWHERE)
  // ===========================================================================

  /// 1. Prominent Context Card (Best for top of Forms like Apply Leave, Attendance, Outdoor)
  /// Usage: `BusinessWidget.instance.showContextCard(context, onBusinessChanged: () { ... })`
  Widget showContextCard(BuildContext context, {VoidCallback? onBusinessChanged, bool allowChange = true}) {
    return ValueListenableBuilder<String>(
      valueListenable: selectedBusinessName,
      builder: (context, name, _) {
        final displayName = (name.isEmpty || name == 'null') ? 'No Business Selected' : name;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4FE),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFC7D7FE), width: 1.2),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.business_rounded, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "SUBMITTING UNDER BUSINESS",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayName,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (allowChange)
                TextButton(
                  onPressed: () => openBusinessPicker(context, onBusinessChanged: onBusinessChanged),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Change",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.blue,
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.blue),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// 2. Compact AppBar Chip / Subtitle
  /// Usage: `BusinessWidget.instance.showAppBarChip(context, onBusinessChanged: () { ... })`
  Widget showAppBarChip(BuildContext context, {VoidCallback? onBusinessChanged, bool allowChange = true}) {
    return ValueListenableBuilder<String>(
      valueListenable: selectedBusinessName,
      builder: (context, name, _) {
        if (name.isEmpty || name == 'null') return const SizedBox.shrink();
        return InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: allowChange ? () => openBusinessPicker(context, onBusinessChanged: onBusinessChanged) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white30, width: 0.8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.apartment_rounded, size: 12, color: Colors.white),
                const SizedBox(width: 4),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 150),
                  child: Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (allowChange) ...[
                  const SizedBox(width: 2),
                  const Icon(Icons.arrow_drop_down, size: 14, color: Colors.white),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// 3. Minimalist Inline Badge (for lists, detail screens, or profile cards)
  /// Usage: `BusinessWidget.instance.showInlineBadge()`
  Widget showInlineBadge({Color? backgroundColor, Color? textColor}) {
    return ValueListenableBuilder<String>(
      valueListenable: selectedBusinessName,
      builder: (context, name, _) {
        final displayName = (name.isEmpty || name == 'null') ? '-' : name;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.blue.shade50,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.business, size: 12, color: textColor ?? Colors.blue.shade700),
              const SizedBox(width: 4),
              Text(
                displayName,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: textColor ?? Colors.blue.shade700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
