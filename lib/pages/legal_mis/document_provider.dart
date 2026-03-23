import 'package:Intranet/pages/legal_mis/api_service.dart';
import 'package:Intranet/pages/legal_mis/document_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides an instance of the ApiService.
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

/// Fetches the document status.
/// The `.family` modifier allows us to pass the `requestId` when we use the provider.
final documentStatusProvider = FutureProvider.autoDispose
    .family<DocumentStatus, String>((ref, requestId) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getDocumentStatus(requestId);
});
