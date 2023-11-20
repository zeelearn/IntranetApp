class UploadImageResponse {
  UploadImageResponse({
    required this.message,
    required this.imageModel,
  });
  late final String message;
  late final List<UploadImageModel>? imageModel;

  UploadImageResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    imageModel = List.from(json['data'])
        .map((e) => UploadImageModel.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['message'] = message;
    data['data'] = imageModel!.map((e) => e.toJson()).toList();
    return data;
  }
}

class UploadImageModel {
  UploadImageModel({
    required this.fieldname,
    required this.originalname,
    required this.encoding,
    required this.mimetype,
    required this.size,
    required this.bucket,
    required this.key,
    required this.acl,
    required this.contentType,
    this.contentDisposition,
    this.contentEncoding,
    required this.storageClass,
    this.serverSideEncryption,
    required this.metadata,
    required this.location,
    required this.etag,
  });
  late final String fieldname;
  late final String originalname;
  late final String encoding;
  late final String mimetype;
  late final int size;
  late final String bucket;
  late final String key;
  late final String acl;
  late final String contentType;
  late final dynamic contentDisposition;
  late final dynamic contentEncoding;
  late final String storageClass;
  late final dynamic serverSideEncryption;
  late final Metadata metadata;
  late final String location;
  late final String etag;

  UploadImageModel.fromJson(Map<String, dynamic> json) {
    fieldname = json['fieldname'] ?? '';
    originalname = json['originalname'] ?? '';
    encoding = json['encoding'] ?? '';
    mimetype = json['mimetype'] ?? '';
    size = json['size'] ?? '';
    bucket = json['bucket'] ?? '';
    key = json['key'] ?? '';
    acl = json['acl'] ?? '';
    contentType = json['contentType'] ?? '';
    contentDisposition = null;
    contentEncoding = null;
    storageClass = json['storageClass'] ?? '';
    serverSideEncryption = null;
    metadata = Metadata.fromJson(json['metadata']);
    location = json['location'];
    etag = json['etag'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['fieldname'] = fieldname;
    data['originalname'] = originalname;
    data['encoding'] = encoding;
    data['mimetype'] = mimetype;
    data['size'] = size;
    data['bucket'] = bucket;
    data['key'] = key;
    data['acl'] = acl;
    data['contentType'] = contentType;
    data['contentDisposition'] = contentDisposition;
    data['contentEncoding'] = contentEncoding;
    data['storageClass'] = storageClass;
    data['serverSideEncryption'] = serverSideEncryption;
    data['metadata'] = metadata.toJson();
    data['location'] = location;
    data['etag'] = etag;
    return data;
  }
}

class Metadata {
  Metadata({
    required this.fieldName,
  });
  late final String fieldName;

  Metadata.fromJson(Map<String, dynamic> json) {
    fieldName = json['fieldName'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['fieldName'] = fieldName;
    return data;
  }
}
