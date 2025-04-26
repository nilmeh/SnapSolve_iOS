//
//  ContentView.swift
//  SnapSolve
//
//  Created by Niloy Meharchandani on 25/04/25.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var cameraService = CameraService()
    @StateObject private var locationManager = LocationManager()
    @State private var result: AnalysisResult?
    @State private var ticket: Ticket?
    @State private var showTicket = false
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
                    print("No camera access")
                }
            }
            locationManager.requestPermission()
        }

        .sheet(item: $ticket) { ticket in
            TicketView(ticket: ticket)
        }

    }

    func capture() {
        isProcessing = true
        cameraService.capturePhoto { data in
            guard let data = data else {
                isProcessing = false
                return
            }
            let location = locationManager.lastLocation
            
            GeminiService.analyze(imageData: data) { result in
                isProcessing = false
                switch result {
                case .success(let analysis):
                    let id = UUID().uuidString
                    ticket = Ticket(
                        id: id,
                        imageData: data,
                        location: location,
                        analysis: analysis
                    )
                    showTicket = true

                case .failure(let error):
                    print("Failed to analyze image: \(error.localizedDescription)")
                    // Optional: show an alert if you want
                }
            }
        }
    }
}


#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
