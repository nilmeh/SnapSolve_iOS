//
//  GeminiService.swift
//  SnapSolve
//
//  Created by Niloy Meharchandani on 25/04/25.
//


import Foundation

struct AnalysisResult {
    let description: String
    let recommendedAction: String
}

class GeminiService {
    static func analyze(imageData: Data, completion: @escaping (AnalysisResult) -> Void) {
        // TODO: replace with actual Gemini Vision API call
        // For now, return a mock response
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            let mock = AnalysisResult(
                description: "Pothole detected",
                recommendedAction: "Notify Public Works Department"
            )
            DispatchQueue.main.async {
                completion(mock)
            }
        }
    }
}
