//
//  HorizontalSeparatorView.swift
//  Chat
//
//  Created by Apple on 06/11/23.
//

import SwiftUI

struct HorizontalSeparatorView: View {
    
    var height: CGFloat
    
    init(_ height: CGFloat = 0.5) {
        self.height = height
    }
    
    var body: some View {
        Rectangle()
            .frame(height: height)
            .foregroundColor(Color(red: 0.87, green: 0.87, blue: 0.87))
    }
}

struct HorizontalSeparatorView_Previews: PreviewProvider {
    static var previews: some View {
        HorizontalSeparatorView(0.5)
    }
}
