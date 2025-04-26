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
    private var photoDelegate: AVCapturePhotoCaptureDelegate?

    func configure() {
        session.beginConfiguration()
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else {
            session.commitConfiguration()
            return
        }
        if session.canAddInput(input) { session.addInput(input) }
        if session.canAddOutput(output) { session.addOutput(output) }
        session.sessionPreset = .photo
        session.commitConfiguration()
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
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
