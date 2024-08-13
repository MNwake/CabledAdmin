//
//  DockHandView.swift
//  TheCWA_admin
//
//  Created by Theo Koester on 3/7/24.
//

import SwiftUI
import UIKit

struct DockHandView: View {
    @ObservedObject var viewModel = DockHandViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                // Check if the device is iPhone, then use ScrollView
                if UIDevice.current.userInterfaceIdiom == .phone {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(viewModel.contestCarriers ?? []) { carrier in
                                CarrierView(viewModel: viewModel, carrier: carrier, index: carrier.number)
                            }
                        }.padding()
                    }
                } else {
                    // For iPad or other devices, use a normal HStack
                    HStack(spacing: 20) {
                        ForEach(viewModel.contestCarriers ?? []) { carrier in
                            CarrierView(viewModel: viewModel, carrier: carrier, index: carrier.number)
                        }
                    }.padding()
                }
                List(viewModel.unassignedRiders) { rider in
                    if let index = viewModel.riders.firstIndex(where: { $0 == rider }) {
                        DockHandListItem(viewModel: viewModel, rider: $viewModel.riders[index])
                    }
                }
                
            }
            .navigationTitle("DockHand")
            .onAppear {
                viewModel.getRiderData()
                viewModel.getContestCarriers()
                viewModel.addObserver()
            }
            .onDisappear {
                viewModel.removeObserver()
            }
        }
    }
}

struct DockHandListItem: View {
    @ObservedObject var viewModel: DockHandViewModel
    
    @Binding var rider: Rider
    @State var selectedColor: String?
    
    private let availableColors: [BibColor] = [.red, .green, .blue, .orange, .purple]
    
    var body: some View {
        HStack {
            Text(rider.fullName)
            Spacer()
            // Custom color picker
            Text("Bib:")
            BibColorPicker(selectedColor: $selectedColor)
        }
        .onDrag {
            if let unwrappedRiderId = rider.id, let selectedColor = selectedColor, !selectedColor.isEmpty {
                print("Rider ID: \(unwrappedRiderId) with color: \(selectedColor)")
                let riderData = "\(unwrappedRiderId)|\(selectedColor)"
                return NSItemProvider(object: riderData as NSString)
            } else {
                // No color selected or rider ID is nil
                print("Error: Either Rider ID is nil or no color selected")
                return NSItemProvider()
            }
        } preview: {
            // Custom drag preview
            dragPreview(for: rider)
        }
        .onAppear {
            selectedColor = ""
        }
    }
    // Helper function to create a view for drag preview
    func dragPreview(for rider: Rider) -> some View {
        let previewColor = color(forBibColorName: selectedColor ?? "")
        return HStack {
            Text(rider.fullName)
            //                .background(previewColor.opacity(0.5)) // Using the selected color with opacity
                .frame(width: 250, height: 40)
                .cornerRadius(5)
        }.background(previewColor.opacity(0.5))
    }
    
    func color(forBibColorName name: String) -> Color {
        return availableColors.first { $0.rawValue == name }?.color ?? Color.gray
    }
}


struct BibColorPicker: View {
    @Binding var selectedColor: String?
    var onColorSelected: ((BibColor) -> Void)?
    
    var body: some View {
        HStack {
            ForEach(BibColor.allCases, id: \.self) { bibColor in
                colorButton(for: bibColor)
                    .onTapGesture {
                        self.selectedColor = bibColor.rawValue
                        onColorSelected?(bibColor)
                    }
            }
        }
    }
    
    private func colorButton(for bibColor: BibColor) -> some View {
        Circle()
            .fill(bibColor.color)
            .frame(width: 24, height: 24)
            .overlay(
                Circle()
                    .stroke(self.selectedColor == bibColor.rawValue ? Color(UIColor.label) : Color.clear, lineWidth: 2)
            )
    }
}

struct DockHandView_Previews: PreviewProvider {
    static var previews: some View {
        DockHandView()
    }
}
