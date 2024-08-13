//
//  Park.swift
//  TheCWA
//
//  Created by Theo Koester on 2/29/24.
//

import Foundation

// Struct for the entire response
struct Parks: Codable {
    let data: [Park]

    var count: Int {
        return data.count
    }
}

struct Park: Codable {
    let id: String
    let name: String
    let state: String
    let abbreviation: String
    
    
    

    enum CodingKeys: String, CodingKey {
        case id, name, state, abbreviation
        
    }
}
