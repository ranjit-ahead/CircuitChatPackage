//
//  ChatItem.swift
//  Chat
//
//  Created by Apple on 21/08/23.
//

import SwiftUI

struct ChatItem: View {
    
    let apiResponse: LastChatResponse?
    let item: LastChatData?
    
    @Binding var editMode: EditMode
    
    var body: some View {
        if let item = item {
            HStack(spacing: 5) {
                
                if editMode == .active {
                    if item.isSelected ?? false {
                        Image("selectedTickIcon", bundle: .module)
                            .imageIconModifier(imageSize: 14, iconSize: 24, imageColor: Color.white, color: .blue)
                    } else {
                        Circle()
                            .strokeBorder(Color(UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1)), lineWidth: 2)
                            .frame(width: 24, height: 24)
                    }
                }
                
                //Image
                ZStack(alignment: .bottomTrailing) {
                    
                    ImageDownloader(item.chat.avatar, systemImage: "person.crop.circle")
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 54, height: 54)
                        .clipShape(Circle())
                    
                    if item.chat.active ?? false {
                        Circle()
                            .strokeBorder(Color(UIColor.systemBackground), lineWidth: 2)
                            .background(Circle().fill(.green))
                            .frame(width: 14, height: 14)
                    }
                }
                
                HStack(alignment: .top) {
                    
                    //Text
                    VStack(alignment: .leading, spacing: 4) {
                        ChatName(name: item.chat.name, verified: item.chat.verified)
                        
                        HStack(alignment: .top, spacing: 4) {
                            if let action = item.chat.action {
                                Text(action)
                                    .font(.semiBoldFont(14))
                                    .frame(height: 40, alignment: .top)
                            } else {
                                
                                //Message Status
                                VStack {
                                    if (item.senderDetails?.id == circuitChatUID) || (item.fromMe ?? false) {
                                        if let messageStatus = item.userChatData?.messageStatus {
                                            if messageStatus == 2 {
                                                Image("receivedStatusIcon", bundle: .module)
                                                    .resizable()
                                                    .frame(width: 13.97447, height: 8)
                                            } else if messageStatus == 3 {
                                                Image("seenStatusIcon", bundle: .module)
                                                    .resizable()
                                                    .frame(width: 13.97447, height: 8)
                                            } else {
                                                Image("sentStatusIcon", bundle: .module)
                                                    .resizable()
                                                    .frame(width: 12.22766, height: 7)
                                            }
                                        } else {
                                            Image("sentStatusIcon", bundle: .module)
                                                .resizable()
                                                .frame(width: 12.22766, height: 7)
                                        }
                                    }
                                }.padding(.top, 5)
                                
                                HStack {
                                    
                                    let userChatData = item.userChatData
                                    
                                    let youText = apiResponse?.menu.you ?? "You"
                                    let userName = item.senderDetails?.id==circuitChatUID ? youText : (item.senderDetails?.name ?? "")
                                    let user = item.chat.chatType == "group" ? "\(userName == "" ? "" : userName+": ")" : ""
                                    
                                    let image =
                                    userChatData?.contentType == ContentType.image.rawValue ? Image(systemName: "camera.fill") :
                                    userChatData?.contentType == ContentType.video.rawValue ? Image(systemName: "video.fill") :
                                    userChatData?.contentType == ContentType.audio.rawValue ? Image(systemName: "mic.fill") :
                                    userChatData?.contentType == ContentType.application.rawValue ? Image(systemName: "doc.fill") :
                                    userChatData?.contentType == ContentType.contact.rawValue ? Image(systemName: "person.circle.fill") :
                                    userChatData?.contentType == ContentType.location.rawValue ? Image(systemName: "location.fill") : Image(systemName: "")
                                    
                                    let photoText = apiResponse?.menu.photo ?? "Photo"
                                    let videoText = apiResponse?.menu.video ?? "Video"
                                    let audioText = apiResponse?.menu.audio ?? "Audio"
                                    let documentText = apiResponse?.menu.document ?? "Document"
                                    let locationText = apiResponse?.menu.location ?? "Location"
                                    
                                    let text =
                                    userChatData?.contentType == ContentType.image.rawValue ? photoText :
                                    userChatData?.contentType == ContentType.video.rawValue ? videoText :
                                    userChatData?.contentType == ContentType.audio.rawValue ? audioText :
                                    userChatData?.contentType == ContentType.application.rawValue ? documentText :
                                    userChatData?.contentType == ContentType.contact.rawValue ? (userChatData?.contact?.first?.name ?? "") :
                                    userChatData?.contentType == ContentType.location.rawValue ? locationText : ""
                                    
                                    Text(user) + (text != "" ? (Text(image) + Text(" ")) : Text("")) + Text(userChatData?.text ?? text)
                                }
                                .font(.regularFont(14))
                                .foregroundColor(Color(red: 0.43, green: 0.43, blue: 0.43))
                                .lineLimit(2)
                                .frame(height: 40, alignment: .top)
                            }
                        }
                    }.padding(.leading, 5)
                    
                    Spacer()
                    
                    //Time & Notifications
                    VStack(alignment: .trailing, spacing: 7) {
                        if let createdAt = item.userChatData?.createdAt {
                            if (item.unread) > 0 {
                                Text("\(createdAt.readableDateFormat)")
                                    .font(.regularFont(14))
                                    .foregroundColor(Color(red: 0.02, green: 0.49, blue: 0.99))
                            } else {
                                Text("\(createdAt.readableDateFormat)")
                                    .font(.regularFont(14))
                                    .foregroundColor(Color(red: 0.44, green: 0.44, blue: 0.44))
                            }
                        }
                        
                        HStack {
                            if item.pin ?? false {
                                Image("pin", bundle: .module)
                                    .resizable()
                                    .frame(width: 17, height: 17)
                            }
                            if item.mute ?? false {
                                Image("mute", bundle: .module)
                                    .resizable()
                                    .frame(width: 17, height: 17)
                            }
                            if item.unread>0 {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: 22, height: 22)
                                    .background(Color(red: 0.02, green: 0.49, blue: 0.99))
                                    .cornerRadius(50)
                                    .overlay(
                                        Text("\(item.unread)")
                                            .font(.semiBoldFont(15))
                                            .foregroundColor(.white)
                                    )
                            }
                        }
                    }
                }
            }
            .frame(height: 81)
            .padding(.horizontal, 13)
            .padding(.vertical, 8.5)
        }
    }
}


struct ChatItem_Previews: PreviewProvider {
    static var previews: some View {
        ChatItem(apiResponse: nil, item: nil, editMode: .constant(.inactive))
    }
}
