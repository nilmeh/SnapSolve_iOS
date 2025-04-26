//
//  GeminiService.swift
//  SnapSolve
//
//  Created by Niloy Meharchandani on 25/04/25.
//

import Foundation
import UIKit

// MARK: - Result Struct
struct AnalysisResult {
    let description: String
    let recommendedAction: String
}

// MARK: - Codable Structs for API Interaction

struct GeminiRequest: Codable {
    let contents: [Content]
}

struct Content: Codable {
    let parts: [Part]
}

struct Part: Codable {
    let text: String?
    let inlineData: InlineData?

    init(text: String) {
        self.text = text
        self.inlineData = nil
    }

    init(inlineData: InlineData) {
        self.text = nil
        self.inlineData = inlineData
    }
}

struct InlineData: Codable {
    let mimeType: String
    let data: String // Base64-encoded image
}

// Success Response
struct GeminiResponse: Decodable {
    let candidates: [Candidate]?
    let error: GeminiAPIError?
}

struct Candidate: Decodable {
    let content: ContentResponse?
}

struct ContentResponse: Decodable {
    let parts: [PartResponse]?
}

struct PartResponse: Decodable {
    let text: String?
}

// Inner Parsed JSON from AI Response
struct ParsedAnalysis: Decodable {
    let description: String
    let recommendation: String
}

// Gemini API Error Struct
struct GeminiAPIError: Decodable {
    let code: Int?
    let message: String?
    let status: String?
}

// MARK: - Gemini Service

class GeminiService {

    static private let apiKey = "AIzaSyAB5sYUDg5VNytaSZdGeSmQho7GhTu2ETs" // Replace this
    static private let endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro-vision:generateContent"
    
    static private let session = URLSession.shared
    static private let decoder = JSONDecoder()
    static private let encoder = JSONEncoder()

    static func analyze(imageData: Data, completion: @escaping (Result<AnalysisResult, Error>) -> Void) {
        guard var urlComponents = URLComponents(string: endpoint) else {
            completion(.failure(GeminiError.custom("Invalid API endpoint.")))
            return
        }
        urlComponents.queryItems = [URLQueryItem(name: "key", value: apiKey)]
        guard let url = urlComponents.url else {
            completion(.failure(GeminiError.custom("Failed to build URL.")))
            return
        }
        
        let base64Image = imageData.base64EncodedString()

        let prompt = """
        Analyze this image and identify any urban infrastructure issues (e.g., potholes, broken streetlights, damaged bike racks).
        Respond ONLY with a JSON object with two fields: \"description\" and \"recommendation\".
        """

        let requestPayload = GeminiRequest(contents: [
            Content(parts: [
                Part(text: prompt),
                Part(inlineData: InlineData(mimeType: "image/jpeg", data: base64Image))
            ])
        ])

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try encoder.encode(requestPayload)
        } catch {
            completion(.failure(GeminiError.encoding(error.localizedDescription)))
            return
        }

        session.dataTask(with: request) { data, response, error in
            let complete: (Result<AnalysisResult, Error>) -> Void = { result in
                DispatchQueue.main.async { completion(result) }
            }
            
            if let error = error {
                complete(.failure(GeminiError.network(error)))
                return
            }
            guard let data = data else {
                complete(.failure(GeminiError.custom("No data received.")))
                return
            }

            do {
                let geminiResponse = try decoder.decode(GeminiResponse.self, from: data)

                if let apiError = geminiResponse.error {
                    complete(.failure(GeminiError.api(apiError.message ?? "Unknown error.")))
                    return
                }

                guard let textResponse = geminiResponse.candidates?.first?.content?.parts?.first?.text else {
                    complete(.failure(GeminiError.parsing("Missing AI text response.")))
                    return
                }

                let cleanedText = textResponse
                    .replacingOccurrences(of: "```json", with: "")
                    .replacingOccurrences(of: "```", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                guard let textData = cleanedText.data(using: .utf8) else {
                    complete(.failure(GeminiError.parsing("Failed to parse cleaned AI text.")))
                    return
                }

                let parsedAnalysis = try decoder.decode(ParsedAnalysis.self, from: textData)

                let result = AnalysisResult(
                    description: parsedAnalysis.description,
                    recommendedAction: parsedAnalysis.recommendation
                )
                complete(.success(result))

            } catch {
                print("Gemini JSON decoding error: \(error.localizedDescription)")
                print("Raw response: \(String(data: data, encoding: .utf8) ?? "Unreadable response")")
                complete(.failure(GeminiError.decoding(error.localizedDescription)))
            }

        }.resume()
    }
}

// MARK: - Custom Error Type

enum GeminiError: Error, LocalizedError {
    case custom(String)
    case encoding(String)
    case network(Error)
    case api(String)
    case decoding(String)
    case parsing(String)

    var errorDescription: String? {
        switch self {
        case .custom(let msg): return msg
        case .encoding(let msg): return "Encoding error: \(msg)"
        case .network(let err): return "Network error: \(err.localizedDescription)"
        case .api(let msg): return "Gemini API error: \(msg)"
        case .decoding(let msg): return "Decoding error: \(msg)"
        case .parsing(let msg): return "Parsing error: \(msg)"
        }
    }
}
