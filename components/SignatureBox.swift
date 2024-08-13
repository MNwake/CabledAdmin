//
//  SignatureBox.swift
//  TheCWA_admin
//
//  Created by Theo Koester on 3/16/24.
//

import SwiftUI

struct SignatureBox: View {
    
    @State var isSigning: Bool = false
    @State var clearSignature: Bool = false
    @Binding var signatureImage: UIImage?
    @Binding var signaturePDF: Data?
    
    
    var body: some View {
        VStack {
            Group {
                VStack(alignment: .leading, spacing: 16){
                    Text("Please sign below to accept the terms")
                        .font(.headline)
                        .foregroundColor(.accentColor)
                }
                .padding(.top, 20)
            }
            .padding(.horizontal, 16)
            
            
            Divider()
            
            
            VStack(spacing: 16) {
                ZStack(alignment: isSigning ? .bottomTrailing: .center) {
                    SignatureViewContainer(clearSignature: $clearSignature, signatureImage: $signatureImage, pdfSignature: $signaturePDF)
                        .disabled(!isSigning)
                        .frame(height: 197)
                        .frame(maxWidth: .infinity)
                        .background(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.accentColor, lineWidth: 3)
                        )
                    if isSigning {
                        Button(action: {
                            clearSignature = true
                        }, label: {
                            HStack {
                                Text("Clear")
                                    .font(.callout)
                                    .foregroundColor(.black)
                            }
                            .padding(.horizontal, 12)
                            .frame(height: 28)
                            .background(
                                Capsule()
                                    .fill(.green)
                            )
                        })
                        .offset(.init(width: -12, height: -12))
                    } else {
                        Button(action: {
                            isSigning = true
                        }, label: {
                            VStack(alignment: .center, spacing: 0) {
                                Image(systemName: "pencil")
                                    .resizable()
                                    .foregroundColor(.black)
                                    .frame(width: 20, height: 20)
                                    .padding(8)
                                Text("Sign here")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                        })
                    }
                }
                .padding(.top, 16)
                .padding(.horizontal, 3)
                
            }
            
        }
        .padding()
        
    }
}


