import 'dart:convert';
import 'package:Intranet/pages/helper/LocalStrings.dart';
import 'package:Intranet/pages/legal_mis/document_status.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // final String _baseUrl =
  //     'commonapi.zeelearn.com';
  final String _path = '/V1/commonapi/api/bp/agreementstatus';

  Future<DocumentStatus> getDocumentStatus(String requestId) async {
    final uri = Uri.https(LocalStrings.bpms_no_http, _path);

    try {
      final response = await http.post(uri,
          body: jsonEncode({"request_id": requestId}),
          headers: {"content-type": "application/json", "dbid": "1"});

      // print('API Response Status:  ${requestId} ${response.statusCode} - ${response.body.runtimeType} - ${response.body} ');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> body = json.decode(response.body);

        // 2. Check if the response is wrapped in standard Zoho Function structure
        if (body['success'] && body['data']?['output'] != null) {
          final dynamic output = body['data']['output'];
          if (output is String) {
            return DocumentStatus.fromJson(json.decode(output));
          } else {
            return DocumentStatus.fromJson(output);
          }
        } else {
          throw Exception(
              'API returned an error: ${body['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception(
            'Failed to load document status: ${response.statusCode}');
      }
    } catch (e) {
      // Re-throw for the UI layer to handle.
      throw Exception('Failed to connect to the server: $e');
    }
  }
}
