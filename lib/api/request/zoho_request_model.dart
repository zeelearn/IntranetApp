class ZohoRequestModel {
  List<Requests>? requests;
  String? error;

  ZohoRequestModel({this.requests});
  ZohoRequestModel.setError(String message) {
    error = message;
  }

  ZohoRequestModel.fromJson(Map<String, dynamic> json) {
    if (json['requests'] != null) {
      requests = <Requests>[];
      json['requests'].forEach((v) {
        requests!.add(Requests.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (requests != null) {
      data['requests'] = requests!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Requests {
  String? requestStatus;
  String? notes;
  num? reminderPeriod;
  String? ownerId;
  String? description;
  String? requestName;
  num? modifiedTime;
  num? actionTime;
  bool? isDeleted;
  num? expirationDays;
  bool? isSequential;
  num? signSubmittedTime;

  String? ownerFirstName;
  num? signPercentage;
  num? expireBy;
  String? ownerEmail;
  num? createdTime;
  bool? emailReminders;
  List<DocumentIds>? documentIds;
  bool? selfSign;
  bool? inProcess;
  num? validity;
  String? requestTypeName;
  String? requestId;
  String? zsdocumentid;
  String? requestTypeId;
  String? ownerLastName;
  List<Actions>? actions;

  Requests(
      {this.requestStatus,
      this.notes,
      this.reminderPeriod,
      this.ownerId,
      this.description,
      this.requestName,
      this.modifiedTime,
      this.actionTime,
      this.isDeleted,
      this.expirationDays,
      this.isSequential,
      this.signSubmittedTime,
      this.ownerFirstName,
      this.signPercentage,
      this.expireBy,
      this.ownerEmail,
      this.createdTime,
      this.emailReminders,
      this.documentIds,
      this.selfSign,
      this.inProcess,
      this.validity,
      this.requestTypeName,
      this.requestId,
      this.zsdocumentid,
      this.requestTypeId,
      this.ownerLastName,
      this.actions});

  Requests.fromJson(Map<String, dynamic> json) {
    requestStatus = json['request_status'];
    notes = json['notes'];
    reminderPeriod = json['reminder_period'];
    ownerId = json['owner_id'];
    description = json['description'];
    requestName = json['request_name'];
    modifiedTime = json['modified_time'];
    actionTime = json['action_time'];
    isDeleted = json['is_deleted'];
    expirationDays = json['expiration_days'];
    isSequential = json['is_sequential'];
    signSubmittedTime = json['sign_submitted_time'];

    ownerFirstName = json['owner_first_name'];
    signPercentage = json['sign_percentage'];
    expireBy = json['expire_by'];
    ownerEmail = json['owner_email'];
    createdTime = json['created_time'];
    emailReminders = json['email_reminders'];
    if (json['document_ids'] != null) {
      documentIds = <DocumentIds>[];
      json['document_ids'].forEach((v) {
        documentIds!.add(DocumentIds.fromJson(v));
      });
    }
    selfSign = json['self_sign'];
    inProcess = json['in_process'];
    validity = json['validity'];
    requestTypeName = json['request_type_name'];
    requestId = json['request_id'];
    zsdocumentid = json['zsdocumentid'];
    requestTypeId = json['request_type_id'];
    ownerLastName = json['owner_last_name'];
    if (json['actions'] != null) {
      actions = <Actions>[];
      json['actions'].forEach((v) {
        actions!.add(Actions.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['request_status'] = requestStatus;
    data['notes'] = notes;
    data['reminder_period'] = reminderPeriod;
    data['owner_id'] = ownerId;
    data['description'] = description;
    data['request_name'] = requestName;
    data['modified_time'] = modifiedTime;
    data['action_time'] = actionTime;
    data['is_deleted'] = isDeleted;
    data['expiration_days'] = expirationDays;
    data['is_sequential'] = isSequential;
    data['sign_submitted_time'] = signSubmittedTime;
    data['owner_first_name'] = ownerFirstName;
    data['sign_percentage'] = signPercentage;
    data['expire_by'] = expireBy;
    data['owner_email'] = ownerEmail;
    data['created_time'] = createdTime;
    data['email_reminders'] = emailReminders;
    if (documentIds != null) {
      data['document_ids'] = documentIds!.map((v) => v.toJson()).toList();
    }
    data['self_sign'] = selfSign;
    data['in_process'] = inProcess;
    data['validity'] = validity;
    data['request_type_name'] = requestTypeName;
    data['request_id'] = requestId;
    data['zsdocumentid'] = zsdocumentid;
    data['request_type_id'] = requestTypeId;
    data['owner_last_name'] = ownerLastName;
    if (actions != null) {
      data['actions'] = actions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DocumentIds {
  String? documentName;
  EstampingRequest? estampingRequest;
  num? documentSize;
  String? documentOrder;
  bool? isNom151Present;
  bool? isEditable;
  num? totalPages;
  String? documentId;

  DocumentIds(
      {this.documentName,
      this.estampingRequest,
      this.documentSize,
      this.documentOrder,
      this.isNom151Present,
      this.isEditable,
      this.totalPages,
      this.documentId});

  DocumentIds.fromJson(Map<String, dynamic> json) {
    documentName = json['document_name'];
    estampingRequest = json['estamping_request'] != null
        ? EstampingRequest.fromJson(json['estamping_request'])
        : null;
    documentSize = json['document_size'];
    documentOrder = json['document_order'];
    isNom151Present = json['is_nom151_present'];
    isEditable = json['is_editable'];
    totalPages = json['total_pages'];
    documentId = json['document_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['document_name'] = documentName;
    if (estampingRequest != null) {
      data['estamping_request'] = estampingRequest!.toJson();
    }
    data['document_size'] = documentSize;
    data['document_order'] = documentOrder;
    data['is_nom151_present'] = isNom151Present;
    data['is_editable'] = isEditable;
    data['total_pages'] = totalPages;
    data['document_id'] = documentId;
    return data;
  }
}

class EstampingRequest {
  String? transactionId;
  EsbtrDetails? esbtrDetails;
  String? referenceId;
  String? considerationAmount;
  String? documentCategory;
  String? stampState;
  String? stampAmount;
  SecondPartyDetails? secondPartyDetails;
  String? secondPartyName;
  String? dutyPayerPhoneNumber;
  String? documentName;
  List<String>? stampPaperNumber;
  FirstPartyAddress? firstPartyAddress;
  String? stampDutyPaidBy;
  String? firstPartyName;
  FirstPartyDetails? firstPartyDetails;
  SecondPartyAddress? secondPartyAddress;

  EstampingRequest(
      {this.transactionId,
      this.esbtrDetails,
      this.referenceId,
      this.considerationAmount,
      this.documentCategory,
      this.stampState,
      this.stampAmount,
      this.secondPartyDetails,
      this.secondPartyName,
      this.dutyPayerPhoneNumber,
      this.documentName,
      this.stampPaperNumber,
      this.firstPartyAddress,
      this.stampDutyPaidBy,
      this.firstPartyName,
      this.firstPartyDetails,
      this.secondPartyAddress});

  EstampingRequest.fromJson(Map<String, dynamic> json) {
    transactionId = json['transaction_id'];
    esbtrDetails = json['esbtr_details'] != null
        ? EsbtrDetails.fromJson(json['esbtr_details'])
        : null;
    referenceId = json['reference_id'];
    considerationAmount = json['consideration_amount'];
    documentCategory = json['document_category'];
    stampState = json['stamp_state'];
    stampAmount = json['stamp_amount'];
    secondPartyDetails = json['second_party_details'] != null
        ? SecondPartyDetails.fromJson(json['second_party_details'])
        : null;
    secondPartyName = json['second_party_name'];
    dutyPayerPhoneNumber = json['duty_payer_phone_number'];
    documentName = json['document_name'];
    stampPaperNumber = json['stamp_paper_number']?.cast<String>();
    firstPartyAddress = json['first_party_address'] != null
        ? FirstPartyAddress.fromJson(json['first_party_address'])
        : null;
    stampDutyPaidBy = json['stamp_duty_paid_by'];
    firstPartyName = json['first_party_name'];
    firstPartyDetails = json['first_party_details'] != null
        ? FirstPartyDetails.fromJson(json['first_party_details'])
        : null;
    secondPartyAddress = json['second_party_address'] != null
        ? SecondPartyAddress.fromJson(json['second_party_address'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['transaction_id'] = transactionId;
    if (esbtrDetails != null) {
      data['esbtr_details'] = esbtrDetails!.toJson();
    }
    data['reference_id'] = referenceId;
    data['consideration_amount'] = considerationAmount;
    data['document_category'] = documentCategory;
    data['stamp_state'] = stampState;
    data['stamp_amount'] = stampAmount;
    if (secondPartyDetails != null) {
      data['second_party_details'] = secondPartyDetails!.toJson();
    }
    data['second_party_name'] = secondPartyName;
    data['duty_payer_phone_number'] = dutyPayerPhoneNumber;
    data['document_name'] = documentName;
    data['stamp_paper_number'] = stampPaperNumber;
    if (firstPartyAddress != null) {
      data['first_party_address'] = firstPartyAddress!.toJson();
    }
    data['stamp_duty_paid_by'] = stampDutyPaidBy;
    data['first_party_name'] = firstPartyName;
    if (firstPartyDetails != null) {
      data['first_party_details'] = firstPartyDetails!.toJson();
    }
    if (secondPartyAddress != null) {
      data['second_party_address'] = secondPartyAddress!.toJson();
    }
    return data;
  }
}

class EsbtrDetails {
  PropertyAddress? propertyAddress;
  String? district;
  String? subRegistrarOffice;

  EsbtrDetails({this.propertyAddress, this.district, this.subRegistrarOffice});

  EsbtrDetails.fromJson(Map<String, dynamic> json) {
    propertyAddress = json['property_address'] != null
        ? PropertyAddress.fromJson(json['property_address'])
        : null;
    district = json['district'];
    subRegistrarOffice = json['sub_registrar_office'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (propertyAddress != null) {
      data['property_address'] = propertyAddress!.toJson();
    }
    data['district'] = district;
    data['sub_registrar_office'] = subRegistrarOffice;
    return data;
  }
}

class PropertyAddress {
  String? addressline1;

  PropertyAddress({this.addressline1});

  PropertyAddress.fromJson(Map<String, dynamic> json) {
    addressline1 = json['addressline_1'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['addressline_1'] = addressline1;
    return data;
  }
}

class SecondPartyDetails {
  String? secondPartyIdType;
  String? secondPartyEntityType;
  String? secondPartyIdNumber;

  SecondPartyDetails(
      {this.secondPartyIdType,
      this.secondPartyEntityType,
      this.secondPartyIdNumber});

  SecondPartyDetails.fromJson(Map<String, dynamic> json) {
    secondPartyIdType = json['second_party_id_type'];
    secondPartyEntityType = json['second_party_entity_type'];
    secondPartyIdNumber = json['second_party_id_number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['second_party_id_type'] = secondPartyIdType;
    data['second_party_entity_type'] = secondPartyEntityType;
    data['second_party_id_number'] = secondPartyIdNumber;
    return data;
  }
}

class FirstPartyAddress {
  String? streetAddress;
  String? pincode;
  String? country;
  String? city;
  String? state;

  FirstPartyAddress(
      {this.streetAddress, this.pincode, this.country, this.city, this.state});

  FirstPartyAddress.fromJson(Map<String, dynamic> json) {
    streetAddress = json['street_address'];
    pincode = json['pincode'];
    country = json['country'];
    city = json['city'];
    state = json['state'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['street_address'] = streetAddress;
    data['pincode'] = pincode;
    data['country'] = country;
    data['city'] = city;
    data['state'] = state;
    return data;
  }
}

class FirstPartyDetails {
  String? firstPartyEntityType;
  String? firstPartyIdNumber;
  String? firstPartyIdType;

  FirstPartyDetails(
      {this.firstPartyEntityType,
      this.firstPartyIdNumber,
      this.firstPartyIdType});

  FirstPartyDetails.fromJson(Map<String, dynamic> json) {
    firstPartyEntityType = json['first_party_entity_type'];
    firstPartyIdNumber = json['first_party_id_number'];
    firstPartyIdType = json['first_party_id_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['first_party_entity_type'] = firstPartyEntityType;
    data['first_party_id_number'] = firstPartyIdNumber;
    data['first_party_id_type'] = firstPartyIdType;
    return data;
  }
}

class SecondPartyAddress {
  String? streetAddress;
  String? country;
  String? city;
  String? state;

  SecondPartyAddress({this.streetAddress, this.country, this.city, this.state});

  SecondPartyAddress.fromJson(Map<String, dynamic> json) {
    streetAddress = json['street_address'];
    country = json['country'];
    city = json['city'];
    state = json['state'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['street_address'] = streetAddress;
    data['country'] = country;
    data['city'] = city;
    data['state'] = state;
    return data;
  }
}

class Actions {
  bool? verifyRecipient;
  String? recipientCountrycodeIso;
  String? actionType;
  String? privateNotes;
  String? cloudProviderName;
  bool? hasPayment;
  String? recipientEmail;
  bool? sendCompletedDocument;
  String? recipientPhonenumber;
  bool? isBulk;
  String? actionId;
  bool? isRevoked;
  bool? isEmbedded;
  num? signingOrder;
  num? cloudProviderId;
  String? recipientName;
  String? deliveryMode;
  String? actionStatus;
  bool? isSigningGroup;
  String? recipientCountrycode;
  bool? allowSigning;

  Actions(
      {this.verifyRecipient,
      this.recipientCountrycodeIso,
      this.actionType,
      this.privateNotes,
      this.cloudProviderName,
      this.hasPayment,
      this.recipientEmail,
      this.sendCompletedDocument,
      this.recipientPhonenumber,
      this.isBulk,
      this.actionId,
      this.isRevoked,
      this.isEmbedded,
      this.signingOrder,
      this.cloudProviderId,
      this.recipientName,
      this.deliveryMode,
      this.actionStatus,
      this.isSigningGroup,
      this.recipientCountrycode,
      this.allowSigning});

  Actions.fromJson(Map<String, dynamic> json) {
    verifyRecipient = json['verify_recipient'];
    recipientCountrycodeIso = json['recipient_countrycode_iso'];
    actionType = json['action_type'];
    privateNotes = json['private_notes'];
    cloudProviderName = json['cloud_provider_name'];
    hasPayment = json['has_payment'];
    recipientEmail = json['recipient_email'];
    sendCompletedDocument = json['send_completed_document'];
    recipientPhonenumber = json['recipient_phonenumber'];
    isBulk = json['is_bulk'];
    actionId = json['action_id'];
    isRevoked = json['is_revoked'];
    isEmbedded = json['is_embedded'];
    signingOrder = json['signing_order'];
    cloudProviderId = json['cloud_provider_id'];
    recipientName = json['recipient_name'];
    deliveryMode = json['delivery_mode'];
    actionStatus = json['action_status'];
    isSigningGroup = json['is_signing_group'];
    recipientCountrycode = json['recipient_countrycode'];
    allowSigning = json['allow_signing'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['verify_recipient'] = verifyRecipient;
    data['recipient_countrycode_iso'] = recipientCountrycodeIso;
    data['action_type'] = actionType;
    data['private_notes'] = privateNotes;
    data['cloud_provider_name'] = cloudProviderName;
    data['has_payment'] = hasPayment;
    data['recipient_email'] = recipientEmail;
    data['send_completed_document'] = sendCompletedDocument;
    data['recipient_phonenumber'] = recipientPhonenumber;
    data['is_bulk'] = isBulk;
    data['action_id'] = actionId;
    data['is_revoked'] = isRevoked;
    data['is_embedded'] = isEmbedded;
    data['signing_order'] = signingOrder;
    data['cloud_provider_id'] = cloudProviderId;
    data['recipient_name'] = recipientName;
    data['delivery_mode'] = deliveryMode;
    data['action_status'] = actionStatus;
    data['is_signing_group'] = isSigningGroup;
    data['recipient_countrycode'] = recipientCountrycode;
    data['allow_signing'] = allowSigning;
    return data;
  }
}
