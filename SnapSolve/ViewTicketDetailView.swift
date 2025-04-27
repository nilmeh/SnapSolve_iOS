// ViewTicketDetailView.swift
import SwiftUI
import MapKit

struct ViewTicketDetailView: View {
    let report: Report

    @State private var mapRegion: MKCoordinateRegion

    init(report: Report) {
        self.report = report
        _mapRegion = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: report.location.latitude,
                longitude: report.location.longitude
            ),
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        ))
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let imageData = Data(base64Encoded: report.imageBase64),
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 220)
                            .clipped()
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        InfoRow(title: "Issue Description", value: report.problem_description)
                        InfoRow(title: "Recommendation", value: report.recommendation)
                        InfoRow(title: "Contact Email", value: report.email)

                        Map(coordinateRegion: $mapRegion, annotationItems: [AnnotatedLocation(coordinate: mapRegion.center)]) { loc in
                            MapMarker(coordinate: loc.coordinate, tint: .red)
                        }
                        .frame(height: 140)
                        .cornerRadius(12)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Ticket Details")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

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
