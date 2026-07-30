import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/modules/projects/controllers/branding_kit_controller.dart';
import 'package:Intranet/modules/projects/models/branding_kit_models.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';
import 'package:Intranet/modules/projects/models/indent_item.dart';
import 'package:Intranet/modules/projects/utils/project_date_utils.dart';

Future<void> showBrandingKitSheet({
  required BuildContext context,
  required IndentItem item,
}) async {
  final controller = BrandingKitController.putForSheet(item: item);
  try {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _BrandingKitSheet(controller: controller),
    );
  } finally {
    BrandingKitController.deleteForSheet(item);
  }
}

class _BrandingKitSheet extends StatelessWidget {
  const _BrandingKitSheet({required this.controller});

  final BrandingKitController controller;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.88;
    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Branding Kit',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: DashboardColors.textDark,
                          ),
                        ),
                        Text(
                          controller.indentItem.franchiseeName.isEmpty
                              ? 'Franchisee #${controller.franchiseeId}'
                              : controller.indentItem.franchiseeName,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: DashboardColors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Obx(() {
                    if (controller.view.value == BrandingKitView.form) {
                      return IconButton(
                        tooltip: 'Back',
                        onPressed: controller.backToOverview,
                        icon: const Icon(Icons.arrow_back_rounded),
                      );
                    }
                    return IconButton(
                      tooltip: 'Refresh',
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.loadProducts,
                      icon: const Icon(Icons.refresh_rounded),
                    );
                  }),
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.data.value == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.errorMessage.value != null &&
                    controller.data.value == null) {
                  return _ErrorState(
                    message: controller.errorMessage.value!,
                    onRetry: controller.loadProducts,
                  );
                }
                if (controller.view.value == BrandingKitView.form) {
                  return _OrderFormView(controller: controller);
                }
                return _OverviewView(controller: controller);
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewView extends StatelessWidget {
  const _OverviewView({required this.controller});

  final BrandingKitController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final indents = controller.indents;
      if (indents.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined,
                  size: 56, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                'No Branding Orders',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: DashboardColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Create a branding order for this franchisee.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: DashboardColors.textMuted,
                ),
              ),
              const SizedBox(height: 20),
              Obx(() {
                if (!controller.canAddOrder) {
                  return Text(
                    'Only MAN / BH can add a branding order.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: DashboardColors.textMuted,
                    ),
                  );
                }
                return FilledButton.icon(
                  style: DashboardColors.primaryFilledButton(),
                  onPressed: controller.products.isEmpty
                      ? null
                      : controller.openAddOrderForm,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Order'),
                );
              }),
            ],
          ),
        );
      }

      return Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              itemCount: indents.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return _IndentLineCard(line: indents[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: DashboardColors.primaryFilledButton(
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: controller.products.isEmpty
                    ? null
                    : controller.openUpdateOrderForm,
                icon: const Icon(Icons.add),
                label: const Text('Add Order'),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _IndentLineCard extends StatelessWidget {
  const _IndentLineCard({required this.line});

  final BrandingIndentLine line;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DashboardColors.scaffold,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  line.productName.isEmpty ? '—' : line.productName,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: DashboardColors.textDark,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: DashboardColors.purpleLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '#${line.indentId}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: DashboardColors.purple,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Code: ${line.productCode.isEmpty ? '—' : line.productCode}',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: DashboardColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Qty: ${line.quantity} · Amount: ${ProjectDateUtils.formatAmount(line.indentAmount)}',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: DashboardColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Date: ${ProjectDateUtils.formatReadable(line.indentDate)}',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: DashboardColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderFormView extends StatelessWidget {
  const _OrderFormView({required this.controller});

  final BrandingKitController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Obx(
              () => Text(
                controller.hasExistingIndents
                    ? 'Update branding products'
                    : 'Select branding products',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: DashboardColors.textMuted,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.formRows.isEmpty) {
              return Center(
                child: Text(
                  'No products available.',
                  style: GoogleFonts.poppins(color: DashboardColors.textMuted),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              itemCount: controller.formRows.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final row = controller.formRows[index];
                return _ProductFormTile(
                  row: row,
                  onSelected: (v) => controller.toggleProduct(index, v ?? false),
                  onQuantityChanged: (q) => controller.setQuantity(index, q),
                );
              },
            );
          }),
        ),
        Obx(
          () => Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      '${controller.selectedCount} selected',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: DashboardColors.textMuted,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Total ${ProjectDateUtils.formatAmount(controller.formTotal)}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: DashboardColors.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: DashboardColors.primaryFilledButton(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: controller.isSaving.value
                        ? null
                        : () => controller.confirmAndSave(context),
                    child: controller.isSaving.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            controller.hasExistingIndents
                                ? 'Add Order'
                                : 'Add Order',
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductFormTile extends StatelessWidget {
  const _ProductFormTile({
    required this.row,
    required this.onSelected,
    required this.onQuantityChanged,
  });

  final BrandingFormRow row;
  final ValueChanged<bool?> onSelected;
  final ValueChanged<int> onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    final product = row.product;
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
      decoration: BoxDecoration(
        color: row.selected
            ? DashboardColors.primaryLight.withValues(alpha: 0.45)
            : DashboardColors.scaffold,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: row.selected
              ? DashboardColors.primary.withValues(alpha: 0.35)
              : Colors.grey.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: row.selected,
            activeColor: DashboardColors.primary,
            onChanged: onSelected,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: DashboardColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${product.productCode} · MRP ${ProjectDateUtils.formatAmount(product.mrp)}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: DashboardColors.textMuted,
                  ),
                ),
                if (row.selected) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Qty',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 72,
                        height: 36,
                        child: TextFormField(
                          key: ValueKey(
                            '${product.productId}_${row.quantity}',
                          ),
                          initialValue: row.quantity.toString(),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (v) {
                            final q = int.tryParse(v) ?? product.minQuantity;
                            onQuantityChanged(q);
                          },
                        ),
                      ),
                      const Spacer(),
                      Text(
                        ProjectDateUtils.formatAmount(row.totalPrice),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: DashboardColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: DashboardColors.textMuted),
            ),
            const SizedBox(height: 16),
            FilledButton(
              style: DashboardColors.primaryFilledButton(),
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
