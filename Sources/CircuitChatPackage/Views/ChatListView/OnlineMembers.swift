//
//  OnlineMembers.swift
//  Chat
//
//  Created by Apple on 20/08/23.
//

import SwiftUI

struct OnlineMembers: View {
    
    var userImage: String?
    var userName: String
    var isVerified = false
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottomTrailing) {
                ImageDownloader(userImage, systemImage: "person.crop.circle")
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 70, height: 70)
                    .clipShape(Circle())

                Circle()
                    .strokeBorder(Color(UIColor.systemBackground), lineWidth: 3)
                    .background(Circle().fill((Color(red: 0.35, green: 0.83, blue: 0.22))))
                    .frame(width: 18, height: 18)
            }

            ChatName(name: userName, font: .regularFont(15), verified: isVerified, iconSize: 18)
                .frame(width: 70)
        }
    }
}

struct OnlineMembers_Previews: PreviewProvider {
    static var previews: some View {
        OnlineMembers(userImage: "https://picsum.photos/200", userName: "Rohan")
    }
}
