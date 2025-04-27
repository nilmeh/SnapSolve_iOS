//
//  Report.swift
//  SnapSolve
//
//  Created by Niloy Meharchandani on 26/04/25.
//


import SwiftUI

struct Report: Identifiable, Decodable {
    let id: String
    let problem_description: String
    let recommendation: String
    let timestamp: Int
    let email: String
    let location: Location
    let imageBase64: String

    struct Location: Decodable {
        let latitude: Double
        let longitude: Double
    }

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case problem_description, recommendation, timestamp, email, location, imageBase64
    }
}

struct TicketsListView: View {
    @State private var reports: [Report] = []
    @State private var isLoading = false

    var body: some View {
        List(reports) { report in
            NavigationLink(value: report) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(report.problem_description)
                        .font(.headline)
                    Text(report.recommendation)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(Date(timeIntervalSince1970: TimeInterval(report.timestamp)),
                         style: .date)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("My Tickets")
        .task {
            await fetchReports()
        }
        .overlay {
            if isLoading {
                ProgressView()
            }
        }
    }

    private func fetchReports() async {
        guard let url = URL(string: "https://YOUR_NGROK_URL/api/tickets") else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            reports = try JSONDecoder().decode([Report].self, from: data)
        } catch {
            print("Failed to fetch tickets:", error)
        }
    }
}