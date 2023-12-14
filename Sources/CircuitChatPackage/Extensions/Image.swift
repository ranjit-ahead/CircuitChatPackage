//
//  Image.swift
//  Chat
//
//  Created by Apple on 01/11/23.
//

import SwiftUI

extension Image {
    
    func imageIconModifier(imageSize: CGFloat, iconSize: CGFloat, imageColor: Color? = nil, color: Color) -> some View {
        self
            .renderingMode(imageColor==nil ? .original : .template)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: imageSize, height: imageSize)
            .padding()
            .foregroundColor(imageColor)
            .background(color)
            .frame(width: iconSize, height: iconSize)
            .clipShape(Circle())
    }
}
