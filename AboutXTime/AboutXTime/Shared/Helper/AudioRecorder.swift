//
//  AudioRecorder.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/13.
//

import SwiftUI
import AVFoundation
import AVKit

class AudioRecorder: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var audioURL: URL?
    @Published var recordingTime: TimeInterval = 0
    @Published var isAudioPlaying = false
    @Published var playbackTime: TimeInterval = 0
    @Published var audioDuration: TimeInterval = 0

    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var playbackTimer: Timer?
    private var recordingTimer: Timer?
    var recordingFinished: ((URL?) -> Void)?
    private let maxRecordingDuration: TimeInterval = 300
    private var isPaused: Bool = false

    override init() {
        super.init()
    }

    // 配置錄音環境
    private func setupAudioSessionForRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true, options: [])
        } catch {
            print("Failed to set up audio session for recording: \(error.localizedDescription)")
        }
    }

    // 配置播放環境
    private func setupAudioSessionForPlayback() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true, options: [])
        } catch {
            print("Failed to set up audio session for playback: \(error.localizedDescription)")
        }
    }

    func setAudioDuration(from url: URL) {
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            DispatchQueue.main.async {
                self.audioDuration = player.duration
            }
        } catch {
            print("Failed to get audio duration: \(error.localizedDescription)")
        }
    }

    func reset() {
        if let url = audioURL {
            do {
                try FileManager.default.removeItem(at: url)
                print("Deleted audio file at: \(url)")
            } catch {
                print("Failed to delete audio file: \(error.localizedDescription)")
            }
        }

        audioRecorder?.stop()
        audioPlayer?.stop()
        audioRecorder = nil
        audioPlayer = nil
        stopRecordingTimer()
        stopPlaybackTimer()

        DispatchQueue.main.async {
            self.audioURL = nil
            self.isRecording = false
            self.isAudioPlaying = false
            self.isPaused = false
            self.recordingTime = 0
            self.playbackTime = 0
            self.audioDuration = 0
        }

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false, options: [])
        } catch {
            print("Failed to deactivate audio session in reset: \(error.localizedDescription)")
        }
    }
}

extension AudioRecorder: AVAudioRecorderDelegate {
    func startRecording() {
        let audioApplication = AVAudioApplication.shared
        switch audioApplication.recordPermission {
        case .granted:
            beginRecording()
        case .denied:
            print("Audio recording permission denied.")
        case .undetermined:
            AVAudioApplication.requestRecordPermission { [weak self] allowed in
                if allowed {
                    self?.beginRecording()
                } else {
                    print("User denied audio recording permission.")
                }
            }
        @unknown default:
            break
        }
    }

    func beginRecording() {
        if let recorder = audioRecorder {
            recorder.stop()
            audioRecorder = nil
        }

        setupAudioSessionForRecording()

        let fileName = "recording-\(UUID().uuidString).m4a"
        let tempDirectory = FileManager.default.temporaryDirectory
        let audioFilename = tempDirectory.appendingPathComponent(fileName)
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            if audioRecorder?.prepareToRecord() == true {
                audioRecorder?.record(forDuration: maxRecordingDuration)
                print("Recording started successfully")
                DispatchQueue.main.async {
                    self.isRecording = true
                    self.recordingTime = 0
                    self.startRecordingTimer()
                }
            } else {
                print("Failed to prepare for recording.")
                DispatchQueue.main.async {
                    self.isRecording = false
                }
            }
        } catch {
            print("Could not start recording: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.isRecording = false
            }
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        stopRecordingTimer()
        DispatchQueue.main.async {
            self.isRecording = false
        }

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false, options: [])
        } catch {
            print("Failed to deactivate audio session after recording: \(error.localizedDescription)")
        }
    }

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("audioRecorderDidFinishRecording called, flag: \(flag)")
        DispatchQueue.main.async {
            if flag {
                self.audioURL = recorder.url
                do {
                    let attributes = try FileManager.default.attributesOfItem(atPath: recorder.url.path)
                    if let fileSize = attributes[.size] as? UInt64, fileSize > 0 {
                        self.recordingFinished?(recorder.url)
                        self.setAudioDuration(from: recorder.url)
                    } else {
                        print("Recording file is empty.")
                        self.audioURL = nil
                    }
                } catch {
                    print("Failed to get file attributes: \(error.localizedDescription)")
                    self.audioURL = nil
                }
            } else {
                print("Recording failed")
                self.audioURL = nil
            }
            self.isRecording = false
            self.stopRecordingTimer()
        }
    }

    private func startRecordingTimer() {
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.recordingTime += 1
            }
        }
    }

    private func stopRecordingTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
    }
}

extension AudioRecorder: AVAudioPlayerDelegate {
    private func startPlaybackTimer() {
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.audioPlayer else { return }
            DispatchQueue.main.async {
                self.playbackTime = player.currentTime
            }
        }
    }

    private func stopPlaybackTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }

    func seek(to time: TimeInterval) {
        audioPlayer?.currentTime = time
        playbackTime = time
        if isAudioPlaying {
            audioPlayer?.play()
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isAudioPlaying = false
            self.isPaused = false
            self.stopPlaybackTimer()
            self.playbackTime = 0
        }

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false, options: [])
        } catch {
            print("Failed to deactivate audio session after playback: \(error.localizedDescription)")
        }
    }

    func playAudio(url: URL) {
        if isAudioPlaying {
            pauseAudio()
        } else {
            if let player = audioPlayer, isPaused {
                player.play()
                isPaused = false
                startPlaybackTimer()
                isAudioPlaying = true
            } else {
                if url.isFileURL {
                    playAudioFromLocalURL(url)
                } else {
                    downloadAndPlayAudio(from: url)
                }
            }
        }
    }

    private func playAudioFromLocalURL(_ url: URL) {
        guard FileManager.default.fileExists(atPath: url.path) else {
            print("Audio file does not exist at path: \(url.path)")
            return
        }

        setupAudioSessionForPlayback()

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.volume = 1.0
            audioPlayer?.prepareToPlay()
            audioPlayer?.delegate = self

            DispatchQueue.main.async {
                self.audioDuration = self.audioPlayer?.duration ?? 0
                self.playbackTime = 0
                self.audioPlayer?.play()
                self.isAudioPlaying = true
                self.startPlaybackTimer()
            }
        } catch {
            print("Audio playback error: \(error.localizedDescription)")
        }
    }

    private func downloadAndPlayAudio(from url: URL) {
        URLSession.shared.downloadTask(with: url) { [weak self] localURL, _, error in
            if let error = error {
                print("Failed to download audio: \(error.localizedDescription)")
                return
            }

            guard let localURL = localURL else {
                print("Unable to get local URL")
                return
            }

            self?.playAudioFromLocalURL(localURL)
        }.resume()
    }

    private func pauseAudio() {
        audioPlayer?.pause()
        isPaused = true
        isAudioPlaying = false
        stopPlaybackTimer()
    }
}
