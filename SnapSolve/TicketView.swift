// TicketView.swift
// SnapSolve
// Sleek, professional Apple-style ticket confirmation view with unified button sizing and capsule shapes

import SwiftUI
import MapKit
import CoreLocation
import FirebaseAuth


struct TicketView: View {
    let ticket: Ticket
    var onConfirm: () -> Void = {}
    var onCancel: () -> Void = {}

    @State private var mapRegion: MKCoordinateRegion
    @State private var userName: String = ""

    init(ticket: Ticket, onConfirm: @escaping () -> Void = {}, onCancel: @escaping () -> Void = {}) {
        self.ticket = ticket
        self.onConfirm = onConfirm
        self.onCancel = onCancel

        let coordinate = ticket.location ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
        _mapRegion = State(initialValue: MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        ))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Header
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color.accentColor.opacity(0.2))
                        .frame(width: 48, height: 48)
                        .overlay(
                            Image(systemName: "person.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.accentColor)
                        )
                    VStack(alignment: .leading, spacing: 2) {
                        Text(userName)
                            .font(.headline)
                        Text("Reporter")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Image
                        if let uiImage = UIImage(data: ticket.imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 220)
                                .clipped()
                                .cornerRadius(12)
                                .padding(.horizontal)
                        }
                        
                        // Details
                        VStack(alignment: .leading, spacing: 12) {
                            InfoRow(title: "Issue Description", value: ticket.analysis.description)
                            InfoRow(title: "Recommendation", value: ticket.analysis.recommendation)
                            if let email = ticket.analysis.email {
                                InfoRow(title: "Contact Email", value: email)
                            }
                            // Map
                            if ticket.location != nil {
                                Map(
                                    coordinateRegion: $mapRegion,
                                    annotationItems: [AnnotatedLocation(coordinate: ticket.location!)]
                                ) { loc in
                                    MapMarker(coordinate: loc.coordinate, tint: .red)
                                }
                                .frame(height: 140)
                                .cornerRadius(12)
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }

                // Action Buttons
                HStack(spacing: 16) {
                    Button(action: onCancel) {
                        Label("Cancel", systemImage: "xmark")
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    .controlSize(.large)

                    Button(action: onConfirm) {
                        Label("Confirm & Send", systemImage: "paperplane.fill")
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .controlSize(.large)
                }
                .padding([.horizontal, .bottom])
            }
            .navigationTitle("Review Ticket")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if let user = Auth.auth().currentUser {
                    self.userName = user.displayName ?? "SnapSolve User"
                }
            }
        }
    }
}

// MARK: - Subviews

private struct InfoRow: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
        }
    }
}

private struct AnnotatedLocation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

// MARK: - Preview

struct TicketView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleAnalysis = AnalysisResult(
            description: "Large pothole on Charles E. Young Drive West",
            recommendation: "Notify UCLA Facilities Management",
            email: "facilities@ucla.edu"
        )
        let sampleTicket = Ticket(
            id: "ticket_12345",
            imageData: UIImage(systemName: "photo")!.pngData()!,
            location: CLLocationCoordinate2D(latitude: 34.0689, longitude: -118.4452),
            analysis: sampleAnalysis
        )
        TicketView(ticket: sampleTicket)
    }
}
