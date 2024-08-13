//
//  ContestCarriers.swift
//  TheCWA_admin
//
//  Created by Theo Koester on 3/8/24.
//

import Foundation
import SwiftUI

struct ContestCarrier: Codable, Identifiable, Hashable, Equatable {
    let id: String
    let number: Int
    var rider_id: String?
    var bib_color: String?
    var session: UUID?  // Updated to be of type Session?

    var bibColor: Color {
        return BibColor.from(string: bib_color ?? "")?.color ?? .clear
    }

    init(id: String, number: Int, rider_id: String? = nil, bib_color: String? = nil, session: UUID? = nil) {
        self.id = id
        self.number = number
        self.rider_id = rider_id
        self.bib_color = bib_color
        self.session = session
    }
}


struct ContestCarriers: Codable {
    var data: [ContestCarrier]
}

