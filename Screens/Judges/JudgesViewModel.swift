//
//  JudgesViewModel.swift
//  TheCWA_admin
//
//  Created by Theo Koester on 3/11/24.
//

import Foundation

final class JudgesViewModel: ObservableObject, WebSocketObserver {
    @Published var contestCarriers: [ContestCarrier] = []
    @Published var riders: [Rider] = []
    @Published var rider: Rider?
    @Published var bibColor: String = ""
    @Published var scorecard: Scorecard = Scorecard()
    @Published var alertItem: AlertItem?
    
    var websocketHandler: WebSocketHandler
    
    init() {
        self.websocketHandler = WebSocketHandler.shared
        websocketHandler.addObserver(self)
    }
    
    
    func didReceiveWebSocketMessage(_ message: WebSocketMessage) {
        DispatchQueue.main.async {
            switch message.type {
            case "carrier":
                if let jsonData = message.data?.data(using: .utf8) {
                    do {
                        let updatedCarrier = try JSONDecoder().decode(ContestCarrier.self, from: jsonData)
                        self.updateContestCarrier(updatedCarrier)
                    } catch {
                        print("Decoding error: \(error)")
                    }
                }
                // ... handle other message types ...
                
            default:
                break
            }
        }
    }
    private func updateContestCarrier(_ updatedCarrier: ContestCarrier) {
        if let index = contestCarriers.firstIndex(where: { $0.number == updatedCarrier.number }) {
            contestCarriers[index] = updatedCarrier
        } else {
            // If the carrier doesn't exist in the array, add it.
            contestCarriers.append(updatedCarrier)
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
                    self.riders = fetchedRiders
                }
            } catch {
                DispatchQueue.main.async {
                    // Handle error by setting an appropriate alert item
                    self.alertItem = AlertContext.alert(for: .unableToComplete)
                }
            }
        }
    }
    
    func submitScores(landed: Bool) {
        guard let riderId = scorecard.riderObj?.id else { return }
        
        // Find the session associated with the rider
        let sessionUUID = contestCarriers.first { $0.rider_id == riderId }?.session ?? UUID()
        
        
        // Update scorecard properties
        scorecard.division *= 10
        scorecard.execution *= 10
        scorecard.creativity *= 10
        scorecard.difficulty *= 10
        // Round the properties to two decimal places
        scorecard.division = scorecard.division.rounded(toPlaces: 2)
        scorecard.execution = scorecard.execution.rounded(toPlaces: 2)
        scorecard.creativity = scorecard.creativity.rounded(toPlaces: 2)
        scorecard.difficulty = scorecard.difficulty.rounded(toPlaces: 2)
        
        
        // Calculate the score by averaging execution, creativity, and difficulty
        let calculatedScore = (scorecard.execution + scorecard.creativity + scorecard.difficulty) / 3
        let roundedScore = calculatedScore.rounded(toPlaces: 2)
        
        if !landed {
                scorecard.execution = 0
            }
        
        let sendable_scorecard: Scorecard = Scorecard(
            section: scorecard.section,
            division: scorecard.division,
            execution: scorecard.execution,
            creativity: scorecard.creativity,
            difficulty: scorecard.difficulty,
            score: roundedScore,
            landed: landed,
            approach: scorecard.approach,
            trickType: scorecard.trickType,
            spin: scorecard.spin,
            spinDirection: scorecard.spinDirection,
            modifiers: scorecard.modifiers,
            park: scorecard.park,
            rider: riderId,
            session: sessionUUID
        )
        // Send the scorecard message
        sendMessage(type: .scorecard, data: sendable_scorecard)
        
        // Optionally, send the session message separately
        
        
        riderSkip()
    }
    
    private func sendMessage(type: MessageType, data: Codable) {
        guard let message = MessageHandler.createMessage(type: type, data: data) else { return }
        websocketHandler.sendMessage(message)
    }
    
    func riderLanded() {
        submitScores(landed: true)
    }
    
    func riderFell() {
        submitScores(landed: false)
    }
    
    
    func riderSkip() {
        guard let currentRider = scorecard.riderObj,
              let currentIndex = contestCarriers.firstIndex(where: { $0.rider_id == currentRider.id }) else {
            
            return
        }
        
        
        
        var nextIndex = (currentIndex + 1) % contestCarriers.count
        
        while nextIndex != currentIndex {
            let nextCarrier = contestCarriers[nextIndex]
            
            
            if let nextRiderID = nextCarrier.rider_id, let nextRider = riders.first(where: { $0.id == nextRiderID }) {
                
                
                self.scorecard = Scorecard()
                self.scorecard.riderObj = nextRider
                self.bibColor = nextCarrier.bib_color ?? ""
                return
            }
            
            nextIndex = (nextIndex + 1) % contestCarriers.count
        }
        
        
    }
    
    
    
}
