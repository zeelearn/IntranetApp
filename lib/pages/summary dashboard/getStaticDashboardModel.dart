class GetStaticDashboardModel {
  GetStaticDashboardModel({
    required this.success,
    required this.data,
  });

  final num? success;
  static const String successKey = "success";

  final List<Datum> data;
  static const String dataKey = "data";

  GetStaticDashboardModel copyWith({
    num? success,
    List<Datum>? data,
  }) {
    return GetStaticDashboardModel(
      success: success ?? this.success,
      data: data ?? this.data,
    );
  }

  factory GetStaticDashboardModel.fromJson(Map<String, dynamic> json) {
    return GetStaticDashboardModel(
      success: json["success"],
      data: json["data"] == null
          ? []
          : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data.map((x) => x.toJson()).toList(),
      };

  @override
  String toString() {
    return "$success, $data, ";
  }
}

class Datum {
  Datum({
    required this.empLevel,
    required this.levelType,
    required this.ticketCount,
    required this.unresolvedticketCount,
    required this.status,
    required this.category,
    required this.avgTicketReOpenTimesIn,
    required this.avgFirstReponseTimeInHours,
    required this.averageResolutionTimeInHours,
    required this.ticketResolutionRate,
    required this.unresolvedPriority,
  });

  final num? empLevel;
  static const String empLevelKey = "Emp_Level";

  final String? levelType;
  static const String levelTypeKey = "Level_Type";

  final num? ticketCount;
  static const String ticketCountKey = "Ticket_count";

  final num? unresolvedticketCount;
  static const String unresolvedticketCountKey = "Unresolved_Ticket_Count";

  final List<Category> status;
  static const String statusKey = "Status";

  final List<Category> category;
  static const String categoryKey = "Unresolved_Category";

  final String? avgTicketReOpenTimesIn;
  static const String avgTicketReOpenTimesInKey =
      "Avg_Ticket_ReOpen_Times_In_%";

  final num? avgFirstReponseTimeInHours;
  static const String avgFirstReponseTimeInHoursKey =
      "Avg_First_Reponse_Time_In_hours";

  final num? averageResolutionTimeInHours;
  static const String averageResolutionTimeInHoursKey =
      "Average_Resolution_Time_in_hours";

  final num? ticketResolutionRate;
  static const String ticketResolutionRateKey = "Ticket_Resolution_Rate";

  final List<Category> unresolvedPriority;
  static const String unresolvedPriorityKey = "unresolved_priority";

  Datum copyWith({
    num? empLevel,
    String? levelType,
    num? ticketCount,
    num? unresolvedticketCount,
    List<Category>? status,
    List<Category>? category,
    String? avgTicketReOpenTimesIn,
    num? avgFirstReponseTimeInHours,
    num? averageResolutionTimeInHours,
    num? ticketResolutionRate,
    List<Category>? unresolvedPriority,
  }) {
    return Datum(
      empLevel: empLevel ?? this.empLevel,
      levelType: levelType ?? this.levelType,
      ticketCount: ticketCount ?? this.ticketCount,
      unresolvedticketCount:
          unresolvedticketCount ?? this.unresolvedticketCount,
      status: status ?? this.status,
      category: category ?? this.category,
      avgTicketReOpenTimesIn:
          avgTicketReOpenTimesIn ?? this.avgTicketReOpenTimesIn,
      avgFirstReponseTimeInHours:
          avgFirstReponseTimeInHours ?? this.avgFirstReponseTimeInHours,
      averageResolutionTimeInHours:
          averageResolutionTimeInHours ?? this.averageResolutionTimeInHours,
      ticketResolutionRate: ticketResolutionRate ?? this.ticketResolutionRate,
      unresolvedPriority: unresolvedPriority ?? this.unresolvedPriority,
    );
  }

  factory Datum.fromJson(Map<String, dynamic> json) {
    return Datum(
      empLevel: json["Emp_Level"],
      levelType: json["Level_Type"],
      ticketCount: json["Ticket_count"],
      unresolvedticketCount: json["Unresolved_Ticket_Count"],
      status: json["Status"] == null
          ? []
          : List<Category>.from(
              json["Status"]!.map((x) => Category.fromJson(x))),
      category: json["Unresolved_Category"] == null
          ? []
          : List<Category>.from(
              json["Unresolved_Category"]!.map((x) => Category.fromJson(x))),
      avgTicketReOpenTimesIn: json["Avg_Ticket_ReOpen_Times_In_%"],
      avgFirstReponseTimeInHours: json["Avg_First_Reponse_Time_In_hours"],
      averageResolutionTimeInHours: json["Average_Resolution_Time_in_hours"],
      ticketResolutionRate: json["Ticket_Resolution_Rate"],
      unresolvedPriority: json["unresolved_priority"] == null
          ? []
          : List<Category>.from(
              json["unresolved_priority"]!.map((x) => Category.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "Emp_Level": empLevel,
        "Level_Type": levelType,
        "Ticket_count": ticketCount,
        "Unresolved_Ticket_Count": unresolvedticketCount,
        "Status": status.map((x) => x.toJson()).toList(),
        "Unresolved_Category": category.map((x) => x.toJson()).toList(),
        "Avg_Ticket_ReOpen_Times_In_%": avgTicketReOpenTimesIn,
        "Avg_First_Reponse_Time_In_hours": avgFirstReponseTimeInHours,
        "Average_Resolution_Time_in_hours": averageResolutionTimeInHours,
        "Ticket_Resolution_Rate": ticketResolutionRate,
        "unresolved_priority":
            unresolvedPriority.map((x) => x.toJson()).toList(),
      };

  @override
  String toString() {
    return "$ticketCount, $unresolvedticketCount, $status, $category, $avgTicketReOpenTimesIn, $avgFirstReponseTimeInHours, $averageResolutionTimeInHours, $ticketResolutionRate, $unresolvedPriority, ";
  }
}

class Category {
  Category(
      {required this.label, required this.count, this.colorCode, this.labelId});

  String? label;
  static const String labelKey = "label";

  num? count;
  static const String countKey = "count";

  num? labelId;
  static const String labelIdKey = "label_id";

  String? colorCode;

  Category copyWith(
      {String? label, num? count, String? colorCode, num? labelId}) {
    return Category(
        labelId: labelId ?? this.labelId,
        label: label ?? this.label,
        count: count ?? this.count,
        colorCode: colorCode ?? this.colorCode);
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      label: json["label"],
      count: json["count"],
      labelId: json["label_id"],
    );
  }

  Map<String, dynamic> toJson() => {
        "label": label,
        "count": count,
        "label_id": labelId,
      };

  @override
  String toString() {
    return "$label, $count, $colorCode, $labelId";
  }
}
