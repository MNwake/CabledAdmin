//
//  DockHandViewModel.swift
//  TheCWA_admin
//
//  Created by Theo Koester on 3/7/24.
//

import Foundation
import UIKit

final class DockHandViewModel: ObservableObject, WebSocketObserver {
    @Published var riders: [Rider] = []
    @Published var alertItem: AlertItem?
    @Published var contestCarriers: [ContestCarrier]?// Represents 4 carriers
    @Published var drugItem: DockHandListItem?
    private var websocketHandler: WebSocketHandler
    
    init() {
            self.websocketHandler = WebSocketHandler.shared
            websocketHandler.addObserver(self)
            getContestCarriers()
            getRiderData()
        }
    
    func didReceiveWebSocketMessage(_ message: WebSocketMessage) {
        print("Received websocket message on dockahndviewmodel")
        print(message)
        switch message.type {
        case "carrier":
            if let jsonString = message.data,
               let jsonData = jsonString.data(using: .utf8),
               let updatedCarrier = try? JSONDecoder().decode(ContestCarrier.self, from: jsonData) {
                updateCarrier(carrierUpdate: updatedCarrier, sendUpdate: false)
            }
        default:
            return
        }
    }
    
    func updateCarrier(carrierUpdate: ContestCarrier, sendUpdate: Bool = true) {
        // Check if the carrier exists and find its index
        guard let index = contestCarriers?.firstIndex(where: { $0.number == carrierUpdate.number }) else {
            print("ViewModel: carrier with number \(carrierUpdate.number) not found")
            return
        }
        DispatchQueue.main.async {
            self.contestCarriers?[index] = carrierUpdate
            print("ViewModel: carrier updated")
        }
        
        // Send the updated carrier via WebSocket if the update originates from the app
        if sendUpdate, let updateMessage = MessageHandler.createMessage(type: .carrier, data: carrierUpdate) {
            websocketHandler.sendMessage(updateMessage)
        }
    }
    
    
    deinit {
        // Don't forget to remove the observer when the view model is deallocated
        websocketHandler.removeObserver(self)
    }
    
    // Add as observer to the WebSocket messages
    func addObserver() {
        websocketHandler.addObserver(self)
    }
    
    // Remove as observer from the WebSocket messages
    func removeObserver() {
        websocketHandler.removeObserver(self)
    }
    var unassignedRiders: [Rider] {
        // Ensure contestCarriers are loaded
        guard let contestCarriers = contestCarriers else { return [] }
        
        return riders.filter { rider in
            rider.is_registered ?? false && !contestCarriers.contains(where: { $0.rider_id == rider.id })
        }
    }
    
    func getContestCarriers() {
        Task {
            do {
                let fetchedContestCarriers = try await NetworkManager.shared.fetchContestCarriers()
                DispatchQueue.main.async {
                    self.contestCarriers = fetchedContestCarriers
                }
            } catch {
                DispatchQueue.main.async {
                    // Handle error
                    self.alertItem = AlertContext.alert(for: .unableToComplete)
                }
            }
        }
    }
    
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
    
    func handleDrop(providers: [NSItemProvider], at carrierIndex: Int) -> Bool {
        guard let provider = providers.first, provider.canLoadObject(ofClass: NSString.self) else {
            return false
        }
        
        provider.loadObject(ofClass: NSString.self) { [weak self] (nsstring, error) in
            DispatchQueue.main.async {
                if let stringData = nsstring as? String, let self = self {
                    let components = stringData.components(separatedBy: "|")
                    if components.count == 2 {
                        let riderId = components[0]
                        let bibColor = components[1]
                        self.assignRiderToCarrier(riderId: riderId, bibColor: bibColor, at: carrierIndex)
                    }
                }
            }
        }
        return true
    }
    
    private func assignRiderToCarrier(riderId: String, bibColor: String, at carrierIndex: Int) {
        guard let index = contestCarriers?.firstIndex(where: { $0.number == carrierIndex }) else {
            print("ViewModel: Carrier with index \(carrierIndex) not found")
            return
        }
        print("Rider Placed on Carrier")
        
        var updatedCarrier = contestCarriers![index]
        print("Carrier #: \(updatedCarrier.number)")
        updatedCarrier.rider_id = riderId
        updatedCarrier.bib_color = bibColor
        updatedCarrier.session = UUID()
        
        updateCarrier(carrierUpdate: updatedCarrier, sendUpdate: true) // Using sendUpdate true
    }
    
    
    func removeRiderFromCarrier(at carrierNumber: Int) {
        guard let index = contestCarriers?.firstIndex(where: { $0.number == carrierNumber }) else { return }
        var updatedCarrier = contestCarriers![index]
        updatedCarrier.rider_id = nil  // Removing the rider
        updateCarrier(carrierUpdate: updatedCarrier)
    }
    
    func updateBibColor(for carrierNumber: Int, to color: String) {
        guard let index = contestCarriers?.firstIndex(where: { $0.number == carrierNumber }) else { return }
        var updatedCarrier = contestCarriers![index]
        updatedCarrier.bib_color = color
        updateCarrier(carrierUpdate: updatedCarrier)
    }
    
    
}
