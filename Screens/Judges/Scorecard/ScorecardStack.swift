//
//  ScorecardStack.swift
//  TheCWA_admin
//
//  Created by Theo Koester on 3/12/24.
//

import SwiftUI
enum ScorecardRoute: Hashable {
    case section
    case approach
    case kicker
    case rail
    case airtrick
    case spin
    case spinOn
    case spinOff
    case flip
    case score
    
}

struct ScorecardStack: View {
    @Binding var scorecard: Scorecard
    @Binding var alertItem: AlertItem?
    @Binding var bibColor: String
    var riderLanded: () -> Void
    var riderFell: () -> Void
    var riderSkip: () -> Void
    
    @State var stackPath = [ ScorecardRoute ]()
    
    var body: some View {
        VStack {
            NavigationStack(path: $stackPath) {
                ScorecardSectionView(scorecard: $scorecard, path: $stackPath, alertItem: $alertItem, bibColor: $bibColor, riderSkip: riderSkip)
                    .navigationDestination(for: ScorecardRoute.self) { route in
                        switch route {
                        case .section:
                            ScorecardSectionView(scorecard: $scorecard, path: $stackPath, alertItem: $alertItem, bibColor: $bibColor, riderSkip: riderSkip)
                        case .approach:
                            ScorecardApproachView(scorecard: $scorecard, path: $stackPath, bibColor: $bibColor)
                        case .kicker:
                            ScorecardKickerView(scorecard: $scorecard, path: $stackPath, bibColor: $bibColor)
                        case .rail:
                            ScorecardRailView(scorecard: $scorecard, path: $stackPath, bibColor: $bibColor)
                        case .airtrick:
                            ScorecardAirtickView(scorecard: $scorecard, path: $stackPath, bibColor: $bibColor)
                        case .spin:
                            ScorecardSpinView(scorecard: $scorecard, path: $stackPath, bibColor: $bibColor)
                        case .flip:
                            ScorecardFlipView(scorecard: $scorecard,
                                              path: $stackPath,
                                              bibColor: $bibColor
                            )
                        case .score:
                            ScorecardScoreView(scorecard: $scorecard,
                                               path: $stackPath,
                                               bibColor: $bibColor,
                                               riderLanded: riderLanded,
                                               riderFell: riderFell
                                           )
                        case .spinOn:
                            ScorecardRailSpinOnView(scorecard: $scorecard, path: $stackPath, bibColor: $bibColor)
                        case .spinOff:
                            ScorecardRailSpinOffView(scorecard: $scorecard, path: $stackPath, bibColor: $bibColor)
                        }
                        
                    }
            }
        }
        
    }
}


struct ScorecardRailView: View {
    @Binding var scorecard: Scorecard
    @Binding var path: [ScorecardRoute]
    @Binding var bibColor: String

    let railOptions = ["Ride On", "Ollie On", "Transfer", "Box 2 Rail", "Hip Transfer", "Wall-Ride"]
    
    var body: some View {
        VStack {
            Text("Type")
                .font(.largeTitle)
                .padding(.bottom)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                ForEach(railOptions, id: \.self) { option in
                    JudgesButton(title: option, color: BibColor.from(string: bibColor)?.color ?? Color.gray) {
                        handleOptionSelection(option)
                    }
                }
            }
            .padding(.bottom)
            
            Spacer()
        }
    }

    private func handleOptionSelection(_ option: String) {
        scorecard.trickType = option
        navigateToSpin()
    }
    
    private func navigateToSpin() {
        path.append(.spinOn) // Programmatically navigate to the spin view
    }
}

struct ScorecardAirtickView: View {
    @Binding var scorecard: Scorecard
    @Binding var path: [ScorecardRoute]
    @Binding var bibColor: String

    
    let heelsideAirTricks = ["Raley", "Backroll", "Frontflip", "Bel-Air"]
    let toesideAirTricks = ["Raley", "Frontroll", "Backroll", "Egg-Roll"]
    
    var body: some View {
        VStack {
            Text("Type")
                .font(.largeTitle)
                .padding()
            
            // Use LazyVGrid to display options
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                ForEach(airTrickOptions, id: \.self) { option in
                    JudgesButton(title: option, color: BibColor.from(string: bibColor)?.color ) {
                        scorecard.trickType = option
                        path.append(.spin) // or next appropriate route
                    }
                }
            }
            .padding(.bottom)
            
            Spacer()
        }
    }
    
    // Determine which set of tricks to use based on approach
    private var airTrickOptions: [String] {
        switch scorecard.approach {
        case "Toeside", "Switch Toeside":
            return toesideAirTricks
        case "Heelside", "Switch Heelside":
            return heelsideAirTricks
        default:
            return []  // Default options or empty array
        }
    }
}
struct ScorecardSpinView: View {
    @Binding var scorecard: Scorecard
    @Binding var path: [ScorecardRoute]
    @Binding var bibColor: String

    
    let spinValues = ["0", "180", "360", "540", "720", "900", "1080", "1260", "1440"]
    
    var body: some View {
        VStack {
            Text("Spin")
                .font(.largeTitle)
                .padding(.bottom)
            
            HStack {
                spinGrid(title: "Backside", spins: spinValues)
                Divider()
                spinGrid(title: "Frontside", spins: spinValues)
            }
            Spacer()
        }
        .padding(.bottom)
        .onAppear {
            scorecard.spin = "0"
            
            
        }
        
    }
    private func spinGrid(title: String, spins: [String]) -> some View {
        VStack {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                ForEach(spins, id: \.self) { spin in
                    JudgesButton(title: spin, color: BibColor.from(string: bibColor)?.color ) {
                        scorecard.spinDirection = title
                        scorecard.spin = spin
                        path.append(.score)
                    }
                    
                }
            }
            .padding()
        }
        .padding()
    }
}

struct ScorecardRailSpinOnView: View {
    @Binding var scorecard: Scorecard
    @Binding var path: [ScorecardRoute]
    @Binding var bibColor: String

    let spinValues = ["0", "90", "180", "270", "360", "450", "540", "630", "720"]


    var body: some View {
        VStack {
            Text("Spin On")
                .font(.largeTitle)
                .padding(.bottom)
            HStack {
                spinGrid(title: "Backside", spins: spinValues)
                Divider()
                spinGrid(title: "Frontside", spins: spinValues)
            }
            
            Spacer()
        }
        .padding(.bottom)
    }

    private func spinGrid(title: String, spins: [String]) -> some View {
        VStack {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                ForEach(spins, id: \.self) { spin in
                    JudgesButton(title: spin, color: BibColor.from(string: bibColor)?.color ?? Color.gray) {
                        scorecard.spinDirection = title
                        scorecard.spin = spin
                        path.append(.spinOff)
                    }
                }
            }
            .padding()
        }
    }
}

struct ScorecardRailSpinOffView: View {
    @Binding var scorecard: Scorecard
    @Binding var path: [ScorecardRoute]
    @Binding var bibColor: String

    let spinValues = ["0", "90", "180", "270", "360", "450", "540", "630", "720"]


    var body: some View {
        VStack {
            Text("Spin Off")
                .font(.largeTitle)
                .padding(.bottom)
            
            HStack{
                spinGrid(title: "Backside", spins: spinValues)
                Divider()
                spinGrid(title: "Frontside", spins: spinValues)
            }

            Spacer()
        }
        .padding(.bottom)
    }

    private func spinGrid(title: String, spins: [String]) -> some View {
        VStack {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                ForEach(spins, id: \.self) { spin in
                    JudgesButton(title: spin, color: BibColor.from(string: bibColor)?.color ?? Color.gray) {
                        appendSpinOffValue(spinValue: spin, title: title)
                        path.append(.score)
                    }
                }
            }
            .padding()
        }
    }
    private func appendSpinOffValue(spinValue: String, title: String) {
            if scorecard.spin.isEmpty {
                scorecard.spin = spinValue
            } else {
                scorecard.spin += ", \(spinValue)"
            }
            scorecard.spinDirection += ", \(title)"
        }
}


struct ScorecardFlipView: View {
    @Binding var scorecard: Scorecard
    @Binding var path: [ScorecardRoute]
    @Binding var bibColor: String

    
    var toesideOptions = ["Frontroll", "Backroll", "Frontflip",]
    var heelsideOptions = ["Tantrum", "Backroll", "Frontflip"]
    
    var body: some View {
        VStack {
            Text("Flip")
                .font(.largeTitle)
                .padding()
            
            
            HStack {
                ForEach(currentOptions, id: \.self) { option in
                    JudgesButton(title: option, color: BibColor.from(string: bibColor)?.color) {
                        scorecard.trickType = option
                        path.append(.spin)
                    }
                    
                }
            }
        }
        .padding(.bottom)
        Spacer()
    }
    
    private var currentOptions: [String] {
        switch scorecard.approach {
        case "Toeside", "Switch Toeside":
            return toesideOptions
        case "Heelside", "Switch Heelside":
            return heelsideOptions
        default:
            return []  // Or some default options
        }
    }
}

struct ScorecardScoreView: View {
    @Binding var scorecard: Scorecard
    @Binding var path: [ScorecardRoute]
    @Binding var bibColor: String

    var riderLanded: () -> Void
    var riderFell: () -> Void
    
    @State var hasBeenEdited: Bool = false
    
    private let redModifiers = ["Repeat", "Sketchy", "Lazy", "Zeached", "Over/Under Rotated", "Wild", "Bailed", "Rushed", "911", ]
    private let blueModifiers = ["Grabbed", "Ole", "Wrapped", "Boosted", "Stomped", "Tweaked", "High-Stakes", "Technical", "Innovative" ]
    
    private let railRedModifiers = ["Repeat", "Sketchy", "Lazy", "Zeached", "Off-Early", "Wild", "Bailed", "Rushed", "911"]
    private let railBlueModifiers = ["Pressed", "Switch-Up", "MJ'd", "HandDrag", "Stomped", "Tweaked", "High-Stakes", "Technical", "Innovative"]

    
    var body: some View {
        
        HStack {
            
            VStack {
                
                ScoreSlider(label: "Division", value: $scorecard.division, hasBeenEdited: $hasBeenEdited)
                Divider()
                ScoreSlider(label: "Creativity", value: $scorecard.creativity, hasBeenEdited: $hasBeenEdited)
                Divider()
                ScoreSlider(label: "Difficulty", value: $scorecard.difficulty, hasBeenEdited: $hasBeenEdited)
                Divider()
                ScoreSlider(label: "Execution", value: $scorecard.execution, hasBeenEdited: $hasBeenEdited)
                Divider()
                
                HStack {
                    SubmitButton(label: "Fell", color: .red) {
                        riderFell()
                        path.removeAll()
                    }
                    
                    SubmitButton(label: "Landed", color: .green) {
                        riderLanded()
                        // TODO: Set alert notifying of submitted score
                        path.removeAll()
                    }.frame(maxWidth: .infinity)
                }
                
            }
            .frame(maxWidth: .infinity)
            //            .border(Color.gray, width: 1)
            
            
            VStack {
                            if scorecard.section == "Rail" {
                                modifierGrid(items: railRedModifiers, color: .red)
                                Divider()
                                modifierGrid(items: railBlueModifiers, color: .blue)
                            } else {
                                modifierGrid(items: redModifiers, color: .red)
                                Divider()
                                modifierGrid(items: blueModifiers, color: .blue)
                            }
                        }
        }.padding()
        Spacer()
        
    }
    
    
    private func modifierGrid(items: [String], color: Color) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
            ForEach(items, id: \.self) { item in
                Button(action: {
                    toggleModifier(item)
                }) {
                    Text(item)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(scorecard.modifiers.contains(item) ? color : color.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                         // Adds padding around the button for spacing
                }
            }
        }
        .padding()
    }
    private func toggleModifier(_ name: String) {
        if let index = scorecard.modifiers.firstIndex(of: name) {
            scorecard.modifiers.remove(at: index)
        } else {
            scorecard.modifiers.append(name)
        }
    }
}


struct ScoreSlider: View {
    let label: String
    @Binding var value: Double
    @State private var isEditing = false
    @Binding  var hasBeenEdited: Bool
    
    var body: some View {
        VStack {
            HStack {
                Text(label).foregroundColor(isEditing ? .red : .blue)
                if label == "Division" {
                    Text(divisionLabel(for: value)).foregroundColor(isEditing ? .red : .blue)
                } else {
                    Text(String(format: "%.1f", value)).foregroundColor(isEditing ? .red : .blue)
                }
            }
            Slider(
                value: $value,
                in: 0...10,
                step: 0.001
            ) {
                // Slider configuration
            } onEditingChanged: { editing in
                hasBeenEdited = true
                isEditing = editing
            }
        }
        .onAppear {
            if value == 0 && label != "Division" {
                value = 5
            }
        }
    }
}

struct ScorecardSectionView: View {
    @Binding var scorecard: Scorecard
    @Binding var path: [ScorecardRoute]
    @Binding var alertItem: AlertItem?
    @Binding var bibColor: String

    var riderSkip: () -> Void
    
    private let options = ["Kicker", "Rail", "Air Trick", "Pass"]
    
    var body: some View {
        VStack {
            Text("Section")
                .font(.largeTitle)
                .padding(.bottom)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                ForEach(options, id: \.self) { option in
                    JudgesButton(title: option, color: BibColor.from(string: bibColor)?.color, action: {
                        if scorecard.riderObj != nil {
                            handleOptionSelection(option)
                        } else {
                            alertItem = AlertContext.alert(for: .selectRiderFirst)
                        }
                    })
                }
            }
            .padding(.bottom)
            .alert(item: $alertItem) { item in
                Alert(title: item.title, message: item.message, dismissButton: item.dismissButton)
            }
            
            Spacer()
        }
        .onAppear {
            if let rider = scorecard.riderObj {
                scorecard = Scorecard()
                scorecard.riderObj = rider
            } else {
                scorecard = Scorecard()
            }
        }
    }
    private func handleOptionSelection(_ option: String) {
        if option == "Pass" {
            riderSkip()   // Call riderSkip when the option is "Pass"
            navigateToRoot()
        } else {
            
            scorecard.section = option
            navigateToApproach()
        }
    }
    
    private func navigateToApproach() {
        path.append(.approach) // Programmatically navigate to the approach view
    }
    
    private func navigateToRoot() {
        path.removeAll()
    }
}

struct ScorecardKickerView: View {
    @Binding var scorecard: Scorecard
    @Binding var path: [ScorecardRoute]
    @Binding var bibColor: String

    private let options = ["Flip", "Spin", "Double Flip", "Raley"]
    
    var body: some View {
        VStack {
            Text("Type")
                .font(.largeTitle)
                .padding(.bottom)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(options, id: \.self) { option in
                    JudgesButton(title: option, color: BibColor.from(string: bibColor)?.color,  action: {
                        navigateToOption(option)
                    })
                }
            }
            .padding(.bottom)
            
            Spacer()
        }
        
        .padding()
    }
    
    private func navigateToOption(_ option: String) {
        switch option {
        case "Flip":
            path.append(.flip)
        case "Spin":
            path.append(.spin)
            scorecard.trickType = "Spin"
        case "Double Flip":
            path.append(.flip)
            scorecard.modifiers.append("Double Flip")
        case "Raley":
            path.append(.spin)
        default:
            break  // Handle default case, if needed
        }
    }
}

struct ScorecardApproachView: View {
    @Binding var scorecard: Scorecard
    @Binding var path: [ScorecardRoute]
    @Binding var bibColor: String

    
    // Define the button titles for each stance
    var buttonTitlesRegular = ["Heelside", "Toeside", "Switch Toeside", "Switch Heelside"]
    var buttonTitlesGoofy = ["Toeside", "Heelside", "Switch Heelside", "Switch Toeside"]
    
    var body: some View {
        VStack {
            Text("Approach")
                .font(.largeTitle)
                .padding(.bottom)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(currentButtonTitles, id: \.self) { title in
                    JudgesButton(title: title, color: BibColor.from(string: bibColor)?.color) {
                        scorecard.approach = title
                        navigateToNextView(title: title)
                        
                    }
                }
                
            }
            .padding(.bottom)
            
            Spacer()
            
        }
        .onAppear {
            scorecard.approach = ""
        }
    }
    
    private var currentButtonTitles: [String] {
        scorecard.riderObj?.stance == "Goofy" ? buttonTitlesGoofy : buttonTitlesRegular
    }
    
    private func navigateToNextView(title: String) {
        // Decide and append the next route based on your app's logic
        // Example:
        if scorecard.section == "Kicker" {
            path.append(.kicker) // or .rail, .airtrick, etc., as per your navigation flow
        }
        if scorecard.section == "Air Trick" {
            path.append(.airtrick)
        }
        if scorecard.section == "Rail" {
            path.append(.rail)
        }
    }
}
