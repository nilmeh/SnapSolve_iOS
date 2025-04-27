//
//  CameraService.swift
//  SnapSolve
//
//  Created by Niloy Meharchandani on 25/04/25.
//


import Foundation
import AVFoundation

class CameraService: NSObject, ObservableObject {
    let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()

    // NEW:
    @Published var zoomFactor: CGFloat = 1.0
    private var device: AVCaptureDevice?

    func configure() {
        session.beginConfiguration()
        guard
            let dev = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input = try? AVCaptureDeviceInput(device: dev)
        else {
            session.commitConfiguration()
            return
        }

        device = dev
        if session.canAddInput(input) { session.addInput(input) }
        if session.canAddOutput(output) { session.addOutput(output) }
        session.sessionPreset = .photo

        // initialize zoom
        do {
            try dev.lockForConfiguration()
            dev.videoZoomFactor = 1.0
            dev.unlockForConfiguration()
        } catch {
            print("Failed to set initial zoom: \(error)")
        }

        session.commitConfiguration()
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }

    func setZoom(factor: CGFloat) {
        guard let dev = device else { return }
        let clamped = min(max(factor, dev.minAvailableVideoZoomFactor), dev.maxAvailableVideoZoomFactor)
        do {
            try dev.lockForConfiguration()
            dev.videoZoomFactor = clamped
            dev.unlockForConfiguration()
            DispatchQueue.main.async {
                self.zoomFactor = clamped
            }
        } catch {
            print("Zoom error: \(error)")
        }
    }

    func capturePhoto(completion: @escaping (Data?) -> Void) {
        let settings = AVCapturePhotoSettings()
        settings.isAutoStillImageStabilizationEnabled = true
        let delegate = PhotoDelegate { data in
            completion(data)
            self.photoDelegate = nil
        }
        photoDelegate = delegate
        output.capturePhoto(with: settings, delegate: delegate)
    }

    private var photoDelegate: AVCapturePhotoCaptureDelegate?
    private class PhotoDelegate: NSObject, AVCapturePhotoCaptureDelegate {
        let callback: (Data?) -> Void
        init(callback: @escaping (Data?) -> Void) { self.callback = callback }
        func photoOutput(_ output: AVCapturePhotoOutput,
                         didFinishProcessingPhoto photo: AVCapturePhoto,
                         error: Error?) {
            guard error == nil, let data = photo.fileDataRepresentation() else {
                callback(nil); return
            }
            callback(data)
        }
    }
}
