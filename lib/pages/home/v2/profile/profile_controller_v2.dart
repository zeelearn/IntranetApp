import 'dart:convert';
import 'dart:typed_data';

import 'package:Intranet/api/response/login_response.dart';
import 'package:Intranet/pages/helper/LocalConstant.dart';
import 'package:Intranet/pages/helper/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

/// Loads employee profile from Hive `KEY_LOGIN_RESPONSE` (view-only).
class ProfileControllerV2 extends GetxController {
  final isLoading = true.obs;
  final errorMessage = RxnString();

  final fullName = ''.obs;
  final designation = ''.obs;
  final employeeCode = ''.obs;
  final email = ''.obs;
  final contact = ''.obs;
  final profileImageUrl = ''.obs;
  final profileAvatarBytes = Rxn<Uint8List>();

  final personalRows = <ProfileInfoRow>[].obs;
  final workRows = <ProfileInfoRow>[].obs;
  final contactRows = <ProfileInfoRow>[].obs;
  final otherRows = <ProfileInfoRow>[].obs;
  final businesses = <BusinessApplications>[].obs;
  final roles = <EmployeeRoles>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final box = await Utility.openBox();
      await Hive.openBox(LocalConstant.KidzeeDB);

      final avatarUrl =
          box.get(LocalConstant.KEY_EMPLOYEE_AVTAR)?.toString() ?? '';
      profileImageUrl.value = avatarUrl;

      final encodedAvatar =
          box.get(LocalConstant.KEY_EMPLOYEE_AVTAR_LIST)?.toString();
      if (encodedAvatar != null && encodedAvatar.isNotEmpty) {
        profileAvatarBytes.value = base64.decode(encodedAvatar);
      }

      final raw = box.get(LocalConstant.KEY_LOGIN_RESPONSE)?.toString() ?? '';
      if (raw.isEmpty) {
        errorMessage.value = 'Login profile data not found.';
        _seedFromHiveFallback(box);
        return;
      }

      final response = LoginResponseModel.fromJson(json.decode(raw));
      if (response.responseData.employeeDetails.isEmpty) {
        errorMessage.value = 'Employee details not available.';
        _seedFromHiveFallback(box);
        return;
      }

      final e = response.responseData.employeeDetails.first;
      _applyEmployee(e);
      businesses.assignAll(response.responseData.businessApplications);
      roles.assignAll(response.responseData.employeeRoles);
    } catch (error) {
      errorMessage.value = 'Unable to load profile.';
      debugPrint('ProfileControllerV2 load failed: $error');
    } finally {
      isLoading.value = false;
    }
  }

  void _seedFromHiveFallback(Box box) {
    final first = box.get(LocalConstant.KEY_FIRST_NAME)?.toString() ?? '';
    final last = box.get(LocalConstant.KEY_LAST_NAME)?.toString() ?? '';
    fullName.value = '$first $last'.trim();
    designation.value =
        box.get(LocalConstant.KEY_DESIGNATION)?.toString() ?? '';
    employeeCode.value =
        box.get(LocalConstant.KEY_EMPLOYEE_CODE)?.toString() ?? '';
    email.value = box.get(LocalConstant.KEY_EMAIL)?.toString() ?? '';
    contact.value = box.get(LocalConstant.KEY_CONTACT)?.toString() ?? '';
  }

  void _applyEmployee(EmployeeDetails e) {
    final middle = e.employeeMiddleName.trim();
    fullName.value = [
      e.employeeFirstName,
      if (middle.isNotEmpty) middle,
      e.employeeLastName,
    ].where((s) => s.trim().isNotEmpty).join(' ');

    designation.value = e.employeeDesignation;
    employeeCode.value = e.employeeCode;
    email.value = e.employeeEmailId;
    contact.value = e.employeeContactNumber;

    personalRows.assignAll([
      ProfileInfoRow('Employee Code', e.employeeCode),
      ProfileInfoRow('Employee ID', _num(e.employeeId)),
      ProfileInfoRow('Gender', e.gender),
      ProfileInfoRow('Date of Birth', e.employeeDateOfBirth),
      ProfileInfoRow('Actual DOB', e.employeeDateOfBirthActual),
      ProfileInfoRow('Marital Status', e.employeeMaritalStatus),
      ProfileInfoRow('Date of Marriage', e.employeeDateOfMarriage),
      ProfileInfoRow('Qualification', e.employeeQualification),
    ].where((r) => r.value.isNotEmpty).toList());

    workRows.assignAll([
      ProfileInfoRow('Designation', e.employeeDesignation),
      ProfileInfoRow('Department', e.employeeDepartmentName),
      ProfileInfoRow('Role', e.employeeRoleName),
      ProfileInfoRow('Grade', e.employeeGrade),
      ProfileInfoRow('Company', e.companyName),
      ProfileInfoRow('Location', e.employeeLocation),
      ProfileInfoRow('Zone', e.zone),
      ProfileInfoRow('Date of Joining', e.employeeDateOfJoining),
      ProfileInfoRow('Manager', e.managerName),
      ProfileInfoRow('Username', e.userName),
      ProfileInfoRow('CEO', e.isCEO ? 'Yes' : 'No'),
      ProfileInfoRow('Business Head', e.isBusinessHead ? 'Yes' : 'No'),
      ProfileInfoRow('Status', e.isActive ? 'Active' : 'Inactive'),
    ].where((r) => r.value.isNotEmpty).toList());

    contactRows.assignAll([
      ProfileInfoRow('Email', e.employeeEmailId),
      ProfileInfoRow('Contact', e.employeeContactNumber),
    ].where((r) => r.value.isNotEmpty).toList());

    otherRows.assignAll([
      ProfileInfoRow('External User', e.isExternal ? 'Yes' : 'No'),
      ProfileInfoRow('Landing Page', e.landingPage),
    ].where((r) => r.value.isNotEmpty).toList());
  }

  static String _num(dynamic value) {
    if (value == null) return '';
    if (value is num) {
      return value % 1 == 0 ? value.toInt().toString() : value.toString();
    }
    return value.toString();
  }
}

class ProfileInfoRow {
  const ProfileInfoRow(this.label, this.value);
  final String label;
  final String value;
}
