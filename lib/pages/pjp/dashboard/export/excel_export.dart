import 'package:Intranet/api/response/pjp/pjplistresponse.dart';
import 'package:excel/excel.dart';
import 'dart:io';

class ExcelExporter {
  static void export(List<GetDetailedPJP> visits) {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Dashboard'];

    sheet.appendRow([
      TextCellValue("Franchisee"),
      TextCellValue("Latitude"),
      TextCellValue("Longitude"),
      TextCellValue("Time"),
      // TextCellValue("Duration"),
      TextCellValue("Completed")
    ]);

    for (var v in visits) {
      sheet.appendRow([
        TextCellValue(v.franchiseeName),
        TextCellValue(v.Latitude.toString()),
        TextCellValue(v.Longitude.toString()),
        TextCellValue(v.visitTime.toString()),
        // TextCellValue(v.),
        TextCellValue(v.Status)
      ]);
    }

    File("dashboard.xlsx")
      ..createSync(recursive: true)
      ..writeAsBytesSync(excel.encode()!);
  }
}
