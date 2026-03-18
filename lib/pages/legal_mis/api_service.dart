import 'dart:convert';
import 'package:Intranet/pages/legal_mis/document_status.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String _baseUrl = 'www.zohoapis.in';
  final String _path =
      '/crm/v7/functions/getzohosigndocumentstatus/actions/execute';

  Future<DocumentStatus> getDocumentStatus(String requestId) async {
    final apiKey = dotenv.env['ZOHO_API_KEY'];
    if (apiKey == null) {
      throw Exception('ZOHO_API_KEY not found in environment variables.');
    }

    final queryParameters = {
      'auth_type': 'apikey',
      'zapikey': apiKey,
      'request_id': requestId,
    };

    final uri = Uri.https(_baseUrl, _path, queryParameters);

    try {
      final response = await http.get(uri, headers: {
        'Cookie':
            '_zcsr_tmp=15cd5135-3d85-4142-99e5-cfcb5c245569; crmcsr=15cd5135-3d85-4142-99e5-cfcb5c245569; group_name=usergroup1'
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);

        // 1. Check if the response is the data directly (Unwrapped)
        if (body.containsKey('req_id')) {
          return DocumentStatus.fromJson(body);
        }

        // 2. Check if the response is wrapped in standard Zoho Function structure
        if ((body['code'] == 'success' || body['code'] == 'SUCCESS') &&
            body['details']?['output'] != null) {
          final dynamic output = body['details']['output'];
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
