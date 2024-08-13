//
//  NetworkManager.swift
//  TheCWA
//
//  Created by Theo Koester on 2/29/24.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage


class NetworkManager {
    private let cache = NSCache<NSString, UIImage>()
    static let shared = NetworkManager()
    
    let ridersURL = BASE_URL + "/riders"
    let riderStatsURL = BASE_URL + "/stats/riders"
    let parksURL = BASE_URL + "/parks"
    let scorecardURL = BASE_URL + "/scorecards"
    let contestCarriersURL = BASE_URL + "/contest/carriers"
    
    private init() {}
    
    // Function to fetch riderse data
    func fetchRiders() async throws -> [Rider] {
        guard let url = URL(string: ridersURL) else {
            throw RequestError.invalidURL
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            
            // Custom date decoding strategy
            decoder.dateDecodingStrategy = .custom { decoder -> Date in
                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)
                
                // Try parsing with the primary format
                if let date = DateFormatter.yyyyMMddTHHmmssSSSSSS.date(from: dateString) {
                    return date
                }
                // Fallback for secondary format
                else if let date = DateFormatter.yyyyMMddTHHmmss.date(from: dateString) {
                    return date
                } else {
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format")
                }
            }
            
            return try decoder.decode(Riders.self, from: data).data
        } catch {
            print("Decoding error: \(error)")
            throw RequestError.unableToComplete
        }
    }
    
    func fetchContestCarriers() async throws -> [ContestCarrier] {
        guard let url = URL(string: contestCarriersURL) else {
            throw RequestError.invalidURL
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(DateFormatter.yyyyMMddTHHmmssSSSSSS)
            return try decoder.decode(ContestCarriers.self, from: data).data
        } catch {
            print("Decoding elinerror: \(error)")
            throw RequestError.unableToComplete
        }
    }
    
    //    func fetchRiderStats() async throws -> [RiderStat] {
    //        guard let url = URL(string: riderStatsURL) else {
    //            throw RequestError.invalidURL
    //        }
    //
    //        do {
    //            let (data, _) = try await URLSession.shared.data(from: url)
    //            let decoder = JSONDecoder()
    //            decoder.dateDecodingStrategy = .iso8601
    //            return try decoder.decode(RiderStats.self, from: data).data
    //        } catch {
    //            throw RequestError.unableToComplete
    //        }
    //    }
    
    func fetchParks() async throws -> [Park] {
        print("Fetch Parks")
        guard let url = URL(string: parksURL) else {
            throw RequestError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(Parks.self, from: data).data
            
        } catch {
            print("fetchPark network manager error")
            throw RequestError.unableToComplete
        }
    }
    
    func fetchScorecards(url: URL? = URL(string: NetworkManager.shared.scorecardURL)) async throws -> [Scorecard] {
        guard let effectiveURL = url else {
            throw RequestError.invalidURL
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: effectiveURL)
            
            
            let decoder = JSONDecoder()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS" // Custom date format
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Adjust if necessary
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            return try decoder.decode(Scorecards.self, from: data).data
        } catch {
            throw RequestError.unableToComplete
        }
    }
    
    func updateRider(_ rider: Rider) async throws -> String {
        guard let url = URL(string: "\(ridersURL)/update") else {
            throw RequestError.invalidURL
        }
        print("update Rider")
        // Prepare the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Encode the rider object to JSON
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(DateFormatter.yyyyMMddTHHmmss)
        guard let jsonData = try? encoder.encode(rider) else {
            print("jsoh data error")
            throw RequestError.invalidData
        }
        request.httpBody = jsonData
        
        // Perform the request
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            print("http resonse error")
            throw RequestError.unableToComplete
        }
        
        
        // Decode JSON to get rider_id
        let decoder = JSONDecoder()
        let responseData = try decoder.decode(RiderResponse.self, from: data)
        return responseData.rider_id
        

    }
    
    func createNewRider() async throws -> String {
        guard let url = URL(string: "\(ridersURL)/create") else {
            throw RequestError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let emptyData = Data()
        request.httpBody = emptyData

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw RequestError.unableToComplete
        }

        let decoder = JSONDecoder()
        let responseData = try decoder.decode(RiderResponse.self, from: data)
        return responseData.rider_id
    }
    
    func downloadImage(fromURLString urlString: String, completed: @escaping (UIImage?) -> Void ) {
        
        let cacheKey = NSString(string: urlString)
        
        if let image = cache.object(forKey: cacheKey) {
            completed(image)
            return
        }
        
        guard let url = URL(string: urlString) else {
            completed(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
            
            guard let data, let image = UIImage(data: data) else {
                completed(nil)
                return
            }
            
            self.cache.setObject(image, forKey: cacheKey)
            completed(image)
        }
        
        task.resume()
    }
    
    
    func uploadImageToFirebase(_ image: UIImage, for riderId: String, as imageType: ImageType) async throws -> URL {
        guard let imageData = image.jpegData(compressionQuality: 0.1) else {
            throw RequestError.invalidData
        }

        let storageRef = Storage.storage().reference()
        let imagePath: String

        switch imageType {
        case .profile:
            imagePath = "Rider/ProfileImages/\(riderId).jpg"
        case .waiver:
            imagePath = "Rider/WaiverImages/\(riderId).jpg"
        }

        let imageRef = storageRef.child(imagePath)

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        do {
            _ = try await imageRef.putDataAsync(imageData, metadata: metadata)
            let downloadURL = try await imageRef.downloadURL()
            print("Image uploaded to Firebase Storage at URL: \(downloadURL)")
            return downloadURL
        } catch let error {
            print("Error uploading image: \(error.localizedDescription)")
            throw error
        }
    }

     
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

// Helper DateFormatter extension
extension DateFormatter {
    static let yyyyMMddTHHmmss: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter
    }()
    static let yyyyMMddTHHmmssSSSSSS: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}

    
    
struct RiderResponse: Decodable {
    let success: Bool
    let rider_id: String
}


