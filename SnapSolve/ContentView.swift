// ContentView.swift
// SnapSolve

import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var cameraService = CameraService()
    @StateObject private var locationManager = LocationManager()
    @State private var ticket: Ticket?    // when non-nil, sheet appears
    @State private var isProcessing = false

    var body: some View {
        ZStack {
            CameraPreview(session: cameraService.session)
                .ignoresSafeArea()

            VStack {
                Spacer()
                if isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(2)
                        .padding(.bottom, 50)
                } else {
                    Button(action: capture) {
                        Circle()
                            .strokeBorder(Color.white, lineWidth: 4)
                            .frame(width: 70, height: 70)
                            .background(Circle().fill(Color.white.opacity(0.3)))
                    }
                    .padding(.bottom, 50)
                }
            }
        }
        .onAppear {
            Task {
                let granted = await AVCaptureDevice.requestAccess(for: .video)
                if granted {
                    cameraService.configure()
                } else {
                    print("Camera access denied")
                }
            }
            locationManager.requestPermission()
        }
        .sheet(item: $ticket) { ticket in
            TicketView(
                ticket: ticket,
                onConfirm: {
                    // Send to backend, then dismiss
                    BackendService.submitTicket(ticket: ticket) { result in
                        switch result {
                        case .success(let id):
                            print("Ticket submitted with ID: \(id)")
                        case .failure(let error):
                            print("Submit failed: \(error.localizedDescription)")
                        }
                        // Dismiss sheet regardless
                        self.ticket = nil
                    }
                },
                onCancel: {
                    // Simply dismiss without sending
                    self.ticket = nil
                }
            )
        }
    }

    func capture() {
        isProcessing = true
        cameraService.capturePhoto { data in
            guard let data = data else {
                isProcessing = false
                return
            }
            let loc = locationManager.lastLocation
            BackendService.analyze(imageData: data, location: loc) { result in
                isProcessing = false
                switch result {
                case .success(let analysis):
                    ticket = Ticket(
                        id: UUID().uuidString,
                        imageData: data,
                        location: loc,
                        analysis: analysis
                    )
                case .failure(let error):
                    print("Analysis failed: \(error.localizedDescription)")
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
