//
//  ShowVideo.swift
//  Chat
//
//  Created by Apple on 20/10/23.
//

import SwiftUI
import AVKit
import AVFoundation

struct ShowVideo: View {
    
    var url: String
    
    var body: some View {
        VideoPlayer(player: AVPlayer(url: URL(string: url)!))
    }
}

struct ShowVideo_Previews: PreviewProvider {
    static var previews: some View {
        ShowVideo(url: "http://snschatapp.s3.ap-south-1.amazonaws.com/uploads/media/2023/10/9/1696837134368-274672413.mp4")
    }
}
