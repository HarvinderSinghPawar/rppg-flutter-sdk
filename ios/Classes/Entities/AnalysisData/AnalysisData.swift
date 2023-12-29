//
//  AnalysisData.swift
//  rppg_common
//
//  Created by Wegile on 21/12/23.
//

import Foundation
import RPPGCommon

// MARK: - ScoreType
//enum ScoreType: String, Decodable {
//    case low    = "LOW"
//    case medium = "MEDIUM"
//    case high   = "HIGH"
//}

protocol StructChangeListener: AnyObject {
    func structValueChanged(newValue: AnalysisData)
}

// MARK: - Analysis
struct AnalysisData {
    var avgBpm: Double?
    var avgO2SaturationLevel: Double?
    var avgRespirationRate: Double?
    var isMoveWarning: Bool?
//    var reportId: Int?
//    var scoreType: ScoreType?
//    var dateCreated: String?
//    var reportTimestamp: Int?
    var stressStatus: RPPGSocketMessageMeanData.StressStatus?
    var bloodPressureStatus: RPPGSocketMessageMeanData.BloodPressureStatus?
    var bloodPressure: RPPGSocketMessageBloodPressure?
    
    var analysisDataDict = [String: Any]()
    var oldAnalysisDataDict = [String: Any]()
    
    // Define a weak reference to the listener
    weak var listener: StructChangeListener?
    
    // Function to update the struct value and notify the listener
    mutating func updateValue(newValue: AnalysisData) {
        self = newValue
        
        let systolic = newValue.bloodPressure?.systolic ?? 0
        let diastolic =  newValue.bloodPressure?.diastolic ?? 0
        
        analysisDataDict = [ "avgBpm": newValue.avgBpm ?? "",
                             "avgO2SaturationLevel": newValue.avgO2SaturationLevel ?? "",
                             "avgRespirationRate": newValue.avgRespirationRate ?? "",
                             "bloodPressure": [systolic , diastolic],
                             "bloodPressureStatus":newValue.bloodPressureStatus?.localizedDescription ?? "",
                             "stressStatus": newValue.stressStatus?.localizedDescription ?? "",
                             "isMoveWarning": newValue.isMoveWarning ?? false
        ]
    
        listener?.structValueChanged(newValue: newValue)
    }

    
//    func convertToJSON(_ data: AnalysisData) -> String? {
//        do {
//            // Convert the dictionary to JSON data
//            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
//            
//            // Convert the JSON data to a String (optional)
//            if let jsonString = String(data: jsonData, encoding: .utf8) {
//                return jsonString
//            }
//            
//            // Now you have the JSON data, which you can use as needed
//        } catch {
//            return nil
//        }
//        return nil
//    }
    
    mutating func getDictData() -> [String: Any] {
        print("self.analysisDataDict \(self.analysisDataDict)")
        return self.analysisDataDict
    }

}
