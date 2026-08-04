import 'package:equatable/equatable.dart';

class BrandingProduct extends Equatable {
  const BrandingProduct({
    required this.select,
    required this.productId,
    required this.productCode,
    required this.productName,
    required this.mrp,
    required this.minQuantity,
  });

  final int select;
  final int productId;
  final String productCode;
  final String productName;
  final double mrp;
  final int minQuantity;

  factory BrandingProduct.fromJson(Map<String, dynamic> json) {
    return BrandingProduct(
      select: _asInt(json['Select']),
      productId: _asInt(json['Product_Id']),
      productCode: _asString(json['Product_Code']),
      productName: _asString(json['Product_Name']),
      mrp: _asDouble(json['MRP']),
      minQuantity: _asInt(json['Min_Quantity']).clamp(1, 999999),
    );
  }

  Map<String, dynamic> toJson() => {
        'Select': select,
        'Product_Id': productId,
        'Product_Code': productCode,
        'Product_Name': productName,
        'MRP': mrp,
        'Min_Quantity': minQuantity,
      };

  static String _asString(dynamic v) => v?.toString().trim() ?? '';

  static int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _asDouble(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  @override
  List<Object?> get props =>
      [select, productId, productCode, productName, mrp, minQuantity];
}

class BrandingIndentLine extends Equatable {
  const BrandingIndentLine({
    required this.indentId,
    required this.indentDate,
    required this.productCode,
    required this.productName,
    required this.quantity,
    required this.indentAmount,
  });

  final int indentId;
  final String indentDate;
  final String productCode;
  final String productName;
  final int quantity;
  final double indentAmount;

  factory BrandingIndentLine.fromJson(Map<String, dynamic> json) {
    return BrandingIndentLine(
      indentId: BrandingProduct._asInt(json['Indent_Id']),
      indentDate: BrandingProduct._asString(json['Indent_Date']),
      productCode: BrandingProduct._asString(json['Product_Code']),
      productName: BrandingProduct._asString(json['Product_Name']),
      quantity: BrandingProduct._asInt(json['Quantity']),
      indentAmount: BrandingProduct._asDouble(json['Indent_Amount']),
    );
  }

  Map<String, dynamic> toJson() => {
        'Indent_Id': indentId,
        'Indent_Date': indentDate,
        'Product_Code': productCode,
        'Product_Name': productName,
        'Quantity': quantity,
        'Indent_Amount': indentAmount,
      };

  @override
  List<Object?> get props => [
        indentId,
        indentDate,
        productCode,
        productName,
        quantity,
        indentAmount,
      ];
}

class BrandingProductData extends Equatable {
  const BrandingProductData({
    required this.productList,
    required this.indents,
  });

  final List<BrandingProduct> productList;
  final List<BrandingIndentLine> indents;

  bool get hasExistingIndents => indents.isNotEmpty;

  factory BrandingProductData.fromJson(Map<String, dynamic> json) {
    final products = <BrandingProduct>[];
    final rawProducts = json['ProductList'];
    if (rawProducts is List) {
      for (final item in rawProducts) {
        if (item is Map) {
          products.add(
            BrandingProduct.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    final indentLines = <BrandingIndentLine>[];
    final rawIndents = json['Indents'];
    if (rawIndents is List) {
      for (final item in rawIndents) {
        if (item is Map) {
          indentLines.add(
            BrandingIndentLine.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return BrandingProductData(
      productList: products,
      indents: indentLines,
    );
  }

  @override
  List<Object?> get props => [productList, indents];
}

class BrandingProductResponse extends Equatable {
  const BrandingProductResponse({
    required this.success,
    required this.data,
  });

  final int success;
  final BrandingProductData data;

  factory BrandingProductResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final data = raw is Map
        ? BrandingProductData.fromJson(Map<String, dynamic>.from(raw))
        : const BrandingProductData(productList: [], indents: []);
    return BrandingProductResponse(
      success: BrandingProduct._asInt(json['success']),
      data: data,
    );
  }

  @override
  List<Object?> get props => [success, data];
}

/// One line in InsertBrandingIndent InputData.
class BrandingOrderLine extends Equatable {
  const BrandingOrderLine({
    required this.productId,
    required this.quantity,
    required this.totalPrice,
    this.classId = 0,
  });

  final int productId;
  final int classId;
  final int quantity;
  final double totalPrice;

  Map<String, dynamic> toJson() => {
        'Product_Id': productId,
        'ClassId': classId,
        'Quantity': quantity,
        'TotalPrice': totalPrice,
      };

  @override
  List<Object?> get props => [productId, classId, quantity, totalPrice];
}

class InsertBrandingIndentRequest extends Equatable {
  const InsertBrandingIndentRequest({
    required this.franchiseeId,
    required this.academicYearId,
    required this.createdBy,
    required this.inputData,
  });

  final int franchiseeId;
  final int academicYearId;
  final int createdBy;
  final List<BrandingOrderLine> inputData;

  Map<String, dynamic> toJson() => {
        'FranchiseeId': franchiseeId,
        'AcademicYearId': academicYearId,
        'CreatedBy': createdBy,
        'InputData':
            inputData.map((e) => e.toJson()).toList(growable: false),
      };

  /// Validates finance payload before network call.
  String? validate() {
    if (franchiseeId <= 0) return 'Invalid franchisee.';
    if (createdBy <= 0) return 'Invalid user. Please sign in again.';
    if (academicYearId <= 0) return 'Invalid academic year.';
    if (inputData.isEmpty) return 'Select at least one product.';
    for (final line in inputData) {
      if (line.productId <= 0) return 'Invalid product selected.';
      if (line.quantity <= 0) return 'Quantity must be at least 1.';
      if (line.totalPrice < 0) return 'Invalid total price.';
    }
    return null;
  }

  @override
  List<Object?> get props =>
      [franchiseeId, academicYearId, createdBy, inputData];
}

class InsertBrandingIndentResult extends Equatable {
  const InsertBrandingIndentResult({
    required this.success,
    required this.indentId,
    required this.message,
  });

  final bool success;
  final int indentId;
  final String message;

  factory InsertBrandingIndentResult.fromJson(Map<String, dynamic> json) {
    final successCode = BrandingProduct._asInt(json['success']);
    final data = json['data'];
    var indentId = 0;
    if (data is Map) {
      indentId = BrandingProduct._asInt(
        data['IndentId'] ?? data['Indent_Id'] ?? data['indentId'],
      );
    }
    final ok = successCode == 200 && indentId > 0;
    return InsertBrandingIndentResult(
      success: ok,
      indentId: indentId,
      message: ok
          ? 'Branding order saved. Indent #$indentId'
          : 'Unable to save branding order. Please try again.',
    );
  }

  @override
  List<Object?> get props => [success, indentId, message];
}

/// Editable row state for the branding order form.
class BrandingFormRow extends Equatable {
  const BrandingFormRow({
    required this.product,
    required this.selected,
    required this.quantity,
  });

  final BrandingProduct product;
  final bool selected;
  final int quantity;

  double get totalPrice => product.mrp * quantity;

  BrandingFormRow copyWith({bool? selected, int? quantity}) {
    return BrandingFormRow(
      product: product,
      selected: selected ?? this.selected,
      quantity: quantity ?? this.quantity,
    );
  }

  BrandingOrderLine? toOrderLine() {
    if (!selected || quantity <= 0) return null;
    return BrandingOrderLine(
      productId: product.productId,
      quantity: quantity,
      totalPrice: totalPrice,
    );
  }

  @override
  List<Object?> get props => [product, selected, quantity];
}

/// Builds form rows from ProductList, prefilled via Indents Product_Code.
List<BrandingFormRow> buildBrandingFormRows({
  required List<BrandingProduct> products,
  required List<BrandingIndentLine> indents,
}) {
  final qtyByCode = <String, int>{};
  for (final line in indents) {
    final code = line.productCode.trim().toLowerCase();
    if (code.isEmpty) continue;
    qtyByCode[code] = line.quantity > 0 ? line.quantity : 1;
  }

  return products.map((p) {
    final code = p.productCode.trim().toLowerCase();
    final prefilledQty = qtyByCode[code];
    final selected = prefilledQty != null;
    final qty = selected
        ? ((prefilledQty >= p.minQuantity) ? prefilledQty : p.minQuantity)
        : p.minQuantity;
    return BrandingFormRow(
      product: p,
      selected: selected,
      quantity: qty,
    );
  }).toList(growable: false);
}
