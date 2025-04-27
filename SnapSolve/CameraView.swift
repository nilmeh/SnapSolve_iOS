//
//  CameraView.swift
//  SnapSolve
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    @StateObject private var cameraService = CameraService()
    @StateObject private var locationManager = LocationManager()
    @State private var ticket: Ticket?
    @State private var isProcessing = false
    @State private var showingProfile = false
    @EnvironmentObject var sessionManager: SessionManager

    // track last scale so zoom is continuous
    @State private var lastScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // attach pinch gesture to the preview
            CameraPreview(session: cameraService.session)
                .ignoresSafeArea()
                .gesture(
                    MagnificationGesture()
                        .onChanged { scale in
                            let newFactor = lastScale * scale
                            cameraService.setZoom(factor: newFactor)
                        }
                        .onEnded { scale in
                            lastScale = cameraService.zoomFactor
                        }
                )

            VStack {
                Spacer()

                if isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                        .padding(.bottom, 100)
                } else {
                    Button(action: capture) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.3))
                                .frame(width: 80, height: 80)
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                            Circle()
                                .strokeBorder(Color.white, lineWidth: 4)
                                .frame(width: 70, height: 70)
                        }
                    }
                    .padding(.bottom, 115)
                }
            }
        }
        .navigationTitle("SnapSolve")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showingProfile.toggle() }
                label: {
                    Image(systemName: "person.crop.circle")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
        }
        .sheet(isPresented: $showingProfile) {
            ProfileView().environmentObject(sessionManager)
        }
        .onAppear {
            Task {
                if await AVCaptureDevice.requestAccess(for: .video) {
                    cameraService.configure()
                }
            }
            locationManager.requestPermission()
        }
        .sheet(item: $ticket) { selectedTicket in
            TicketView(
                ticket: selectedTicket,
                onConfirm: {
                    BackendService.submitTicket(ticket: selectedTicket) { result in
                        switch result {
                        case .success(let id):
                            print("Ticket submitted with ID: \(id)")
                        case .failure(let error):
                            print("Submit failed: \(error.localizedDescription)")
                        }
                        self.ticket = nil
                    }
                },
                onCancel: {
                    self.ticket = nil
                }
            )
        }
    }

    private func capture() {
        isProcessing = true
        cameraService.capturePhoto { data in
            defer { isProcessing = false }
            guard let data = data else { return }
            let loc = locationManager.lastLocation
            BackendService.analyze(imageData: data, location: loc) { result in
                if case .success(let analysis) = result {
                    ticket = Ticket(
                        id: UUID().uuidString,
                        imageData: data,
                        location: loc,
                        analysis: analysis
                    )
                }
            }
        }
    }
}
#Preview {
    CameraView()
        .environmentObject(SessionManager())
        .modelContainer(for: Item.self, inMemory: true)
}
