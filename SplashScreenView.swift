//
//  SplashScreenView.swift
//  CWA
//
//  Created by Theo Koester on 3/20/24.
//

import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ZStack {
                Image("motor_tower")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
