//
//  VideoRecorderViewController.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/13.
//

import AVFoundation
import UIKit

class VideoRecorderViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    private let captureSession = AVCaptureSession()
    private var videoOutput: AVCaptureMovieFileOutput?
    private var outputURL: URL?
    private var isRecording = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
    }

    private func setupCaptureSession() {
        captureSession.sessionPreset = .high

        guard let videoDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }

        captureSession.addInput(videoInput)

        videoOutput = AVCaptureMovieFileOutput()
        if let videoOutput = videoOutput { 
            captureSession.addOutput(videoOutput)
        }

        captureSession.startRunning()
    }

    func startRecording() {
        guard !isRecording else { return }

        isRecording = true
        outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mov")
        if let outputURL = outputURL, let videoOutput = videoOutput {
            videoOutput.startRecording(to: outputURL, recordingDelegate: self)
        }
    }

    func stopRecording() {
        guard isRecording else { return }

        isRecording = false
        videoOutput?.stopRecording()
    }

    func fileOutput(_ output: AVCaptureFileOutput,
                    didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection],
                    error: Error?) {
    }
}
