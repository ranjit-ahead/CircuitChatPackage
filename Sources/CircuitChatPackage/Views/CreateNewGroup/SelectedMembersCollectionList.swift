//
//  SelectedMembersCollectionList.swift
//  Chat
//
//  Created by Apple on 20/09/23.
//

import SwiftUI

struct SelectedMembersCollectionList: View {
    
    let item: Chat
    
    @Binding var selections: [Chat]
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottomTrailing) {
                
                ZStack(alignment: .topTrailing) {
                    
                    ImageDownloader(item.avatar)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                    
                    Button {
                        selections.removeAll(where: { $0 == item })
                    } label: {
                        ZStack {
                            Circle()
                                .foregroundColor(.clear)
                                .background(.white)
                            Image(systemName: "plus")
                                .resizable()
                                .foregroundColor(.black)
                                .frame(width: 8, height: 8)
                                .rotationEffect(.degrees(45))
                        }
                    }
                    .cornerRadius(10)
                    .clipped()
                    .frame(width: 20, height: 20)
                    .shadow(color: Color(UIColor.label).opacity(0.11), radius: 1, x: 0, y: 0)
                }
                
                if item.active ?? false {
                    Circle()
                        .strokeBorder(Color(UIColor.systemBackground), lineWidth: 2.5)
                        .background(Circle().fill((Color(red: 0.35, green: 0.83, blue: 0.22))))
                        .frame(width: 14, height: 14)
                }
            }

            ChatName(name: item.name, font: .regularFont(15), verified: item.verified, iconSize: 19)
                .frame(width: 60)
        }
    }
}

//struct SelectedMembersCollectionList_Previews: PreviewProvider {
//    static var previews: some View {
//        SelectedMembersCollectionList()
//    }
//}
