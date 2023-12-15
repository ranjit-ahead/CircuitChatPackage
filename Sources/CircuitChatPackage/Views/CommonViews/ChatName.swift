//
//  VerifiedIcon.swift
//  Chat
//
//  Created by Apple on 13/10/23.
//

import SwiftUI

struct ChatName: View {
    
    var name: String
    var font: Font = .semiBoldFont(16)
    var color: Color = Color(.label)
    var lineLimit = 1
    
    var verified : Bool? = false
    var iconSize: CGFloat = 20
    
    var body: some View {
        HStack(spacing: 0) {
            Text(name)
                .font(font)
                .foregroundColor(color)
                .lineLimit(lineLimit)
            
            if verified ?? false {
                VerifiedIcon(width: iconSize, height: iconSize)
            }
        }
    }
}

struct VerifiedIcon: View {
    
    var width: CGFloat
    var height: CGFloat
     
    var body: some View {
        Rectangle()
            .foregroundColor(.clear)
            .frame(width: width, height: height)
            .background(
                Image("verifiedIcon", bundle: .module)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: height)
                    .clipped()
            )
    }
}

struct VerifiedIcon_Previews: PreviewProvider {
    static var previews: some View {
        VerifiedIcon(width: 20, height: 20)
    }
}
