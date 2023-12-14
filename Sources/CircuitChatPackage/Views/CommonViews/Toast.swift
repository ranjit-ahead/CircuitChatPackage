//
//  Toast.swift
//  Chat
//
//  Created by Apple on 02/11/23.
//

import SwiftUI

struct Toast: View {
    
    @Binding var isShowing: String?
    
    var body: some View {
        if let showing = self.isShowing {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    self.isShowing = nil
                }
            }
        }
        return HStack {
            Image("checkCircleGreen")
                .imageIconModifier(imageSize: 24, iconSize: 24, color: Color.clear)
            Text(isShowing ?? "")
        }
        .padding()
        .background(Color(.label))
        .foregroundColor(Color(.systemBackground))
        .cornerRadius(50)
        .transition(.slide)
        .opacity(self.isShowing != nil ? 1 : 0)
        .background(BackgroundBlurView())
        .onAppear {
            UIView.setAnimationsEnabled(false)
        }
        .position(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height-140)
    }
}
