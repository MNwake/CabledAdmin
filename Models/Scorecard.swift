//
//  Scorecard.swift
//  TheCWA
//
//  Created by Theo Koester on 3/1/24.
//

import Foundation

struct Scorecard: Codable, Identifiable, Hashable {
    var id: String?
    var date: Date
    var section: String = "" // non-optional
    var division: Double = 0
    var execution: Double = 0
    var creativity: Double = 0
    var difficulty: Double = 0
    var score: Double = 0
    var landed: Bool = false
    var approach: String = "" // corrected
    var trickType: String = ""
    var spin: String = ""
    var spinDirection: String = ""
    var modifiers: [String] = []
    var park: String?
    var rider: String?
    var session: UUID?
    
    
    var riderObj: Rider?
    var judge: String?
    
    // Custom initializer
    init(date: Date = Date(), section: String = "", division: Double = 0, execution: Double = 0, creativity: Double = 0, difficulty: Double = 0, score: Double = 0, landed: Bool = false, approach: String = "", trickType: String = "", spin: String = "", spinDirection: String = "", modifiers: [String] = [], park: String? = nil, rider: String? = nil, session: UUID? = nil, riderObj: Rider? = nil, judge: String? = nil) {
        self.id = nil
        self.date = date
        self.section = section
        self.division = division
        self.execution = execution
        self.creativity = creativity
        self.difficulty = difficulty
        self.score = score
        self.landed = landed
        self.approach = approach
        self.trickType = trickType
        self.spin = spin
        self.spinDirection = spinDirection
        self.modifiers = modifiers
        self.park = park
        self.rider = rider
        self.session = session  // Correctly assigning the parameter to the property
        self.riderObj = riderObj
        self.judge = judge
    }
    static let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss" // Match this format to your server's expected format
            formatter.timeZone = TimeZone(secondsFromGMT: 0) // Adjust if necessary
            return formatter
        }()

}
struct Scorecards: Codable {
    let data: [Scorecard]
    let cursor: String
}
