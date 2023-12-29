// To parse this JSON data, do
//
//     final analysisData = analysisDataFromJson(jsonString);

import 'dart:convert';

AnalysisData analysisDataFromJson(String str) => AnalysisData.fromJson(json.decode(str));

String analysisDataToJson(AnalysisData data) => json.encode(data.toJson());

class AnalysisData {
    int avgBpm;
    String bloodPressureStatus;
    int avgO2SaturationLevel;
    int avgRespirationRate;
    List<dynamic> bloodPressure;
    String stressStatus;
    bool isMoveWarning;

    AnalysisData({
        required this.avgBpm,
        required this.bloodPressureStatus,
        required this.avgO2SaturationLevel,
        required this.avgRespirationRate,
        required this.bloodPressure,
        required this.stressStatus,
        required this.isMoveWarning,
    });

    factory AnalysisData.fromJson(Map<String, dynamic> json) => AnalysisData(
        avgBpm: json["avgBpm"],
        bloodPressureStatus: json["bloodPressureStatus"],
        avgO2SaturationLevel: json["avgO2SaturationLevel"],
        avgRespirationRate: json["avgRespirationRate"],
        bloodPressure: List<dynamic>.from(json["bloodPressure"].map((x) => x)),
        stressStatus: json["stressStatus"],
        isMoveWarning: json["isMoveWarning"],
    );

    Map<String, dynamic> toJson() => {
        "avgBpm": avgBpm,
        "bloodPressureStatus": bloodPressureStatus,
        "avgO2SaturationLevel": avgO2SaturationLevel,
        "avgRespirationRate": avgRespirationRate,
        "bloodPressure": List<dynamic>.from(bloodPressure.map((x) => x)),
        "stressStatus": stressStatus,
        "isMoveWarning": isMoveWarning,
    };
}
