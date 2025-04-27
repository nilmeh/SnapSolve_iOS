import SwiftUI
import MapKit

struct IssuesMapView: View {
    @State private var reports: [Report] = []
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 34.05, longitude: -118.25),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var selected: Report?

    var body: some View {
        ZStack {
            Map(coordinateRegion: $region,
                annotationItems: reports) { report in
                MapAnnotation(
                    coordinate: CLLocationCoordinate2D(
                        latitude: report.location.latitude,
                        longitude: report.location.longitude
                    )
                ) {
                    Button {
                        selected = report
                    } label: {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title2)
                            .foregroundColor(.red)
                    }
                }
            }
            .ignoresSafeArea()
            .onAppear {
                Task { await fetchReports() }
            }

            if let rpt = selected {
                ReportDetailView(report: rpt) {
                    selected = nil
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    private func fetchReports() async {
        guard let url = URL(string: "https://YOUR_NGROK_URL/api/tickets") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            reports = try JSONDecoder().decode([Report].self, from: data)
        } catch {
            print("Error loading issues:", error)
        }
    }
}

struct ReportDetailView: View {
    let report: Report
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .padding()
                }
            }

            Text(report.problem_description)
                .font(.headline)
                .padding(.horizontal)

            Text(report.recommendation)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            if let data = Data(base64Encoded: report.imageBase64),
               let ui = UIImage(data: data) {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(12)
                    .padding()
            }

            Spacer()
        }
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .padding()
    }
}