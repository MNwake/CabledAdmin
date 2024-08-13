//
//  MessageHandler.swift
//  TheCWA_admin
//
//  Created by Theo Koester on 3/10/24.
//

import Foundation


enum MessageType: String {
    case connect = "connect"
    case carrier = "carrier"
    case rider = "rider"
    case stat = "stat"
    case scorecard = "scorecard"
    case session = "session"
}

struct MessageHandler {
    
    static func createMessage(type: MessageType, data: Any) -> String? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(GlobalSettings.dateFormatter)

        let jsonData: Data
        if let dataAsCodable = data as? Codable {
            jsonData = (try? encoder.encode(AnyEncodable(dataAsCodable))) ?? Data()
        } else {
            jsonData = (try? JSONSerialization.data(withJSONObject: data, options: [])) ?? Data()
        }

        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }

        let messageDict: [String: Any] = [
            "type": type.rawValue,
            "data": jsonString
        ]
        return convertToJson(messageDict)
    }
        
    
    private static func convertToJson(_ dictionary: [String: Any]) -> String? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: []),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("Failed to serialize message dictionary")
            return nil
        }
        return jsonString
    }
}

// Helper struct to encode any Codable
private struct AnyEncodable: Encodable {
    var value: Encodable
    
    init(_ value: Encodable) {
        self.value = value
    }
    
    func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
}
