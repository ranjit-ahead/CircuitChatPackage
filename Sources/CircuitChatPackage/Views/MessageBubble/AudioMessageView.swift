//
//  AudioMessageView.swift
//  Chat
//
//  Created by Apple on 26/09/23.
//

import SwiftUI
import AVKit

struct AudioMessageView: View {
    
    @State private var isPlaying = false
    @State private var player: AVPlayer?
    @State private var currentTime: Double = 0
    @State private var duration: Double = 1.0 //By default value to resolve error Range requires lowerBound <= upperBound
    
    var playbackSpeedOptions: [Float] = [1, 1.5, 2] // Available playback speed options
    @State private var currentSpeedIndex = 0 // Index of the currently selected playback speed
    
    var formattedPlaybackSpeed: String {
        // Format the playback speed for display
        let speed = playbackSpeedOptions[currentSpeedIndex]
        if speed == 1.0 || speed == 2.0 {
            return "\(Int(speed))x"
        } else {
            return String(format: "%.1fx", speed)
        }
    }
    
    let audioURL: URL
    
    var body: some View {
        HStack(spacing: 5) {
            Button(action: {}) {
                Image(systemName: isPlaying ? "pause.circle" : "play.circle")
                    .resizable()
                    .foregroundColor(.blue)
            }
            .onTapGesture(perform: {
                let cmTime = CMTime(seconds: currentTime, preferredTimescale: (player?.currentItem?.duration.timescale)!)
                player?.seek(to: cmTime, toleranceBefore: cmTime, toleranceAfter: cmTime)
                if isPlaying {
                    player?.pause()
                } else {
                    player?.play()
                    player?.rate = playbackSpeedOptions[currentSpeedIndex]
                }
                isPlaying.toggle()
            })
            .frame(width: 19, height: 19)
            
            if let player = player {
                AudioPlayerView(player: player, isPlaying: $isPlaying, currentTime: $currentTime, duration: $duration)
//                    .onAppear {
//                        player.play()
//                        player.rate = playbackSpeedOptions[currentSpeedIndex] // Set the initial playback speed
//                        isPlaying = true
//                    }
            }
            
            Button(action: {}) {
                ZStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 30, height: 18)
                        .background(.black.opacity(0.41))
                        .cornerRadius(50)
                    Text(formattedPlaybackSpeed)
                        .font(.regularPoppins(10))
                        .foregroundColor(.white)
                }
            }
            .onTapGesture(perform: {
                togglePlaybackSpeed()
            })
            .frame(width: 30, height: 18)
        }
        .padding()
        .onAppear {
            player = AVPlayer(url: audioURL)
            print(CMTimeGetSeconds(self.player?.currentItem?.duration ?? CMTime()))
            player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: DispatchQueue.main) { time in
                let currentTime = CMTimeGetSeconds(time)
                let duration = CMTimeGetSeconds(self.player?.currentItem?.duration ?? CMTime())
                self.currentTime = currentTime
                self.duration = duration
            }
        }
    }
    func togglePlaybackSpeed() {
        // Cycle through playback speed options in a loop
        currentSpeedIndex += 1
        if currentSpeedIndex >= playbackSpeedOptions.count {
            currentSpeedIndex = 0
        }
        if isPlaying {
            player?.rate = playbackSpeedOptions[currentSpeedIndex]
        }
    }
}

struct AudioMessageView_Previews: PreviewProvider {
    static var previews: some View {
        AudioMessageView(audioURL: URL(string: "http://snschatapp.s3.ap-south-1.amazonaws.com/uploads/media/2023/9/25/1695648131643-48483479.mp3")!)
    }
}


struct AudioPlayerView: View {
    var player: AVPlayer
    @Binding var isPlaying: Bool
    @Binding var currentTime: Double
    @Binding var duration: Double
    
    var formattedTime: String {
        let minutes = currentTime / 60
        let seconds = Int(currentTime.truncatingRemainder(dividingBy: 60.0))
        return String(format: "%02d", minutes) + String(format: ":%02d", seconds)
    }
    
    var body: some View {
        VStack {
            if duration > 0 {
                Slider(value: $currentTime, in: 0...duration)
                    .padding(.horizontal)
            }
//            formatTime(seconds: currentTime) + " / " + formatTime(seconds: duration)
            Text(formattedTime)
                .font(.caption)
                .padding(.bottom, 20)
        }
    }
    
    func formatTime(seconds: Double) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        return formatter.string(from: TimeInterval(seconds)) ?? "0:00"
    }
}
