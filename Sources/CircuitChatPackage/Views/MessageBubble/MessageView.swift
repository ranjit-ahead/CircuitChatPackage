//
//  MessageView.swift
//  Chat
//
//  Created by Apple on 25/08/23.
//

import Foundation
import SwiftUI

enum ContentType: String {
    case text
    case image
    case video
    case audio
    case gif
    case location
    case sticker
    case reply
    case forwarded
    case application
    case deleted
    case contact
}

struct MessageView: View {
    
    var fromMe = false
    
    var starredMessageView = false
    
    var forwardMessage = false
    
    @Environment(\.colorScheme) var colorScheme
    
    let chatDetail: UserChatData
    
    var chatName: String
    var chatType: String
    
    @Binding var scrollToMessageId: String
    
    @State private var thumbnailImage: UIImage? = nil
    
    @State private var fileSizeText: String? = nil
    
    @State private var showImageView = false
    
    //MARK: BODY
    var body: some View {
        Group {
            if fromMe {
                sameUserMessage
            } else {
                differentUserMessage
            }
        }
    }
    
    var sameUserMessage: some View {
        checkContentType
            .padding(5)
            .background(content: {
                ZStack(alignment: .bottomTrailing) {
                    Rectangle()
                        .cornerRadius(8)
                    Image("chat_right_arrow", bundle: .module)
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 19, height: 19)
                        .padding(-10)
                }.foregroundColor(colorScheme == .dark ? Color(red: 0.03, green: 0.27, blue: 0.51) : Color(red: 0.92, green: 0.98, blue: 1))
            })
    }
    
    var differentUserMessage: some View {
        checkContentType
            .padding(5)
            .background(content: {
                ZStack(alignment: .bottomLeading) {
                    Rectangle()
                        .cornerRadius(8)
                    if chatDetail.senderDetails?.avatar != "" || chatType=="user" {
                        Image("chat_left_arrow", bundle: .module)
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 19, height: 19)
                            .padding(-10)
                    }
                }.foregroundColor(Color(.systemGray6))//(Color(red: 0.98, green: 0.98, blue: 0.98))
            })
    }
    
    var checkContentType: some View {
        Group {
            if chatDetail.contentType == ContentType.audio.rawValue {
                VStack {
                    if forwardMessage {
                        forwardedView
                    }
                    if let media = chatDetail.media {
                        AudioMessageView(audioURL: URL(string: media)!)
                    }
                }
            } else if chatDetail.contentType == ContentType.video.rawValue {
                VStack {
                    if forwardMessage {
                        forwardedView
                    }
                    sendByUserView
                    if let _ = chatDetail.text { videoMessageView() } else {
                        ZStack(alignment: .bottomTrailing) {
                            videoMessageView()
                        }
                    }
                }
                .onTapGesture {
                    showImageView.toggle()
                }
                .background(
                    NavigationLink(destination: ShowVideo(url: chatDetail.media ?? ""), isActive: $showImageView) {
                        EmptyView()
                    }.opacity(0)
                )
            } else if chatDetail.contentType == ContentType.image.rawValue {
                VStack {
                    if forwardMessage {
                        forwardedView
                    }
                    sendByUserView
                    
                    if let _ = chatDetail.text {
                        imageMessageView()
                    } else {
                        ZStack(alignment: .bottomTrailing) {
                            imageMessageView()
                        }
                    }
                }
                .onTapGesture {
                    showImageView.toggle()
                }
                .background(
                    NavigationLink(destination: ShowImage(url: chatDetail.media), isActive: $showImageView) {
                        EmptyView()
                    }.opacity(0)
                )
            }  else if chatDetail.contentType == ContentType.application.rawValue {
//                ShowDocument(url: chatDetail.media!).toolbar(.hidden, for: .tabBar)
                if let media =  chatDetail.media {
                    let mediaUrl = URL(string: media)!
                    VStack {
                        if forwardMessage {
                            forwardedView
                        }
                        sendByUserView
                        if let _ = chatDetail.text { documentMessageView() } else {
                            ZStack(alignment: .bottomTrailing) {
                                documentMessageView()
                            }
                        }
                    }
                    .onTapGesture {
                        showImageView.toggle()
                    }
                    .background(
                        NavigationLink(destination: WebView(url: mediaUrl).navigationTitle(mediaUrl.lastPathComponent), isActive: $showImageView) {
                            EmptyView()
                        }.opacity(0)
                    )
                }
            } else if chatDetail.contentType == ContentType.location.rawValue {
                VStack {
                    if forwardMessage {
                        forwardedView
                    }
                    sendByUserView
                    locationMessageView()
                }
                .frame(maxWidth: 250)
                .onTapGesture {
                    openInAppleMaps()
                }
            } else if chatDetail.contentType == ContentType.contact.rawValue {
                VStack {
                    if forwardMessage {
                        forwardedView
                    }
                    sendByUserView
                    contactMessageView()
                }
            }else if let text = chatDetail.text {
                VStack {
                    if forwardMessage {
                        forwardedView
                    }
                    sendByUserView
                    textMessageView(text)
                }
                .scaledToFit()
            }
        }
    }
    
    var forwardedView : some View {
        HStack(spacing: 0) {
            Image(systemName: "arrowshape.turn.up.forward.fill")
                .imageScale(.medium)
                .foregroundColor(.gray)
            Text("Forwarded")
                .font(.regularFont(13))
                .foregroundColor(.gray)
            Spacer()
        }.frame(height: 30)
    }
    
    //MARK: Text
    func textMessageView(_ text : String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(text)
                .font(.regularFont(15))
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(Color(uiColor: .label))
            timeSeenView
                .foregroundColor(colorScheme == .dark ?  Color(red: 0.76, green: 0.76, blue: 0.76) : Color(red: 0.57, green: 0.57, blue: 0.57))
        }.padding(.horizontal, 5)
    }
    
    //MARK: Image
    func imageMessageView() -> some View {
        Group {
            ImageDownloader(chatDetail.media).cornerRadius(8)
            
            if let text = chatDetail.text {
                textMessageView(text)
            } else {
                timeSeenView
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 3)
                    .padding(5)
            }
        }
    }
    
    //MARK: Video
    func videoMessageView() -> some View {
        Group {
            
            ZStack {
                if let thumbnailImage = thumbnailImage {
                    Image(uiImage: thumbnailImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.leading, 0).padding(.trailing, 0)
                } else {
                    Rectangle()
                        .foregroundColor(Color(.lightGray))
                        .frame(height: 200)
                        .padding(.leading, 0).padding(.trailing, 0)
                        .onAppear {
                            Task {
                                fetchVideoThumbnail(URL(string: chatDetail.media!)!, image: $thumbnailImage)
                            }
                        }
                }
                Image(systemName: "play.circle.fill")
                    .resizable()
                    .frame(maxWidth: 50, maxHeight: 50)
                    .background(Color.clear)
                    .foregroundColor(Color(red: 0.93, green: 0.93, blue: 0.93))
                    .shadow(radius: 10)
                
            }.cornerRadius(8)//.frame(width: (UIScreen.screenWidth*2)/3)
            
            if let text = chatDetail.text {
                textMessageView(text)
            } else {
                timeSeenView
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 3)
                    .padding(5)
            }
        }
    }
    
    //MARK: Document
    func documentMessageView() -> some View {
        Group {
            
            let fileExtension = URL(string: chatDetail.media ?? "")!.pathExtension
            VStack {
                if fileExtension=="pdf" || fileExtension=="docx" || fileExtension=="xls" {
                    Image(fileExtension=="pdf" ? "pdfFileIcon" : fileExtension=="docx" ? "docxFileIcon" : "excelFileIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 50)
                        .padding()
                } else {
                    Image(systemName: "doc.circle")
                        .resizable()
                        .frame(width: 75, height: 75)
                        .foregroundColor(Color(.systemGray))
                        .padding()
                }
                
                HStack {
                    Image(systemName: "doc")
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(URL(string: chatDetail.media ?? "")!.lastPathComponent)").lineLimit(1)
                        HStack {
                            if let fileSizeText = fileSizeText {
                                Text(fileSizeText)
                                    .padding(.leading, 0).padding(.trailing, 0)
                            } else {
                                Text("5 KB")
                                    .padding(.leading, 0).padding(.trailing, 0)
                                    .onAppear {
                                        Task {
                                            getFileSizeFromURL(urlString: chatDetail.media ?? "") { fileSize in
                                                fileSizeText = fileSize?.convertBytesToGBMBKB
                                            }
                                        }
                                    }
                            }
                            Text("|  \(String(describing: fileExtension.uppercased()))")
                            Spacer()
                        }
                    }.font(.regularFont(15))
                }
            }.padding().background(.black.opacity(0.05)).cornerRadius(8)
            
            if let text = chatDetail.text {
                textMessageView(text)
            } else {
                timeSeenView
                    .foregroundColor(colorScheme == .dark ?  Color(red: 0.76, green: 0.76, blue: 0.76) : Color(red: 0.57, green: 0.57, blue: 0.57))
                    .padding(5)
            }
        }
    }
    
    //MARK: Location
    func locationMessageView() -> some View {
        let endTime = chatDetail.location?.endTime?.getTimeFormatInHourAndMin ?? ""
        let status = chatDetail.location?.status
        return VStack(spacing: 5) {
            
            ZStack(alignment: .bottomLeading) {
                ImageDownloader("https://maps.google.com/maps/api/staticmap?markers=\(chatDetail.location?.latitude ?? 27.998270),\(chatDetail.location?.longitude ?? 79.230171)&size=250x270&sensor=true&key=AIzaSyBqpvO9b57QaoWD_OsDlmu-2ILU8KjCBlA&zoom=15")
                    .padding(.bottom, -50)
                
                if chatDetail.location?.locationType=="live_location" {
                    HStack {
                        Image("liveLocation", bundle: .module)
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 16, height: 16)
                        Text(status==1 ? "Live until \(endTime)" : "Live location ended")
                            .font(.regularFont(12))
                        
                        Spacer(minLength: 1)
                        
                        timeSeenView
                            .foregroundColor(colorScheme == .dark ?  Color(red: 0.76, green: 0.76, blue: 0.76) : Color(red: 0.57, green: 0.57, blue: 0.57))
                        
                    }.foregroundColor(status==1 ? Color(red: 0.26, green: 0.26, blue: 0.26) : (colorScheme == .dark ?  Color(red: 0.76, green: 0.76, blue: 0.76) : Color(red: 0.57, green: 0.57, blue: 0.57))).frame(height: 30).padding(.horizontal, 5).background(.ultraThinMaterial)
                } else if chatDetail.text==nil {
                    timeSeenView
                        .foregroundColor(colorScheme == .dark ?  Color(red: 0.76, green: 0.76, blue: 0.76) : Color(red: 0.57, green: 0.57, blue: 0.57))
                        .padding(5)
                }
            }.cornerRadius(4)
            
            if let text = chatDetail.text {
                textMessageView(text)
            }
            
            if status==1 && chatDetail.location?.locationType=="live_location" {
                if let _ = chatDetail.text {
                    Rectangle().foregroundColor(Color(.lightGray)).frame(height: 0.5)
                }
                Button {
                    print("stop")
                } label: {
                    Text("Stop Sharing")
                        .font(.regularFont(14))
                        .foregroundColor(Color(.systemRed))
                        .multilineTextAlignment(.center)
                }.frame(height: 20).frame(maxWidth: .infinity).padding(5)
            }
        }
    }
    
    //MARK: Contact
    func contactMessageView() -> some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(.gray)
                    .font(.regularFont(46))
                
                if let contact = chatDetail.contact {
                    let namesArray = contact.map ({ $0.name })
                    Text(namesArray.joined(separator: ", ")).font(.semiBoldFont(13)).lineLimit(2).fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                Image("rightArrow", bundle: .module)
                    .resizable()
                    .frame(width: 17, height: 17)
            }
            timeSeenView
                .foregroundColor(colorScheme == .dark ?  Color(red: 0.76, green: 0.76, blue: 0.76) : Color(red: 0.57, green: 0.57, blue: 0.57))
            
            Spacer(minLength: 5)
            
            HorizontalSeparatorView()
            
            Group {
                if let contact = chatDetail.contact {
                    if contact.count>1 {
                        Button {
                            
                        } label: {
                            Text("View All")
                                .font(.regularFont(14))
                                .foregroundColor(.blue)
                        }
                    } else {
                        HStack {
                            Button {
                                
                            } label: {
                                Text("Message")
                                    .font(.regularFont(14))
                                    .foregroundColor(.blue)
                            }.frame(maxWidth: .infinity)
                            
                            VerticalSeparatorView()
                            
                            Button {
                                
                            } label: {
                                Text("Save Contact")
                                    .font(.regularFont(14))
                                    .foregroundColor(.blue)
                            }.frame(maxWidth: .infinity)
                        }
                    }
                }
            }.frame(height: 34)
            
        }.frame(width: 250).padding(0)
    }
    
    //MARK: Time & Message Status
    var timeSeenView: some View {
        HStack(spacing: 3) {
            Spacer()
            
            if chatDetail.edited ?? false {
                Text("Edited")
            }
            
            if chatDetail.starred ?? false {
                Image(systemName: "star.fill")
            }
            
            if let timeFormat = chatDetail.createdAt?.getTimeFormatInHourAndMin {
                Text(timeFormat)
            }
            
            //.foregroundColor(colorScheme == .dark ?  Color(red: 0.76, green: 0.76, blue: 0.76) : Color(red: 0.57, green: 0.57, blue: 0.57))
            
            if fromMe {
                //Message Status
                if chatDetail.messageStatus == 2 {
                    Image("receivedStatusIcon", bundle: .module)
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 13.97447, height: 8)
                } else if chatDetail.messageStatus == 3 {
                    Image("seenStatusIcon", bundle: .module)
                        .resizable()
                        .frame(width: 13.97447, height: 8)
                } else {
                    Image("sentStatusIcon", bundle: .module)
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 12.22766, height: 7)
                }
            }
        }.font(.regularFont(10))
    }
    
    //Replied Message View
    func repliedMessageView(_ reply: UserChatReplyData) -> some View {
        HStack(spacing: 5) {
            VStack(alignment: .leading, spacing: 5) {
                
                    let sender = chatDetail.reply?.sender
                    let repliedUser = chatDetail.reply?.sender==circuitChatUID ? "You" : (chatDetail.reply?.senderDetails?.name ?? "")
                    
                    Text(repliedUser)
                        .font(.semiBoldFont(13))
                    
                    HStack {
                        let text =
                        reply.contentType == ContentType.image.rawValue ? "Photo" :
                        reply.contentType  == ContentType.video.rawValue ? "Video" :
                        reply.contentType  == ContentType.audio.rawValue ? "Audio" :
                        reply.contentType == ContentType.application.rawValue ? "Document" :
                        reply.contentType  == ContentType.contact.rawValue ? (reply.contact?.first?.name ?? "") :
                        reply.contentType  == ContentType.location.rawValue ? "Location" : ""
                        
                        let image =
                        reply.contentType == ContentType.image.rawValue ? Image(systemName: "camera.fill") :
                        reply.contentType == ContentType.video.rawValue ? Image(systemName: "video.fill") :
                        reply.contentType == ContentType.audio.rawValue ? Image(systemName: "mic.fill") :
                        reply.contentType == ContentType.application.rawValue ? Image(systemName: "doc.fill") :
                        reply.contentType == ContentType.contact.rawValue ? Image(systemName: "person.circle.fill") :
                        reply.contentType == ContentType.location.rawValue ? Image(systemName: "location.fill") : Image(systemName: "")
                        
                        (text != "" ? Text(image) : Text("")) + Text(reply.text ?? text)
                        
                        Spacer()
                    }
                    .font(.regularFont(14))
                    .foregroundColor(Color(red: 0.43, green: 0.43, blue: 0.43))
                    .lineLimit(3)
            }
            .padding()
            .frame(maxWidth: .infinity)
            
            Spacer()
            
            if let _ = reply.media {
                Spacer(minLength: 60)
            } else if reply.contentType == ContentType.location.rawValue {
                Spacer(minLength: 60)
            }
        }
        .contentShape(Rectangle())
        .overlay {
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    Rectangle().foregroundColor(Color(red: 0.02, green: 0.49, blue: 0.99)).frame(width: 4).cornerRadius(40)
                    Rectangle().foregroundColor(.black.opacity(0.05)).cornerRadius(4, corners: [.topRight, .bottomRight])
                    Group {
                        if let media = reply.media {
                            ImageDownloader(media)
                        } else if reply.contentType == ContentType.location.rawValue {
                            ImageDownloader("https://maps.google.com/maps/api/staticmap?markers=\(reply.location?.latitude ?? 27.998270),\(reply.location?.longitude ?? 79.230171)&size=250x270&sensor=true&key=AIzaSyBqpvO9b57QaoWD_OsDlmu-2ILU8KjCBlA&zoom=15")
                                .padding(.bottom, -50)
                        }
                    }.frame(width: 60, height: geometry.size.height).scaledToFill().cornerRadius(4, corners: [.topRight, .bottomRight])
                }
            }
        }
        .onTapGesture {
            scrollToMessageId = (chatDetail.reply?.id ?? "")
            print(scrollToMessageId)
        }
    }
    
    var sendByUserView: some View {
        VStack(spacing: 5) {
            if !starredMessageView {
                if let senderName = chatDetail.senderDetails?.name, senderName != "", fromMe==false {
                    HStack {
                        Text(senderName)
                            .font(.regularFont(12))
                            .foregroundColor(Color(.systemBlue))
                        
                        //                    if let receiverName = chatDetail.receiverDetails?.name, receiverName != "", chatDetail.receiver != uID {
                        //
                        //                        Image(systemName: "arrowtriangle.right.fill")
                        //                            .resizable()
                        //                            .frame(width: 5, height: 5)
                        //                            .foregroundColor(Color(.lightGray))
                        //
                        //                        Text(receiverName)
                        //                            .font(.regularFont(12))
                        //                            .foregroundColor(Color(.darkGray))
                        //
                        //
                        //                        Image(systemName: "circle.fill")
                        //                            .resizable()
                        //                            .frame(width: 5, height: 5)
                        //                            .foregroundColor(Color(.lightGray))
                        //
                        //                        Text(chatDetail.createdAt?.chatDateFormat ?? "")
                        //                            .font(.regularFont(12))
                        //                            .foregroundColor(Color(.darkGray))
                        //                    }
                        
                        Spacer()
                    }
                    .lineLimit(1)
                    .padding(.top, 5)
                    .padding(.leading, 5)
                    .padding(.trailing, 5)
                }
            }
            
            if let reply = chatDetail.reply {
                repliedMessageView(reply)
            }
        }
    }
    
    func openInAppleMaps() {
        if let url = URL(string: "http://maps.apple.com/?ll=\(chatDetail.location?.latitude ?? 0),\(chatDetail.location?.longitude ?? 0)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func openInGoogleMaps() {
        if let url = URL(string: "comgooglemaps://?saddr=&daddr=\(chatDetail.location?.latitude ?? 0),\(chatDetail.location?.longitude ?? 0)&directionsmode=driving") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                if let webURL = URL(string: "https://www.google.com/maps/dir/?api=1&destination=\(chatDetail.location?.latitude ?? 0),\(chatDetail.location?.longitude ?? 0)") {
                    UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
                }
            }
        }
    }
}

//struct MessageView_Previews: PreviewProvider {
//    static var previews: some View {
//        MessageView(message: Message(text: "Your words matter, and our paraphrasing tool is designed to ensure you use the right ones. With unlimited Custom modes and 8 predefined modes, Paraphraser lets you rephrase text countless ways. Our product will improve your fluency while also ensuring you have the appropriate vocabulary, tone, and style for any occasion. Simply enter your text into the input box, and our AI will work with you to create the best paraphrase. paraphras", isUser: true))
//    }
//}

