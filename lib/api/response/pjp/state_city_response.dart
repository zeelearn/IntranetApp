class StateCityResponse {
  late List<StateModel> data;

  StateCityResponse({required this.data});

  StateCityResponse.fromJson(Map<String, dynamic> json) {
    data = <StateModel>[];
    if (json['data'] != null && json['data'] is List) {
      for (var v in (json['data'] as List)) {
        if (v != null && v is Map<String, dynamic>) {
          data.add(StateModel.fromJson(v));
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['data'] = data.map((v) => v.toJson()).toList();
    return map;
  }
}

class StateModel {
  late String stateName;
  late List<CityModel> cityList;

  StateModel({required this.stateName, required this.cityList});

  StateModel.fromJson(Map<String, dynamic> json) {
    stateName = (json['state_name'] ?? '').toString().trim();
    cityList = <CityModel>[];
    if (json['city'] != null && json['city'] is List) {
      for (var v in (json['city'] as List)) {
        if (v != null && v is Map<String, dynamic>) {
          cityList.add(CityModel.fromJson(v));
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['state_name'] = stateName;
    map['city'] = cityList.map((v) => v.toJson()).toList();
    return map;
  }
}

class CityModel {
  late int cityId;
  late String cityName;
  late String cityGrade;

  CityModel({
    required this.cityId,
    required this.cityName,
    required this.cityGrade,
  });

  CityModel.fromJson(Map<String, dynamic> json) {
    if (json['city_id'] is int) {
      cityId = json['city_id'];
    } else {
      cityId = int.tryParse(json['city_id']?.toString() ?? '0') ?? 0;
    }
    cityName = (json['city_name'] ?? '').toString().trim();
    cityGrade = (json['city_grade'] ?? '').toString().trim();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['city_id'] = cityId;
    map['city_name'] = cityName;
    map['city_grade'] = cityGrade;
    return map;
  }
}
