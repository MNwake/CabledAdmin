//
//  ContentView.swift
//  CWA
//
//  Created by Theo Koester on 3/19/24.
//
import SwiftUI
import UIKit

struct ContentView: View {
    @State private var selectedTab = "ManageRiders"

    var body: some View {
        TabView(selection: $selectedTab) {
            ManageRidersView()
                .tabItem {
                    Label("Registration", systemImage: "person.3")
                }
                .tag("ManageRiders")
            
            DockHandView()
                .tabItem {
                    Label("DockHand", systemImage: "rectangle.and.hand.point.up.left.filled")
                }
                .tag("DockHand")

            // Conditionally show JudgesView only if the device is not an iPhone
            if UIDevice.current.userInterfaceIdiom != .phone {
                JudgesView()
                    .tabItem {
                        Label("Judges", systemImage: "list.clipboard")
                    }
                    .tag("Judges")
            }
    
            // ResourcesView() can be added similarly
        }
    }
}


