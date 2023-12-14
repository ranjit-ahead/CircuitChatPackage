//
//  VerticalSeparatorView.swift
//  Chat
//
//  Created by Apple on 08/11/23.
//

import SwiftUI

struct VerticalSeparatorView: View {
    
    var width: CGFloat
    
    init(_ width: CGFloat = 0.5) {
        self.width = width
    }
    
    var body: some View {
        Rectangle()
            .frame(width: width)
            .foregroundColor(Color(red: 0.87, green: 0.87, blue: 0.87))
    }
}

struct VerticalSeparatorView_Previews: PreviewProvider {
    static var previews: some View {
        VerticalSeparatorView(0.5)
    }
}
