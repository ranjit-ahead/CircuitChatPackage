//
//  AddMembersViewRow.swift
//  Chat
//
//  Created by Apple on 19/09/23.
//

import SwiftUI

struct AddMembersViewRow: View {
    var item: Chat
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: self.action) {
            HStack {
                
                //Image
                ZStack(alignment: .bottomTrailing) {
                    
                    ImageDownloader(item.avatar)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 46, height: 46)
                        .clipShape(Circle())
                    
                    if item.active ?? false {
                        Circle()
                            .strokeBorder(Color(UIColor.systemBackground), lineWidth: 1.5)
                            .background(Circle().fill(.green))
                            .frame(width: 13, height: 13)
                    }
                }
                
                //Text
                VStack(alignment: .leading) {
                    ChatName(name: item.name, font: .semiBoldFont(15), verified: item.verified, iconSize: 20)
                        .padding(.top, 8.5)
                }
                Spacer()
                
                if self.isSelected {
                    Image("selectedTickIcon", bundle: .module)
                        .resizable()
                        .frame(width: 14, height: 14)
                        .background(content: {
                            Rectangle()
                                .foregroundColor(.clear)
                                .background(Color(red: 0.02, green: 0.49, blue: 0.99))
                                .cornerRadius(17)
                                .padding(EdgeInsets(top: -5, leading: -5, bottom: -5, trailing: -5))
                        })
                        .padding(.trailing, 20)
                } else {
                    Circle()
                        .strokeBorder(Color(UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1)), lineWidth: 2)
                        .frame(width: 22, height: 22)
                        .padding()
                }
            }
        }
    }
}

//struct AddMembersViewRow_Previews: PreviewProvider {
//    static var previews: some View {
//        AddMembersViewRow()
//    }
//}
