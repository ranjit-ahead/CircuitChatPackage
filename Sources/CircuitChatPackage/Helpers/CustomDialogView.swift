//
//  CustomDialogView.swift
//  Chat
//
//  Created by Apple on 06/10/23.
//

import SwiftUI

struct CustomDialogData: Codable, Hashable {
    var image: String
    var text: String
}

struct CustomDialogView: View {
    var arrayData: [CustomDialogData]
    @Binding var cancelAction: Bool
    
    var body: some View {
        VStack {
            ForEach(arrayData, id: \.self) { customData in
                Button {
                    cancelAction.toggle()
                } label: {
                    HStack {
                        Image(systemName: customData.image)
                            .padding()
                            .background(Color(red: 0.96, green: 0.96, blue: 0.96))
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                        Text(customData.text)
                        Spacer()
                    }
                }
                Divider()
            }
        }
        .padding()
    }
}

//CustomDialogView(arrayData: [CustomDialogData(image: "person.crop.circle", text: "View Profile"), CustomDialogData(image: "envelope.badge", text: "Mark as read"), CustomDialogData(image: "speaker.slash", text: "Mute Notifications")], cancelAction: $showMoreOptions)
