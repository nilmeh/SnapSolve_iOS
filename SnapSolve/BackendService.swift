//
//  BackendService.swift
//  SnapSolve
//
//  Created by Niloy Meharchandani on 04/26/25.
//

import Foundation
import CoreLocation

struct AnalysisResult: Decodable {
    let description: String
    let recommendation: String
}

enum BackendError: Error, LocalizedError {
    case invalidURL
    case encodingError
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid backend URL."
        case .encodingError:
            return "Failed to encode request body."
        case .serverError(let message):
            return "Server error: \(message)"
        }
    }
}

class BackendService {
    static func analyze(
        imageData: Data,
        location: CLLocationCoordinate2D?,
        completion: @escaping (Result<AnalysisResult, Error>) -> Void
    ) {
        print("Captured image size: \(imageData.count) bytes")

        let urlString = "https://5f54-131-179-94-177.ngrok-free.app/api/analyze"
        print("Sending POST to: \(urlString)")
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            completion(.failure(BackendError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any?] = [
            "imageBase64": imageData.base64EncodedString(),
            "latitude": location?.latitude,
            "longitude": location?.longitude
        ]
        let filteredBody = body.compactMapValues { $0 }

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: filteredBody, options: [])
            print("Request body: \(filteredBody)")
        } catch {
            print("Encoding error: \(error)")
            completion(.failure(BackendError.encodingError))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Network error: \(error)")
                    completion(.failure(error))
                    return
                }

                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                print("HTTP status: \(statusCode)")

                guard let data = data else {
                    print("No data received from server")
                    completion(.failure(BackendError.serverError("No data received")))
                    return
                }
                if let bodyString = String(data: data, encoding: .utf8) {
                    print("Response body: \(bodyString)")
                }

                do {
                    let result = try JSONDecoder().decode(AnalysisResult.self, from: data)
                    completion(.success(result))
                } catch {
                    print("Decoding error: \(error)")
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let message = json["error"] as? String {
                        completion(.failure(BackendError.serverError(message)))
                    } else {
                        completion(.failure(error))
                    }
                }
            }
        }.resume()
    }
}
