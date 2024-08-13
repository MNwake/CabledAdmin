//
//  RidersError.swift
//  TheCWA
//
//  Created by Theo Koester on 2/29/24.
//

import Foundation

enum RequestError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
    case unableToComplete
    case invalidEmail
    case invalidForm
    case userSaveSuccess
    case invalidUserData
    case invalidDOB
    case selectRiderFirst
    case defaultAlert
    case firebaseConfigurationError
    case uploadTaskFailed
    case badResponse
    case serverSideError(Int)
}

import SwiftUI

struct AlertItem: Identifiable {
    let id = UUID()
    let title: Text
    let message: Text
    let dismissButton: Alert.Button
    var onDismiss: (() -> Void)? = nil // Add this line
}

// Example usage for a dismiss button
let defaultDismissButton = Alert.Button.default(Text("OK"))

struct AlertContext {
    static func alert(for error: RequestError, onDismiss: (() -> Void)? = nil) -> AlertItem {
        switch error {
        case .defaultAlert:
            return AlertItem(title: Text("Unexpected Error"),
                             message: Text("An unexpected issue occurred. Please try again. If the problem persists, contact our support team for assistance."),
                             dismissButton: defaultDismissButton)
            
            
            //MARK: - HTTP Request
        case .invalidURL:
            return AlertItem(title: Text("Connection Error"),
                             message: Text("We're having trouble connecting to our servers. Please check your internet connection and try again."),
                             dismissButton: defaultDismissButton)
            
        case .invalidResponse:
            return AlertItem(title: Text("Server Response Error"),
                             message: Text("We received an unexpected response from the server. Please try again later or contact support if the issue continues."),
                             dismissButton: defaultDismissButton)
            
        case .invalidData:
            return AlertItem(title: Text("Data Error"),
                             message: Text("We encountered an error processing data from the server. Please try again later or reach out to our support team."),
                             dismissButton: defaultDismissButton)
            
        case .unableToComplete:
            return AlertItem(title: Text("Internet Connection Error"),
                             message: Text("Your request couldn't be completed due to a connection issue. Please check your internet and try again."),
                             dismissButton: defaultDismissButton)
            
        case .badResponse:
            return AlertItem(title: Text("Bad Response"),
                             message: Text("The response from the server was not valid. Please try again later."),
                             dismissButton: .default(Text("OK")))
            
        case .serverSideError(let statusCode):
            return AlertItem(title: Text("Server Error"),
                             message: Text("The server encountered an error. Status Code: \(statusCode)"),
                             dismissButton: .default(Text("OK")))
            
            
            
            
            
            //MARK: - Account Alerts
            
        case .invalidForm:
            return AlertItem(title: Text("Form Incomplete"),
                             message: Text("Please make sure all required fields are filled out correctly."),
                             dismissButton: .default(Text("OK")))
            
        case .invalidEmail:
            return AlertItem(title: Text("Email Error"),
                             message: Text("The email you entered doesn’t appear to be valid. Please check and try again."),
                             dismissButton: .default(Text("OK")))
            
        case .userSaveSuccess:
            return AlertItem(title: Text("Success"),
                             message: Text("Your profile information has been successfully updated."),
                             dismissButton: .default(Text("OK"), action: onDismiss),
                             onDismiss: onDismiss)
            
        case .invalidUserData:
            return AlertItem(title: Text("Profile Update Error"),
                             message: Text("We encountered an issue with your profile update. Please try again or contact support."),
                             dismissButton: .default(Text("OK")))
            
        case .invalidDOB:
            return AlertItem(title: Text("Date of Birth Error"),
                             message: Text("The date of birth you entered is invalid. Please enter a valid date."),
                             dismissButton: .default(Text("OK")))
            
            
            
            //MARK: - Judges Alert
            
        case .selectRiderFirst:
            return AlertItem(title: Text("Rider Selection Required"),
                             message: Text("Please select a rider before proceeding to choose a section."),
                             dismissButton: .default(Text("OK")))
            
            
            //MARK: - Firebase Alerts
        case .firebaseConfigurationError:
            return AlertItem(title: Text("Firebase Configuration Error"),
                             message: Text("There was an issue initializing Firebase. Please ensure Firebase is configured correctly and restart the app."),
                             dismissButton: .default(Text("OK"), action: onDismiss),
                             onDismiss: onDismiss)
            
        case .uploadTaskFailed:
            return AlertItem(title: Text("Upload Failed"),
                             message: Text("Failed to upload the data to Firebase Storage. Please check your internet connection and try again."),
                             dismissButton: .default(Text("OK"), action: onDismiss),
                             onDismiss: onDismiss)
            
            
        }
    }
}
