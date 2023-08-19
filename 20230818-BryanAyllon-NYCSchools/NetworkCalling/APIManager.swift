//
//  APIManager.swift
//  20230818-BryanAyllon-NYCSchools
//
//  Created by Bryan Ayllon on 8/18/23.
//

import Foundation

/// Constants for API endpoints.
struct APIURLConstants {
    static let fetchSchools = "https://data.cityofnewyork.us/resource/s3k6-pzi2.json"
    static let fetchSATScores = "https://data.cityofnewyork.us/resource/f9bf-2cp4.json"
}

/// Manages network operations and data fetching.
class NetworkManager {
    typealias CompletionHandler = (Result<Data, Error>) -> Void
    
    /// Fetches data from a specified URL.
    ///
    /// - Parameters:
    ///   - urlString: The URL string to fetch data from.
    ///   - completionHandler: A closure to handle the result of the fetch operation.
    func fetchData(urlString: String, completionHandler: @escaping CompletionHandler) {
        // Ensure the URL is properly encoded and valid.
        guard let urlPath = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: urlPath) else {
            completionHandler(.failure(NetworkError.invalidURL))
            return
        }
        
        // Create a data task to fetch data from the URL.
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 403 {
                // Handle access denied error.
                completionHandler(.failure(NetworkError.accessDenied))
                return
            }
            
            if let error = error {
                // Handle other network-related errors.
                completionHandler(.failure(error))
                return
            }
            
            guard let data = data else {
                // Handle case where no data was fetched.
                completionHandler(.failure(NetworkError.noData))
                return
            }
            
            // Successfully fetched data.
            completionHandler(.success(data))
        }
        task.resume()
    }
}

/// Errors that can occur during network operations.
enum NetworkError: Error {
    case invalidURL
    case accessDenied
    case noData
}
