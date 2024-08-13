//
//  MockData.swift
//  TheCWA_admin
//
//  Created by Theo Koester on 3/12/24.
//

import Foundation

struct MockData {
    
    static let sampleRider = Rider(email: "alex.taylor@example.com",
                                       first_name: "Alex",
                                       last_name: "Taylor",
                                       date_of_birth: Calendar.current.date(from: DateComponents(year: 1988, month: 6, day: 15))!,
                                       gender: "Female",
                                       date_created: Date(),
                                       profile_image: URL(string: "https://example.com/profile.jpg")!,
                                       stance: "Goofy",
                                       year_started: 2005,
                                       division: 2.5,
                                       home_park: "Sunshine Wake Park",
                                       statistics: "Champion of 2021 Summer Series",
                                       score: 92.5,
                                       is_registered: true)
}
