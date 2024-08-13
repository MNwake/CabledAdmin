//
//  CarrierView.swift
//  TheCWA_admin
//
//  Created by Theo Koester on 3/11/24.
//

import SwiftUI

struct CarrierView: View {
    @ObservedObject var viewModel: DockHandViewModel
    @State private var isHovering = false
    @State var selectedColor: String?
    var carrier: ContestCarrier?
    
    let index: Int
    
    var rider: Rider? {
        viewModel.riders.first { $0.id == carrier?.rider_id }
    }
    
    var body: some View {
        ZStack {
            // Background and main content
            RoundedRectangle(cornerRadius: 10)
                .fill(carrier?.bibColor ?? Color(UIColor.systemBackground).opacity(0.5))
                .frame(width: 160, height: 210)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 2)  // Thin black outline
                )
            //            Text("Empty")
            
            
            
            if let rider = rider {
                occupiedView(rider: rider)
            } else {
                VStack {
                    
                    Text("Carrier #\(carrier?.number ?? 0)")
                    Text("Empty")
                    
                }
                .frame(width: 160, height: 210)
            }
            
        }
        .frame(width: 160, height: 210)
        .onDrop(of: [.text], isTargeted: $isHovering) { providers in
            if let carrierNumber = carrier?.number {
                return viewModel.handleDrop(providers: providers, at: carrierNumber)
            }
            return false
        }
    }
    
    
    private func removeRider() {
        guard let carrierNumber = carrier?.number else { return }
        viewModel.removeRiderFromCarrier(at: carrierNumber)
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

                Button(action: {
                    removeRider()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.black)
                        .imageScale(.large)
                        .padding(8)
                }
            }.padding(.horizontal)

            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 120, height: 120)

                AsyncRiderImageView(urlString: rider.profile_image.absoluteString)
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
            }

            Text(rider.fullName)
                .font(.subheadline)
                .lineLimit(1)
                .opacity(0.5)
        }
        .frame(width: 180, height: 230)
    }
}
