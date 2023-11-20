import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/response/bpms/franchisee_details_response.dart';
import '../../helper/LocalStrings.dart';
import 'exceptions.dart';


abstract class BPMSRepository {
  Future<GetFranchiseeDetailsResponse> getFranchiseeDetailInfo({
    required int franchiseeId
  });
}

class BPMSAPIRepository implements BPMSRepository {
  late final Dio _dio;

  BPMSAPIRepository(this._dio);

  @override
  Future<String> login(
      {required String email, required String password}) async {
    const url = 'https://reqres.in/api/login';

    try {
      final data = {
        'email': email,
        'password': password,
      };

      final response = await _dio.post(url, data: data);

      final token = response.data['token'] as String;
      return token;
    } on DioException catch (e) {
      throw APIException(message: 'Unable to login');
    } catch (e) {
      throw Exception('Unable to login');
    }
  }

  @override
  Future<GetFranchiseeDetailsResponse> getFranchiseeDetailInfo({required int franchiseeId}) async {
    const url = LocalStrings.bpms;
    try {
      final data = {
        'Franchisee_ID': franchiseeId,
      };
      final response = await _dio.post(url, data: data);
      return GetFranchiseeDetailsResponse.fromJson(
        json.decode(response.data as String),
      );
      //final token = response.data['token'] as String;
      //return token;
    } on DioException catch (e) {
      throw APIException(message: 'Unable to login');
    } catch (e) {
      throw Exception('Unable to login');
    }
  }
}

final authRepositoryProvider = Provider<BPMSRepository>((ref) {
  return BPMSAPIRepository(Dio());
});