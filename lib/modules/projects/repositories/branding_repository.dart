import 'package:Intranet/modules/projects/models/branding_kit_models.dart';
import 'package:Intranet/modules/projects/services/branding_remote_service.dart';
import 'package:Intranet/pages/helper/LocalStrings.dart';

class BrandingRepository {
  BrandingRepository({required BrandingRemoteService remoteService})
      : _remote = remoteService;

  final BrandingRemoteService _remote;

  Future<BrandingProductData> loadProducts({required int franchiseeId}) {
    return _remote.fetchBrandingProducts(franchiseeId: franchiseeId);
  }

  Future<InsertBrandingIndentResult> saveOrder({
    required int franchiseeId,
    required int createdBy,
    required List<BrandingOrderLine> lines,
    int academicYearId = LocalStrings.kidzeeBrandingAcademicYearId,
  }) {
    final request = InsertBrandingIndentRequest(
      franchiseeId: franchiseeId,
      academicYearId: academicYearId,
      createdBy: createdBy,
      inputData: lines,
    );
    return _remote.insertBrandingIndent(request: request);
  }
}
