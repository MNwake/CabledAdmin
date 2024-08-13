//
//  WaiverView.swift
//  TheCWA_admin
//
//  Created by Theo Koester on 3/16/24.
//

import SwiftUI


struct WaiverView: View {
    
    @Binding private var signatureImage: UIImage?
    
    @State private var signaturePDF: Data?
    @State private var termsOfServiceText: String = ""
    @Environment(\.presentationMode) var presentationMode
    @State private var alertItem: AlertItem?
    @State private var showAlert = false
    
    init(signatureImage: Binding<UIImage?>) {
        self._signatureImage = signatureImage
        self._termsOfServiceText = State(initialValue: self.loadTermsOfService())
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer() // Pushes the button to the right
                Button(action: {
                    // Action to dismiss the view
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .frame(width: 44, height: 44)
                }
            }
            Text("Terms of Service/Liability Release")
                .font(.title)
            
            ScrollView {
                
                
                Text(termsOfServiceText).font(.body)
                // ... Other UI elements ...
            }
            //            Toggle("I Agree to the Terms of Service", isOn: $agreed)
            SignatureBox(signatureImage: $signatureImage, signaturePDF: $signaturePDF)
            Button("Submit Waiver") {
                if signatureImage != nil {
                    presentationMode.wrappedValue.dismiss()
                } else {
                    // Show an alert or some indication that a signature is required
                    alertItem = AlertItem(title: Text("Signature Required"), message: Text("Please provide a signature to submit the waiver."), dismissButton: .default(Text("OK")))
                }
            }
        }
        .padding()
        .alert(item: $alertItem) { alert in
            Alert(title: alert.title, message: alert.message, dismissButton: alert.dismissButton)
        }
    }
    
    private func loadTermsOfService() -> String {
        guard let fileURL = Bundle.main.url(forResource: "terms_of_service", withExtension: "txt") else {
            return "Terms of Service not found."
        }
        
        do {
            return try String(contentsOf: fileURL)
        } catch {
            return "Error loading Terms of Service."
        }
    }
    
}

//struct WaiverView_Previews: PreviewProvider {
//    @State static var sampleRider = MockData.sampleRider // State variable for Rider
//
//    static var previews: some View {
//        WaiverView(rider: $sampleRider) // Binding to the state variable
//    }
//}
