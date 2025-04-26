//
//  CameraService.swift
//  SnapSolve
//
//  Created by Niloy Meharchandani on 25/04/25.
//


// CameraService.swift
import Foundation
import AVFoundation
import UIKit

class CameraService: NSObject, ObservableObject {
    let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()

    func configure() {
        session.beginConfiguration()
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else {
            session.commitConfiguration()
            return
        }
        if session.canAddInput(input) {
            session.addInput(input)
        }
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        session.sessionPreset = .photo
        session.commitConfiguration()
        session.startRunning()
    }

    func capturePhoto(completion: @escaping (Data?) -> Void) {
        let settings = AVCapturePhotoSettings()
        settings.isAutoStillImageStabilizationEnabled = true
        output.capturePhoto(with: settings, delegate: PhotoCaptureDelegate(completion: completion))
    }

    private class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
        let completion: (Data?) -> Void
        init(completion: @escaping (Data?) -> Void) {
            self.completion = completion
        }
        func photoOutput(_ output: AVCapturePhotoOutput,
                         didFinishProcessingPhoto photo: AVCapturePhoto,
                         error: Error?) {
            guard error == nil,
                  let data = photo.fileDataRepresentation() else {
                completion(nil)
                return
            }
            completion(data)
        }
    }
}