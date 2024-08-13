//
//  JudgesView.swift
//  TheCWA_admin
//
//  Created by Theo Koester on 3/11/24.
//

import SwiftUI
import UIKit


struct JudgesView: View {
    @StateObject var viewModel = JudgesViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            buildContent(isLandscape: isLandscape)
        }
        .alert(item: $viewModel.alertItem) { alertItem in
            Alert(title: alertItem.title, message: alertItem.message, dismissButton: alertItem.dismissButton)
        }
        .navigationTitle("Judges")
        .onAppear {
            viewModel.getRiderData()
            viewModel.getContestCarriers()
        }
    }

    @ViewBuilder
    private func buildContent(isLandscape: Bool) -> some View {
        if isLandscape {
            // Landscape layout
            VStack {
                HStack {
                    ScorecardRiderView(
                        riders: $viewModel.riders,
                        contestCarriers: $viewModel.contestCarriers,
                        scorecard: $viewModel.scorecard,
                        bibColor: $viewModel.bibColor
                    )
                    
                    ScorecardReview(scorecard: $viewModel.scorecard)
                }
                
                ScorecardStack(scorecard: $viewModel.scorecard,
                               alertItem: $viewModel.alertItem,
                               bibColor: $viewModel.bibColor,
                               riderLanded: viewModel.riderLanded,
                               riderFell: viewModel.riderFell,
                               riderSkip: viewModel.riderSkip
                )
            }
        } else {
            // Portrait layout
            VStack {
                ScorecardRiderView(
                    riders: $viewModel.riders,
                    contestCarriers: $viewModel.contestCarriers,
                    scorecard: $viewModel.scorecard,
                    bibColor: $viewModel.bibColor
                ).padding(.top)
                
                ScorecardReview(scorecard: $viewModel.scorecard)
                
                ScorecardStack(scorecard: $viewModel.scorecard,
                               alertItem: $viewModel.alertItem,
                               bibColor: $viewModel.bibColor,
                               riderLanded: viewModel.riderLanded,
                               riderFell: viewModel.riderFell,
                               riderSkip: viewModel.riderSkip
                )
            }
        }
    }
}


struct ScorecardRiderView: View {
    @Binding var riders: [Rider]
    @Binding var contestCarriers: [ContestCarrier]
    
    @Binding var scorecard: Scorecard
    @Binding var bibColor: String
    
    var body: some View {
        HStack {
            ForEach(contestCarriers, id: \.id) { carrier in
                let rider = riders.first { $0.id == carrier.rider_id }
                RiderOnWater(rider: rider, carrier: carrier, isSelected: scorecard.riderObj == rider) {
                    // Actions to perform when a rider is tapped
                    
                    scorecard.riderObj = rider
                    
                    bibColor = carrier.bib_color ?? "gray"
                }
                
            }
        }
    }
}



struct RiderOnWater: View {
    var rider: Rider?
    var carrier: ContestCarrier?
    var isSelected: Bool
    var onTap: () -> Void
    
    private var frameWidth: CGFloat {
        isLandscape() ? (isSelected ? 150 : 130) : (isSelected ? 180 : 160)
    }
    
    private var frameHeight: CGFloat {
        isLandscape() ? (isSelected ? 200 : 180) : (isSelected ? 230 : 210)
    }
    
    var body: some View {
        Button(action: {
            if rider != nil {
                onTap()
            }
        }) {
            cardContent(for: rider, isSelected: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: frameWidth, height: frameHeight)
        .opacity(isSelected ? 1.0 : 0.6)
    }
    
    @ViewBuilder
    private func cardContent(for rider: Rider?, isSelected: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(carrier?.bibColor ?? Color(UIColor.systemBackground).opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? Color.blue : Color.black, lineWidth: isSelected ? 3 : 2)
                )
            
            if let rider = rider {
                occupiedView(rider: rider)
            } else {
                VStack {
                    Text("Carrier #\(carrier?.number ?? 0)")
                    Text("Empty")
                }
            }
        }
    }
    
    @ViewBuilder
    private func occupiedView(rider: Rider) -> some View {
        VStack {
            HStack {
                Text("#\(carrier?.number ?? 0)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.leading, 10)
                Spacer()
            }
            
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 120, height: 120)

                AsyncRiderImageView(urlString: rider.profile_image.absoluteString)
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
            }
            
            Text(rider.fullName)
                .font(.headline)
                .lineLimit(1)
                .opacity(0.5)
        }
    }
    private func isLandscape() -> Bool {
        return UIDevice.current.orientation.isLandscape
    }
}

struct ScorecardReview: View {
    @Binding var scorecard: Scorecard
    
    var body: some View {
        Group {
            if isLandscape() {
                VStack(alignment: .leading, spacing: 10) {
                    // First item: HStack with the rider's full name and division
                    
                    Text(scorecard.riderObj?.fullName ?? "Select a Rider")
                        .font(.headline)
                    
                    Text("Division: \(divisionLabel(for: scorecard.division))")
                        .font(.subheadline)
                    
                    
                    // Text defining the section, approach, type, spin
                    Text("\(scorecard.section) \(scorecard.approach) \(scorecard.trickType) \(scorecard.spinDirection) \(scorecard.spin)")
                        .font(.caption)
                    
                    // Scorecard modifiers
                    Text(scorecard.modifiers.joined(separator: ", "))
                        .font(.caption2)
                    
                    // HStack of ScoreStacks
                    HStack(spacing: 20) {
                        ScoreStack(value: scorecard.creativity, title: "Creativity")
                        ScoreStack(value: scorecard.execution, title: "Execution")
                        ScoreStack(value: scorecard.difficulty, title: "Difficulty")
                        ScoreStack(value: averageScore, title: "Score")
                    }
                }
                .padding()
            } else {
                // Existing Portrait Layout
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(scorecard.riderObj?.fullName ?? "Select a Rider")
                            .font(.headline)
                        Text("Division: \(divisionLabel(for: scorecard.division))")
                            .font(.subheadline)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 5) {
                        Text("\(scorecard.section) \(scorecard.approach) \(scorecard.trickType) \(scorecard.spinDirection) \(scorecard.spin)")
                            .font(.caption)
                        Text(scorecard.modifiers.joined(separator: ", "))
                            .font(.caption2)
                        HStack(spacing: 20) {
                            ScoreStack(value: scorecard.creativity, title: "Creativity")
                            ScoreStack(value: scorecard.execution, title: "Execution")
                            ScoreStack(value: scorecard.difficulty, title: "Difficulty")
                            ScoreStack(value: averageScore, title: "Score")
                        }
                    }
                    
                }.padding(.horizontal, 40)
            }
        }
    }
    
    private var averageScore: Double {
        (scorecard.creativity + scorecard.difficulty + scorecard.execution) / 3
    }
    
    private func isLandscape() -> Bool {
        return UIDevice.current.orientation.isLandscape
    }
}

struct ScoreStack: View {
    var value: Double
    var title: String
    
    var body: some View {
        VStack {
            Text(String(format: "%.1f", value))
                .fontWeight(.bold)
            Text(title)
                .font(.caption2)
        }
        .padding(8)
    }
}


struct JudgesView_Previews: PreviewProvider {
    static var previews: some View {
        JudgesView()
    }
}
