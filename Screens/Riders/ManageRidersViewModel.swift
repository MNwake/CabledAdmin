//
//  RiderProfileViewModel.swift
//  TheCWA_admin
//
//  Created by Theo Koester on 3/4/24.
//

import Foundation

final class ManageRidersViewModel: ObservableObject {
    @Published var riders: [Rider] = []
    @Published var alertItem: AlertItem?
    @Published var searchText = ""
    
    // Filtered riders based on search text
    var filteredRiders: [Rider] {
        searchText.isEmpty ? riders : riders.filter { $0.fullName.lowercased().contains(searchText.lowercased()) }
    }

    // Function to fetch riders from the network
    func getRiderData() {
        Task {
            do {
                let fetchedRiders = try await NetworkManager.shared.fetchRiders()
                DispatchQueue.main.async {
                    self.riders = fetchedRiders.sorted { $0.fullName < $1.fullName }
                }
            } catch {
                DispatchQueue.main.async {
                    // Handle error by setting an appropriate alert item
                    self.alertItem = AlertContext.alert(for: .unableToComplete)
                }
            }
        }
    }
    
    
}

//    func saveChanges() {
//        guard isValidForm else { return }
//        // Save changes to the rider here, potentially updating the database or API
//    }
//}
