import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Intranet/modules/projects/models/branding_kit_models.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';
import 'package:Intranet/modules/projects/models/dashboard_failure.dart';
import 'package:Intranet/modules/projects/models/indent_item.dart';
import 'package:Intranet/modules/projects/repositories/branding_repository.dart';
import 'package:Intranet/modules/projects/services/branding_remote_service.dart';
import 'package:Intranet/modules/projects/utils/indent_action_roles.dart';
import 'package:Intranet/pages/helper/LocalConstant.dart';
import 'package:Intranet/pages/helper/LocalStrings.dart';
import 'package:Intranet/pages/helper/utils.dart';

enum BrandingKitView { overview, form }

/// GetX controller for Branding Kit bottom sheet (finance-safe flow).
class BrandingKitController extends GetxController {
  BrandingKitController({
    required this.indentItem,
    required BrandingRepository repository,
    this.academicYearId = LocalStrings.kidzeeBrandingAcademicYearId,
  }) : _repository = repository;

  final IndentItem indentItem;
  final BrandingRepository _repository;
  final int academicYearId;

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxnString errorMessage = RxnString();
  final Rx<BrandingKitView> view = BrandingKitView.overview.obs;

  final Rxn<BrandingProductData> data = Rxn<BrandingProductData>();
  final RxList<BrandingFormRow> formRows = <BrandingFormRow>[].obs;

  int createdBy = 0;
  final RxString employeeType = ''.obs;

  int get franchiseeId => indentItem.franchiseeId;
  bool get hasExistingIndents => data.value?.hasExistingIndents ?? false;
  List<BrandingIndentLine> get indents => data.value?.indents ?? const [];
  List<BrandingProduct> get products => data.value?.productList ?? const [];

  /// Add Order — MAN & BH only.
  bool get canAddOrder =>
      IndentActionRoles.canAccessFinanceActions(employeeType.value);

  double get formTotal => formRows
      .where((r) => r.selected)
      .fold<double>(0, (sum, r) => sum + r.totalPrice);

  int get selectedCount => formRows.where((r) => r.selected).length;

  @override
  void onInit() {
    super.onInit();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _loadSession();
    await loadProducts();
  }

  Future<void> _loadSession() async {
    try {
      final box = await Utility.openBox();
      createdBy =
          int.tryParse(box.get(LocalConstant.KEY_EMPLOYEE_ID)?.toString() ?? '') ??
              0;
      employeeType.value =
          (box.get(LocalConstant.KEY_EMP_TYPE)?.toString() ?? '').trim();
    } catch (_) {
      createdBy = 0;
      employeeType.value = '';
    }
  }

  Future<void> loadProducts() async {
    if (franchiseeId <= 0) {
      errorMessage.value =
          'Franchisee ID is missing. Cannot open Branding Kit.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result =
          await _repository.loadProducts(franchiseeId: franchiseeId);
      data.value = result;
      view.value = BrandingKitView.overview;
    } on DashboardFailure catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void openAddOrderForm() {
    if (!canAddOrder) return;
    _prepareForm();
    view.value = BrandingKitView.form;
  }

  void openUpdateOrderForm() {
    _prepareForm();
    view.value = BrandingKitView.form;
  }

  void backToOverview() {
    view.value = BrandingKitView.overview;
  }

  void _prepareForm() {
    formRows.assignAll(
      buildBrandingFormRows(
        products: products,
        indents: indents,
      ),
    );
  }

  void toggleProduct(int index, bool selected) {
    if (index < 0 || index >= formRows.length) return;
    final row = formRows[index];
    formRows[index] = row.copyWith(selected: selected);
  }

  void setQuantity(int index, int quantity) {
    if (index < 0 || index >= formRows.length) return;
    final row = formRows[index];
    final min = row.product.minQuantity;
    final qty = quantity < min ? min : quantity;
    formRows[index] = row.copyWith(quantity: qty, selected: true);
  }

  Future<bool> confirmAndSave(BuildContext context) async {
    if (isSaving.value) return false;

    // New order (Add) is MAN/BH only; Update remains available when indents exist.
    if (!hasExistingIndents && !canAddOrder) {
      _snack(
        context,
        'Add Order is available only for MAN and BH roles.',
      );
      return false;
    }

    final lines = formRows
        .map((r) => r.toOrderLine())
        .whereType<BrandingOrderLine>()
        .toList(growable: false);

    final draft = InsertBrandingIndentRequest(
      franchiseeId: franchiseeId,
      academicYearId: academicYearId,
      createdBy: createdBy,
      inputData: lines,
    );
    final validationError = draft.validate();
    if (validationError != null) {
      _snack(context, validationError);
      return false;
    }

    final isUpdate = hasExistingIndents;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isUpdate ? 'Update Branding Order?' : 'Add Branding Order?'),
        content: Text(
          isUpdate
              ? 'Update branding order for "${indentItem.franchiseeName}" with '
                  '$selectedCount product(s)?\n\nTotal: ${formTotal.toStringAsFixed(0)}'
              : 'Create branding order for "${indentItem.franchiseeName}" with '
                  '$selectedCount product(s)?\n\nTotal: ${formTotal.toStringAsFixed(0)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: DashboardColors.primaryFilledButton(),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(isUpdate ? 'Update' : 'Add Order'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return false;
    return _save(context, lines);
  }

  Future<bool> _save(
    BuildContext context,
    List<BrandingOrderLine> lines,
  ) async {
    isSaving.value = true;
    try {
      final result = await _repository.saveOrder(
        franchiseeId: franchiseeId,
        createdBy: createdBy,
        lines: lines,
        academicYearId: academicYearId,
      );
      if (!context.mounted) return result.success;
      _snack(context, result.message, success: result.success);
      if (result.success) {
        await loadProducts();
        view.value = BrandingKitView.overview;
      }
      return result.success;
    } on DashboardFailure catch (e) {
      if (context.mounted) _snack(context, e.message);
      return false;
    } catch (e) {
      if (context.mounted) _snack(context, e.toString());
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  void _snack(BuildContext context, String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            success ? DashboardColors.success : DashboardColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static BrandingKitController putForSheet({
    required IndentItem item,
    BrandingRepository? repository,
  }) {
    final tag = 'branding_kit_${item.franchiseeId}_${item.indentId}';
    if (Get.isRegistered<BrandingKitController>(tag: tag)) {
      Get.delete<BrandingKitController>(tag: tag, force: true);
    }
    if (Get.isRegistered<BrandingRemoteService>(tag: tag)) {
      Get.delete<BrandingRemoteService>(tag: tag, force: true);
    }
    if (Get.isRegistered<BrandingRepository>(tag: tag)) {
      Get.delete<BrandingRepository>(tag: tag, force: true);
    }

    final remote = Get.put(BrandingRemoteService(), tag: tag);
    final BrandingRepository repo = repository ??
        Get.put(BrandingRepository(remoteService: remote), tag: tag);
    return Get.put(
      BrandingKitController(indentItem: item, repository: repo),
      tag: tag,
    );
  }

  static void deleteForSheet(IndentItem item) {
    final tag = 'branding_kit_${item.franchiseeId}_${item.indentId}';
    if (Get.isRegistered<BrandingKitController>(tag: tag)) {
      Get.delete<BrandingKitController>(tag: tag, force: true);
    }
    if (Get.isRegistered<BrandingRepository>(tag: tag)) {
      Get.delete<BrandingRepository>(tag: tag, force: true);
    }
    if (Get.isRegistered<BrandingRemoteService>(tag: tag)) {
      Get.delete<BrandingRemoteService>(tag: tag, force: true);
    }
  }
}
