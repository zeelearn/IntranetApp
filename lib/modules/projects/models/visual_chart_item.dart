import 'package:equatable/equatable.dart';

class VisualChartItem extends Equatable {
  const VisualChartItem({
    required this.name,
    required this.description,
    required this.url,
  });

  final String name;
  final String description;
  final String url;

  factory VisualChartItem.fromJson(Map<String, dynamic> json) {
    return VisualChartItem(
      name: _asString(json['Name']),
      description: _asString(json['Description']),
      url: _asString(json['URL'] ?? json['Url'] ?? json['url']),
    );
  }

  Map<String, dynamic> toJson() => {
        'Name': name,
        'Description': description,
        'URL': url,
      };

  bool get hasValidUrl {
    final u = url.trim();
    if (u.isEmpty) return false;
    final uri = Uri.tryParse(u);
    return uri != null && (uri.isScheme('http') || uri.isScheme('https'));
  }

  static String _asString(dynamic v) => v?.toString().trim() ?? '';

  @override
  List<Object?> get props => [name, description, url];
}

class VisualChartsResponse extends Equatable {
  const VisualChartsResponse({
    required this.success,
    required this.data,
  });

  final int success;
  final List<VisualChartItem> data;

  factory VisualChartsResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final list = <VisualChartItem>[];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          list.add(VisualChartItem.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return VisualChartsResponse(
      success: _asInt(json['success']),
      data: list,
    );
  }

  static int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  @override
  List<Object?> get props => [success, data];
}
