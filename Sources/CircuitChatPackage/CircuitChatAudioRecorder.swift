//
//  CircuitChatAudioRecorder.swift
//  Chat
//
//  Created by Apple on 26/09/23.
//

import AVFoundation

class CircuitChatAudioRecorder: NSObject, ObservableObject, AVAudioRecorderDelegate {
    private var audioRecorder: AVAudioRecorder?
    var isRecording = false
    
    var audioURL: URL?

    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)

            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            audioRecorder = try AVAudioRecorder(url: audioFileURL(), settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            isRecording = true
        } catch {
            print("Error setting up audio recording: \(error.localizedDescription)")
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
    }

    private func audioFileURL() -> URL {
        let dirPaths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docsDir = dirPaths[0]
        let filename = "audioRecording.m4a"
        audioURL = docsDir.appendingPathComponent(filename)
        return audioURL!
    }
}

