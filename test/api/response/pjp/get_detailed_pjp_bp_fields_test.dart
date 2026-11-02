import 'package:flutter_test/flutter_test.dart';
import 'package:Intranet/api/response/pjp/pjplistresponse.dart';

void main() {
  group('GetDetailedPJP new BP / email fields', () {
    test('fromJson parses isEmailSubmitted, BusinessPartnerName, BusinessPartnerEmail',
        () {
      final cvf = GetDetailedPJP.fromJson({
        'PJPCVF_Id': '13233',
        'Visit_Date': '2026-07-15',
        'Visit_Time': '12:00:00',
        'Franchisee_Id': '1144',
        'Franchisee_Code': 'E-C-U-1144',
        'Franchisee_Name': 'Kidzee Pakri, Arah',
        'Latitude': '25.560104',
        'Longitude': '84.657516',
        'Address': 'Ara , Bihar',
        'IsCancelled': '1',
        'Remarks': 'test cvf cancel',
        'isEmailSubmitted': '0',
        'BusinessPartnerName': 'Ms. Suchita Jain',
        'BusinessPartnerEmail': 'ki*********@******.com',
      });

      expect(cvf.isEmailSubmitted, isFalse);
      expect(cvf.businessPartnerName, 'Ms. Suchita Jain');
      expect(cvf.businessPartnerEmail, 'ki*********@******.com');
      expect(cvf.hasBusinessPartnerEmail, isTrue);
    });

    test('isEmailSubmitted accepts 1/true flags', () {
      final cvf = GetDetailedPJP.fromJson({
        'PJPCVF_Id': '1',
        'isEmailSubmitted': '1',
        'BusinessPartnerName': 'Partner',
        'BusinessPartnerEmail': 'partner@example.com',
      });
      expect(cvf.isEmailSubmitted, isTrue);

      final json = cvf.toJson();
      expect(json['isEmailSubmitted'], '1');
      expect(json['BusinessPartnerName'], 'Partner');
      expect(json['BusinessPartnerEmail'], 'partner@example.com');
    });

    test('null / missing values default safely', () {
      final cvf = GetDetailedPJP.fromJson({
        'PJPCVF_Id': '2',
        'isEmailSubmitted': null,
        'BusinessPartnerName': null,
        'BusinessPartnerEmail': null,
      });
      expect(cvf.isEmailSubmitted, isFalse);
      expect(cvf.businessPartnerName, '');
      expect(cvf.businessPartnerEmail, '');
      expect(cvf.hasBusinessPartnerEmail, isFalse);
    });
  });
}
