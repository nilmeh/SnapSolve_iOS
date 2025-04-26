//
//  CameraPreview.swift
//  SnapSolve
//
//  Created by Niloy Meharchandani on 25/04/25.
//


// CameraPreview.swift
import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let view = PreviewUIView(session: session)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // No need to update frame here; handled in PreviewUIView
    }

    class PreviewUIView: UIView {
        private let previewLayer: AVCaptureVideoPreviewLayer

        init(session: AVCaptureSession) {
            self.previewLayer = AVCaptureVideoPreviewLayer(session: session)
            self.previewLayer.videoGravity = .resizeAspectFill
            self.previewLayer.connection?.videoOrientation = .portrait
            super.init(frame: .zero)
            self.layer.addSublayer(previewLayer)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            previewLayer.frame = bounds // Update frame when view lays out
        }
    }
}
