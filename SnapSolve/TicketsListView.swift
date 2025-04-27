// TicketsListView.swift
import SwiftUI
import FirebaseAuth

struct Report: Identifiable, Decodable, Hashable {
    
    let id: String
    let problem_description: String
    let recommendation: String
    let timestamp: Int
    let email: String
    let location: Location
    let imageBase64: String

    struct Location: Decodable, Hashable {
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
    @State private var selectedReport: Report? = nil
    @State private var showingProfile = false
    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        List(reports) { report in
            VStack(alignment: .leading, spacing: 4) {
                Text(report.problem_description)
                    .font(.headline)
                Text(report.recommendation)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(Date(timeIntervalSince1970: TimeInterval(report.timestamp)), style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
            .onTapGesture {
                selectedReport = report
            }
        }
        .navigationTitle("My Tickets")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showingProfile.toggle() }
                label: {
                    Image(systemName: "person.crop.circle")
                        .font(.title2)
                        .foregroundColor(.accentColor)
                }
            }
        }
        .sheet(isPresented: $showingProfile) {
            ProfileView().environmentObject(sessionManager)
        }
        .task {
            await fetchReports()
        }
        .overlay {
            if isLoading {
                ProgressView()
            }
        }
        .sheet(item: $selectedReport) { report in
            ViewTicketDetailView(report: report)
        }
    }

    private func fetchReports() async {
        guard let url = URL(string: "https://940f-131-179-132-163.ngrok-free.app/api/tickets/my") else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            guard let user = Auth.auth().currentUser else {
                print("User not logged in")
                return
            }
            let idToken = try await user.getIDToken()

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")

            let (data, _) = try await URLSession.shared.data(for: request)
            reports = try JSONDecoder().decode([Report].self, from: data)
        } catch {
            print("Failed to fetch tickets:", error)
        }
    }
}
