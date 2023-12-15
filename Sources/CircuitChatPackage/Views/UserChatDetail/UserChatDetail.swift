//
//  UserChatDetail.swift
//  Chat
//
//  Created by Apple on 24/08/23.
//

import SwiftUI

struct UserChatDetail: View {
    
    @EnvironmentObject var socketIO: CircuitChatSocketManager
    
    @StateObject private var observed = UserChatDetailObserved()
    @StateObject private var presentContactView = NewChatNavigation()
    @StateObject var audioRecorder = CircuitChatAudioRecorder()
    
    @State private var selectedMedia = SelectedMedia()
    
    @State private var newMessageText = ""
    
    @State private var isCameraPresented = false
    
    @State private var selectedImageURL: [URL] = []
    @State private var selectedVideoURL: URL?
    
    @State private var isGalleryPresented = false
    @State private var showMediaSelected: Bool = false
    
    @State private var selectedDocumentURL: URL?
    @State private var isDocumentPickerPresented = false
    
    @State private var presentMapView: Bool = false
    
    @State private var chatDate = ""
    
    @State private var addMoreOptions = false
    
    @State private var replyMessage: UserChatData? = nil
    
    @State private var scrollToMessage = ""
    
    @State private var deleteMode: EditMode = .inactive
    @State private var deleteMessageAlert = false
    
    @State private var forwardMode: EditMode = .inactive
    @State private var showAllUsersView = false
    
    @State private var showReactionsBackground = false
    
    @State private var reportBlockDialog: DialogView?
    
    var userDetails: Chat?
    var password: String?
    var contentType = "text"
    
    //MARK: BODY
    var body: some View {
        if let userDetails = userDetails {
            NavigationStack {
                VStack(spacing:0) {
                    
                    ScrollView {
                        ScrollViewReader { scrollReader in
                            VStack {
                                if let userChatDataArray = observed.userChatDataArray {
                                    ForEach(userChatDataArray) { chat in
                                        getMessagesView(chat)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .background(GeometryReader { geometry in
                                Color.clear
                                    .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).origin)
                            })
                            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                                if value.y>0 && !observed.requestFetching {
                                    observed.fetchChatMessages(lastChatData: userDetails, password: password)
                                }
                            }
                            .onChange(of: observed.userChatDataArray, perform: { userChatDataArray in
                                if let chat = userChatDataArray?.last, userChatDataArray?.count ?? 0 <= observed.limitCount {
                                    withAnimation(.none) {
                                        scrollReader.scrollTo((chat.id ?? ""))
                                    }
                                }
                            })
                            .onChange(of: observed.scrolledUserChatData) { userChatData in
                                withAnimation(.none) {
                                    scrollReader.scrollTo((userChatData?.id ?? ""), anchor: .top)
                                }
                            }
                            .onChange(of: observed.userChatData) { userChatData in
                                withAnimation(.none) {
                                    scrollReader.scrollTo(userChatData?.id ?? "")
                                }
                            }
                            .onChange(of: scrollToMessage, perform: { id in
                                if scrollToMessage != "" {
                                    withAnimation(.none) {
                                        scrollReader.scrollTo(id, anchor: .center)
                                    }
                                    scrollToMessage = ""
                                }
                            })
                        }
                    }
                    
                    if deleteMode == .active {
                        HStack {
                            let indexArray = observed.userChatDataArray?.filter({ $0.isSelected ?? false }).map({ $0 })
                            let arrayCount = indexArray?.count ?? 0
                            
                            //DELETE BUTTON
                            Button {
                                if arrayCount>0 {
                                    deleteMessageAlert.toggle()
                                }
                            } label: {
                                Image(systemName: "trash")
                                    .imageIconModifier(imageSize: 24, iconSize: 46, imageColor: arrayCount>0 ? .blue : Color(.lightGray) , color: Color(.systemGray6))
                                    .disabled(arrayCount>0 ? false : true)
                            }
                            .fullScreenCover(isPresented: $deleteMessageAlert, content: {
                                ShowCustomDialogSheet(action: { deleteMessageAlert.toggle() }, content: {
                                    VStack(spacing: 30) {
                                        
                                        let text = arrayCount==1 ? "Delete \(arrayCount) Message?" : "Delete \(arrayCount) Messages?"
                                        Text(text)
                                            .font(.semiBoldFont(20))
                                            .foregroundColor(Color(.label))
                                        
                                        if let array = indexArray {
                                            if array.allSatisfy { ($0.sender ?? "")==circuitChatUID } {
                                                if array.allSatisfy { ($0.contentType ?? "") != "deleted" } {
                                                    Button {
                                                        deleteMessageAlert.toggle()
                                                        deleteMode.toggle()
                                                        if let data = observed.userChatDataArray {
                                                            let chatIDs = data.filter{ $0.isSelected ?? false }.map{ $0 }
                                                            observed.deleteMessage(chatIDs, forEveryone: true)
                                                        }
                                                    } label: {
                                                        Text("Delete For Everyone")
                                                            .font(.regularFont(16))
                                                            .foregroundColor(.red)
                                                    }
                                                }
                                            }
                                        }
                                        
                                        Button {
                                            deleteMessageAlert.toggle()
                                            deleteMode.toggle()
                                            if let data = observed.userChatDataArray {
                                                let chatIDs = data.filter{ $0.isSelected ?? false }.map{ $0 }
                                                observed.deleteMessage(chatIDs)
                                            }
                                        } label: {
                                            Text("Delete For Me")
                                                .font(.regularFont(16))
                                                .foregroundColor(.red)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                })
                            })
                            
                            Spacer()
                            
                            if let indexArray = observed.userChatDataArray?.filter{ $0.isSelected ?? false }.map{ $0 } {
                                Text("\(indexArray.count) Selected")
                                    .font(.regularFont(16))
                            }
                        }
                        .padding(.horizontal)
                        .background(.ultraThinMaterial)
                        .overlay(Rectangle().frame(height: 0.2).foregroundColor(Color.gray), alignment: .top)
                        .onAppear {
                            UIView.setAnimationsEnabled(false)
                        }
                    } else if forwardMode == .active {
                        HStack {
                            let indexArray = observed.userChatDataArray?.filter({ $0.isSelected ?? false }).map({ $0 })
                            let arrayCount = indexArray?.count ?? 0
                            
                            //FORWARD BUTTON
                            Button {
                                if arrayCount>0 {
                                    showAllUsersView.toggle()
                                }
                            } label: {
                                Image(systemName: "arrowshape.turn.up.forward")
                                    .imageIconModifier(imageSize: 24, iconSize: 46, imageColor: arrayCount>0 ? .blue : Color(.lightGray) , color: Color(.systemGray6))
                                    .disabled(arrayCount>0 ? false : true)
                            }
                            
                            Spacer()
                            
                            if let indexArray = observed.userChatDataArray?.filter{ $0.isSelected ?? false }.map{ $0 } {
                                Text("\(indexArray.count) Selected")
                                    .font(.regularFont(16))
                            }
                            
                            Spacer()
                            
                            //Share
                            Button {
                                if arrayCount>0 {
                                    showAllUsersView.toggle()
                                }
                            } label: {
                                Image(systemName: "square.and.arrow.up")
                                    .imageIconModifier(imageSize: 24, iconSize: 46, imageColor: arrayCount>0 ? .blue : Color(.lightGray) , color: Color(.systemGray6))
                                    .disabled(arrayCount>0 ? false : true)
                            }
                        }
                        .sheet(isPresented: $showAllUsersView, content: {
                            if let dialog = observed.userChat?.footerDialog?.first, dialog.key=="forward" {
                                if let selectedMessage = observed.userChatDataArray?.filter({ $0.isSelected ?? false }).map({ $0.id ?? "" }) {
                                    AddMembersView(apiRequest: ApiRequest(apiURL: dialog.apiUrl, method: dialog.apiMethod), forwardMode: $forwardMode, forwardMessages: selectedMessage)
                                }
                            }
                        })
                        .padding(.horizontal)
                        .background(.ultraThinMaterial)
                        .overlay(Rectangle().frame(height: 0.2).foregroundColor(Color.gray), alignment: .top)
                        .onAppear {
                            UIView.setAnimationsEnabled(false)
                        }
                    } else {
                        if let reply = replyMessage {
                            repliedMessageView(reply)
                        }
                        customTextField
                    }
                }
                .fullScreenCover(isPresented: .constant(getBoolFromString(observed.toastMessage))) {
                    Toast(isShowing: $observed.toastMessage)
                }
                .fullScreenCover(isPresented: $addMoreOptions, content: {
                    addMoreOptionsCustomDialog
                })
                .fullScreenCover(isPresented: $showMediaSelected, content: {
                    ShowMediaSelected(selectedMedia: $selectedMedia, userDetails: userDetails, openShowEditView: $showMediaSelected, mediaText: .constant(""))
                })
                .fullScreenCover(isPresented: .constant(reportBlockDialog != nil ? true : false), content: {
                    ShowCustomDialogSheet(action: { reportBlockDialog = nil }, content: {
                        VStack(spacing: 30) {
                            if let label = reportBlockDialog?.label {
                                Text(label)
                                    .font(.semiBoldFont(20))
                                    .foregroundColor(Color(.label))
                            }
                            if let desc = reportBlockDialog?.description {
                                Text(desc)
                                    .font(.regularFont(14))
                                    .foregroundColor(Color(.label))
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .multilineTextAlignment(.center)
                            }
                            
                            VStack(alignment:.leading) {
                                
                                if let buttons = reportBlockDialog?.buttons {
                                    ForEach(buttons) { button in
                                        reportBlockDialogView(button, lastIndex: buttons.last==button)
                                    }
                                } else if let confirmText = reportBlockDialog?.confirmText {
                                    Button {
                                        observed.reportChat(apiRequest: ApiRequest(apiURL: reportBlockDialog?.apiUrl, method: reportBlockDialog?.apiMethod), block: false, leave: false)
                                        reportBlockDialog = nil
                                    } label: {
                                        Text(confirmText)
                                            .font(.regularFont(16))
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                        .padding()
                    })
                })
                .onAppear {
                    if observed.pageCount == 1 {
                        observed.fetchChatMessages(lastChatData: userDetails, password: password)
                        //                        if userDetails.unread > 0 {
                        let json = [
                            "chat": userDetails.id,
                            "receiverType": userDetails.chatType ?? "user"
                        ]
                        socketIO.defaultUserSocket?.emit(CircuitChatSocketEvents.message_seen.rawValue, json)
                        //                        }
                    }
                }
                .toolbar {
                    // Add custom views to the navigation toolbar here
                    
                    ToolbarItem(placement: .principal) {
                        NavigationLink(destination: {
                            if userDetails.chatType=="user"  {
                                UserInfo(id: userDetails.id).toolbarRole(.editor)
                            } else {
                                GroupInfo(userDetails: userDetails).toolbarRole(.editor)
                            }}, label: {
                                HStack {
                                    ImageDownloader(userDetails.avatar)
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                        .padding(.vertical, 8)
                                    
                                    VStack(alignment: .leading, spacing: 1) {
                                        ChatName(name: userDetails.name, font: .semiBoldFont(15), verified: userDetails.verified, iconSize: 19)
                                        if let action = userDetails.action {
                                            Text(action)
                                                .font(.regularFont(12))
                                                .foregroundColor(Color(red: 0.43, green: 0.43, blue: 0.43))
                                        } else if userDetails.active ?? false {
                                            Text("Online")
                                                .font(.regularFont(12))
                                                .foregroundColor(Color(red: 0, green: 0.67, blue: 0.11))
                                        } else if userDetails.chatType == "group" {
                                            Text("tap here for group info")
                                                .font(.regularFont(12))
                                                .foregroundColor(Color(red: 0.43, green: 0.43, blue: 0.43))
                                        } else if let lastActive = userDetails.lastActive?.onlineDateFormat {
                                            Text("last seen \(lastActive)")
                                                .font(.regularFont(12))
                                                .foregroundColor(Color(red: 0.43, green: 0.43, blue: 0.43))
                                        } else {
                                            Text("tap here for friend info")
                                                .font(.regularFont(12))
                                                .foregroundColor(Color(red: 0.43, green: 0.43, blue: 0.43))
                                        }
                                    }
                                    
                                    Spacer()
                                }.frame(width: UIScreen.screenWidth-160)
                            })
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack(spacing: 15) {
                            
                            if deleteMode == .active {
                                Text("Cancel").foregroundColor(.blue).font(.semiBoldFont(18)).minimumScaleFactor(0.1)
                                    .onTapGesture {
                                        if let chat = observed.userChatDataArray{
                                            for chatData in chat {
                                                if let index = observed.userChatDataArray?.firstIndex(of: chatData) {
                                                    observed.userChatDataArray?[index].isSelected = false
                                                }
                                            }
                                        }
                                        deleteMode.toggle()
                                    }
                            } else if forwardMode == .active {
                                Text("Cancel").foregroundColor(.blue).font(.semiBoldFont(18)).minimumScaleFactor(0.1)
                                    .onTapGesture {
                                        if let chat = observed.userChatDataArray{
                                            for chatData in chat {
                                                if let index = observed.userChatDataArray?.firstIndex(of: chatData) {
                                                    observed.userChatDataArray?[index].isSelected = false
                                                }
                                            }
                                        }
                                        forwardMode.toggle()
                                    }
                            } else {
                                Button {
                                    observed.toastMessage = "coming soon..."
                                } label: {
                                    Image("userPageCall")
                                        .renderingMode(.template)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(Color(UIColor.label))
                                }
                                Button {
                                    observed.toastMessage = "coming soon..."
                                } label: {
                                    Image("userPageVideo")
                                        .renderingMode(.template)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(Color(UIColor.label))
                                }
                            }
                        }
                    }
                }
            }
            .environmentObject(presentContactView).environmentObject(observed).navigationBarTitle(userDetails.name)
            
            //MARK: SOCKETS
            
            //Chat Block
            .onChange(of: socketIO.chatBlock, perform: { chatResponse in
                if let chatResponse = chatResponse, chatResponse.chat?.contains(userDetails.id) == true {
                    observed.userChat?.blocked = true
                    
                    socketIO.chatBlock = nil
                }
            })
            
            //Chat Unblock
            .onChange(of: socketIO.chatUnblock, perform: { chatResponse in
                if let chatResponse = chatResponse, chatResponse.chat?.contains(userDetails.id) == true {
                    observed.userChat?.blocked = false
                    
                    socketIO.chatBlock = nil
                }
            })
            
            //New Message
            .onChange(of: socketIO.newMessageArray) { userChatDataArray in
                
                if let userChatData = userChatDataArray?.first,
                    userChatData.sender == userDetails.id || userChatData.receiver == userDetails.id {
                    observed.userChatData = userChatData
                    observed.userChatDataArray?.append(userChatData)
                }
                observed.changeDataModel()
                let json = [
                    "chat": userDetails.id,
                    "receiverType": userDetails.chatType ?? "user"
                ]
                socketIO.defaultUserSocket?.emit(CircuitChatSocketEvents.message_seen.rawValue, json)
            }
            
            //Message Deleted for me
            .onChange(of: socketIO.messageDeleted) { messageDeleted in
                if let messageId = messageDeleted?.first?.first,
                   let index = observed.userChatDataArray?.firstIndex(where: { $0.id == messageId }) {
                    observed.userChatDataArray?.remove(at: index)
                }
            }
            
            //Message Deleted for everyone
            .onChange(of: socketIO.messageDeletedEveryone) { messageDeletedEveryone in
                if let messageDeletedEveryone = messageDeletedEveryone?.first,
                   let index = observed.userChatDataArray?.firstIndex(where: { $0.id == messageDeletedEveryone.id }) {
                    observed.userChatDataArray?[index] = messageDeletedEveryone
                    observed.userChatData = messageDeletedEveryone
                }
            }
            
            //Message Received
            .onChange(of: socketIO.messageRecieved) { messageRecieved in
                if let messageRecieved = messageRecieved?.first,
                   let index = observed.userChatDataArray?.firstIndex(where: { $0.id == messageRecieved }) {
                    observed.userChatDataArray?[index].messageStatus = 2
                }
            }
            
            //Message Seen
            .onChange(of: socketIO.messageSeen) { messageSeen in
                if let messageSeenArray = messageSeen?.first {
                    observed.userChatDataArray?.enumerated().forEach { index, chatData in
                        if let chatId = chatData.id, messageSeenArray.contains(chatId) {
                            observed.userChatDataArray?[index].messageStatus = 3
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func reportBlockDialogView(_ button: FetchResponse, lastIndex: Bool) -> some View {
        Button {
            if button.subDialog==nil {
                if button.id=="unblock", let userDetails {
                    observed.unblockChat(apiRequest: ApiRequest(apiURL: button.apiURL, method: button.apiMethod), user: userDetails.id)
                } else {
                    observed.reportChat(apiRequest: ApiRequest(apiURL: button.apiURL, method: button.apiMethod), block: button.id=="reportBlock", leave: false)
                }
            }
            reportBlockDialog = button.subDialog
        } label: {
            HStack {
                if button.icon==nil {
                    Spacer()
                }
                Text(button.label ?? "")
                    .font(.regularFont(16))
                    .foregroundColor(.red)
                Spacer()
                if let _ = button.icon {
                    ImageDownloader(button.icon)
                        .frame(width: 26, height: 26)
                }
            }
        }.contentShape(Rectangle())
        if !lastIndex {
            HorizontalSeparatorView()
        }
    }
    
    //Replied Message View
    func repliedMessageView(_ chat: UserChatData) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            if let reply = chat {
                HStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            
                            let sender = chat.sender ?? ""
                            let repliedUser = sender==circuitChatUID ? "You" : (userDetails?.chatType=="group" ? (reply.senderDetails?.name ?? "") : userDetails?.name ?? "")
                            
                            Text(repliedUser)
                                .font(.semiBoldFont(13))
                            
                            VStack {
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
                            }
                            .font(.regularFont(14))
                            .foregroundColor(Color(red: 0.43, green: 0.43, blue: 0.43))
                        }
                        .padding()
                        .contentShape(Rectangle())
                        .overlay {
                            GeometryReader { geometry in
                                HStack {
                                    Rectangle().foregroundColor(Color(red: 0.02, green: 0.49, blue: 0.99)).frame(width: 4)
                                    Spacer()
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Group {
                            if let media = reply.media {
                                ImageDownloader(media)
                            } else if reply.contentType == ContentType.location.rawValue {
                                ImageDownloader("https://maps.google.com/maps/api/staticmap?markers=\(reply.location?.latitude ?? 27.998270),\(reply.location?.longitude ?? 79.230171)&size=250x270&sensor=true&key=AIzaSyBqpvO9b57QaoWD_OsDlmu-2ILU8KjCBlA&zoom=15")
                                    .padding(.bottom, -50)
                            }
                        }.frame(width: 56).scaledToFit().cornerRadius(4).padding(2)
                        
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        scrollToMessage = (chat.id ?? "")
                    }
                    
                    Button {
                        replyMessage = nil
                    } label: {
                        Image(systemName: "x.circle").resizable().foregroundColor(.blue).frame(maxWidth: 22, maxHeight: 22).padding()
                    }
                }
            }
        }.background {
            Rectangle()
                .foregroundColor(.clear)
                .background(Color(UIColor.systemGray6))
//                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: -5)
        }
        .frame(height: 60)
    }
    
    var customTextField: some View {
        
        //Custom TextField

            HStack {
                Button {
                    if observed.userChat?.blocked ?? false {
                        if let unblock = observed.userChat?.unBlock {
                            reportBlockDialog = unblock
                        }
                    } else {
                        addMoreOptions.toggle()
                    }
                } label: {
                    Image("addCircleIcon")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 34, height: 34)
                        .aspectRatio(contentMode: .fill)
                        .foregroundColor(Color(UIColor.label))
                }
                .sheet(isPresented: $isDocumentPickerPresented) {
                    DocumentPicker(selectedDocumentURL: $selectedDocumentURL)
                }

                ZStack(alignment: .trailing) {
//                    TextField("", text: $newMessageText, onEditingChanged: { begin in
//                        if begin {
//
//                        }
//                    })
                    TextEditorView(string: $newMessageText)
                    .placeholder(when: newMessageText.isEmpty) {
                        Text("Message...")
                            .font(.regularFont(13))
                            .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.45))
                    }
                    .padding(.horizontal)
                    .padding(.trailing, 30)
                    .onChange(of: newMessageText, perform: { newMessageText in
                        if newMessageText != "", observed.userChat?.blocked==false {
                            if let userDetails = userDetails {
                                let json = [
                                    "chat": userDetails.id,
                                    "receiverType": userDetails.chatType ?? "user",
                                    "action": "typing"
                                ]
                                socketIO.defaultUserSocket?.emit(CircuitChatSocketEvents.user_action.rawValue, json)
                            }
                        }
                    })
                    Button {
                        observed.toastMessage = "coming soon..."
                    } label: {
                        Image("attachFile")
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 26, height: 26)
                            .aspectRatio(contentMode: .fill)
                            .padding(.trailing)
                            .foregroundColor(Color(UIColor.label))
                    }
                }
//                .frame(height: 44)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(50)

                if !newMessageText.isEmpty || selectedVideoURL != nil || selectedDocumentURL != nil {
                    Button(action: sendMessage) {
                        Image("sendIcon")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 30, height: 30)
                            .clipped()
                    }
                } else {
                    Button {
                        if observed.userChat?.blocked ?? false {
                            if let unblock = observed.userChat?.unBlock {
                                reportBlockDialog = unblock
                            }
                        } else {
                            //isGalleryPresented = true
                            observed.toastMessage = "coming soon..."
                        }
                    } label: {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 34, height: 34)
                            .background(
                                Image("cameraIcon")
                                    .renderingMode(.template)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 34, height: 34)
                                    .clipped()
                                    .foregroundColor(Color(UIColor.label))
                            )
                    }
                    .sheet(isPresented: $isCameraPresented, content: {
                        //CameraPicker(selectedImageURL: $selectedImageURL, isPresented: $isCameraPresented)
                    })
                    .sheet(isPresented: $isGalleryPresented, content: {
//                        ImageAndVideoPicker(selectedImageURL: $selectedImageURL, selectedVideoURL: $selectedVideoURL, isPickerPresented: $isGalleryPresented, showMediaSelected: $showMediaSelected, allowEditing: false)
                        PhotoPicker(mediaItems: $selectedMedia, allowOneSelection: true) { didSelectItem in
                            // Handle didSelectItems value here...
                            if didSelectItem {
                                showMediaSelected.toggle()
                            }
                            isGalleryPresented = false
                        }
                    })

                    Button(action: {
                        if observed.userChat?.blocked ?? false {
                            if let unblock = observed.userChat?.unBlock {
                                reportBlockDialog = unblock
                            }
                        } else {
                            if self.audioRecorder.isRecording {
                                self.audioRecorder.stopRecording()
                                sendMessage()
                            } else {
                                self.audioRecorder.startRecording()
                                if let userDetails = userDetails {
                                    let json = [
                                        "chat": userDetails.id,
                                        "receiverType": userDetails.chatType ?? "user",
                                        "action": "recording"
                                    ]
                                    socketIO.defaultUserSocket?.emit(CircuitChatSocketEvents.user_action.rawValue, json)
                                }
                            }
                        }
                    }) {
                        Image(systemName: self.audioRecorder.isRecording ? "record.circle" : "mic.fill")
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 19.1579, height: 26)
                            .aspectRatio(contentMode: .fill)
                            .foregroundColor(Color(self.audioRecorder.isRecording ? .red : UIColor.label))
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background {
                Rectangle()
                    .foregroundColor(Color(UIColor.systemGray6))
                    .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: -5)
                    .edgesIgnoringSafeArea(.all)
            }
    }
    
    var addMoreOptionsCustomDialog: some View {
        CustomDialog(isPresented: $addMoreOptions, bodyContent: {
            VStack {
                Group {
                    Button {
                        observed.toastMessage = "coming soon..."
                        //isCameraPresented.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "camera")
                                .padding()
                                .background(Color(.systemGray6))
                                .frame(width: 32, height: 32)
                                .clipShape(Circle())
                            Text("Camera")
                            Spacer()
                        }.foregroundColor(Color(.label))
                    }
                    Divider()
                    Button {
                        isGalleryPresented.toggle()
                        addMoreOptions.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "photo.artframe")
                                .padding()
                                .background(Color(.systemGray6))
                                .frame(width: 32, height: 32)
                                .clipShape(Circle())
                            Text("Photo & Video Library")
                            Spacer()
                        }.foregroundColor(Color(.label))
                    }
                    Divider()
                    Button {
                        isDocumentPickerPresented.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "doc.text")
                                .padding()
                                .background(Color(.systemGray6))
                                .frame(width: 32, height: 32)
                                .clipShape(Circle())
                            Text("Document")
                            Spacer()
                        }.foregroundColor(Color(.label))
                    }
                    Divider()
                    Button {
                        presentMapView.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .padding()
                                .background(Color(.systemGray6))
                                .frame(width: 32, height: 32)
                                .clipShape(Circle())
                            Text("Location")
                            Spacer()
                        }.foregroundColor(Color(.label))
                    }
                    .sheet(isPresented: $presentMapView, content: {
                        MapView(userChat: userDetails)
                    })
                }
                Group {
                    Divider()
                    Button {
                        presentContactView.showSheet.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "person.circle")
                                .padding()
                                .background(Color(.systemGray6))
                                .frame(width: 32, height: 32)
                                .clipShape(Circle())
                            Text("Contact")
                            Spacer()
                        }.foregroundColor(Color(.label))
                    }.sheet(isPresented: $presentContactView.showSheet, content: {
                        ContactListView(userChat: userDetails)
                    })
                    Divider()
                    Button {
                        observed.toastMessage = "coming soon..."
                        addMoreOptions.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "chart.bar.xaxis")
                                .padding()
                                .background(Color(.systemGray6))
                                .frame(width: 32, height: 32)
                                .clipShape(Circle())
                            Text("Poll")
                            Spacer()
                        }.foregroundColor(Color(.label))
                    }
                }
            }
            .accentColor(.black)
            .padding()
        }, cancelContent: {
            Button {
                addMoreOptions.toggle()
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
    
    @ViewBuilder
    func getMessagesView(_ chat: UserChatData) -> some View {
        VStack {
            if let contentType = chat.contentType, contentType == "notification" {
                Text(chat.text ?? "").font(.regularFont(14))
                    .padding(5)
                    .background {
                        Rectangle()
                            .foregroundColor(Color(.systemGray6))
                            .cornerRadius(5)
                    }
                    .padding()
            } else {
                if let date = chat.dateText, date != "" {
                    HStack {
                        HorizontalSeparatorView()
                        Text(date)
                            .font(.regularFont(15))
                            .padding(13)
                            .foregroundColor(Color(red: 0.57, green: 0.57, blue: 0.57))
                        HorizontalSeparatorView()
                    }
                }
                HStack {
                    
                    if deleteMode == .active || forwardMode == .active {
                        if chat.isSelected ?? false {
                            Image("selectedTickIcon")
                                .imageIconModifier(imageSize: 14, iconSize: 24, imageColor: Color.white, color: .blue)
                                .frame(alignment: .center)
                        } else {
                            Circle()
                                .strokeBorder(Color(UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1)), lineWidth: 2)
                                .frame(width: 24, height: 24, alignment: .center)
                        }
                    }
                    
                    if chat.sender != circuitChatUID {
                        if let avatar = chat.senderDetails?.avatar, avatar != "" {
                            ImageDownloader(avatar)
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 36, height: 36, alignment: .bottom)
                                .clipShape(Circle())
                        } else if userDetails?.chatType=="group"{
                            Spacer(minLength: 46)
                        }
                    }
                    let avatar = chat.senderDetails?.avatar
                    
                    let fromMe = chat.fromMe ?? false
                    MessageView(fromMe: fromMe, forwardMessage: chat.forward ?? false, chatDetail: chat, chatName: userDetails?.name ?? "", chatType: userDetails?.chatType ?? "", scrollToMessageId: $scrollToMessage)
                        .contentShape(ContentShapeKinds.contextMenuPreview, RoundedRectangle(cornerRadius: 8))
                        .frame(maxWidth: .infinity, alignment: fromMe ? .trailing : .leading)
                        .padding(fromMe ? .leading : .trailing, (UIScreen.screenWidth*1)/7)
                        .padding(.horizontal, 7)
                        .padding(.bottom, (avatar == "" && chat.sender != circuitChatUID) ? 0 : 8)
//                        .onLongPressGesture {
//                            showReactionsBackground.toggle()
//                        }
                        .contextMenu {
                            if let dialog = chat.dialog, deleteMode == .inactive, forwardMode == .inactive {
                                ForEach(dialog) { button in
                                    dialogButtons(button, chat: chat)
                                }
                            }
                        }
                }.id(chat.id).disabled((deleteMode == .active || forwardMode == .active) ? true : false)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if deleteMode == .active || forwardMode == .active {
                if let index = observed.userChatDataArray?.firstIndex(of: chat) {
                    observed.userChatDataArray?[index].isSelected = !(chat.isSelected ?? false)
                }
            } else {
                UIApplication.shared.endEditing()
            }
        }
        
    }
    
    @ViewBuilder
    func dialogButtons(_ button: FetchResponse, chat: UserChatData) -> some View {
//        Button {
//
//        } label: {
//            Text(button.label ?? "")
//            ImageDownloader(button.icon, renderMode: .template)
//        }
        if button.id=="star" {
            Button {
                // save my code
                observed.starredMessage(chat)
            } label: {
                Label(chat.starred ?? false ? (button.labelSelected ?? "Unstar") : (button.label ?? "Star"), systemImage: chat.starred ?? false ? "star.slash.fill" : "star")
            }
        }

        if button.id=="reply" {
            Button {
                // save my code
                replyMessage = chat
            } label: {
                Label(button.label ?? "Reply", systemImage: "arrowshape.turn.up.backward")
            }
        }
        
        if button.id=="replyPrivately" {
            Button {
                // save my code
                replyMessage = chat
            } label: {
                Label(button.label ?? "Reply Privately", systemImage: "arrowshape.turn.up.backward")
            }
        }
        
        if button.id=="personalMessage" {
            Button {
            
            } label: {
                Label(button.label ?? "Message", systemImage: "message")
            }
        }
        
        if button.id=="forward" {
            Button {
                forwardMode.toggle()
                if let index = observed.userChatDataArray?.firstIndex(of: chat) {
                    observed.userChatDataArray?[index].isSelected = true
                }
            } label: {
                Label(button.label ?? "Forward", systemImage: "arrowshape.turn.up.forward")
            }
        }
        
        if button.id=="copy" {
            Button {
                copyTextToClipboard(chat.text)
            } label: {
                Label(button.label ?? "Copy", systemImage: "doc.on.doc")
            }
        }
        
        if button.id=="edit" {
            Button {
                
            } label: {
                Label(button.label ?? "Edit", systemImage: "pencil")
            }
        }
        
        if button.id=="report" {
            Button(role: .destructive) {
                observed.userChatData = chat
                reportBlockDialog = button.subDialog
            } label: {
                Label(button.label ?? "Report", systemImage: "flag")
            }
        }
        
        if button.id=="delete" {
            Button(role: .destructive) {
                deleteMode.toggle()
                if let index = observed.userChatDataArray?.firstIndex(of: chat) {
                    observed.userChatDataArray?[index].isSelected = true
                }
            } label: {
                Label(button.label ?? "Delete", systemImage: "trash")
            }
        }
    }
    
    func sendMessage() {
        if observed.userChat?.blocked ?? false {
            if let unblock = observed.userChat?.unBlock {
                reportBlockDialog = unblock
            }
        } else {
            if !newMessageText.isEmpty || (audioRecorder.audioURL != nil) || selectedVideoURL != nil || selectedDocumentURL != nil {
                if let userDetails = userDetails {
                    observed.sendMessage(imageURLs: selectedImageURL, videoURL: selectedVideoURL ?? nil, audioURL: audioRecorder.audioURL ?? nil, docURL: selectedDocumentURL ?? nil, to: userDetails.id, contentType: contentType, text: newMessageText=="" ? nil : newMessageText, receiverType: userDetails.chatType ?? "user", replyMessage: replyMessage)
                }
                newMessageText = ""
                selectedImageURL.removeAll()
                selectedVideoURL = nil
                audioRecorder.audioURL = nil
                replyMessage = nil
            }
        }
    }
}

//struct UserChatDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        UserChatDetail(userDetails: nil)
//    }
//}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero

    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
    }
}


