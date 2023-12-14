//
//  ShowCustomDialogSheet.swift
//  Chat
//
//  Created by Apple on 01/11/23.
//

import SwiftUI

struct ShowCustomDialogSheet<Content: View>: View {
    
    @State private var showSheet: Bool = true
    var action: () -> Void
    @ViewBuilder var content: Content
    
    var body: some View {
        CustomDialog(isPresented: $showSheet, bodyContent: {
            content
        }, cancelContent: {
            Button {
                action()
            } label: {
                HStack {
                    Spacer()
                    Text("Cancel")
                        .font(.semiBoldFont(16))
                    Spacer()
                }
                .foregroundColor(Color(.label))
                .accentColor(.black)
                .padding()
                .background(Color(.tertiarySystemBackground))
                .frame(height: 53)
            }.background(Color(.tertiarySystemBackground)).cornerRadius(10)
        })
        .background(BackgroundBlurView())
        .background { Color.black.opacity(0.25).edgesIgnoringSafeArea(.all) }
        .onAppear {
            UIView.setAnimationsEnabled(false)
        }
    }
}
