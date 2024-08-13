//
//  buttons.swift
//  TheCWA_admin
//
//  Created by Theo Koester on 3/13/24.
//

import SwiftUI

struct JudgesButton: View {
    let title: String
    var color: Color?  // Optional color
    let action: () -> Void
    var isEnabled: Bool = true

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title2)
                .bold()
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(color ?? Color.gray)  // Use provided color or default to gray
                .foregroundColor(.white)
                .cornerRadius(10)
                
        }.disabled(!isEnabled)
    }
}

struct JudgesButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            JudgesButton(title: "Accept", color: .green, action: {})
            JudgesButton(title: "Reject", color: .red, action: {})
            JudgesButton(title: "Pending", color: .yellow, action: {}, isEnabled: false)
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}


struct SubmitButton: View {
    let label: String
    let color: Color
    let action: () -> Void
    var isEnabled: Bool = true
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .padding()
                .background(color)
                .cornerRadius(8)
        }.disabled(!isEnabled)
            .padding(.top)
    }
}


struct SectionToggleButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    var isEnabled: Bool = true
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .foregroundColor(isSelected ? .white : .black)
            // Style the button
        }
        .disabled(!isEnabled)
        
    }
}

struct StyledButtonContent: View {
    let title: String
    

    var body: some View {
        Text(title)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}
//#Preview {
//    buttons()
//}
