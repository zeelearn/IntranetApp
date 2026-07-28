import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:Intranet/api/APIService.dart';
import 'package:Intranet/api/request/bpms/insert_attachment.dart';
import 'package:Intranet/api/response/uploadimage.dart';
import 'package:Intranet/modules/projects/models/dashboard_failure.dart';
import 'package:Intranet/pages/helper/LocalStrings.dart';
import 'package:Intranet/pages/helper/utils.dart';
import 'package:Intranet/pages/iface/onClick.dart';

class FileUploadResult {
  const FileUploadResult({
    required this.location,
    required this.originalName,
    required this.mimeType,
    required this.sizeBytes,
  });

  final String location;
  final String originalName;
  final String mimeType;
  final int sizeBytes;
}

/// Cross-platform task attachment upload (Android / iOS / Web).
///
/// Prefer in-memory [bytes] (required on web). On mobile images with a path,
/// [APIService.uploadImage] is tried first, then Dio multipart fallback.
class TaskAttachmentUploadService {
  TaskAttachmentUploadService({
    APIService? apiService,
    Dio? dio,
    this.uploadUrl = 'https://kubapi.zeelearn.com/V1/pentemind/2025/api/fileUpload/upload',
    this.timeout = const Duration(seconds: 120),
  })  : _api = apiService ?? APIService(),
        _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 60),
                receiveTimeout: const Duration(seconds: 120),
                sendTimeout: const Duration(seconds: 120),
              ),
            );

  final APIService _api;
  final Dio _dio;
  final String uploadUrl;
  final Duration timeout;

  /// Same as web curl:
  /// `https://kubapi.zeelearn.com/V1/commonapi/api/bp//InserttaskAttachment`
  String get insertUrl =>
      '${LocalStrings.bpms}/${LocalStrings.API_INSERT_ATTACHMENT}'
          .replaceAll('///', '//');

  /// Upload binary then register attachment on the task.
  Future<FileUploadResult> uploadAndAttach({
    required String taskId,
    required int userId,
    required String fileName,
    String localPath = '',
    List<int>? bytes,
    bool isVideoFile = false,
    bool isImageFile = false,
  }) async {
    final platform = kIsWeb ? 'web' : defaultTargetPlatform.name;
    debugPrint(
      '[TaskAttach] START platform=$platform taskId=$taskId userId=$userId '
      'fileName=$fileName path=$localPath bytes=${bytes?.length ?? 0} '
      'isVideo=$isVideoFile isImage=$isImageFile',
    );
    debugPrint('[TaskAttach] uploadUrl=$uploadUrl');
    debugPrint('[TaskAttach] insertUrl=$insertUrl');

    if ((bytes == null || bytes.isEmpty) && localPath.trim().isEmpty) {
      throw const DashboardFailure(
        type: DashboardFailureType.unknown,
        message: 'No file data available to upload.',
      );
    }

    FileUploadResult? uploaded;

    // Mobile images with filesystem path: try existing ChatPage uploader first.
    if (!kIsWeb &&
        localPath.trim().isNotEmpty &&
        isImageFile &&
        !isVideoFile) {
      try {
        debugPrint(
          '[TaskAttach] trying APIService.uploadImage path=$localPath',
        );
        uploaded = await uploadViaApiService(
          userId: userId.toString(),
          filePath: localPath,
          isVideoFile: false,
        );
        debugPrint(
          '[TaskAttach] APIService.uploadImage OK location=${uploaded.location}',
        );
      } catch (e, st) {
        debugPrint('[TaskAttach] APIService.uploadImage FAILED: $e');
        debugPrint('[TaskAttach] stack: $st');
        uploaded = null;
      }
    }

    if (uploaded == null) {
      final data = bytes;
      if (data == null || data.isEmpty) {
        throw const DashboardFailure(
          type: DashboardFailureType.unknown,
          message:
              'Unable to upload: file bytes missing. Please re-select the file.',
        );
      }
      uploaded = await uploadBytesViaDio(
        bytes: data,
        fileName: fileName.isEmpty ? 'attachment.bin' : fileName,
      );
    }

    debugPrint(
      '[TaskAttach] upload OK location=${uploaded.location} '
      'name=${uploaded.originalName} size=${uploaded.sizeBytes}',
    );

    await insertTaskAttachment(
      taskId: taskId,
      filePath: uploaded.location,
      userId: userId.toString(),
    );
    debugPrint(
      '[TaskAttach] insert OK taskId=$taskId file_path=${uploaded.location}',
    );
    return uploaded;
  }

  /// Dio multipart upload — works on Android, iOS, and Web (bytes).
  Future<FileUploadResult> uploadBytesViaDio({
    required List<int> bytes,
    required String fileName,
  }) async {
    debugPrint(
      '[TaskAttach] Dio POST $uploadUrl field=inputFile fileName=$fileName '
      'bytes=${bytes.length}',
    );
    try {
      final formData = FormData.fromMap({
        'inputFile': MultipartFile.fromBytes(
          bytes,
          filename: fileName,
        ),
      });

      final response = await _dio
          .post<dynamic>(
            uploadUrl,
            data: formData,
            options: Options(
              contentType: 'multipart/form-data',
              responseType: ResponseType.json,
              validateStatus: (code) => code != null && code < 500,
            ),
          )
          .timeout(timeout);

      debugPrint(
        '[TaskAttach] Dio status=${response.statusCode} '
        'responseUrl=${response.realUri}',
      );
      debugPrint('[TaskAttach] Dio body=${response.data}');

      if (response.statusCode == null ||
          response.statusCode! < 200 ||
          response.statusCode! >= 300) {
        throw DashboardFailure(
          type: DashboardFailureType.server,
          message: 'Upload failed (${response.statusCode}).',
        );
      }

      final decoded = response.data is String
          ? jsonDecode(response.data as String)
          : response.data;
      if (decoded is! Map) {
        throw const DashboardFailure(
          type: DashboardFailureType.invalidJson,
          message: 'Invalid upload response.',
        );
      }
      final map = Map<String, dynamic>.from(decoded);
      final data = map['data'];
      if (data is! List || data.isEmpty || data.first is! Map) {
        throw const DashboardFailure(
          type: DashboardFailureType.server,
          message: 'Upload succeeded but no file URL was returned.',
        );
      }
      final first = Map<String, dynamic>.from(data.first as Map);
      final location = first['location']?.toString().trim() ?? '';
      debugPrint('[TaskAttach] parsed location=$location key=${first['key']}');
      if (location.isEmpty) {
        throw const DashboardFailure(
          type: DashboardFailureType.server,
          message: 'Upload succeeded but file location is empty.',
        );
      }
      return FileUploadResult(
        location: location,
        originalName: first['originalname']?.toString() ?? fileName,
        mimeType: first['mimetype']?.toString() ??
            first['contentType']?.toString() ??
            '',
        sizeBytes: int.tryParse('${first['size']}') ?? bytes.length,
      );
    } on DashboardFailure {
      rethrow;
    } on DioException catch (e) {
      debugPrint(
        '[TaskAttach] DioException type=${e.type} message=${e.message} '
        'url=${e.requestOptions.uri} status=${e.response?.statusCode} '
        'response=${e.response?.data} error=${e.error}',
      );
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const DashboardFailure(
          type: DashboardFailureType.timeout,
          message: 'Upload timed out. Please try again.',
        );
      }
      throw DashboardFailure(
        type: DashboardFailureType.noInternet,
        message: e.message?.isNotEmpty == true
            ? e.message!
            : 'Unable to reach upload server (${e.type.name}).',
      );
    } on TimeoutException {
      throw const DashboardFailure(
        type: DashboardFailureType.timeout,
        message: 'Upload timed out. Please try again.',
      );
    } catch (e) {
      debugPrint('[TaskAttach] uploadBytesViaDio unexpected: $e');
      throw DashboardFailure(
        type: DashboardFailureType.unknown,
        message: e.toString(),
      );
    }
  }

  /// Existing ChatPage path: `APIService().uploadImage(userId, path, …)`.
  Future<FileUploadResult> uploadViaApiService({
    required String userId,
    required String filePath,
    bool isVideoFile = false,
  }) async {
    debugPrint(
      '[TaskAttach] APIService.uploadImage userId=$userId path=$filePath '
      'isVideo=$isVideoFile',
    );
    final completer = Completer<FileUploadResult>();
    final listener = _UploadClickListener((action, value) {
      if (completer.isCompleted) return;
      if (action == Utility.ACTION_IMAGE_UPLOAD_RESPONSE_OK &&
          value is UploadImageResponse) {
        final result = _resultFromUploadResponse(value);
        if (result != null) {
          debugPrint('[TaskAttach] listener OK location=${result.location}');
          completer.complete(result);
        } else {
          completer.completeError(
            DashboardFailure(
              type: DashboardFailureType.server,
              message: value.message.isNotEmpty
                  ? value.message
                  : 'Upload succeeded but no file URL was returned.',
            ),
          );
        }
      } else if (action == Utility.ACTION_IMAGE_UPLOAD_RESPONSE_ERROR) {
        debugPrint('[TaskAttach] listener ERROR value=$value');
        completer.completeError(
          DashboardFailure(
            type: DashboardFailureType.server,
            message: value?.toString() ?? 'Upload failed.',
          ),
        );
      }
    });

    final either = await _api
        .uploadImage(
          userId,
          filePath,
          listener: listener,
          isVideoFile: isVideoFile,
          progress: (_, __) {},
        )
        .timeout(timeout);

    if (!completer.isCompleted) {
      either.fold(
        (left) {
          final location = left.trim();
          debugPrint('[TaskAttach] uploadImage Left=$location');
          if (location.startsWith('http')) {
            completer.complete(
              FileUploadResult(
                location: location,
                originalName: filePath.split(RegExp(r'[/\\]')).last,
                mimeType: '',
                sizeBytes: 0,
              ),
            );
          } else {
            completer.completeError(
              DashboardFailure(
                type: DashboardFailureType.server,
                message: location.isEmpty ? 'Upload failed.' : location,
              ),
            );
          }
        },
        (right) {
          final result = _resultFromUploadResponse(right);
          debugPrint(
            '[TaskAttach] uploadImage Right location=${result?.location}',
          );
          if (result != null) {
            completer.complete(result);
          } else {
            completer.completeError(
              const DashboardFailure(
                type: DashboardFailureType.server,
                message: 'Upload succeeded but no file URL was returned.',
              ),
            );
          }
        },
      );
    }

    return completer.future.timeout(timeout);
  }

  Future<void> insertTaskAttachment({
    required String taskId,
    required String filePath,
    required String userId,
  }) async {
    // Curl-compatible payload (numeric ids).
    final body = InsertTaskAttachmentRequest(
      taskId: taskId,
      filePath: filePath,
      userId: userId,
    ).toMap();

    String source = 'unknown';
    if (kIsWeb) {
      source = 'web';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      source = 'Android';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      source = 'IOS';
    }

    final headers = <String, dynamic>{
      'Accept': 'application/json, text/plain, */*',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer admin-token',
      'dbid': '1',
      'source': source,
    };

    debugPrint('[TaskAttach] INSERT url=$insertUrl');
    debugPrint('[TaskAttach] INSERT headers=$headers');
    debugPrint('[TaskAttach] INSERT body=${jsonEncode(body)}');

    try {
      final response = await _dio
          .post<dynamic>(
            insertUrl,
            data: body,
            options: Options(
              headers: headers,
              contentType: 'application/json',
              responseType: ResponseType.json,
              validateStatus: (code) => code != null && code < 500,
            ),
          )
          .timeout(timeout);

      debugPrint(
        '[TaskAttach] INSERT status=${response.statusCode} '
        'responseUrl=${response.realUri}',
      );
      debugPrint('[TaskAttach] INSERT response=${response.data}');

      if (response.statusCode != 200) {
        throw DashboardFailure(
          type: DashboardFailureType.server,
          message:
              'Unable to attach file to task (${response.statusCode}).',
        );
      }

      final decoded = response.data is String
          ? jsonDecode(response.data as String)
          : response.data;
      if (decoded is Map) {
        final success = decoded['success'];
        final ok = success == 200 ||
            success == true ||
            success?.toString() == '200';
        if (!ok && success != null) {
          final data = decoded['data'];
          String msg = '';
          if (data is List && data.isNotEmpty && data.first is Map) {
            msg = (data.first as Map)['msg']?.toString() ?? '';
          }
          throw DashboardFailure(
            type: DashboardFailureType.server,
            message: msg.isNotEmpty
                ? msg
                : (decoded['message']?.toString() ??
                    'Unable to attach file to task.'),
          );
        }
      }

    } on DashboardFailure {
      rethrow;
    } on DioException catch (e) {
      debugPrint(
        '[TaskAttach] INSERT DioException type=${e.type} '
        'url=${e.requestOptions.uri} status=${e.response?.statusCode} '
        'response=${e.response?.data} message=${e.message}',
      );
      throw DashboardFailure(
        type: DashboardFailureType.server,
        message: e.message ?? 'Unable to attach file to task.',
      );
    } on TimeoutException {
      throw const DashboardFailure(
        type: DashboardFailureType.timeout,
        message: 'Attach request timed out.',
      );
    } catch (e) {
      debugPrint('[TaskAttach] INSERT FAILED: $e');
      if (e is DashboardFailure) rethrow;
      throw DashboardFailure(
        type: DashboardFailureType.unknown,
        message: e.toString(),
      );
    }
  }

  static FileUploadResult? _resultFromUploadResponse(UploadImageResponse value) {
    final models = value.imageModel;
    if (models == null || models.isEmpty) return null;
    final first = models.first;
    final location = first.location.trim();
    if (location.isEmpty) return null;
    return FileUploadResult(
      location: location,
      originalName: first.originalname,
      mimeType: first.mimetype,
      sizeBytes: first.size,
    );
  }
}

class _UploadClickListener extends onClickListener {
  _UploadClickListener(this._onClick);

  final void Function(int action, dynamic value) _onClick;

  @override
  void onClick(int action, dynamic value) => _onClick(action, value);
}
