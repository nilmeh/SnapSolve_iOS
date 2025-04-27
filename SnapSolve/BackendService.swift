//
//  BackendService.swift
//  SnapSolve
//
//  Created by Niloy Meharchandani on 04/26/25.
//

import Foundation
import CoreLocation

// MARK: - Models

struct AnalysisResult: Decodable {
    let description: String
    let recommendation: String
    let email: String?
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

// MARK: - BackendService

class BackendService {

    private static let baseURL = "https://940f-131-179-132-163.ngrok-free.app"

    /// Analyze an image and get an AI description and recommendation
    static func analyze(
        imageData: Data,
        location: CLLocationCoordinate2D?,
        completion: @escaping (Result<AnalysisResult, Error>) -> Void
    ) {
        print("Captured image size: \(imageData.count) bytes")

        let urlString = "\(baseURL)/api/analyze"
        print("Sending POST to: \(urlString)")
        guard let url = URL(string: urlString) else {
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
            request.httpBody = try JSONSerialization.data(withJSONObject: filteredBody)
            print("Analyze request body: \(filteredBody)")
        } catch {
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
                print("HTTP status (analyze): \(statusCode)")

                guard let data = data else {
                    completion(.failure(BackendError.serverError("No data received")))
                    return
                }

                if let bodyString = String(data: data, encoding: .utf8) {
                    print("Analyze response body: \(bodyString)")
                }

                do {
                    let result = try JSONDecoder().decode(AnalysisResult.self, from: data)
                    completion(.success(result))
                } catch {
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

    /// Submit a confirmed ticket to backend
    /// Submit a confirmed ticket to backend
    static func submitTicket(
        ticket: Ticket,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        print("Submitting ticket...")

        let urlString = "\(baseURL)/api/tickets"
        print("Sending POST to: \(urlString)")
        guard let url = URL(string: urlString) else {
            completion(.failure(BackendError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Include the base64 image again
        let body: [String: Any?] = [
            "problem_description": ticket.analysis.description,
            "recommendation":      ticket.analysis.recommendation,
            "timestamp":           Int(Date().timeIntervalSince1970),
            "email":               ticket.analysis.email,
            "latitude":            ticket.location?.latitude,
            "longitude":           ticket.location?.longitude,
            "imageBase64":         ticket.imageData.base64EncodedString(),
        ]
        let filteredBody = body.compactMapValues { $0 }
        print("Submit ticket body: \(filteredBody)")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: filteredBody)
        } catch {
            completion(.failure(BackendError.encodingError))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Ticket submission network error: \(error)")
                    completion(.failure(error))
                    return
                }

                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                print("HTTP status (submit): \(statusCode)")

                guard let data = data else {
                    completion(.failure(BackendError.serverError("No data received.")))
                    return
                }

                if let bodyString = String(data: data, encoding: .utf8) {
                    print("Submit ticket response body: \(bodyString)")
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let id = json["_id"] as? String {
                        completion(.success(id))
                    } else if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                              let id = json["id"] as? String {
                        completion(.success(id))
                    } else {
                        completion(.failure(BackendError.serverError("Invalid server response format.")))
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
