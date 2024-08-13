//
//  RiderAccountViewModel.swift
//  TheCWA_admin
//
//  Created by Theo Koester on 3/7/24.
//

import Foundation

import SwiftUI // For using SwiftUI-specific types

class RiderAccountViewModel: ObservableObject {
    @Published var rider: Rider
    @Published var selectedParkIndex: Int = -1
    @Published var waiverImage: UIImage?
    @Published var parks: [Park] = []
    @Published var riderImage: UIImage?
    
    
    @Published var saveSuccessful: Bool = false
    @Published var alertItem: AlertItem?
    @Published var isUpdating: Bool = false

    var genderOptions = ["Male", "Female"]
    var stanceOptions = ["Regular", "Goofy"]

    init(rider: Rider) {
        self.rider = rider
    }

    func updateSelectedParkIndex() {
        if let index = parks.firstIndex(where: { $0.id == rider.home_park }) {
            selectedParkIndex = index
        } else {
            selectedParkIndex = -1
        }
    }

    func fetchParks() {
        Task {
            do {
                let fetchParks = try await NetworkManager.shared.fetchParks()
                print(fetchParks)
                DispatchQueue.main.async {
                    self.parks = fetchParks
                    print(self.parks)
                    self.updateSelectedParkIndex()
                }
            } catch {
                DispatchQueue.main.async {
                    self.alertItem = AlertContext.alert(for: .unableToComplete)
                }
            }
        }
    }

    func isValidForm() -> Bool {
        if rider.first_name.isEmpty || rider.last_name.isEmpty || rider.email.isEmpty {
            alertItem = AlertContext.alert(for: .invalidForm)
            return false
        }

        if !rider.email.isValidEmail {
            alertItem = AlertContext.alert(for: .invalidEmail)
            return false
        }

        let isDefaultSelection = ["Please Select:", ""]
        if isDefaultSelection.contains(rider.gender) ||
           isDefaultSelection.contains(rider.stance) ||
           rider.year_started == 0 ||
           rider.home_park.isEmpty {
            alertItem = AlertContext.alert(for: .invalidForm)
            return false
        }

        if Calendar.current.isDateInToday(rider.date_of_birth) {
            alertItem = AlertContext.alert(for: .invalidDOB)
            return false
        }

        return true
    }

    
    func updateRider() async throws {
        guard isValidForm() else { return }
        DispatchQueue.main.async {
            self.isUpdating = true
        }

        do {
            // If rider id is nil, create a new rider first
            if rider.id == nil {
                let newRiderId = try await NetworkManager.shared.createNewRider()
                DispatchQueue.main.async {
                    self.rider.id = newRiderId
                }
            }

            // Continue with the update process after getting the rider id
            // Step 1: Update profile image if present
            if let profileImage = riderImage {
                let profileURL = try await NetworkManager.shared.uploadImageToFirebase(profileImage, for: rider.id!, as: .profile)
                DispatchQueue.main.async {
                    self.rider.profile_image = profileURL  // Assign URL directly
                }
            }

            // Step 2: Update waiver image if present
            if let waiverImage = waiverImage {
                let waiverURL = try await NetworkManager.shared.uploadImageToFirebase(waiverImage, for: rider.id!, as: .waiver)
                DispatchQueue.main.async {
                    self.rider.waiver_url = waiverURL  // Assign URL directly
                    self.rider.waiver_date = Calendar.current.date(byAdding: .year, value: 1, to: Date())
                }
            }

            // Step 3: Update rider information
            let _ = try await NetworkManager.shared.updateRider(rider)

            DispatchQueue.main.async {
                // Update UI on success
                self.isUpdating = false
                self.alertItem = AlertContext.alert(for: .userSaveSuccess) {
                    self.saveSuccessful = true
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.isUpdating = false
                print("update rider failed")
                // Handle errors and update UI accordingly
                self.alertItem = AlertContext.alert(for: .defaultAlert) // Example alert for network error
            }
            throw error
        }
    }
    
}

