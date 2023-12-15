//
//  StarredMessage.swift
//  Chat
//
//  Created by Apple on 03/11/23.
//

import SwiftUI

struct StarredMessage: View {
    
    var chatId: String?
    var chatName: String?
    var chatType: String?
    
    @StateObject private var observed = Observed()
    
    @State private var scrollToMessage = ""
    
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        NavigationStack {
            VStack(spacing:0) {
                ScrollView {
                    ScrollViewReader { scrollReader in
                        if let _ = observed.userChatDataArray {
                            getMessagesView()
                                .padding(.horizontal)
                        } else {
                            VStack {
                                Image("star", bundle: .module)
                                    .imageIconModifier(imageSize: 48, iconSize: 110, color: Color(red: 0.95, green: 0.95, blue: 0.95))
                                Text("No Starred Message")
                                    .font(.semiBoldFont(20))
                                Text("Tap and hold on any message to star it, so you can easily find it later.")
                                    .font(.regularFont(14))
                                    .foregroundColor(Color(red: 0.31, green: 0.33, blue: 0.36))
                                    .multilineTextAlignment(.center)
                            }.padding()
                        }
                    }
                }
                
                if editMode == .active {
                    HStack {
                        
                        //FORWARD MESSAGE
                        Button {
                            
                        } label: {
                            Image(systemName: "arrowshape.turn.up.right")
                                .imageIconModifier(imageSize: 24, iconSize: 46, imageColor: Color(.label) , color: Color(.systemGray6))
                        }
                        
                        Spacer()
                        
                        //STAR SELECTED MESSAGE
                        Button {
                            if let data = observed.userChatDataArray {
                                let chatIDs = data.filter{ $0.isSelected ?? false }.map{ $0 }
                                observed.starredMessage(chatIDs)
                            }
                        } label: {
                            Image(systemName: "star.slash")
                                .imageIconModifier(imageSize: 24, iconSize: 46, imageColor: Color(.label) , color: Color(.systemGray6))
                        }
                        Spacer()
                        
                        //SHARE BUTTON
                        Button {
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .imageIconModifier(imageSize: 24, iconSize: 46, imageColor: Color(.label) , color: Color(.systemGray6))
                        }
                        
                        Spacer()
                        
                        //DELETE BUTTON
                        Button {
                        } label: {
                            Image(systemName: "trash")
                                .imageIconModifier(imageSize: 24, iconSize: 46, imageColor: Color(.label) , color: Color(.systemGray6))
                        }
                        
                    }
                    .padding(.horizontal)
                    .background(.ultraThinMaterial)
                    .overlay(Rectangle().frame(height: 0.2).foregroundColor(Color.gray), alignment: .top)
//                    .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: -5)
                    .onAppear {
                        UIView.setAnimationsEnabled(false)
                    }
                }
            }
            .navigationTitle("Starred Message")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if let _ = observed.userChatDataArray {
                        Button {
                            editMode.toggle()
                        } label: {
                            Text(editMode == .active ? "Done" : "Edit").font(.regularFont(16)).foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            observed.fetchChatMessages(id: chatId ?? "", type: chatType ?? "")
        }
    }
    
    func getMessagesView() -> some View {
        return LazyVStack {
            if let userChatDataArray = observed.userChatDataArray {
                ForEach(userChatDataArray) { chat in
                    
                    HStack {
                        if editMode == .active {
                            if chat.isSelected ?? false {
                                Image("selectedTickIcon", bundle: .module)
                                    .imageIconModifier(imageSize: 14, iconSize: 24, imageColor: Color.white, color: .blue)
                            } else {
                                Circle()
                                    .strokeBorder(Color(UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1)), lineWidth: 2)
                                    .frame(width: 24, height: 24)
                            }
                        }
                        
                        VStack {
                            
                            if let senderName = chat.sender == circuitChatUID ? "You" : chat.senderDetails?.name, senderName != "" {
                                HStack {
                                    if let avatar = chat.senderDetails?.avatar, avatar != "" {
                                        ImageDownloader(avatar)
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 36, height: 36)
                                            .clipShape(Circle())
                                    }

                                    Text(senderName)
                                        .font(.regularFont(12))

                                    if let receiverName = chat.receiverDetails?.name, receiverName != "" {
                                        Image(systemName: "arrowtriangle.right.fill")
                                            .resizable()
                                            .frame(width: 5, height: 5)
                                            .foregroundColor(Color(.lightGray))

                                        Text(receiverName)
                                            .font(.regularFont(12))
                                            .foregroundColor(Color(.darkGray))

                                    }

                                    Spacer()

                                    Text(chat.createdAt?.chatDateFormat ?? "")
                                        .font(.regularFont(12))
                                        .foregroundColor(Color(.darkGray))
                                }
                                .lineLimit(1)
                                .padding(.top, 5)
                                .padding(.leading, 5)
                                .padding(.trailing, 5)
                            }
                            
                            let avatar = chat.senderDetails?.avatar
                            MessageView(starredMessageView: true, chatDetail: chat, chatName: chatName ?? "", chatType: chatType ?? "", scrollToMessageId: $scrollToMessage)
                                .contentShape(ContentShapeKinds.contextMenuPreview, RoundedRectangle(cornerRadius: 8))
                                .frame(maxWidth: .infinity, alignment: chat.sender==circuitChatUID ? .trailing : .leading)
                                .padding(chat.sender==circuitChatUID ? .leading : .trailing, (UIScreen.screenWidth*1)/7)
                                .padding(.horizontal, 7)
                                .padding(.bottom, (avatar == "" && chat.sender != circuitChatUID) ? 0 : 8)
//                                .id(chat.id)
                            
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if editMode == .active {
                            if let index = userChatDataArray.firstIndex(of: chat) {
                                observed.userChatDataArray?[index].isSelected = !(chat.isSelected ?? false)
                            }
                        }
                    }
                }
            }
        }
    }
    
}

struct StarredMessage_Previews: PreviewProvider {
    static var previews: some View {
        StarredMessage()
    }
}
