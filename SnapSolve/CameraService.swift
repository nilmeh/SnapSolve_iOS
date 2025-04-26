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
    
    // 🛠 Keep a reference to the last delegate
    private var photoCaptureDelegate: AVCapturePhotoCaptureDelegate?
    
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
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }
    
    func capturePhoto(completion: @escaping (Data?) -> Void) {
        let settings = AVCapturePhotoSettings()
        settings.isAutoStillImageStabilizationEnabled = true

        let delegate = PhotoCaptureDelegate(completion: { [weak self] data in
            completion(data)
            self?.photoCaptureDelegate = nil // clear reference after capture finishes
        })
        
        self.photoCaptureDelegate = delegate
        output.capturePhoto(with: settings, delegate: delegate)
    }
    
    private class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
        let completion: (Data?) -> Void
        init(completion: @escaping (Data?) -> Void) {
            self.completion = completion
        }
        
        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            if let error = error {
                print("Photo capture error: \(error)")
                completion(nil)
                return
            }
            guard let data = photo.fileDataRepresentation() else {
                completion(nil)
                return
            }
            completion(data)
        }
    }
}
