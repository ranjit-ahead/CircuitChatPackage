//
//  ContentView.swift
//  Chat
//
//  Created by Apple on 19/08/23.
//

import SwiftUI

struct ChatView : View {
    
    var apiRequest: ApiRequest
    
    @EnvironmentObject var socketIO: CircuitChatSocketManager
    
    @StateObject private var observed = ChatListViewObserved()
    @StateObject private var archivedObserved = ChatListViewObserved()
    
    var body: some View {
        NavigationStack {
            ChatListView(apiRequest: apiRequest, observed: observed, chatObserved: observed, archivedObserved: archivedObserved)
        }
        .onAppear {
            if observed.apiResponse == nil {
                observed.apiResponse = nil
                observed.archived = false
                observed.apiRequest = apiRequest
                observed.fetchApiData(apiRequest: observed.apiRequest)
            }
            if archivedObserved.apiResponse == nil {
                archivedObserved.apiResponse = nil
                archivedObserved.archived = true
                archivedObserved.apiRequest = apiRequest
                archivedObserved.fetchApiData(apiRequest: observed.apiRequest)
            }
        }
    }
    
}

struct ChatListView: View {
    
    var apiRequest: ApiRequest
    
    var archivedView = false
    
    @EnvironmentObject var socketIO: CircuitChatSocketManager
    
    @ObservedObject var observed: ChatListViewObserved
    @ObservedObject var chatObserved: ChatListViewObserved
    @ObservedObject var archivedObserved: ChatListViewObserved
    
    @StateObject private var showingNewChat = NewChatNavigation()
    
    @Environment(\.editMode) private var editMode
    
    @State private var searchText = ""
    
    @State private var showingGroupPasswordAccess = false
    @State private var chatSelected: LastChatData?
    @State private var currentChatSelected: Chat?
    @State private var selectedIndexes: Set<Chat> = []
    private func toggleSelection(for index: Chat) {
        if selectedIndexes.contains(index) {
            selectedIndexes.remove(index)
        } else {
            selectedIndexes.insert(index)
        }
    }
    @State private var passwordText = ""
    
    @State private var showMoreOptions = false
    
    @State private var mode: EditMode = .inactive //< -- Here
    
    @State private var showEditingOptions = false
    
    @State private var showProfilePage = false
    
    @State private var muteDialog: DialogView?
    @State private var reportBlockDialog: DialogView?
    @State private var deleteDialog: DialogView?
    
    var body: some View {
        //        NavigationStack {
        VStack {
            searchBarView
            
            if observed.apiResponse == nil {
                ProgressView()
            } else {
                if let _ = observed.apiResponse?.menu.chats {
                    chatList
                }
            }
        }
        .navigationDestination(isPresented: .constant(currentChatSelected != nil ? true : false)) {
            if let chatSelected = currentChatSelected {
                UserChatDetail(userDetails: chatSelected, password: passwordText)
                    .toolbar(.hidden, for: .tabBar)
                    .toolbarRole(.editor)
            }
        }
        .onAppear {
            currentChatSelected = nil
        }
        .navigationTitle(observed.apiResponse?.menu.navigationTitle ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(uiImage: UIImage(named: "leftArrow", in: Bundle.main, with: nil)!)
                        .resizable()
                        .frame(width: 28, height: 28)
                }
            }
            ToolbarItem(placement: .principal) {
                Text(observed.apiResponse?.menu.navigationTitle ?? "")
                    .font(.semiBoldFont(22))
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 15) {
                    //New Chat
                    if let newChat = observed.apiResponse?.menu.newChat {
                        Button {
                            showingNewChat.showSheet.toggle()
                        } label: {
                            ImageDownloader(newChat.icon, renderMode: .template)
                                .frame(width: 25, height: 25)
                                .foregroundColor(Color(UIColor.label))
                        }
                        .sheet(isPresented: $showingNewChat.showSheet) {
                            NewChatView(apiRequest: ApiRequest(apiURL: newChat.apiURL, method: newChat.apiMethod), currentChatSelected: $currentChatSelected)
                        }
                    }
                }
            }
        }
        //        }
        .environmentObject(showingNewChat)
//        .onAppear {
//            if observed.apiResponse == nil {
//                observed.apiResponse = nil
//                observed.archived = archivedView
//                observed.apiRequest = apiRequest
//                observed.fetchApiData(apiRequest: observed.apiRequest)
//            }
//        }
        
        //MARK: SOCKET
        
        //New Message
        .onChange(of: socketIO.newMessageArray, perform: { newMessageArray in
            if let newMessageArray = newMessageArray {
                var checkIfUserExist = false

                for newMessage in newMessageArray {
                    var id = newMessage.receiver
                    if id == circuitChatUID {
                        id = newMessage.sender
                    }
                    
                    if let index = chatObserved.apiResponse?.menu.chats.firstIndex(where: { $0.chat.id == id }) {
                        let checkPinnedMessages = chatObserved.apiResponse?.menu.chats.filter{ ($0.pin ?? false && $0.id != id) }.count ?? 0
                        let unreadCount = Int(chatObserved.apiResponse?.menu.chats[index].unread ?? 0)
                        chatObserved.apiResponse?.menu.chats[index].chat.action = nil
                        chatObserved.apiResponse?.menu.chats[index].userChatData = newMessage
                        chatObserved.apiResponse?.menu.chats[index].fromMe = true
                        if newMessage.sender != circuitChatUID {
                            chatObserved.apiResponse?.menu.chats[index].unread = unreadCount + 1
                            chatObserved.apiResponse?.menu.chats[index].fromMe = false
                        } else {
                            chatObserved.apiResponse?.menu.chats[index].fromMe = true
                        }
                        checkIfUserExist = true
                        
                        if let data = observed.apiResponse?.menu.chats[index] {
                            chatObserved.apiResponse?.menu.chats.remove(at: index)
                            chatObserved.apiResponse?.menu.chats.insert(data, at: checkPinnedMessages)
                        }
                    } else if let index = archivedObserved.apiResponse?.menu.chats.firstIndex(where: { $0.chat.id == id }) {
                        let checkPinnedMessages = archivedObserved.apiResponse?.menu.chats.filter{ ($0.pin ?? false && $0.id != id) }.count ?? 0
                        let unreadCount = Int(archivedObserved.apiResponse?.menu.chats[index].unread ?? 0)
                        archivedObserved.apiResponse?.menu.chats[index].chat.action = nil
                        archivedObserved.apiResponse?.menu.chats[index].userChatData = newMessage
                        
                        if newMessage.sender != circuitChatUID {
                            archivedObserved.apiResponse?.menu.chats[index].unread = unreadCount + 1
                            archivedObserved.apiResponse?.menu.chats[index].fromMe = false
                        } else {
                            archivedObserved.apiResponse?.menu.chats[index].fromMe = true
                        }
                        checkIfUserExist = true
                        
                        if let data = archivedObserved.apiResponse?.menu.chats[index] {
                            archivedObserved.apiResponse?.menu.chats.remove(at: index)
                            archivedObserved.apiResponse?.menu.chats.insert(data, at: checkPinnedMessages)
                        }
                    }
                }

                if !checkIfUserExist {
                    reload()
                }

                socketIO.newMessageArray = nil
            }
        })
        
        //Active Friends
        .onChange(of: socketIO.activeFriendsData, perform: { activeFriendsData in
            if let activeFriendsData {
                if let activeFriendsData = activeFriendsData.first {
                    var checkIfActiveFriendExist = false
                    if let activeFriendsDataArray = observed.activeUserResponse?.data {
                        for data in activeFriendsDataArray {
                            if data.id == activeFriendsData.id, (activeFriendsData.active==false) {
                                checkIfActiveFriendExist = true
                                if let index = activeFriendsDataArray.firstIndex(of: data) {
                                    observed.activeUserResponse?.data.remove(at: index)
                                    break
                                }
                            }
                        }
                    }
                    if !checkIfActiveFriendExist {
                        observed.activeUserResponse?.data.append(activeFriendsData)
                    }
                }
                if let data = observed.apiResponse?.menu.chats {
                    for index in 0..<data.count {
                        if let activeFriendsData = activeFriendsData.first {
                            if let chatId = observed.apiResponse?.menu.chats[index].chat.id {
                                if chatId == activeFriendsData.id {
                                    observed.apiResponse?.menu.chats[index].chat.active = activeFriendsData.active
                                }
                            }
                        }
                    }
                }
                
                socketIO.activeFriendsData = nil
            }
        })
        
        //Message Deleted
        .onChange(of: socketIO.messageDeleted, perform: { messageDeleted in
            if let data = observed.apiResponse?.menu.chats, let messageDeleted {
                for index in 0..<data.count {
                    if let messageId = messageDeleted.first?.first {
                        if observed.apiResponse?.menu.chats[index].userChatData?.id == messageId {
                            observed.apiResponse?.menu.chats[index].userChatData?.contentType = "deleted"
                            observed.apiResponse?.menu.chats[index].userChatData?.text = "This message is deleted"
                            break
                        }
                    }
                }
                
                socketIO.messageDeleted = nil
            }
        })
        
        //Message Deleted Everyone
        .onChange(of: socketIO.messageDeletedEveryone, perform: { messageDeletedEveryone in
            if let data = observed.apiResponse?.menu.chats, let messageDeletedEveryone {
                for index in 0..<data.count {
                    if let messageDeletedEveryone = messageDeletedEveryone.first {
                        if observed.apiResponse?.menu.chats[index].userChatData?.id == messageDeletedEveryone.id {
                            observed.apiResponse?.menu.chats[index].userChatData = messageDeletedEveryone
                            break
                        }
                    }
                }
                
                socketIO.messageDeletedEveryone = nil
            }
        })
        
        //Chat Archived
        .onChange(of: socketIO.chatArchived, perform: { chatResponse in
            if !archivedView, let data = observed.apiResponse?.menu.chats, let chatResponse = chatResponse {
                if let menu = chatResponse.menu, let archivedMenu = menu.archived, observed.apiResponse?.menu.archived == nil {
                    observed.apiResponse?.menu.archived = archivedMenu
                }

                let updatedChats = data.filter { lastChatData in
                    if let chatIDs = chatResponse.chat {
                        return !chatIDs.contains(lastChatData.id)
                    }
                    return true
                }

                observed.apiResponse?.menu.chats = updatedChats
                
                let unarchivedChats = data.filter { lastChatData in
                    if let chatIDs = chatResponse.chat {
                        return chatIDs.contains(lastChatData.id)
                    }
                    return false
                }
                
                for chat in unarchivedChats {
                    let index = archivedObserved.getIndexOfChatFromChat(chat)
                    if (index<(archivedObserved.apiResponse?.menu.chats.count ?? 0) || index==0 || (index+1)==(archivedObserved.apiResponse?.menu.count ?? 0)) {
                        archivedObserved.apiResponse?.menu.chats.insert(chat, at: index)
                    }
                }

                socketIO.chatArchived = nil
            }
        })
        
        //Chat Unarchived
        .onChange(of: socketIO.chatUnarchived) { chatResponse in
            if archivedView, let data = observed.apiResponse?.menu.chats, let chatResponse = chatResponse {
                if data.count == 1 {
                    chatObserved.apiResponse?.menu.archived = nil
                }

                let updatedChats = data.filter { lastChatData in
                    if let chatIDs = chatResponse.chat {
                        return !chatIDs.contains(lastChatData.id)
                    }
                    return true
                }

                observed.apiResponse?.menu.chats = updatedChats
                
                let unarchivedChats = data.filter { lastChatData in
                    if let chatIDs = chatResponse.chat {
                        return chatIDs.contains(lastChatData.id)
                    }
                    return false
                }
                
                for chat in unarchivedChats {
                    let index = chatObserved.getIndexOfChatFromChat(chat)
                    if (index<(chatObserved.apiResponse?.menu.chats.count ?? 0) || index==0 || (index+1)==(chatObserved.apiResponse?.menu.count ?? 0)) {
                        chatObserved.apiResponse?.menu.chats.insert(chat, at: index)
                    }
                }

                socketIO.chatUnarchived = nil
            }
        }
        
        //Message Recieved
        .onChange(of: socketIO.messageRecieved, perform: { messageRecieved in
            if let data = observed.apiResponse?.menu.chats, let messageRecieved {
                for index in 0..<data.count {
                    if let messageId = messageRecieved.first {
                        if observed.apiResponse?.menu.chats[index].userChatData?.id == messageId {
                            observed.apiResponse?.menu.chats[index].userChatData?.messageStatus = 2
                            break
                        }
                    }
                }
                
                socketIO.messageRecieved = nil
            }
        })
        
        //Message Seen
        .onChange(of: socketIO.messageSeen, perform: { messageSeen in
            if let data = observed.apiResponse?.menu.chats, let messageSeen {
                for index in 0..<data.count {
                    if let messageId = messageSeen.first?.first {
                        if observed.apiResponse?.menu.chats[index].userChatData?.id == messageId {
                            observed.apiResponse?.menu.chats[index].userChatData?.messageStatus = 3
                        }
                    }
                }
                
                socketIO.messageSeen = nil
            }
        })
        
        //Conversation Deleted
        .onChange(of: socketIO.conversationDeleted) { chatResponse in
            if let data = observed.apiResponse?.menu.chats, let chatResponse = chatResponse {
                let chatIds = chatResponse.chat ?? []

                for chatId in chatIds {
                    if let lastChatDataIndex = data.firstIndex(where: { $0.id == chatId }) {
                        observed.apiResponse?.menu.chats.remove(at: lastChatDataIndex)
                    }
                }

                socketIO.chatRead = nil
            }
        }
        
        //User Action
        .onChange(of: socketIO.userAction, perform: { userAction in
            if let userAction = userAction?.first,
               let data = observed.apiResponse?.menu.chats,
               let index = data.firstIndex(where: { $0.id == userAction.chat && circuitChatUID != userAction.user?.id }) {
               
                observed.apiResponse?.menu.chats[index].chat.action = userAction.label
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                    observed.apiResponse?.menu.chats[index].chat.action = nil
                }
                
                socketIO.userAction = nil
            }
        })
        
        //Chat read
        .onChange(of: socketIO.chatRead, perform: { chatResponse in
            if let data = observed.apiResponse?.menu.chats, let chatResponse = chatResponse {
                let chatIds = chatResponse.chat ?? []

                for chatId in chatIds {
                    if let lastChatDataIndex = data.firstIndex(where: { $0.id == chatId }) {
                        observed.apiResponse?.menu.chats[lastChatDataIndex].unread = 0
                    }
                }

                socketIO.chatRead = nil
            }
        })
        
        //Chat Unread
        .onChange(of: socketIO.chatUnread, perform: { chatResponse in
            if let data = observed.apiResponse?.menu.chats, let chatResponse = chatResponse {
                let chatIds = chatResponse.chat ?? []

                for chatId in chatIds {
                    if let lastChatDataIndex = data.firstIndex(where: { $0.id == chatId }) {
                        observed.apiResponse?.menu.chats[lastChatDataIndex].unread = 1
                    }
                }

                socketIO.chatUnread = nil
            }
        })
        
        //Chat Mute
        .onChange(of: socketIO.chatMute, perform: { chatResponse in
            if let data = observed.apiResponse?.menu.chats, let chatResponse = chatResponse {
                let chatIds = chatResponse.chat ?? []

                for chatId in chatIds {
                    if let lastChatDataIndex = data.firstIndex(where: { $0.id == chatId }) {
                        observed.apiResponse?.menu.chats[lastChatDataIndex].mute = true
                    }
                }

                socketIO.chatMute = nil
            }
        })
        
        //Chat Unmute
        .onChange(of: socketIO.chatUnmute, perform: { chatResponse in
            if let data = observed.apiResponse?.menu.chats, let chatResponse = chatResponse {
                let chatIds = chatResponse.chat ?? []

                for chatId in chatIds {
                    if let lastChatDataIndex = data.firstIndex(where: { $0.id == chatId }) {
                        observed.apiResponse?.menu.chats[lastChatDataIndex].mute = false
                    }
                }

                socketIO.chatUnmute = nil
            }
        })
        
        //Chat Block
        .onChange(of: socketIO.chatBlock, perform: { chatResponse in
            if let data = observed.apiResponse?.menu.chats, let chatResponse = chatResponse {
                let chatIds = chatResponse.chat ?? []

                for chatId in chatIds {
                    if let lastChatDataIndex = data.firstIndex(where: { $0.id == chatId }) {
                        observed.apiResponse?.menu.chats[lastChatDataIndex].blocked = true
                    }
                }

                socketIO.chatBlock = nil
            }
        })
        
        //Chat Unblock
        .onChange(of: socketIO.chatUnblock, perform: { chatResponse in
            if let data = observed.apiResponse?.menu.chats, let chatResponse = chatResponse {
                let chatIds = chatResponse.chat ?? []

                for chatId in chatIds {
                    if let lastChatDataIndex = data.firstIndex(where: { $0.id == chatId }) {
                        observed.apiResponse?.menu.chats[lastChatDataIndex].blocked = false
                    }
                }

                socketIO.chatUnblock = nil
            }
        })
        
        //Blocked Me
        .onChange(of: socketIO.blockedMe, perform: { chatResponse in
            if let data = observed.apiResponse?.menu.chats, let chatResponse = chatResponse, let activeUsers = observed.activeUserResponse?.data, let chatIds = chatResponse.chat {
                let activeUserIds = activeUsers.map { $0.id }
                
                for chat in chatIds {
                    // Remove active user
                    if let activeUserIndex = activeUserIds.firstIndex(of: chat) {
                        observed.activeUserResponse?.data.remove(at: activeUserIndex)
                    }
                    
                    // Update chat data
                    if let lastChatIndex = data.firstIndex(where: { $0.id == chat }) {
                        observed.apiResponse?.menu.chats[lastChatIndex].chat.active = false
                        
                        if let avatar = chatResponse.avatar {
                            observed.apiResponse?.menu.chats[lastChatIndex].chat.avatar = avatar
                        }
                    }
                }
                
                socketIO.blockedMe = nil
            }
        })
        
        //Unblocked Me
        .onChange(of: socketIO.unblockedMe, perform: { chatResponse in
            if let data = observed.apiResponse?.menu.chats, let chatResponse = chatResponse, let chatIds = chatResponse.chat {
                
                for chat in chatIds {
                    // Update chat data
                    if let lastChatIndex = data.firstIndex(where: { $0.id == chat }) {
                        observed.apiResponse?.menu.chats[lastChatIndex].chat.active = true
                        
                        if let avatar = chatResponse.avatar {
                            observed.apiResponse?.menu.chats[lastChatIndex].chat.avatar = avatar
                        }
                    }
                }
                
                socketIO.unblockedMe = nil
            }
        })
        
        //Chat Pin
        .onChange(of: socketIO.chatPin, perform: { chatResponse in
            if let data = observed.apiResponse?.menu.chats, let chatResponse = chatResponse {
                let chatIds = chatResponse.chat ?? []
                
                for chatId in chatIds {
                    if let lastChatDataIndex = data.firstIndex(where: { $0.id == chatId }) {
                        observed.apiResponse?.menu.chats[lastChatDataIndex].pin = true
                        
                        withAnimation {
                            if let item = observed.apiResponse?.menu.chats.remove(at: lastChatDataIndex) {
                                observed.apiResponse?.menu.chats.insert(item, at: 0)
                            }
                        }
                    }
                }
                
                socketIO.chatPin = nil
            }
        })
        
        //Chat Unpin
        .onChange(of: socketIO.chatUnpin, perform: { chatResponse in
            if let data = observed.apiResponse?.menu.chats, let chatResponse = chatResponse {
                let chatIds = chatResponse.chat ?? []

                for chatId in chatIds {
                    if let lastChatDataIndex = data.firstIndex(where: { $0.id == chatId }) {
                        observed.apiResponse?.menu.chats[lastChatDataIndex].pin = false
                        let insertIndex = observed.getIndexOfChat(chatId)

                        withAnimation {
                            if let item = observed.apiResponse?.menu.chats.remove(at: lastChatDataIndex) {
                                observed.apiResponse?.menu.chats.insert(item, at: insertIndex)
                            }
                        }
                    }
                }

                socketIO.chatUnpin = nil
            }
        })
    }
    
    var searchBarView: some View {
        HStack {
            if let search = observed.apiResponse?.menu.search {
                HStack {
                    ImageDownloader(search.icon, renderMode: .template)
                        .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.58))
                        .frame(width: 18.4618, height: 18.7)
                    
                    TextField("", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.regularFont(17))
                        .placeholder(when: searchText.isEmpty) {
                            Text(search.label ?? "").foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.58))
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                        .transition(.move(edge: .trailing))
                        //.animation(.default)
                    }
                }
                .frame(height: 42)
                .padding(.horizontal, 16)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.trailing, -8)
            }
            
            if let filter = observed.apiResponse?.menu.filter {
                Button {
                    observed.apiResponse = nil
                    observed.pageCount = 1
                    observed.apiRequest = ApiRequest(apiURL: filter.apiURL, method: filter.apiMethod)
                    observed.fetchApiData(apiRequest: observed.apiRequest)
                } label : {
                    ImageDownloader(filter.icon, renderMode: .template)
                        .viewIconModifierSize(imageWidth: 24, imageHeight: 16, iconSize: 42, imageColor: Color(uiColor: .systemGray), iconColor: Color(.systemGray6))
                        .padding(.trailing, 15)
                }
            } else if let filter = observed.apiResponse?.menu.filterIcon {
                Button {
                    observed.apiResponse = nil
                    observed.pageCount = 1
                    observed.apiRequest = ApiRequest(apiURL: filter.apiURL, method: filter.apiMethod)
                    observed.fetchApiData(apiRequest: observed.apiRequest)
                } label : {
                    ImageDownloader(filter.icon)
                        .frame(width: 42, height: 42)
                        .padding(.trailing, 15)
                }
            }
        }
        .padding(.top, 10)
    }
    
    //MARK: CHATLIST
    var chatList: some View {
        VStack {
            if let data = observed.apiResponse?.menu.chats {
                List {
                    Section(header:
                                VStack {
                        if observed.archived {
                            HStack {
                                Spacer()
                                Text((mode == .inactive) ? (observed.apiResponse?.menu.editDescription ?? "") : (observed.apiResponse?.menu.doneDescription ?? ""))
                                    .font(.regularFont(14))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(Color(red: 0.43, green: 0.43, blue: 0.43))
                                Spacer()
                            }.textCase(nil)
                        } else {
                            VStack {
                                if let activeUserResponse = observed.activeUserResponse {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack {
                                            ForEach(activeUserResponse.data, id: \.id) { item in
                                                OnlineMembers(userImage: item.avatar ?? nil, userName: item.name, isVerified: item.verified ?? false)
                                                    .padding(.horizontal, 6)
                                                    .onTapGesture {
                                                        currentChatSelected = item
                                                    }
                                            }
                                        }
                                    }
                                    .textCase(nil) //Handle Auto Capitalize
                                    .frame(height: activeUserResponse.data.count>0 ? 100 : 0)
                                }
                            }.padding(.horizontal, -13)
                        }
                    }
                    ) {
                        if !observed.archived {
                            if let archived = observed.apiResponse?.menu.archived {
                                NavigationLink(destination: ChatListView(apiRequest: apiRequest, archivedView: true, observed: archivedObserved, chatObserved: chatObserved, archivedObserved: archivedObserved).toolbar(.hidden, for: .tabBar), label: {
                                    HStack {
                                        ImageDownloader(archived.icon, renderMode: .template)
                                            .frame(width: 28, height: 28)
                                        Text(archived.label ?? "")
                                            .font(.semiBoldFont(17))
                                        Spacer()
                                    }
                                })
                            }
                        }
                        if let filterTitle = observed.apiResponse?.menu.filterTitle {
                            HStack {
                                Text(filterTitle)
                                    .font(.semiBoldFont(17))
                                Spacer()
                            }
                        }
                        if data.count>0 {
                            ForEach(data, id: \.id) { item in
                                ChatItem(apiResponse: observed.apiResponse, item: item, editMode: $mode)
                                    .id(item)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        if mode == .active {
                                            if let index = data.firstIndex(of: item) {
                                                observed.apiResponse?.menu.chats[index].isSelected = !(item.isSelected ?? false)
                                                showEditingOptions.toggle()
                                            }
                                        } else {
                                            chatSelected = item
                                            DispatchQueue.main.async {
                                                if !(item.chat.protected ?? false) {
                                                    toggleSelection(for: item.chat)
                                                } else {
                                                    showingGroupPasswordAccess.toggle()
                                                }
                                            }
                                        }
                                    }
                                    .navigationDestination(isPresented: Binding<Bool>( get: { selectedIndexes.contains(item.chat) },
                                                                                       set: { newValue in
                                        if newValue {
                                            selectedIndexes.insert(item.chat)
                                        } else {
                                            selectedIndexes.remove(item.chat)
                                        }
//                                        if let index = data.firstIndex(of: item) {
//                                            observed.apiResponse?.menu.chats[index].unread = 0
//                                        }
                                    })) {
                                        UserChatDetail(userDetails: item.chat, password: passwordText)
                                            .toolbar(.hidden, for: .tabBar)
                                            .toolbarRole(.editor)
                                            .onAppear {
                                                if let index = data.firstIndex(of: item) {
                                                    observed.apiResponse?.menu.chats[index].unread = 0
                                                }                                            }
                                    }
                                    .navigationDestination(isPresented: $showProfilePage) {
                                        if let chatSelected = chatSelected {
                                            if chatSelected.chat.chatType=="user"  {
                                                UserInfo(id: chatSelected.id).toolbarRole(.editor)
                                            } else {
                                                GroupInfo(userDetails: chatSelected.chat).toolbarRole(.editor)
                                            }
                                        }
                                    }
                                    .onAppear {
                                        Task {
                                            if observed.hasReachedEnd(of: item, array: data) {
                                                observed.fetchApiData(apiRequest: observed.apiRequest)
                                            }
                                        }
                                    }
                                    .swipeActions {
                                        if let swipeOptions = observed.apiResponse?.menu.swipeOptions {
                                            ForEach(swipeOptions.reversed()) { swipeOption in
                                                swipeOptionView(swipeOption, item: item)
                                            }
                                        }
                                    }
                            }
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        } else if let noData = observed.apiResponse?.menu.noData {
                            HStack {
                                Spacer()
                                LazyVStack {
                                    ImageDownloader(noData.icon)
                                        .frame(width: 120, height: 120)
                                    Text(noData.label ?? "")
                                        .font(.regularFont(18))
                                        .foregroundColor(Color(red: 0.63, green: 0.63, blue: 0.63))
                                }
                                Spacer()
                            } .listRowSeparator(.hidden)
                        }
                    }
                    .listSectionSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .refreshable {
                    reload()
                }
                .toolbar {
                    EditButton()
                        .font(.semiBoldFont(13))
                        .background(Color(.systemGray6))
                        .cornerRadius(30)
                        .onTapGesture {
                            showEditingOptions.toggle()
                        }
                }
                .environment(\.editMode, $mode)
                .scrollContentBackground(.hidden)
                .listStyle(.grouped)
                .onAppear {
                    observed.fetchOnlineMembers()
                }
                .toolbar(mode == .active ? .hidden : .visible, for: .tabBar)
                .fullScreenCover(isPresented: $showMoreOptions, content: {
                    chatCustomDialog
                        .onAppear {
                            if let chatSelected = chatSelected {
                                observed.fetchChatMenus(chat: chatSelected, apiRequest: apiRequest)
                            }
                            UIView.setAnimationsEnabled(false)
                        }
                        .onDisappear {
                            observed.moreMenus = nil
                        }
                })
                .fullScreenCover(isPresented: .constant(muteDialog != nil ? true : false), content: {
                    ShowCustomDialogSheet(action: { muteDialog = nil }, content: {
                        VStack(spacing: 30) {
                            Text(muteDialog?.label ?? "")
                                .font(.semiBoldFont(20))
                                .foregroundColor(Color(.label))
                            Text(muteDialog?.description ?? "")
                                .font(.regularFont(14))
                                .foregroundColor(Color(.label))
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .multilineTextAlignment(.center)

                            VStack(alignment:.leading) {
                                
                                if let buttons = muteDialog?.buttons {
                                    ForEach(buttons) { buttons in
                                        muteDialogView(buttons)
                                    }
                                }
                            }
                        }
                        .padding()
                    })
                })
                .fullScreenCover(isPresented: .constant(reportBlockDialog != nil ? true : false), content: {
                    ShowCustomDialogSheet(action: { reportBlockDialog = nil }, content: {
                        VStack(spacing: 30) {
                            Text(reportBlockDialog?.label ?? "")
                                .font(.semiBoldFont(20))
                                .foregroundColor(Color(.label))
                            Text(reportBlockDialog?.description ?? "")
                                .font(.regularFont(14))
                                .foregroundColor(Color(.label))
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .multilineTextAlignment(.center)

                            VStack(alignment:.leading) {
                                
                                if let buttons = reportBlockDialog?.buttons {
                                    ForEach(buttons) { button in
                                        reportBlockDialogView(button, lastIndex: buttons.last==button)
                                    }
                                } else if let confirmText = reportBlockDialog?.confirmText {
                                    Button {
                                        if let chatSelected = chatSelected {
                                            observed.reportChat(chat: chatSelected, apiRequest: ApiRequest(apiURL: reportBlockDialog?.apiUrl, method: reportBlockDialog?.apiMethod), block: false, leave: reportBlockDialog?.key=="reportExit" ? true : false)
                                        }
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
                .fullScreenCover(isPresented: .constant(deleteDialog != nil ? true : false), content: {
                    ShowCustomDialogSheet(action: { deleteDialog = nil }, content: {
                        VStack(spacing: 30) {
                            Text(deleteDialog?.label ?? "")
                                .font(.semiBoldFont(20))
                                .foregroundColor(Color(.label))
                            Text(deleteDialog?.description ?? "")
                                .font(.regularFont(14))
                                .foregroundColor(Color(.label))
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .multilineTextAlignment(.center)

                            VStack(alignment:.leading) {
                                
                                if let buttons = deleteDialog?.buttons {
                                    ForEach(buttons) { button in
                                        deleteDialogView(button, lastIndex: buttons.last==button)
                                    }
                                } else if let confirmText = deleteDialog?.confirmText {
                                    Button {
                                        if let chatSelected = chatSelected {
                                            observed.readDeleteChatNotification(chats: [chatSelected], apiRequest: ApiRequest(apiURL: deleteDialog?.apiUrl, method: deleteDialog?.apiMethod))
                                        }
                                        deleteDialog = nil
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
            }
            if showingGroupPasswordAccess {
                VStack {}
                    .fullScreenCover(isPresented: $showingGroupPasswordAccess, content: {
                        GroupPasswordAccess(chatSelected: chatSelected!.chat, protectedGroup: chatSelected?.protectedGroup, showingGroupPasswordAccess: $showingGroupPasswordAccess, currentChatSelected: $currentChatSelected, passwordText: $passwordText)
                    })
                    .onAppear {
                        UIView.setAnimationsEnabled(false)
                    }
            }
            if mode == .active {
                HStack {
                    
                    if let footer = observed.apiResponse?.menu.footer {
                        ForEach(footer) { footer in
                            footerView(footer)
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .overlay(Rectangle().frame(width: nil, height: 0.2).foregroundColor(Color.gray), alignment: .top)
                //.shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: -5)
                .onAppear {
                    UIView.setAnimationsEnabled(false)
                }
            }
        }
    }
    
    @ViewBuilder
    func muteDialogView(_ buttons: FetchResponse) -> some View {
        Button {
            observed.muteChatNotifications(apiRequest: ApiRequest(apiURL: muteDialog?.apiUrl, method: muteDialog?.apiMethod), chat: chatSelected!, time: buttons.value)
            muteDialog = nil
        } label: {
            HStack {
                Text(buttons.label ?? "")
                    .font(.regularFont(16))
                Spacer()
            }
        }.contentShape(Rectangle())
        HorizontalSeparatorView()
    }
    
    @ViewBuilder
    func reportBlockDialogView(_ button: FetchResponse, lastIndex: Bool) -> some View {
        Button {
            if button.subDialog==nil {
                if let chatSelected = chatSelected {
                    if button.id=="block" {
                        observed.blockChat(chat: chatSelected, apiRequest: ApiRequest(apiURL: button.apiURL, method: button.apiMethod))
                    } else {
                        observed.reportChat(chat: chatSelected, apiRequest: ApiRequest(apiURL: button.apiURL, method: button.apiMethod), block: button.id=="reportBlock" ? true : false, leave: false)
                    }
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
    
    @ViewBuilder
    func deleteDialogView(_ button: FetchResponse, lastIndex: Bool) -> some View {
        Button {
            if button.subDialog==nil {
                if let chatSelected = chatSelected {
                    observed.readDeleteChatNotification(chats: [chatSelected], apiRequest: ApiRequest(apiURL: deleteDialog?.apiUrl, method: deleteDialog?.apiMethod))
                }
            }
            deleteDialog = button.subDialog
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
    
    @ViewBuilder
    func footerView(_ footer: FetchResponse) -> some View {
        if let data = observed.apiResponse?.menu.chats {
            let indexArray = data.filter{ $0.isSelected ?? false }.map{ observed.apiResponse?.menu.chats.firstIndex(of: $0) ?? 0 }
            
            if footer.id=="archive" || footer.id=="unarchive" { //ARCHIVE BUTTON
                Button {
                    let chatIDs = data.filter{ $0.isSelected ?? false }.map{ $0.id }
                    observed.archiveChat(chatIds: chatIDs)
                    
                    mode.toggle()
                    for index in indexArray {
                        observed.apiResponse?.menu.chats[index].isSelected = false
                    }
                } label: {
                    Text(footer.label ?? "")
                }.disabled(indexArray.count > 0 ? false : true)
                
                Spacer()
            } else if footer.id=="read" { //READ ALL BUTTON
                Button {
                    let chatArray = data.filter{ $0.isSelected ?? false }
                    observed.readDeleteChatNotification(chats: chatArray, apiRequest: ApiRequest(apiURL: footer.apiURL, method: footer.apiMethod))
                    
                    mode.toggle()
                    for index in indexArray {
                        observed.apiResponse?.menu.chats[index].isSelected = false
                    }
                } label: {
                    Text(indexArray.count>1 ? (footer.labelSelected ?? "") : (footer.label ?? ""))
                }.disabled(indexArray.count > 0 ? false : true)
                
                Spacer()
            } else if footer.id=="delete" { //DELETE BUTTON
                let checkIfGroupSelected = indexArray.contains { index in
                    return observed.apiResponse?.menu.chats[index].chat.chatType == "group"
                }
                Button {
                    let chatIDs = data.filter{ $0.isSelected ?? false }.map{ data in
                        return ChatIDAndType(id: data.id, chatType: (data.chat.chatType ?? "user"))
                    }
                    observed.deleteConversation(chatIds: chatIDs, apiRequest: ApiRequest(apiURL: footer.apiURL, method: footer.apiMethod))
                    
                    mode.toggle()
                    for index in indexArray {
                        observed.apiResponse?.menu.chats[index].isSelected = false
                    }
                } label: {
                    Text(footer.label ?? "")
                }.disabled((!checkIfGroupSelected && indexArray.count > 0) ? false : true)
            }
        }
    }
    
    @ViewBuilder
    func swipeOptionView(_ swipeOption: SwipeOptions, item: LastChatData) -> some View {
        if swipeOption.id=="archive" || swipeOption.id=="unarchive" {
            Button {
                observed.archiveChat(chatIds: [item.id])
            } label: {
                Label(swipeOption.label ?? "", image: swipeOption.id=="archive" ? "archived" : "unarchived")
                    .font(.regularFont(12))
                //                                            Label(title: {
                //                                                Text(archive.label ?? "")
                //                                            }, icon: {
                //                                                if let image = archive.icon {
                //                                                    ImageFetch(image)
                //                                                }
                //                                                }
                //                                            }).font(.regularFont(12))
            }
            .tint(Color.purple)
        } else if swipeOption.id=="pin" {
            if !observed.archived {
                Button {
                    observed.pinChat(chat: item)
                } label: {
                    Label((item.pin ?? false) ? (swipeOption.labelSelected ?? "") : (swipeOption.label ?? ""), image: (item.pin ?? false) ? "unpinned" : "pinned")
                        .font(.regularFont(12))
                }
                .tint(Color.blue)
            }
        } else if swipeOption.id=="more" {
            Button {
                chatSelected = item
                showMoreOptions.toggle()
                
            } label: {
                Label(swipeOption.label ?? "", image: "more")
                    .font(.regularFont(12))
            }
            .tint(Color(uiColor: .systemGray3))
        }
    }
    
    var chatCustomDialog: some View {
        Group {
            if let moreMenus = observed.moreMenus?.menu {
                CustomDialog(isPresented: $showMoreOptions, bodyContent: {
                    VStack {
                        ForEach(moreMenus) { moreMenu in
                            if moreMenu.id=="profile" {
                                Button {
                                    showMoreOptions.toggle()
                                    showProfilePage.toggle()
                                } label: {
                                    HStack {
                                        ImageDownloader(moreMenu.icon, renderMode: .template)
                                            .viewIconModifier(imageSize: 22, iconSize: 32, imageColor: Color(.label), iconColor: Color(.systemGray5))
                                        Text(moreMenu.label ?? "")
                                        Spacer()
                                    }.foregroundColor(Color(.label))
                                }
                            } else if moreMenu.id=="read" {
                                Button {
                                    showMoreOptions.toggle()
                                    if let chatSelected = chatSelected {
                                        observed.readDeleteChatNotification(chats: [chatSelected], apiRequest: ApiRequest(apiURL: moreMenu.apiURL, method: moreMenu.apiMethod))
                                    }
                                } label: {
                                    HStack {
                                        ImageDownloader(moreMenu.icon, renderMode: .template)
                                            .viewIconModifier(imageSize: 22, iconSize: 32, imageColor: Color(.label), iconColor: Color(.systemGray5))
                                        Text(moreMenu.label ?? "")
                                        Spacer()
                                    }.foregroundColor(Color(.label))
                                }
                            } else if moreMenu.id=="mute" {
                                Button {
                                    if chatSelected?.mute ?? false { // Unmute
                                        if let muteDialog = moreMenu.unMuteDialog {
                                            observed.muteChatNotifications(apiRequest: ApiRequest(apiURL: muteDialog.apiUrl, method: muteDialog.apiMethod), chat: chatSelected!)
                                        }
                                    } else { // Mute
                                        if let dialog = moreMenu.muteDialog {
                                            muteDialog = dialog
                                        }
                                    }
                                    showMoreOptions.toggle()
                                } label: {
                                    HStack {
                                        ImageDownloader(moreMenu.icon, renderMode: .template)
                                            .viewIconModifier(imageSize: 18, iconSize: 32, imageColor: Color(.label), iconColor: Color(.systemGray5))
                                        Text(moreMenu.label ?? "")
                                        Spacer()
                                    }.foregroundColor(Color(.label))
                                }
                            } else if moreMenu.id=="report" {
                                Button {
                                    if let dialog = chatSelected?.chat.chatType == "group" ? moreMenu.reportGroupDialog : moreMenu.reportUserDialog {
                                        reportBlockDialog = dialog
                                    }
                                    showMoreOptions.toggle()
                                } label: {
                                    HStack {
                                        ImageDownloader(moreMenu.icon, renderMode: .template)
                                            .viewIconModifier(imageSize: 22, iconSize: 32, imageColor: Color(.label), iconColor: Color(.systemGray5))
                                        Text(moreMenu.label ?? "")
                                        Spacer()
                                    }.foregroundColor(Color(.label))
                                }
                            } else if moreMenu.id=="delete" {
                                Button {
                                    if let dialog = moreMenu.deleteDialog {
                                        deleteDialog = dialog
                                    }
                                    showMoreOptions.toggle()
                                } label: {
                                    HStack {
                                        ImageDownloader(moreMenu.icon)
                                            .frame(width: 32, height: 32)
                                        Text(moreMenu.label ?? "")
                                            .foregroundColor(.red)
                                        Spacer()
                                    }.foregroundColor(Color(.label))
                                }
                            } else if moreMenu.id=="block" {
                                Button {
                                    if let chatSelected, chatSelected.blocked ?? false {
                                        observed.blockChat(chat: chatSelected, apiRequest: ApiRequest(apiURL: moreMenu.apiURL, method: moreMenu.apiMethod))
                                    } else {
                                        reportBlockDialog = moreMenu.blockDialog
                                    }
                                    showMoreOptions.toggle()
                                } label: {
                                    HStack {
                                        ImageDownloader(moreMenu.icon)
                                            .frame(width: 32, height: 32)
                                        Text(moreMenu.label ?? "")
                                            .foregroundColor(.red)
                                        Spacer()
                                    }.foregroundColor(Color(.label))
                                }
                            }
                            if let index = moreMenus.firstIndex(of: moreMenu) {
                                if index != moreMenus.count-1 && index != moreMenus.count-2 {
                                    Divider()
                                }
                            }
                        }
                    }
                    .accentColor(.black)
                    .padding()
                }, cancelContent: {
                    VStack {
                        if let moreMenu = moreMenus.filter({ $0.id=="cancel" }) {
                            if let cancelMenu = moreMenu.first {
                                Button {
                                    showMoreOptions.toggle()
                                } label: {
                                    HStack {
                                        Spacer()
                                        Text(cancelMenu.label ?? "")
                                            .font(.semiBoldFont(16))
                                        Spacer()
                                    }
                                    .foregroundColor(Color(.label))
                                    .accentColor(.black)
                                    .padding()
                                    .background(Color(.tertiarySystemBackground))
                                    .frame(height: 53)
                                }.background(Color(.tertiarySystemBackground)).cornerRadius(10)
                            }
                        }
                    }
                })
                .background(BackgroundBlurView())
                .background { Color.black.opacity(0.25).edgesIgnoringSafeArea(.all) }
            }
        }
    }
    
    //MARK: RELOAD
    func reload() {
        observed.apiResponse = nil
        observed.pageCount = 1
        observed.fetchApiData(apiRequest: observed.apiRequest)
    }
    
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatListView()
//    }
//}
