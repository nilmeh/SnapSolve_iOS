//
//  IssuesMapView.swift
//  SnapSolve
//

import SwiftUI
import MapKit
import CoreLocation
import FirebaseAuth

struct IssuesMapView: View {
    @State private var reports: [Report] = []
    @State private var selectedReport: Report?
    @State private var isShowingDetail = false
    @State private var isLoading = false
    @State private var userLocation: CLLocationCoordinate2D?
    @State private var showingProfile = false
    @EnvironmentObject var sessionManager: SessionManager
    @State private var mapPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 34.05, longitude: -118.25),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Map(position: $mapPosition, interactionModes: .all) {
                    UserAnnotation()
                    
                    ForEach(reports, id: \.id) { report in
                                            Annotation(
                                                "", // Empty title to avoid displaying ID
                                                coordinate: CLLocationCoordinate2D(
                                                    latitude: report.location.latitude,
                                                    longitude: report.location.longitude
                                                )
                                            ) {
                                                MapPinView {
                                                    selectedReport = report
                                                    isShowingDetail = true
                                                }
                                            }
                                        }
                }
                .mapControls { MapUserLocationButton() }
                .ignoresSafeArea(edges: .top)
                .onAppear {
                    Task {
                        await fetchReports()
                        updateUserLocation()
                    }
                }
                .navigationDestination(isPresented: $isShowingDetail) {
                    if let report = selectedReport {
                        ViewTicketDetailView(report: report)
                    }
                }

                Button {
                    if let loc = userLocation {
                        withAnimation {
                            mapPosition = .region(
                                MKCoordinateRegion(
                                    center: loc,
                                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                )
                            )
                        }
                    }
                } label: {
                    Image(systemName: "location.fill")
                        .font(.title3)
                        .padding(10)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 40)

                if isLoading {
                    Color.black.opacity(0.25).ignoresSafeArea()
                    ProgressView()
                        .scaleEffect(1.5)
                }
            }
            .navigationTitle("All Reports")
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
        }
    }

    private func fetchReports() async {
        guard let url = URL(string: "https://940f-131-179-132-163.ngrok-free.app/api/tickets/all") else {
            print("❌ Invalid URL")
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let (rawData, _) = try await URLSession.shared.data(from: url)
            
            let decoder = JSONDecoder()
            reports = try decoder.decode([Report].self, from: rawData)
            print("✅ Successfully decoded \(reports.count) reports")
            
        } catch {
            print("Error fetching reports:", error.localizedDescription)
        }
    }

    private func updateUserLocation() {
        if let coord = CLLocationManager().location?.coordinate {
            userLocation = coord
        }
    }
}

// MARK: — Map Pin Subview
private struct MapPinView: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "mappin.circle.fill")
                .font(.title2)
                .foregroundColor(.red)
                .background(
                    Circle()
                        .fill(Color.white)
                        .frame(width: 30, height: 30)
                        .shadow(radius: 2)
                )
        }
    }
}
