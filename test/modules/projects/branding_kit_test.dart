import 'package:flutter_test/flutter_test.dart';
import 'package:Intranet/modules/projects/models/branding_kit_models.dart';
import 'package:Intranet/modules/projects/services/branding_remote_service.dart';
import 'package:Intranet/pages/helper/LocalStrings.dart';

void main() {
  group('BrandingRemoteService URL scheme', () {
    test('GetBrandingProduct uses kubapi https with dbid 0', () {
      expect(LocalStrings.kidzeeBrandingDbId, '0');
      expect(
        LocalStrings.API_GET_BRANDING_PRODUCT,
        'https://kubapi.zeelearn.com/V1/commonapi/api/kidzee//GetBrandingProduct',
      );
      final uri = BrandingRemoteService().getProductsUri();
      expect(uri.scheme, 'https');
      expect(uri.host, 'kubapi.zeelearn.com');
      expect(uri.path, contains('GetBrandingProduct'));
    });

    test('InsertBrandingIndent uses kubapi https (not local IP)', () {
      expect(
        LocalStrings.API_INSERT_BRANDING_INDENT,
        'https://kubapi.zeelearn.com/V1/commonapi/api/kidzee//InsertBrandingIndent',
      );
      final uri = BrandingRemoteService().buildInsertUri();
      expect(uri.scheme, 'https');
      expect(uri.host, 'kubapi.zeelearn.com');
      expect(uri.path, contains('InsertBrandingIndent'));
      expect(uri.host, isNot(equals('10.112.1.35')));
    });
  });

  group('BrandingProductData parsing', () {
    test('parses ProductList and Indents from API sample', () {
      final response = BrandingProductResponse.fromJson({
        'success': 200,
        'data': {
          'ProductList': [
            {
              'Select': 0,
              'Product_Id': 107250,
              'Product_Code': '2000431',
              'Product_Name': 'Kidzee Branding Module-1',
              'MRP': 250000,
              'Min_Quantity': 1,
            },
            {
              'Select': 0,
              'Product_Id': 107251,
              'Product_Code': '2000432',
              'Product_Name': 'Kidzee Branding Module-2',
              'MRP': 350000,
              'Min_Quantity': 1,
            },
          ],
          'Indents': [
            {
              'Indent_Id': 1051468,
              'Indent_Date': '2026-07-30T12:01:35.030',
              'Product_Code': '2000431',
              'Product_Name': 'Kidzee Branding Module-1',
              'Quantity': 1,
              'Indent_Amount': 250000,
            },
          ],
        },
      });

      expect(response.success, 200);
      expect(response.data.productList, hasLength(2));
      expect(response.data.indents, hasLength(1));
      expect(response.data.hasExistingIndents, isTrue);
      expect(response.data.productList.first.productId, 107250);
      expect(response.data.indents.first.indentId, 1051468);
    });

    test('empty Indents means add-order mode', () {
      final data = BrandingProductData.fromJson({
        'ProductList': [
          {
            'Product_Id': 1,
            'Product_Code': 'A',
            'Product_Name': 'P',
            'MRP': 10,
            'Min_Quantity': 1,
          },
        ],
        'Indents': [],
      });
      expect(data.hasExistingIndents, isFalse);
    });

    test('tolerates missing data map', () {
      final response = BrandingProductResponse.fromJson({'success': 200});
      expect(response.data.productList, isEmpty);
      expect(response.data.indents, isEmpty);
    });
  });

  group('buildBrandingFormRows', () {
    final products = [
      const BrandingProduct(
        select: 0,
        productId: 107250,
        productCode: '2000431',
        productName: 'Module-1',
        mrp: 250000,
        minQuantity: 1,
      ),
      const BrandingProduct(
        select: 0,
        productId: 107251,
        productCode: '2000432',
        productName: 'Module-2',
        mrp: 350000,
        minQuantity: 1,
      ),
      const BrandingProduct(
        select: 0,
        productId: 107252,
        productCode: '2000433',
        productName: 'Module-3',
        mrp: 450000,
        minQuantity: 2,
      ),
    ];

    test('prefills selected products from Indents by Product_Code', () {
      final rows = buildBrandingFormRows(
        products: products,
        indents: const [
          BrandingIndentLine(
            indentId: 1,
            indentDate: '',
            productCode: '2000431',
            productName: 'Module-1',
            quantity: 3,
            indentAmount: 750000,
          ),
        ],
      );
      expect(rows, hasLength(3));
      expect(rows[0].selected, isTrue);
      expect(rows[0].quantity, 3);
      expect(rows[0].totalPrice, 750000);
      expect(rows[1].selected, isFalse);
      expect(rows[2].selected, isFalse);
    });

    test('uses min quantity when indent qty below min', () {
      final rows = buildBrandingFormRows(
        products: products,
        indents: const [
          BrandingIndentLine(
            indentId: 1,
            indentDate: '',
            productCode: '2000433',
            productName: 'Module-3',
            quantity: 1,
            indentAmount: 450000,
          ),
        ],
      );
      expect(rows[2].selected, isTrue);
      expect(rows[2].quantity, 2);
    });

    test('no indents leaves all unselected with min qty', () {
      final rows = buildBrandingFormRows(products: products, indents: const []);
      expect(rows.every((r) => !r.selected), isTrue);
      expect(rows[2].quantity, 2);
    });
  });

  group('InsertBrandingIndentRequest', () {
    test('toJson matches API shape', () {
      const request = InsertBrandingIndentRequest(
        franchiseeId: 2354,
        academicYearId: 26,
        createdBy: 35959,
        inputData: [
          BrandingOrderLine(
            productId: 107250,
            quantity: 1,
            totalPrice: 250000,
          ),
        ],
      );
      expect(request.toJson(), {
        'FranchiseeId': 2354,
        'AcademicYearId': 26,
        'CreatedBy': 35959,
        'InputData': [
          {
            'Product_Id': 107250,
            'ClassId': 0,
            'Quantity': 1,
            'TotalPrice': 250000,
          },
        ],
      });
    });

    test('validate rejects empty selection and invalid ids', () {
      expect(
        const InsertBrandingIndentRequest(
          franchiseeId: 0,
          academicYearId: 26,
          createdBy: 1,
          inputData: [
            BrandingOrderLine(productId: 1, quantity: 1, totalPrice: 1),
          ],
        ).validate(),
        contains('franchisee'),
      );
      expect(
        const InsertBrandingIndentRequest(
          franchiseeId: 1,
          academicYearId: 26,
          createdBy: 0,
          inputData: [
            BrandingOrderLine(productId: 1, quantity: 1, totalPrice: 1),
          ],
        ).validate(),
        contains('user'),
      );
      expect(
        const InsertBrandingIndentRequest(
          franchiseeId: 1,
          academicYearId: 26,
          createdBy: 1,
          inputData: [],
        ).validate(),
        contains('product'),
      );
      expect(
        const InsertBrandingIndentRequest(
          franchiseeId: 1,
          academicYearId: 26,
          createdBy: 1,
          inputData: [
            BrandingOrderLine(productId: 1, quantity: 1, totalPrice: 10),
          ],
        ).validate(),
        isNull,
      );
    });
  });

  group('InsertBrandingIndentResult', () {
    test('parses IndentId from data', () {
      final result = InsertBrandingIndentResult.fromJson({
        'success': 200,
        'data': {'IndentId': 1051468},
      });
      expect(result.success, isTrue);
      expect(result.indentId, 1051468);
      expect(result.message, contains('1051468'));
    });

    test('fails when IndentId missing', () {
      final result = InsertBrandingIndentResult.fromJson({
        'success': 200,
        'data': {},
      });
      expect(result.success, isFalse);
    });
  });

  group('BrandingFormRow.toOrderLine', () {
    test('returns null when not selected', () {
      const row = BrandingFormRow(
        product: BrandingProduct(
          select: 0,
          productId: 1,
          productCode: 'A',
          productName: 'P',
          mrp: 100,
          minQuantity: 1,
        ),
        selected: false,
        quantity: 2,
      );
      expect(row.toOrderLine(), isNull);
    });

    test('builds line with MRP * qty', () {
      const row = BrandingFormRow(
        product: BrandingProduct(
          select: 0,
          productId: 107250,
          productCode: '2000431',
          productName: 'P',
          mrp: 250000,
          minQuantity: 1,
        ),
        selected: true,
        quantity: 2,
      );
      final line = row.toOrderLine();
      expect(line!.productId, 107250);
      expect(line.quantity, 2);
      expect(line.totalPrice, 500000);
      expect(line.classId, 0);
    });
  });
}
