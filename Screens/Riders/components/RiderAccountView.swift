//
//  RiderAccountView.swift
//  TheCWA_admin
//
//  Created by Theo Koester on 3/6/24.
//

import SwiftUI

struct RiderAccountView: View {
    @ObservedObject var viewModel: RiderAccountViewModel
    var onDismiss: () -> Void
    
    @Environment(\.presentationMode) var presentationMode
    @State private var showingWaiverView = false

    // New additions for focused state
    @FocusState private var focusedTextField: FormTextField?
    enum FormTextField {
        case firstName, lastName, email, dob, gender, stance, yearStarted, homePark
    }

    var body: some View {
        ZStack {
            if viewModel.isUpdating {
                LoadingView()  // Show loading screen when updating
            } else {
                Form {
                    HStack(alignment: .top) {
                        Spacer()
                        if let riderImage = viewModel.riderImage {
                            Image(uiImage: riderImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray, lineWidth: 4))
                                .padding()
                        } else {
                            AsyncRiderImageView(urlString: viewModel.rider.profile_image.absoluteString)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray, lineWidth: 4))
                                .padding()
                        }
                        
                        CaptureImageView(image: $viewModel.riderImage)
                        Spacer()
                    }
                    
                    Section(header: Text("Personal Information: \(viewModel.rider.id ?? "Error")")) {
                        TextField("First Name", text: $viewModel.rider.first_name)
                            .focused($focusedTextField, equals: .firstName)
                            .onSubmit { focusedTextField = .lastName }
                            .submitLabel(.next)
                        
                        TextField("Last Name", text: $viewModel.rider.last_name)
                            .focused($focusedTextField, equals: .lastName)
                            .onSubmit { focusedTextField = .email }
                            .submitLabel(.next)
                        
                        TextField("Email", text: $viewModel.rider.email)
                            .focused($focusedTextField, equals: .email)
                            .onSubmit { focusedTextField = .dob }
                            .submitLabel(.next)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        
                        DatePicker("Date of Birth", selection: $viewModel.rider.date_of_birth, displayedComponents: .date)
                            .focused($focusedTextField, equals: .dob)
                            .onSubmit { focusedTextField = .gender }
                            .submitLabel(.next)
                        
                        Picker("Gender", selection: $viewModel.rider.gender) {
                            Text("Please Select:").tag(String?.none)
                            ForEach(viewModel.genderOptions, id: \.self) { gender in
                                Text(gender).tag(gender as String?)
                            }
                        }
                    }
                    
                    Section(header: Text("Riding Information")) {
                        Picker("Stance", selection: $viewModel.rider.stance) {
                            Text("Please Select:").tag(String?.none)
                            ForEach(viewModel.stanceOptions, id: \.self) { stance in
                                Text(stance).tag(stance as String?)
                            }
                        }
                        
                        Picker("Year Started", selection: $viewModel.rider.year_started) {
                            Text("Please Select:").tag(String?.none)
                            ForEach(viewModel.rider.birthYear...2024, id: \.self) { year in
                                Text(String(year))
                            }
                        }
                        Picker("Home Park", selection: $viewModel.selectedParkIndex) {
                            Text("Please Select:").tag(-1)
                            ForEach(0..<viewModel.parks.count, id: \.self) { index in
                                Text(viewModel.parks[index].name).tag(index as Int?)
                            }
                        }
                        .onChange(of: viewModel.selectedParkIndex) { newIndex in
                            viewModel.rider.home_park = newIndex >= 0 ? viewModel.parks[newIndex].id : ""
                        }
                    }
                    
                    Section {
                        Toggle("Is Registered", isOn: isRegisteredBinding)
                    }
                    Section {
                        HStack {
                            Text("Valid Waiver")
                            Spacer()
                            Image(systemName: waiverIsValid ? "checkmark.circle" : "circle")
                        }
                        .onTapGesture {
                            if !waiverIsValid {
                                showingWaiverView = true
                            }
                        }
                    }
                    Section {
                        Button("Save") {
                            Task {
                                do {
                                    try await viewModel.updateRider()
                                    // Handle successful uploads...
                                } catch {
                                    // Handle errors...
                                }
                            }
                        }
                        Button("Discard Changes") {
                            presentationMode.wrappedValue.dismiss()
                            onDismiss()
                        }
                    }
                    .fullScreenCover(isPresented: $showingWaiverView) {
                        WaiverView(signatureImage: $viewModel.waiverImage)
                    }
                }
                .onAppear {
                    viewModel.fetchParks()
                    viewModel.updateSelectedParkIndex()
                }
                .onChange(of: viewModel.saveSuccessful) { success in
                    if success {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .alert(item: $viewModel.alertItem) { alertItem in
                    Alert(title: alertItem.title, message: alertItem.message, dismissButton: alertItem.dismissButton)
                }
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") { focusedTextField = nil }
                    }
                }
            }
        }
    }

    private var isRegisteredBinding: Binding<Bool> {
        Binding<Bool>(
            get: { viewModel.rider.is_registered ?? false },
            set: { viewModel.rider.is_registered = $0 }
        )
    }
    
    private var waiverIsValid: Bool {
        guard let waiverDate = viewModel.rider.waiver_date else {
            return false
        }
        return waiverDate > Date()
    }
}

