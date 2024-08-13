//
//  ManageRidersView.swift
//  TheCWA_admin
//
//  Created by Theo Koester on 3/4/24.
//

import SwiftUI

struct ManageRidersView: View {
    @StateObject var viewModel = ManageRidersViewModel()
    @State private var showingNewRiderView = false

    var body: some View {
        NavigationStack {
            List(viewModel.filteredRiders) { rider in
                NavigationLink(destination: RiderAccountView(viewModel: RiderAccountViewModel(rider: rider), onDismiss: {
                    viewModel.getRiderData()
                })) {
                    Text(rider.fullName)
                }
            }
            .searchable(text: $viewModel.searchText)
            .navigationTitle("Riders")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingNewRiderView = true
                    }) {
                        Image(systemName: "person.crop.circle.badge.plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewRiderView) {
                RiderAccountView(viewModel: RiderAccountViewModel(rider: Rider()), onDismiss: {
                    showingNewRiderView = false
                    viewModel.getRiderData()
                })
            }
            .onAppear {
                viewModel.getRiderData()
            }
        }
    }
}
