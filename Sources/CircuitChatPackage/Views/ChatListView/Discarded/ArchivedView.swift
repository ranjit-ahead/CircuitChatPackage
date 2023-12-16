//
//  ArchivedView.swift
//  Chat
//
//  Created by Apple on 29/09/23.
//

import SwiftUI

//struct ArchivedView: View {
//
//    var apiRequest: ApiRequest
//
//    @State var archivedView = false
//
//    @EnvironmentObject var socketIO: SocketIOManager
//
//    @StateObject private var observed = Observed()
//    @StateObject private var showingNewChat = NewChatNavigation()
//
//    @Environment(\.editMode) private var editMode
//
//    @State private var searchText = ""
//
//    @State private var showingGroupPasswordAccess = false
//    @State private var chatSelected: LastChatData?
//    @State private var currentChatSelected: Chat?
//    @State private var passwordText = ""
//
//    @State private var showMoreOptions = false
//
//    @State private var mode: EditMode = .inactive //< -- Here
//
//    @State private var showEditingOptions = false
//
//    @State private var showProfilePage = false
//
//    @State private var muteDialog: DialogView?
//    @State private var reportBlockDialog: DialogView?
//    @State private var deleteDialog: DialogView?
//
//    @State private var selectedIndexes: Set<Chat> = []
//    private func toggleSelection(for index: Chat) {
//        if selectedIndexes.contains(index) {
//            selectedIndexes.remove(index)
//        } else {
//            selectedIndexes.insert(index)
//        }
//    }
//
//    var body: some View {
////        NavigationStack {
//            VStack {
//                searchBarView
//
//                if observed.apiResponse == nil {
//                    ProgressView()
//                } else {
//                    if let _ = observed.apiResponse?.menu.chats {
//                        chatList
//                    }
//                }
//            }
////            .navigationDestination(isPresented: .constant(currentChatSelected != nil ? true : false)) {
////                if let chatSelected = currentChatSelected {
////                    UserChatDetail(userDetails: chatSelected, password: passwordText)
////                        .toolbar(.hidden, for: .tabBar)
////                        .toolbarRole(.editor)
////                } else {
////                    Text("Get out")
////                }
////            }
//            .onAppear {
//                currentChatSelected = nil
//            }
//            .navigationTitle(observed.apiResponse?.menu.navigationTitle ?? "")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .principal) {
//                    Text(observed.apiResponse?.menu.navigationTitle ?? "")
//                        .font(.semiBoldFont(22))
//                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    HStack(spacing: 15) {
//                        //New Chat
//                        if let newChat = observed.apiResponse?.menu.newChat {
//                            Button {
//                                showingNewChat.showSheet.toggle()
//                            } label: {
//                                ImageDownloader(newChat.icon, renderMode: .template)
//                                    .frame(width: 25, height: 25)
//                                    .foregroundColor(Color(UIColor.label))
//                            }
//                            .sheet(isPresented: $showingNewChat.showSheet) {
//                                NewChatView(apiRequest: ApiRequest(apiURL: newChat.apiURL, method: newChat.apiMethod), currentChatSelected: $currentChatSelected)
//                            }
//                        }
//                    }
//                }
//            }
////        }
////        .environmentObject(showingNewChat)
////        .environmentObject(observed)
//        .onAppear {
//            if observed.apiResponse == nil {
//                observed.apiResponse = nil
//                observed.archived = archivedView
//                observed.apiRequest = apiRequest
//                observed.fetchApiData(apiRequest: observed.apiRequest)
//            }
//        }
//
//        //MARK: SOCKET
//
//        //New Message
//        .onChange(of: socketIO.newMessageArray, perform: { newMessageArray in
//            var checkIfUserExist = false
//            if let lastMessageDataArray = observed.apiResponse?.menu.chats {
//
//                var checkPinnedMessages = 0
//                for lastMessageData in lastMessageDataArray {
//                    if lastMessageData.pin ?? false {
//                        checkPinnedMessages += 1
//                    }
//                }
//
//                for lastMessageData in lastMessageDataArray {
//                    if let newMessage = newMessageArray?.first {
//                        var id = newMessage.sender
//                        if newMessage.receiverType == "group" {
//                            id = newMessage.receiver
//                        }
//                        if lastMessageData.chat.id == id {
//                            if let index = lastMessageDataArray.firstIndex(of: lastMessageData) {
//                                let unreadCount = Int(observed.apiResponse?.menu.chats[index].unread ?? 0)
//                                observed.apiResponse?.menu.chats[index].userChatData = newMessage
//                                observed.apiResponse?.menu.chats[index].unread = unreadCount+1
//                                checkIfUserExist = true
//
//                                if let data = observed.apiResponse?.menu.chats[index] {
//                                    observed.apiResponse?.menu.chats.remove(at: index)
//                                    observed.apiResponse?.menu.chats.insert(data, at: checkPinnedMessages)
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//            if !checkIfUserExist {
//                reload()
//            }
//        })
//
//        //Active Friends
//        .onChange(of: socketIO.activeFriendsData, perform: { activeFriendsData in
//            if let activeFriendsData = activeFriendsData?.first {
//                var checkIfActiveFriendExist = false
//                if let activeFriendsDataArray = observed.activeUserResponse?.data {
//                    for data in activeFriendsDataArray {
//                        if data.id == activeFriendsData.id, (activeFriendsData.active==false) {
//                            checkIfActiveFriendExist = true
//                            if let index = activeFriendsDataArray.firstIndex(of: data) {
//                                observed.activeUserResponse?.data.remove(at: index)
//                                break
//                            }
//                        }
//                    }
//                }
//                if !checkIfActiveFriendExist {
//                    observed.activeUserResponse?.data.append(activeFriendsData)
//                }
//            }
//            if let data = observed.apiResponse?.menu.chats {
//                for index in 0..<data.count {
//                    if let activeFriendsData = activeFriendsData?.first {
//                        if let chatId = observed.apiResponse?.menu.chats[index].chat.id {
//                            if chatId == activeFriendsData.id {
//                                observed.apiResponse?.menu.chats[index].chat.active = activeFriendsData.active
//                            }
//                        }
//                    }
//                }
//            }
//        })
//
//        //Message Deleted
//        .onChange(of: socketIO.messageDeleted, perform: { messageDeleted in
//            if let data = observed.apiResponse?.menu.chats {
//                for index in 0..<data.count {
//                    if let messageId = messageDeleted?.first?.first {
//                        if observed.apiResponse?.menu.chats[index].userChatData?.id == messageId {
//                            observed.apiResponse?.menu.chats[index].userChatData?.contentType = "deleted"
//                            observed.apiResponse?.menu.chats[index].userChatData?.text = "This message is deleted"
//                            break
//                        }
//                    }
//                }
//            }
//        })
//
//        //Message Deleted Everyone
//        .onChange(of: socketIO.messageDeletedEveryone, perform: { messageDeletedEveryone in
//            if let data = observed.apiResponse?.menu.chats {
//                for index in 0..<data.count {
//                    if let messageDeletedEveryone = messageDeletedEveryone?.first {
//                        if observed.apiResponse?.menu.chats[index].userChatData?.id == messageDeletedEveryone.id {
//                            observed.apiResponse?.menu.chats[index].userChatData = messageDeletedEveryone
//                            break
//                        }
//                    }
//                }
//            }
//        })
//
//        //Chat Archived
//        .onChange(of: socketIO.chatArchived, perform: { chatArchived in
//            if let data = observed.apiResponse?.menu.chats {
//                for index in 0..<data.count {
//                    if let messageId = chatArchived?.first?.first {
//                        if observed.apiResponse?.menu.chats[index].id == messageId {
//                            observed.apiResponse?.menu.chats.remove(at: index)
//                            break
//                        }
//                    }
//                }
//            }
//        })
//
//        //Message Recieved
//        .onChange(of: socketIO.messageRecieved, perform: { messageRecieved in
//            if let data = observed.apiResponse?.menu.chats {
//                for index in 0..<data.count {
//                    if let messageId = messageRecieved?.first {
//                        if observed.apiResponse?.menu.chats[index].userChatData?.id == messageId {
//                            observed.apiResponse?.menu.chats[index].userChatData?.messageStatus = 2
//                            break
//                        }
//                    }
//                }
//            }
//        })
//
//        //Message Seen
//        .onChange(of: socketIO.messageSeen, perform: { messageSeen in
//            if let data = observed.apiResponse?.menu.chats {
//                for index in 0..<data.count {
//                    if let messageId = messageSeen?.first?.first {
//                        if observed.apiResponse?.menu.chats[index].userChatData?.id == messageId {
//                            observed.apiResponse?.menu.chats[index].userChatData?.messageStatus = 3
//                        }
//                    }
//                }
//            }
//        })
//
//        //Chat Unarchived
//        .onChange(of: socketIO.chatUnarchived) { _ in
//            reload()
//        }
//
//        //Conversation Deleted
//        .onChange(of: socketIO.conversationDeleted) { _ in
//            reload()
//        }
//
//        //User Action
//        .onChange(of: socketIO.userAction, perform: { userAction in
//            if userAction != nil {
//                if let userAction = userAction?.first {
//                    if let data = observed.apiResponse?.menu.chats {
//                        for userChatData in data {
//                            if userChatData.id==userAction.chat && uID != userAction.user?.id {
//                                if let index = observed.apiResponse?.menu.chats.firstIndex(of: userChatData) {
//                                    observed.apiResponse?.menu.chats[index].action = userAction.label
//                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(3)) {
//                                        observed.apiResponse?.menu.chats[index].action = nil
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//                socketIO.userAction = nil
//            }
//        })
//
//        //Chat read
//        .onChange(of: socketIO.chatRead, perform: { chatResponse in
//            if let data = observed.apiResponse?.menu.chats {
//                if let chats = chatResponse?.chat {
//                    for lastChatData in data {
//                        for chat in chats {
//                            if lastChatData.id==chat {
//                                if let index = observed.apiResponse?.menu.chats.firstIndex(of: lastChatData) {
//                                    observed.apiResponse?.menu.chats[index].unread = 0
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        })
//
//        //Chat Unread
//        .onChange(of: socketIO.chatUnread, perform: { chatResponse in
//            if let data = observed.apiResponse?.menu.chats {
//                if let chats = chatResponse?.chat {
//                    for lastChatData in data {
//                        for chat in chats {
//                            if lastChatData.id==chat {
//                                if let index = observed.apiResponse?.menu.chats.firstIndex(of: lastChatData) {
//                                    observed.apiResponse?.menu.chats[index].unread = 1
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        })
//
//        //Chat Mute
//        .onChange(of: socketIO.chatMute, perform: { chatResponse in
//            if let data = observed.apiResponse?.menu.chats {
//                if let chats = chatResponse?.chat {
//                    for lastChatData in data {
//                        for chat in chats {
//                            if lastChatData.id==chat {
//                                if let index = observed.apiResponse?.menu.chats.firstIndex(of: lastChatData) {
//                                    observed.apiResponse?.menu.chats[index].mute = true
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        })
//
//        //Chat Unmute
//        .onChange(of: socketIO.chatUnmute, perform: { chatResponse in
//            if let data = observed.apiResponse?.menu.chats {
//                if let chats = chatResponse?.chat {
//                    for lastChatData in data {
//                        for chat in chats {
//                            if lastChatData.id==chat {
//                                if let index = observed.apiResponse?.menu.chats.firstIndex(of: lastChatData) {
//                                    observed.apiResponse?.menu.chats[index].mute = false
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        })
//
//        //Chat Pin
//        .onChange(of: socketIO.chatPin, perform: { chatResponse in
//            if let data = observed.apiResponse?.menu.chats {
//                if let chats = chatResponse?.chat {
//                    for lastChatData in data {
//                        for chat in chats {
//                            if lastChatData.id==chat {
//                                if let index = observed.apiResponse?.menu.chats.firstIndex(of: lastChatData) {
//                                    observed.apiResponse?.menu.chats[index].pin = true
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        })
//
//        //Chat Unpin
//        .onChange(of: socketIO.chatUnpin, perform: { chatResponse in
//            if let data = observed.apiResponse?.menu.chats {
//                if let chats = chatResponse?.chat {
//                    for lastChatData in data {
//                        for chat in chats {
//                            if lastChatData.id==chat {
//                                if let index = observed.apiResponse?.menu.chats.firstIndex(of: lastChatData) {
//                                    observed.apiResponse?.menu.chats[index].pin = false
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        })
//    }
//
//    var searchBarView: some View {
//        HStack {
//            if let search = observed.apiResponse?.menu.search {
//                HStack {
//                    ImageDownloader(search.icon, renderMode: .template)
//                        .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.58))
//                        .frame(width: 18.4618, height: 18.7)
//
//                    TextField("", text: $searchText)
//                        .textFieldStyle(PlainTextFieldStyle())
//                        .font(.regularFont(17))
//                        .placeholder(when: searchText.isEmpty) {
//                            Text(search.label ?? "").foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.58))
//                        }
//
//                    if !searchText.isEmpty {
//                        Button(action: {
//                            searchText = ""
//                        }) {
//                            Image(systemName: "xmark.circle.fill")
//                                .foregroundColor(.gray)
//                        }
//                        .transition(.move(edge: .trailing))
//                        //.animation(.default)
//                    }
//                }
//                .frame(height: 42)
//                .padding(.horizontal, 16)
//                .background(Color(.systemGray6))
//                .cornerRadius(10)
//                .padding(.horizontal)
//                .padding(.trailing, -8)
//            }
//
//            if let filter = observed.apiResponse?.menu.filter {
//                Button {
//                    observed.apiResponse = nil
//                    observed.pageCount = 1
//                    observed.apiRequest = ApiRequest(apiURL: filter.apiURL, method: filter.apiMethod)
//                    observed.fetchApiData(apiRequest: observed.apiRequest)
//                } label : {
//                    ImageDownloader(filter.icon, renderMode: .template)
//                        .viewIconModifierSize(imageWidth: 24, imageHeight: 16, iconSize: 42, imageColor: Color(uiColor: .systemGray), iconColor: Color(.systemGray6))
//                        .padding(.trailing, 15)
//                }
//            } else if let filter = observed.apiResponse?.menu.filterIcon {
//                Button {
//                    observed.apiResponse = nil
//                    observed.pageCount = 1
//                    observed.apiRequest = ApiRequest(apiURL: filter.apiURL, method: filter.apiMethod)
//                    observed.fetchApiData(apiRequest: observed.apiRequest)
//                } label : {
//                    ImageDownloader(filter.icon)
//                        .frame(width: 42, height: 42)
//                        .padding(.trailing, 15)
//                }
//            }
//        }
//        .padding(.top, 10)
//    }
//
//    //MARK: CHATLIST
//    var chatList: some View {
//        VStack {
//            if let data = observed.apiResponse?.menu.chats {
//                List {
//                    Section(header:
//                                VStack {
//                        if observed.archived {
//                            HStack {
//                                Spacer()
//                                Text((mode == .inactive) ? (observed.apiResponse?.menu.editDescription ?? "") : (observed.apiResponse?.menu.doneDescription ?? ""))
//                                    .font(.regularFont(14))
//                                    .multilineTextAlignment(.center)
//                                    .foregroundColor(Color(red: 0.43, green: 0.43, blue: 0.43))
//                                Spacer()
//                            }.textCase(nil)
//                        } else {
//                            VStack {
//                                if let activeUserResponse = observed.activeUserResponse {
//                                    ScrollView(.horizontal, showsIndicators: false) {
//                                        HStack {
//                                            ForEach(activeUserResponse.data, id: \.id) { item in
//                                                OnlineMembers(userImage: item.avatar ?? nil, userName: item.name, isVerified: item.verified ?? false)
//                                                    .padding(.horizontal, 6)
//                                                    .onTapGesture {
//                                                        currentChatSelected = item
//                                                    }
//                                            }
//                                        }
//                                    }
//                                    .textCase(nil) //Handle Auto Capitalize
//                                    .frame(height: activeUserResponse.data.count>0 ? 100 : 0)
//                                }
//                            }.padding(.horizontal, -13)
//                        }
//                    }
//                    ) {
//                        if !observed.archived {
//                            if let archived = observed.apiResponse?.menu.archived {
//                                HStack {
//                                    ImageDownloader(archived.icon, renderMode: .template)
//                                        .frame(width: 28, height: 28)
//                                    Text(archived.label ?? "")
//                                        .font(.semiBoldFont(17))
//                                    Spacer()
//                                }
//                                .onTapGesture(perform: {
//                                    archivedView = true
//                                })
//                                .navigationDestination(isPresented: $archivedView, destination: {
//                                    ChatListView(apiRequest: apiRequest, archivedView: true).toolbar(.hidden, for: .tabBar)
//                                })
//                            }
//                        }
//                        if let filterTitle = observed.apiResponse?.menu.filterTitle {
//                            HStack {
//                                Text(filterTitle)
//                                    .font(.semiBoldFont(17))
//                                Spacer()
//                            }
//                        }
//                        if data.count>0 {
//                            ForEach(data, id: \.id) { item in
//                                ChatItem(apiResponse: observed.apiResponse, item: item, editMode: $mode)
//                                    .contentShape(Rectangle())
//                                    .onTapGesture {
//                                        if mode == .active {
//                                            if let index = data.firstIndex(of: item) {
//                                                observed.apiResponse?.menu.chats[index].isSelected = !(item.isSelected ?? false)
//                                                showEditingOptions.toggle()
//                                            }
//                                        } else {
//                                            chatSelected = item
//                                            DispatchQueue.main.async {
//                                                if !(item.chat.protected ?? false) {
//                                                    toggleSelection(for: item.chat)
//                                                } else {
//                                                    showingGroupPasswordAccess.toggle()
//                                                }
//                                            }
//                                        }
//                                    }
//                                    .navigationDestination(isPresented: Binding<Bool>( get: { selectedIndexes.contains(item.chat) },
//                                                                                       set: { newValue in
//                                        if newValue {
//                                            selectedIndexes.insert(item.chat)
//                                        } else {
//                                            selectedIndexes.remove(item.chat)
//                                        }
////                                        if let index = data.firstIndex(of: item) {
////                                            observed.apiResponse?.data[index].unread = 0
////                                        }
//                                    })) {
//                                        UserChatDetail(userDetails: item.chat, password: passwordText)
//                                            .toolbar(.hidden, for: .tabBar)
//                                            .toolbarRole(.editor)
//                                    }
//                                    .navigationDestination(isPresented: $showProfilePage) {
//                                        if let chatSelected = chatSelected {
//                                            if chatSelected.chat.chatType=="user"  {
//                                                UserInfo(id: chatSelected.id).toolbarRole(.editor)
//                                            } else {
//                                                GroupInfo(userDetails: chatSelected.chat).toolbarRole(.editor)
//                                            }
//                                        }
//                                    }
//                                    .onAppear {
//                                        Task {
//                                            if observed.hasReachedEnd(of: item, array: data) {
//                                                observed.fetchApiData(apiRequest: observed.apiRequest)
//                                            }
//                                        }
//                                    }
//                                    .swipeActions {
//                                        if let swipeOptions = observed.apiResponse?.menu.swipeOptions {
//                                            ForEach(swipeOptions.reversed()) { swipeOption in
//                                                swipeOptionView(swipeOption, item: item)
//                                            }
//                                        }
//                                    }
//                            }
//                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//                        } else if let noData = observed.apiResponse?.menu.noData {
//                            HStack {
//                                Spacer()
//                                LazyVStack {
//                                    ImageDownloader(noData.icon)
//                                        .frame(width: 120, height: 120)
//                                    Text(noData.label ?? "")
//                                        .font(.regularFont(18))
//                                        .foregroundColor(Color(red: 0.63, green: 0.63, blue: 0.63))
//                                }
//                                Spacer()
//                            } .listRowSeparator(.hidden)
//                        }
//                    }
//                    .listSectionSeparator(.hidden)
//                    .listRowBackground(Color.clear)
//                }
//                .refreshable {
//                    reload()
//                }
//                .toolbar {
//                    EditButton()
//                        .font(.semiBoldFont(13))
//                        .background(Color(.systemGray6))
//                        .cornerRadius(30)
//                        .onTapGesture {
//                            showEditingOptions.toggle()
//                        }
//                }
//                .environment(\.editMode, $mode)
//                .scrollContentBackground(.hidden)
//                .listStyle(.grouped)
//                .onAppear {
//                    observed.fetchOnlineMembers()
//                }
//                .toolbar(mode == .active ? .hidden : .visible, for: .tabBar)
//                .fullScreenCover(isPresented: $showMoreOptions, content: {
//                    chatCustomDialog
//                        .onAppear {
//                            if let chatSelected = chatSelected {
//                                observed.fetchChatMenus(chat: chatSelected, apiRequest: apiRequest)
//                            }
//                            UIView.setAnimationsEnabled(false)
//                        }
//                        .onDisappear {
//                            observed.moreMenus = nil
//                        }
//                })
//                .fullScreenCover(isPresented: .constant(muteDialog != nil ? true : false), content: {
//                    ShowCustomDialogSheet(action: { muteDialog = nil }, content: {
//                        VStack(spacing: 30) {
//                            Text(muteDialog?.label ?? "")
//                                .font(.semiBoldFont(20))
//                                .foregroundColor(Color(.label))
//                            Text(muteDialog?.description ?? "")
//                                .font(.regularFont(14))
//                                .foregroundColor(Color(.label))
//                                .frame(minWidth: 0, maxWidth: .infinity)
//                                .multilineTextAlignment(.center)
//
//                            VStack(alignment:.leading) {
//
//                                if let buttons = muteDialog?.buttons {
//                                    ForEach(buttons) { buttons in
//                                        muteDialogView(buttons)
//                                    }
//                                }
//                            }
//                        }
//                        .padding()
//                    })
//                })
//                .fullScreenCover(isPresented: .constant(reportBlockDialog != nil ? true : false), content: {
//                    ShowCustomDialogSheet(action: { reportBlockDialog = nil }, content: {
//                        VStack(spacing: 30) {
//                            Text(reportBlockDialog?.label ?? "")
//                                .font(.semiBoldFont(20))
//                                .foregroundColor(Color(.label))
//                            Text(reportBlockDialog?.description ?? "")
//                                .font(.regularFont(14))
//                                .foregroundColor(Color(.label))
//                                .frame(minWidth: 0, maxWidth: .infinity)
//                                .multilineTextAlignment(.center)
//
//                            VStack(alignment:.leading) {
//
//                                if let buttons = reportBlockDialog?.buttons {
//                                    ForEach(buttons) { button in
//                                        reportBlockDialogView(button, lastIndex: buttons.last==button)
//                                    }
//                                } else if let confirmText = reportBlockDialog?.confirmText {
//                                    Button {
//                                        if let chatSelected = chatSelected {
//                                            observed.reportChat(chat: chatSelected, apiRequest: ApiRequest(apiURL: reportBlockDialog?.apiUrl, method: reportBlockDialog?.apiMethod), block: false, leave: reportBlockDialog?.key=="reportExit" ? true : false)
//                                        }
//                                        reportBlockDialog = nil
//                                    } label: {
//                                        Text(confirmText)
//                                            .font(.regularFont(16))
//                                            .foregroundColor(.red)
//                                    }
//                                }
//                            }
//                        }
//                        .padding()
//                    })
//                })
//                .fullScreenCover(isPresented: .constant(deleteDialog != nil ? true : false), content: {
//                    ShowCustomDialogSheet(action: { deleteDialog = nil }, content: {
//                        VStack(spacing: 30) {
//                            Text(deleteDialog?.label ?? "")
//                                .font(.semiBoldFont(20))
//                                .foregroundColor(Color(.label))
//                            Text(deleteDialog?.description ?? "")
//                                .font(.regularFont(14))
//                                .foregroundColor(Color(.label))
//                                .frame(minWidth: 0, maxWidth: .infinity)
//                                .multilineTextAlignment(.center)
//
//                            VStack(alignment:.leading) {
//
//                                if let buttons = deleteDialog?.buttons {
//                                    ForEach(buttons) { button in
//                                        deleteDialogView(button, lastIndex: buttons.last==button)
//                                    }
//                                } else if let confirmText = deleteDialog?.confirmText {
//                                    Button {
//                                        if let chatSelected = chatSelected {
//                                            observed.readDeleteChatNotification(chat: chatSelected, apiRequest: ApiRequest(apiURL: deleteDialog?.apiUrl, method: deleteDialog?.apiMethod))
//                                        }
//                                        deleteDialog = nil
//                                    } label: {
//                                        Text(confirmText)
//                                            .font(.regularFont(16))
//                                            .foregroundColor(.red)
//                                    }
//                                }
//                            }
//                        }
//                        .padding()
//                    })
//                })
//            }
//            if showingGroupPasswordAccess {
//                VStack {}
//                    .fullScreenCover(isPresented: $showingGroupPasswordAccess, content: {
//                        GroupPasswordAccess(chatSelected: chatSelected!.chat, protectedGroup: chatSelected?.protectedGroup, showingGroupPasswordAccess: $showingGroupPasswordAccess, currentChatSelected: $currentChatSelected, passwordText: $passwordText)
//                    })
//                    .onAppear {
//                        UIView.setAnimationsEnabled(false)
//                    }
//            }
//            if mode == .active {
//                HStack {
//
//                    if let footer = observed.apiResponse?.menu.footer {
//                        ForEach(footer) { footer in
//                            footerView(footer)
//                        }
//                    }
//                }
//                .padding()
//                .background(.ultraThinMaterial)
//                .overlay(Rectangle().frame(width: nil, height: 0.2).foregroundColor(Color.gray), alignment: .top)
//                //.shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: -5)
//                .onAppear {
//                    UIView.setAnimationsEnabled(false)
//                }
//            }
//        }
//        .onAppear {
//            //currentChatSelected = nil
//        }
//    }
//
//    @ViewBuilder
//    func muteDialogView(_ buttons: FetchResponse) -> some View {
//        Button {
//            observed.muteChatNotifications(apiRequest: ApiRequest(apiURL: muteDialog?.apiUrl, method: muteDialog?.apiMethod), chat: chatSelected!, time: buttons.value)
//            muteDialog = nil
//        } label: {
//            HStack {
//                Text(buttons.label ?? "")
//                    .font(.regularFont(16))
//                Spacer()
//            }
//        }.contentShape(Rectangle())
//        HorizontalSeparatorView()
//    }
//
//    @ViewBuilder
//    func reportBlockDialogView(_ button: FetchResponse, lastIndex: Bool) -> some View {
//        Button {
//            if button.subdialog==nil {
//                if let chatSelected = chatSelected {
//                    if button.id=="block" {
//                        observed.blockChat(chat: chatSelected, apiRequest: ApiRequest(apiURL: button.apiURL, method: button.apiMethod))
//                    } else {
//                        observed.reportChat(chat: chatSelected, apiRequest: ApiRequest(apiURL: button.apiURL, method: button.apiMethod), block: button.id=="reportBlock" ? true : false, leave: false)
//                    }
//                }
//            }
//            reportBlockDialog = button.subdialog
//        } label: {
//            HStack {
//                if button.icon==nil {
//                    Spacer()
//                }
//                Text(button.label ?? "")
//                    .font(.regularFont(16))
//                    .foregroundColor(.red)
//                Spacer()
//                if let _ = button.icon {
//                    ImageDownloader(button.icon)
//                        .frame(width: 26, height: 26)
//                }
//            }
//        }.contentShape(Rectangle())
//        if !lastIndex {
//            HorizontalSeparatorView()
//        }
//    }
//
//    @ViewBuilder
//    func deleteDialogView(_ button: FetchResponse, lastIndex: Bool) -> some View {
//        Button {
//            if button.subdialog==nil {
//                if let chatSelected = chatSelected {
//                    observed.readDeleteChatNotification(chat: chatSelected, apiRequest: ApiRequest(apiURL: deleteDialog?.apiUrl, method: deleteDialog?.apiMethod))
//                }
//            }
//            deleteDialog = button.subdialog
//        } label: {
//            HStack {
//                if button.icon==nil {
//                    Spacer()
//                }
//                Text(button.label ?? "")
//                    .font(.regularFont(16))
//                    .foregroundColor(.red)
//                Spacer()
//                if let _ = button.icon {
//                    ImageDownloader(button.icon)
//                        .frame(width: 26, height: 26)
//                }
//            }
//        }.contentShape(Rectangle())
//        if !lastIndex {
//            HorizontalSeparatorView()
//        }
//    }
//
//    @ViewBuilder
//    func footerView(_ footer: FetchResponse) -> some View {
//        if let data = observed.apiResponse?.menu.chats {
//            let indexArray = data.filter{ $0.isSelected ?? false }.map{ observed.apiResponse?.menu.chats.firstIndex(of: $0) ?? 0 }
//
//            if footer.id=="archive" || footer.id=="unarchive" { //ARCHIVE BUTTON
//                Button {
//                    let chatIDs = data.filter{ $0.isSelected ?? false }.map{ $0.id }
//                    observed.archiveChat(chatIds: chatIDs)
//
//                    mode.toggle()
//                    for index in indexArray {
//                        observed.apiResponse?.menu.chats[index].isSelected = false
//                    }
//                } label: {
//                    Text(footer.label ?? "")
//                }.disabled(indexArray.count > 0 ? false : true)
//
//                Spacer()
//            } else if footer.id=="read" { //READ ALL BUTTON
//                Button {
//
//                } label: {
//                    Text(indexArray.count>0 ? (footer.label ?? "") : (footer.labelSelected ?? ""))
//                }
//                Spacer()
//            } else if footer.id=="delete" { //DELETE BUTTON
//                Button {
//                    let chatIDs = data.filter{ $0.isSelected ?? false }.map{ data in
//                        return ChatIDAndType(id: data.id, chatType: (data.chat.chatType ?? "user"))
//                    }
//                    observed.deleteConversation(chatIds: chatIDs)
//
//                    mode.toggle()
//                    for index in indexArray {
//                        observed.apiResponse?.menu.chats[index].isSelected = false
//                    }
//                } label: {
//                    Text(footer.label ?? "")
//                }.disabled(indexArray.count > 0 ? false : true)
//            }
//        }
//    }
//
//    @ViewBuilder
//    func swipeOptionView(_ swipeOption: SwipeOptions, item: LastChatData) -> some View {
//        if swipeOption.id=="archive" || swipeOption.id=="unarchive" {
//            Button {
//                observed.archiveChat(chatIds: [item.id])
//            } label: {
//                //observed.archived ? "Unarchive" : "Archive"
//                Label(swipeOption.label ?? "", systemImage: "archivebox.fill")
//                    .font(.regularFont(12))
//                //                                            Label(title: {
//                //                                                Text(archive.label ?? "")
//                //                                            }, icon: {
//                //                                                if let image = archive.icon {
//                //                                                    ImageFetch(image)
//                //                                                }
//                //                                                }
//                //                                            }).font(.regularFont(12))
//            }
//            .tint(Color.purple)
//        } else if swipeOption.id=="pin" {
//            if !observed.archived {
//                Button {
//                    observed.pinChat(chat: item)
//                } label: {
//                    Label((item.pin ?? false) ? (swipeOption.labelSelected ?? "") : (swipeOption.label ?? ""), systemImage: (item.pin ?? false) ? "pin.slash" : "pin")
//                        .font(.regularFont(12))
//                }
//                .tint(Color.blue)
//            }
//        } else if swipeOption.id=="more" {
//            Button {
//                chatSelected = item
//                showMoreOptions.toggle()
//
//            } label: {
//                Label(swipeOption.label ?? "", systemImage: "ellipsis.message.fill")
//                    .font(.regularFont(12))
//            }
//            .tint(Color(uiColor: .systemGray3))
//        }
//    }
//
//    var chatCustomDialog: some View {
//        Group {
//            if let moreMenus = observed.moreMenus?.menu {
//                CustomDialog(isPresented: $showMoreOptions, bodyContent: {
//                    VStack {
//                        ForEach(moreMenus) { moreMenu in
//                            if moreMenu.id=="profile" {
//                                Button {
//                                    showMoreOptions.toggle()
//                                    showProfilePage.toggle()
//                                } label: {
//                                    HStack {
//                                        ImageDownloader(moreMenu.icon, renderMode: .template)
//                                            .viewIconModifier(imageSize: 22, iconSize: 32, imageColor: Color(.label), iconColor: Color(.systemGray5))
//                                        Text(moreMenu.label ?? "")
//                                        Spacer()
//                                    }.foregroundColor(Color(.label))
//                                }
//                            } else if moreMenu.id=="read" {
//                                Button {
//                                    showMoreOptions.toggle()
//                                    if let chatSelected = chatSelected {
//                                        observed.readDeleteChatNotification(chat: chatSelected, apiRequest: ApiRequest(apiURL: moreMenu.apiURL, method: moreMenu.apiMethod))
//                                    }
//                                } label: {
//                                    HStack {
//                                        ImageDownloader(moreMenu.icon, renderMode: .template)
//                                            .viewIconModifier(imageSize: 22, iconSize: 32, imageColor: Color(.label), iconColor: Color(.systemGray5))
//                                        Text(moreMenu.label ?? "")
//                                        Spacer()
//                                    }.foregroundColor(Color(.label))
//                                }
//                            } else if moreMenu.id=="mute" {
//                                Button {
//                                    if chatSelected?.mute ?? false { // Unmute
//                                        if let muteDialog = moreMenu.unMuteDialog {
//                                            observed.muteChatNotifications(apiRequest: ApiRequest(apiURL: muteDialog.apiUrl, method: muteDialog.apiMethod), chat: chatSelected!)
//                                        }
//                                    } else { // Mute
//                                        if let dialog = moreMenu.muteDialog {
//                                            muteDialog = dialog
//                                        }
//                                    }
//                                    showMoreOptions.toggle()
//                                } label: {
//                                    HStack {
//                                        ImageDownloader(moreMenu.icon, renderMode: .template)
//                                            .viewIconModifier(imageSize: 18, iconSize: 32, imageColor: Color(.label), iconColor: Color(.systemGray5))
//                                        Text(moreMenu.label ?? "")
//                                        Spacer()
//                                    }.foregroundColor(Color(.label))
//                                }
//                            } else if moreMenu.id=="report" {
//                                Button {
//                                    if let dialog = chatSelected?.chat.chatType == "group" ? moreMenu.reportGroupDialog : moreMenu.reportUserDialog {
//                                        reportBlockDialog = dialog
//                                    }
//                                    showMoreOptions.toggle()
//                                } label: {
//                                    HStack {
//                                        ImageDownloader(moreMenu.icon, renderMode: .template)
//                                            .viewIconModifier(imageSize: 22, iconSize: 32, imageColor: Color(.label), iconColor: Color(.systemGray5))
//                                        Text(moreMenu.label ?? "")
//                                        Spacer()
//                                    }.foregroundColor(Color(.label))
//                                }
//                            } else if moreMenu.id=="delete" {
//                                Button {
//                                    if let dialog = moreMenu.deleteDialog {
//                                        deleteDialog = dialog
//                                    }
//                                    showMoreOptions.toggle()
//                                } label: {
//                                    HStack {
//                                        ImageDownloader(moreMenu.icon)
//                                            .frame(width: 32, height: 32)
//                                        Text(moreMenu.label ?? "")
//                                            .foregroundColor(.red)
//                                        Spacer()
//                                    }.foregroundColor(Color(.label))
//                                }
//                            } else if moreMenu.id=="block" {
//                                Button {
//                                    reportBlockDialog = moreMenu.blockDialog
//                                    showMoreOptions.toggle()
//                                } label: {
//                                    HStack {
//                                        ImageDownloader(moreMenu.icon)
//                                            .frame(width: 32, height: 32)
//                                        Text(moreMenu.label ?? "")
//                                            .foregroundColor(.red)
//                                        Spacer()
//                                    }.foregroundColor(Color(.label))
//                                }
//                            }
//                            if let index = moreMenus.firstIndex(of: moreMenu) {
//                                if index != moreMenus.count-1 && index != moreMenus.count-2 {
//                                    Divider()
//                                }
//                            }
//                        }
//                    }
//                    .accentColor(.black)
//                    .padding()
//                }, cancelContent: {
//                    VStack {
//                        if let moreMenu = moreMenus.filter({ $0.id=="cancel" }) {
//                            if let cancelMenu = moreMenu.first {
//                                Button {
//                                    showMoreOptions.toggle()
//                                } label: {
//                                    HStack {
//                                        Spacer()
//                                        Text(cancelMenu.label ?? "")
//                                            .font(.semiBoldFont(16))
//                                        Spacer()
//                                    }
//                                    .foregroundColor(Color(.label))
//                                    .accentColor(.black)
//                                    .padding()
//                                    .background(Color(.tertiarySystemBackground))
//                                    .frame(height: 53)
//                                }.background(Color(.tertiarySystemBackground)).cornerRadius(10)
//                            }
//                        }
//                    }
//                })
//                .background(BackgroundBlurView())
//                .background { Color.black.opacity(0.25).edgesIgnoringSafeArea(.all) }
//            }
//        }
//    }
//
//    //MARK: RELOAD
//    func reload() {
//        observed.apiResponse = nil
//        observed.pageCount = 1
//        observed.fetchApiData(apiRequest: observed.apiRequest)
//    }
//
//}

//extension ArchivedView {
//    class Observed: ObservableObject {
//
//        var apiResponse: LastChatResponse?
//        var apiRequest: ApiRequest?
//
//        var moreMenus: LastChatMoreMenu?
//
//        var pageCount = 1
//        var limitCount = 15
//
//        var archived = false
//        var archivedResponse: LastChatResponse?
//
//        var activeUserResponse: ActiveFriends?
//
//        var unread = false
//
//        func reportChat(chat: LastChatData, apiRequest: ApiRequest, block: Bool, leave: Bool) {
//            let bodyData: [String:Any] = [
//                "reportType" : chat.chat.chatType=="group" ? 3 : 2,
//                "report" : chat.chat.id,
//                "block" : block,
//                "leave" : leave
//            ]
//            sendRequest(apiRequest.apiURL, method: apiRequest.apiMethod, bodyData: bodyData, model: SuccessMessage.self) { result in
//                switch result {
//                case .success:
//                    print("\(chat.chat.id)")
//                case .failure(let error):
//                    print("Error fetching chat messages: \(error.localizedDescription)")
//                }
//            }
//        }
//
//        func blockChat(chat: LastChatData, apiRequest: ApiRequest) {
//            let bodyData: [String:Any] = [
//                "user" : chat.chat.id
//            ]
//            sendRequest(apiRequest.apiURL, method: apiRequest.apiMethod, bodyData: bodyData, model: SuccessMessage.self) { result in
//                switch result {
//                case .success:
//                    print("\(chat.chat.id)")
//                case .failure(let error):
//                    print("Error fetching chat messages: \(error.localizedDescription)")
//                }
//            }
//        }
//
//        func readDeleteChatNotification(chat: LastChatData, apiRequest: ApiRequest) {
//            let bodyData: [[String:Any]] = [[
//                "chat" : chat.chat.id,
//                "chatType" : chat.chat.chatType ?? "user"
//            ]]
//            sendRequest(apiRequest.apiURL, method: apiRequest.apiMethod, bodyData: bodyData, model: SuccessMessage.self) { result in
//                switch result {
//                case .success:
//                    print("\(chat.chat.id)")
//                case .failure(let error):
//                    print("Error fetching chat messages: \(error.localizedDescription)")
//                }
//            }
//        }
//
//        func muteChatNotifications(apiRequest: ApiRequest, chat: LastChatData, time: Int? = nil) {
//            var bodyData: [String:Any] = [
//                "chat" : [ chat.chat.id ]
//            ]
//            bodyData.updateValue(time ?? 1, forKey: "time")
//            sendRequest(apiRequest.apiURL, method: apiRequest.apiMethod, bodyData: bodyData, model: SuccessMessage.self) { result in
//                switch result {
//                case .success(_):
//                    print("\(chat.chat.id)")
//                case .failure(let error):
//                    print("Error fetching chat messages: \(error.localizedDescription)")
//                }
//            }
//        }
//
//        func pinChat(chat: LastChatData) {
//            let bodyData: [String:Any] = [
//                "chat" : [ chat.id ]
//            ]
//            var url = "/chat/pin"
//            if chat.pin ?? false {
//                url = "/chat/unpin"
//            }
//            sendRequest(url, method: .post, bodyData: bodyData, model: SuccessMessage.self) { result in
//                switch result {
//                case .success:
//                    if let data = self.apiResponse?.menu.chats {
////                        for index in 0..<data.count {
////                            if data[index].id == chat.id  {
////                                self.apiResponse?.menu.chats[index].pin = (chat.pin ?? false) ? false : true
////                                if !(chat.pin ?? false) {
////                                    if let chatData = self.apiResponse?.menu.chats.remove(at: index) {
////                                        self.apiResponse?.menu.chats.insert(chatData, at: 0)
////                                    }
////                                }
////                            }
////                        }
//                    }
//                case .failure(let error):
//                    print("Error fetching chat messages: \(error.localizedDescription)")
//                }
//            }
//        }
//
//        func archiveChat(chatIds: [String]) {
//            let bodyData: [String:Any] = [
//                "chat" : chatIds
//            ]
//            var url = "/chat/archive"
//            if archived {
//                url = "/chat/unarchive"
//            }
//            sendRequest(url, method: .post, bodyData: bodyData, model: SuccessMessage.self) { result in
//                switch result {
//                case .success(let data):
//                    print(data)
//                case .failure(let error):
//                    print("Error fetching chat messages: \(error.localizedDescription)")
//                }
//            }
//        }
//
//        func deleteConversation(chatIds: [ChatIDAndType]) {
//            var bodyData: [[String: Any]] = [[:]]
//            for chatIDAndType in chatIds {
//                bodyData.append(["chat": chatIDAndType.id, "chatType": chatIDAndType.chatType])
//            }
//            bodyData.removeFirst()
//            sendRequest("/chat/delete-conversation", method: .post, bodyData: bodyData, model: SuccessMessage.self) { result in
//                switch result {
//                case .success(_):
//                    print("success")
//                case .failure(let error):
//                    print("Error fetching chat messages: \(error.localizedDescription)")
//                }
//            }
//        }
//
//        func fetchOnlineMembers() {
//            sendRequest("/friend/active", method: .get, model: ActiveFriends.self) { result in
//                switch result {
//                case .success(let data):
//                    self.activeUserResponse = data
//                case .failure(let error):
//                    print("Error fetching chat messages: \(error.localizedDescription)")
//                }
//            }
//        }
//
//        func hasReachedEnd(of lastChatData: LastChatData, array: [LastChatData]) -> Bool {
//            return array.last == lastChatData
//        }
//
//        func fetchChatMenus(chat: LastChatData, apiRequest: ApiRequest) {
//            sendRequest("/chat/more/\(chat.chat.chatType ?? "")/\(chat.chat.id)/\(chat.unread)", method: apiRequest.apiMethod, model: LastChatMoreMenu.self) { result in
//                switch result {
//                case .success(let data):
//                    self.moreMenus = data
//                case .failure(let error):
//                    print("Error fetching chat messages: \(error.localizedDescription)")
//                }
//            }
//        }
//
//        func fetchApiData(apiRequest: ApiRequest?) {
//            if let apiRequest = apiRequest {
//                var url = "\(apiRequest.apiURL)?page=\(pageCount)&limit=\(limitCount)"
//                if archived {
//                    url += "&archive=\(archived)"
//                }
//                sendRequest(url, method: apiRequest.apiMethod, model: LastChatResponse.self) { result in
//                    switch result {
//                    case .success(let data):
//                        if self.apiResponse == nil {
//                            self.apiResponse = data
//                        } else {
//                            self.apiResponse?.menu.chats.append(contentsOf: data.menu.chats)
//                        }
//                        if data.menu.chats.count > 0 {
//                            self.pageCount += 1
//                        }
//                    case .failure(let error):
//                        print("Error fetching chat messages: \(error.localizedDescription)")
//                    }
//                }
//            }
//        }
//
//    }
//}


//extension ChatListView {
//    class ChatListViewObserved: ObservableObject {
//
//        var apiResponse: LastChatResponse?
//
//        var moreMenus: LastChatMoreMenu?
//
//        var pageCount = 1
//        var limitCount = 15
//
//        var archived = false
//        var archivedResponse: LastChatResponse?
//
//        var activeUserResponse: ActiveFriends?
//
//        func muteChatNotifications(chat: LastChatData) {
//            let bodyData: [String:Any] = [
//                "chat" : [ chat.id ]
//            ]
//            var url = "/chat/mute"
//            if chat.mute ?? false {
//                url = "/chat/unmute"
//            }
//            sendRequest(url, method: .post, bodyData: bodyData, model: SuccessMessage.self) { result in
//                switch result {
//                case .success:
//                    if let data = self.apiResponse?.menu.chats {
//                        for index in 0..<data.count {
//                            if data[index].id == chat.id  {
//                                self.apiResponse?.menu.chats[index].mute = (chat.mute ?? false) ? false : true
////                                if !(chat.pin ?? false) {
////                                    if let chatData = self.apiResponse?.data.remove(at: index) {
////                                        self.apiResponse?.data.insert(chatData, at: 0)
////                                    }
////                                }
//                            }
//                        }
//                    }
//                case .failure(let error):
//                    print("Error fetching chat messages: \(error.localizedDescription)")
//                }
//            }
//        }
//
//        func pinChat(chat: LastChatData) {
//            let bodyData: [String:Any] = [
//                "chat" : [ chat.id ]
//            ]
//            var url = "/chat/pin"
//            if chat.pin ?? false {
//                url = "/chat/unpin"
//            }
//            sendRequest(url, method: .post, bodyData: bodyData, model: SuccessMessage.self) { result in
//                switch result {
//                case .success:
//                    if let data = self.apiResponse?.menu.chats {
//                        for index in 0..<data.count {
//                            if data[index].id == chat.id  {
//                                self.apiResponse?.menu.chats[index].pin = (chat.pin ?? false) ? false : true
//                                if !(chat.pin ?? false) {
//                                    if let chatData = self.apiResponse?.menu.chats.remove(at: index) {
//                                        self.apiResponse?.menu.chats.insert(chatData, at: 0)
//                                    }
//                                }
//                            }
//                        }
//                    }
//                case .failure(let error):
//                    print("Error fetching chat messages: \(error.localizedDescription)")
//                }
//            }
//        }
//
//        func archiveChat(chatIds: [String]) {
//            let bodyData: [String:Any] = [
//                "chat" : chatIds
//            ]
//            var url = "/chat/archive"
//            if archived {
//                url = "/chat/unarchive"
//            }
//            sendRequest(url, method: .post, bodyData: bodyData, model: SuccessMessage.self) { result in
//                switch result {
//                case .success(let data):
//                    print(data)
//                case .failure(let error):
//                    print("Error fetching chat messages: \(error.localizedDescription)")
//                }
//            }
//        }
//
//        func deleteConversation(chatIds: [ChatIDAndType]) {
//            var bodyData: [[String: Any]] = [[:]]
//            for chatIDAndType in chatIds {
//                bodyData.append(["chat": chatIDAndType.id, "chatType": chatIDAndType.chatType])
//            }
//            bodyData.removeFirst()
//            sendRequest("/chat/delete-conversation", method: .post, bodyData: bodyData, model: SuccessMessage.self) { result in
//                switch result {
//                case .success(_):
//                    print("success")
//                case .failure(let error):
//                    print("Error fetching chat messages: \(error.localizedDescription)")
//                }
//            }
//        }
//
//        func fetchOnlineMembers() {
//            sendRequest("/friend/active", method: .get, model: ActiveFriends.self) { result in
//                switch result {
//                case .success(let data):
//                    self.activeUserResponse = data
//                case .failure(let error):
//                    print("Error fetching chat messages: \(error.localizedDescription)")
//                }
//            }
//        }
//
//        func hasReachedEnd(of lastChatData: LastChatData, array: [LastChatData]) -> Bool {
//            return array.last == lastChatData
//        }
//
//        func fetchChatMenus(chat: LastChatData, apiRequest: ApiRequest) {
//            sendRequest("/chat/more/\(chat.chat.chatType ?? "")/\(chat.chat.id)", method: apiRequest.apiMethod, model: LastChatMoreMenu.self) { result in
//                switch result {
//                case .success(let data):
//                    self.moreMenus = data
//                case .failure(let error):
//                    print("Error fetching chat messages: \(error.localizedDescription)")
//                }
//            }
//        }
//
//        func fetchApiData(apiRequest: ApiRequest) {
//            var url = "\(apiRequest.apiURL)?page=\(pageCount)&limit=\(limitCount)"
//            if archived {
//                url += "&archive=\(archived)"
//            }
//            sendRequest(url, method: apiRequest.apiMethod, model: LastChatResponse.self) { result in
//                switch result {
//                case .success(let data):
//                    if self.apiResponse == nil {
//                        self.apiResponse = data
//                    } else {
//                        self.apiResponse?.menu.chats.append(contentsOf: data.menu.chats)
//                    }
//                    if data.menu.chats.count > 0 {
//                        self.pageCount += 1
//                    }
//                case .failure(let error):
//                    print("Error fetching chat messages: \(error.localizedDescription)")
//                }
//            }
//        }
//
//    }
//}
